import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_reviewer/src/shared/models/ai_model.dart';
import 'package:my_reviewer/src/shared/models/artifact_download.dart';
import 'package:my_reviewer/src/shared/models/storage_root.dart';
import 'package:my_reviewer/src/shared/models/task.dart';
import 'package:my_reviewer/src/shared/services/ai_models/ai_model_provisioner.dart';
import 'package:my_reviewer/src/shared/services/ai_models/artifact_integrity_verifier.dart';
import 'package:my_reviewer/src/shared/services/ai_models/i_ai_model_integrator.dart';
import 'package:my_reviewer/src/shared/services/ai_models/i_artifact_downloader.dart';
import 'package:my_reviewer/src/shared/services/storage/i_file_storage_service.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempRoot;
  late _FakeFileStorageService storageService;
  late _FakeArtifactDownloader downloader;
  late _FakeAiModelIntegrator integrator;
  late AiModelProvisioner provisioner;

  String sha256Of(List<int> bytes) => sha256.convert(bytes).toString();

  AiModelSpec createSpec({
    String id = 'qwen-ocr',
    List<AiModelArtifact>? artifacts,
  }) {
    return AiModelSpec(
      id: id,
      displayName: 'Qwen OCR',
      subtitle: 'Offline OCR model',
      capability: AiModelCapability.ocrTranscription,
      storageRoot: StorageRoot.support,
      artifacts:
          artifacts ??
          [
            AiModelArtifact(
              id: 'weights',
              role: AiModelFileRole.model,
              fileName: 'model.gguf',
              downloadUrl: 'https://example.com/model.gguf',
              expectedBytes: 100,
              sha256: sha256Of(List.filled(100, 1)),
            ),
            AiModelArtifact(
              id: 'mmproj',
              role: AiModelFileRole.mmproj,
              fileName: 'mmproj.gguf',
              downloadUrl: 'https://example.com/mmproj.gguf',
              expectedBytes: 100,
              sha256: sha256Of(List.filled(100, 2)),
            ),
          ],
    );
  }

  String modelDirPath(AiModelSpec spec) =>
      p.joinAll([tempRoot.path, ...spec.relativeSubDirectories]);

  Future<File> writeModelFile(
    AiModelSpec spec,
    String fileName,
    List<int> bytes,
  ) async {
    final dir = Directory(modelDirPath(spec));
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('provisioner_test_');
    storageService = _FakeFileStorageService(tempRoot.path);
    downloader = _FakeArtifactDownloader();
    integrator = _FakeAiModelIntegrator();

    provisioner = AiModelProvisioner(
      storageService: storageService,
      integrators: [integrator],
      downloader: downloader,
      verifier: const ArtifactIntegrityVerifier(),
    );
  });

  tearDown(() async {
    if (await tempRoot.exists()) {
      await tempRoot.delete(recursive: true);
    }
  });

  group('inspect', () {
    test(
      'returns notInstalled when directory and downloader records are absent',
      () async {
        final spec = createSpec();
        final status = await provisioner.inspect(spec);

        expect(status.phase, AiModelInstallPhase.notInstalled);
        expect(status.downloadedBytes, 0);
        expect(status.errorMessage, isNull);
      },
    );

    test(
      'returns failed when lastError is provided even if notInstalled',
      () async {
        final spec = createSpec();
        final status = await provisioner.inspect(
          spec,
          lastError: 'Network error',
        );

        expect(status.phase, AiModelInstallPhase.failed);
        expect(status.errorMessage, 'Network error');
      },
    );

    test('returns notInstalled when directory exists but is empty and has no records', () async {
      final spec = createSpec();
      await Directory(modelDirPath(spec)).create(recursive: true);

      final status = await provisioner.inspect(spec);

      expect(status.phase, AiModelInstallPhase.notInstalled);
      expect(status.downloadedBytes, 0);
    });

    test('returns partialDownload and estimates bytes from downloader progress when file not yet flushed', () async {
      final spec = createSpec();
      downloader.records['qwen-ocr__weights'] = const ArtifactDownloadRecord(
        taskId: 'qwen-ocr__weights',
        isComplete: false,
        progress: 0.45,
      );

      final status = await provisioner.inspect(spec);

      expect(status.phase, AiModelInstallPhase.partialDownload);
      expect(status.downloadedBytes, 45);
    });

    test('returns partialDownload when one artifact is complete and second is missing', () async {
      final spec = createSpec();
      await writeModelFile(spec, 'model.gguf', List.filled(100, 1));

      final status = await provisioner.inspect(spec);

      expect(status.phase, AiModelInstallPhase.partialDownload);
      expect(status.downloadedBytes, 100);
    });

    test('returns partialDownload when file exists on disk but is smaller than expectedBytes and record is incomplete', () async {
      final spec = createSpec();
      await writeModelFile(spec, 'model.gguf', List.filled(60, 1));
      await writeModelFile(spec, 'mmproj.gguf', List.filled(100, 2));

      final status = await provisioner.inspect(spec);

      expect(status.phase, AiModelInstallPhase.partialDownload);
      expect(status.downloadedBytes, 160);
    });

    test('cleans up stale incomplete DB record when file on disk already satisfies expectedBytes', () async {
      final spec = createSpec();
      await writeModelFile(spec, 'model.gguf', List.filled(100, 1));
      await writeModelFile(spec, 'mmproj.gguf', List.filled(100, 2));
      downloader.records['qwen-ocr__weights'] = const ArtifactDownloadRecord(
        taskId: 'qwen-ocr__weights',
        isComplete: false,
        progress: 0.9,
      );

      final status = await provisioner.inspect(spec);

      expect(status.phase, AiModelInstallPhase.downloadedUnverified);
      expect(downloader.deletedTaskIds, contains('qwen-ocr__weights'));
    });

    test('treats non-empty file as complete when record.isComplete is true even if expectedBytes is 0', () async {
      final spec = createSpec(
        artifacts: [
          const AiModelArtifact(
            id: 'weights',
            role: AiModelFileRole.model,
            fileName: 'model.gguf',
            downloadUrl: 'https://example.com/model.gguf',
            expectedBytes: 0,
          ),
        ],
      );
      await writeModelFile(spec, 'model.gguf', [1, 2, 3]);
      downloader.records['qwen-ocr__weights'] = const ArtifactDownloadRecord(
        taskId: 'qwen-ocr__weights',
        isComplete: true,
        progress: 1.0,
      );

      final status = await provisioner.inspect(spec);

      expect(status.phase, AiModelInstallPhase.downloadedUnverified);
      expect(status.downloadedBytes, 3);
    });

    test('returns downloadedUnverified when all files exist but .verified marker is missing', () async {
      final spec = createSpec();
      await writeModelFile(spec, 'model.gguf', List.filled(100, 1));
      await writeModelFile(spec, 'mmproj.gguf', List.filled(100, 2));

      final status = await provisioner.inspect(spec);

      expect(status.phase, AiModelInstallPhase.downloadedUnverified);
      expect(status.downloadedBytes, 200);
    });

    test('returns verifiedUnintegrated when .verified exists but .integrated is missing', () async {
      final spec = createSpec();
      await writeModelFile(spec, 'model.gguf', List.filled(100, 1));
      await writeModelFile(spec, 'mmproj.gguf', List.filled(100, 2));
      await writeModelFile(spec, '.verified', utf8.encode('{}'));

      final status = await provisioner.inspect(spec);

      expect(status.phase, AiModelInstallPhase.verifiedUnintegrated);
      expect(status.downloadedBytes, 200);
    });

    test(
      'returns ready when all files and both sentinel markers exist',
      () async {
        final spec = createSpec();
        await writeModelFile(spec, 'model.gguf', List.filled(100, 1));
        await writeModelFile(spec, 'mmproj.gguf', List.filled(100, 2));
        await writeModelFile(spec, '.verified', utf8.encode('{}'));
        await writeModelFile(spec, '.integrated', utf8.encode('{}'));

        final status = await provisioner.inspect(spec);

        expect(status.phase, AiModelInstallPhase.ready);
        expect(status.downloadedBytes, 200);
      },
    );
  });

  group('provision', () {
    test('executes full 3-stage pipeline, aggregates multi-file progress, writes markers, and dismisses notifications', () async {
      final spec = createSpec();
      final phases = <ProvisionPhase>[];
      final progressEvents = <TaskProgress>[];

      downloader.onDownload = (req) async {
        req.onProgress(0.5);
        req.onProgress(1.0);
        final fillByte = req.fileName == 'model.gguf' ? 1 : 2;
        await File(p.join(req.directoryPath, req.fileName))
            .writeAsBytes(List.filled(100, fillByte), flush: true);
        return const ArtifactDownloadResult(
          isComplete: true,
          isTransientFailure: false,
        );
      };

      await provisioner.provision(
        spec,
        authToken: 'hf_secret',
        requiresWiFi: true,
        onPhaseChanged: phases.add,
        onProgress: progressEvents.add,
      );

      expect(phases, [
        ProvisionPhase.downloading,
        ProvisionPhase.verifying,
        ProvisionPhase.integrating,
      ]);

      expect(downloader.requests, hasLength(2));
      expect(downloader.requests.first.authToken, 'hf_secret');
      expect(downloader.requests.first.requiresWiFi, isTrue);

      final processingSteps = progressEvents
          .where((p) => p.stage == TaskStage.processing && p.total == 100)
          .map((p) => p.current)
          .toList();
      expect(processingSteps, [25, 50, 75, 100]);

      final indeterminateEvents = progressEvents
          .where((p) => p.stage == TaskStage.processing && p.total == 0)
          .toList();
      expect(indeterminateEvents, hasLength(2));

      final dirPath = modelDirPath(spec);
      expect(await File(p.join(dirPath, '.verified')).exists(), isTrue);
      expect(await File(p.join(dirPath, '.integrated')).exists(), isTrue);
      expect(integrator.integratedSpecs, [spec.id]);
      expect(integrator.lastPaths, {
        AiModelFileRole.model: p.join(dirPath, 'model.gguf'),
        AiModelFileRole.mmproj: p.join(dirPath, 'mmproj.gguf'),
      });

      final finalStatus = await provisioner.inspect(spec);
      expect(finalStatus.phase, AiModelInstallPhase.ready);
    });

    test('skips downloading already-complete files and invalidates stale markers only when re-downloading missing artifacts', () async {
      final spec = createSpec();
      await writeModelFile(spec, 'model.gguf', List.filled(100, 1));
      await writeModelFile(spec, '.verified', utf8.encode('{}'));
      await writeModelFile(spec, '.integrated', utf8.encode('{}'));

      downloader.onDownload = (req) async {
        req.onProgress(1.0);
        await File(p.join(req.directoryPath, req.fileName))
            .writeAsBytes(List.filled(100, 2), flush: true);
        return const ArtifactDownloadResult(
          isComplete: true,
          isTransientFailure: false,
        );
      };

      await provisioner.provision(spec);

      expect(downloader.requests.map((r) => r.fileName), ['mmproj.gguf']);
      expect(integrator.integratedSpecs, [spec.id]);
    });

    test(
      'deletes partial/corrupted file on disk before starting a fresh download',
      () async {
        final spec = createSpec(
          artifacts: [
            AiModelArtifact(
              id: 'weights',
              role: AiModelFileRole.model,
              fileName: 'model.gguf',
              downloadUrl: 'https://example.com/model.gguf',
              expectedBytes: 100,
              sha256: sha256Of(List.filled(100, 1)),
            ),
          ],
        );
        final partialFile = await writeModelFile(
          spec,
          'model.gguf',
          List.filled(20, 9),
        );
        var existedWhenDownloadStarted = true;

        downloader.onDownload = (req) async {
          existedWhenDownloadStarted = await partialFile.exists();
          await partialFile.writeAsBytes(List.filled(100, 1), flush: true);
          return const ArtifactDownloadResult(
            isComplete: true,
            isTransientFailure: false,
          );
        };

        await provisioner.provision(spec);

        expect(existedWhenDownloadStarted, isFalse);
      },
    );

    test(
      'retries transient network failures up to 3 attempts and succeeds',
      () async {
        final spec = createSpec(
          artifacts: [
            AiModelArtifact(
              id: 'weights',
              role: AiModelFileRole.model,
              fileName: 'model.gguf',
              downloadUrl: 'https://example.com/model.gguf',
              expectedBytes: 100,
              sha256: sha256Of(List.filled(100, 1)),
            ),
          ],
        );

        var attempts = 0;
        downloader.onDownload = (req) async {
          attempts++;
          if (attempts < 3) {
            return const ArtifactDownloadResult(
              isComplete: false,
              isTransientFailure: true,
              errorDescription: 'Unexpected end of stream',
            );
          }
          await File(p.join(req.directoryPath, req.fileName))
              .writeAsBytes(List.filled(100, 1), flush: true);
          return const ArtifactDownloadResult(
            isComplete: true,
            isTransientFailure: false,
          );
        };

        await provisioner.provision(spec);

        expect(attempts, 3);
        expect(
          (await provisioner.inspect(spec)).phase,
          AiModelInstallPhase.ready,
        );
      },
    );

    test('does not retry non-transient download errors and still dismisses notifications', () async {
      final spec = createSpec();
      var attempts = 0;

      downloader.onDownload = (_) async {
        attempts++;
        return const ArtifactDownloadResult(
          isComplete: false,
          isTransientFailure: false,
          errorDescription: 'HTTP 401 Unauthorized',
        );
      };

      await expectLater(
        () => provisioner.provision(spec),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('HTTP 401 Unauthorized'),
          ),
        ),
      );

      expect(attempts, 1);
    });

    test('on SHA-256 mismatch deletes corrupted file and downloader record, then throws StateError', () async {
      final spec = createSpec(
        artifacts: [
          AiModelArtifact(
            id: 'weights',
            role: AiModelFileRole.model,
            fileName: 'model.gguf',
            downloadUrl: 'https://example.com/model.gguf',
            expectedBytes: 100,
            sha256: sha256Of(List.filled(100, 1)),
          ),
        ],
      );

      downloader.onDownload = (req) async {
        await File(p.join(req.directoryPath, req.fileName))
            .writeAsBytes(List.filled(100, 9), flush: true);
        return const ArtifactDownloadResult(
          isComplete: true,
          isTransientFailure: false,
        );
      };

      await expectLater(
        () => provisioner.provision(spec),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Checksum mismatch'),
          ),
        ),
      );

      final file = File(p.join(modelDirPath(spec), 'model.gguf'));
      expect(await file.exists(), isFalse);
      expect(downloader.deletedTaskIds, contains('qwen-ocr__weights'));
      expect(
        (await provisioner.inspect(spec)).phase,
        AiModelInstallPhase.notInstalled,
      );
    });

    test('skips verification and integration work when .verified and .integrated markers already exist', () async {
      final spec = createSpec();
      await writeModelFile(spec, 'model.gguf', List.filled(100, 1));
      await writeModelFile(spec, 'mmproj.gguf', List.filled(100, 2));
      await writeModelFile(spec, '.verified', utf8.encode('{}'));
      await writeModelFile(spec, '.integrated', utf8.encode('{}'));

      await provisioner.provision(spec);

      expect(downloader.requests, isEmpty);
      expect(integrator.integratedSpecs, isEmpty);
    });

    test('throws StateError when no integrator supports spec and leaves status at verifiedUnintegrated', () async {
      final spec = createSpec();
      integrator.supported = false;

      downloader.onDownload = (req) async {
        final fillByte = req.fileName == 'model.gguf' ? 1 : 2;
        await File(p.join(req.directoryPath, req.fileName))
            .writeAsBytes(List.filled(100, fillByte), flush: true);
        return const ArtifactDownloadResult(
          isComplete: true,
          isTransientFailure: false,
        );
      };

      await expectLater(
        () => provisioner.provision(spec),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('No model integrator registered'),
          ),
        ),
      );

      final status = await provisioner.inspect(spec);
      expect(status.phase, AiModelInstallPhase.verifiedUnintegrated);
    });
  });

  group('deleteModelFiles', () {
    test('cancels downloader group, unintegrates matching integrators, and deletes model directory', () async {
      final spec = createSpec();
      await writeModelFile(spec, 'model.gguf', List.filled(100, 1));
      await writeModelFile(spec, '.verified', utf8.encode('{}'));
      await writeModelFile(spec, '.integrated', utf8.encode('{}'));

      await provisioner.deleteModelFiles(spec);

      expect(downloader.canceledGroups, ['ai_model_qwen-ocr']);
      expect(integrator.unintegratedSpecs, [spec.id]);
      expect(await Directory(modelDirPath(spec)).exists(), isFalse);
      expect(
        (await provisioner.inspect(spec)).phase,
        AiModelInstallPhase.notInstalled,
      );
    });
  });
}

// =============================================================================
// Fakes
// =============================================================================

class _FakeFileStorageService implements IFileStorageService {
  _FakeFileStorageService(this.rootPath);

  final String rootPath;

  @override
  String resolveAbsolutePath(
    String relativePath, {
    StorageRoot root = StorageRoot.support,
  }) => p.join(rootPath, relativePath);

  @override
  Future<Directory> ensureDirectory(
    List<String> subDirectories, {
    StorageRoot root = StorageRoot.support,
  }) async {
    final dir = Directory(p.joinAll([rootPath, ...subDirectories]));
    return dir.create(recursive: true);
  }

  @override
  Future<void> delete(String path, {bool recursive = false}) async {
    final type = await FileSystemEntity.type(path);
    if (type == FileSystemEntityType.notFound) return;
    if (type == FileSystemEntityType.directory) {
      await Directory(path).delete(recursive: recursive);
    } else {
      await File(path).delete();
    }
  }

  @override
  void deleteQuietly(String path, {bool recursive = true}) {
    try {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    } catch (_) {}
  }

  @override
  void deleteQuietlyBatch(Iterable<String> paths) {
    for (final path in paths) {
      deleteQuietly(path);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DownloadRequest {
  _DownloadRequest({
    required this.group,
    required this.taskId,
    required this.url,
    required this.fileName,
    required this.directoryPath,
    required this.requiresWiFi,
    required this.authToken,
    required this.onProgress,
  });

  final String group;
  final String taskId;
  final String url;
  final String fileName;
  final String directoryPath;
  final bool requiresWiFi;
  final String? authToken;
  final void Function(double fraction) onProgress;
}

class _FakeArtifactDownloader implements IArtifactDownloader {
  final Map<String, ArtifactDownloadRecord> records = {};
  final List<String> deletedTaskIds = [];
  final List<String> canceledGroups = [];
  final List<_DownloadRequest> requests = [];

  Future<ArtifactDownloadResult> Function(_DownloadRequest req)? onDownload;

  @override
  Future<List<ArtifactDownloadRecord>> recordsForGroup(String group) async =>
      records.values.toList();

  @override
  Future<ArtifactDownloadRecord?> recordForTask(String taskId) async =>
      records[taskId];

  @override
  Future<void> deleteRecord(String taskId) async {
    deletedTaskIds.add(taskId);
    records.remove(taskId);
  }

  @override
  Future<void> cancelAndDeleteGroup(String group) async {
    canceledGroups.add(group);
    records.clear();
  }

  @override
  void configureGroupNotifications({
    required String group,
    required String displayName,
  }) {}

  @override
  Future<ArtifactDownloadResult> downloadOrResume({
    required String group,
    required String taskId,
    required String url,
    required String fileName,
    required String directoryPath,
    required bool requiresWiFi,
    String? authToken,
    required void Function(double fraction) onProgress,
  }) async {
    final req = _DownloadRequest(
      group: group,
      taskId: taskId,
      url: url,
      fileName: fileName,
      directoryPath: directoryPath,
      requiresWiFi: requiresWiFi,
      authToken: authToken,
      onProgress: onProgress,
    );
    requests.add(req);

    return onDownload?.call(req) ??
        const ArtifactDownloadResult(
          isComplete: true,
          isTransientFailure: false,
        );
  }
}

class _FakeAiModelIntegrator implements IAiModelIntegrator {
  bool supported = true;
  final List<String> integratedSpecs = [];
  final List<String> unintegratedSpecs = [];
  Map<AiModelFileRole, String>? lastPaths;

  @override
  bool supports(AiModelSpec spec) => supported;

  @override
  Future<void> integrate(
    AiModelSpec spec,
    Map<AiModelFileRole, String> resolvedPaths,
  ) async {
    integratedSpecs.add(spec.id);
    lastPaths = resolvedPaths;
  }

  @override
  Future<void> unintegrate(AiModelSpec spec) async {
    unintegratedSpecs.add(spec.id);
  }
}
