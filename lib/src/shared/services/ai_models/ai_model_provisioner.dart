import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:crypto/crypto.dart';
import 'package:my_reviewer/src/shared/models/ai_model.dart';
import 'package:my_reviewer/src/shared/models/task.dart' hide TaskStatus;
import 'package:my_reviewer/src/shared/services/storage/i_file_storage_service.dart';
import 'package:path/path.dart' as p;

import 'i_ai_model_integrator.dart';

enum ProvisionPhase { downloading, verifying, integrating }

class AiModelProvisioner {
  AiModelProvisioner({
    required this._storageService,
    required this._integrators,
  });

  final IFileStorageService _storageService;
  final List<IAiModelIntegrator> _integrators;

  static const String _verifiedMarkerFile = '.verified';
  static const String _integratedMarkerFile = '.integrated';

  /// Inspects disk + background_downloader task database to detect:
  /// - `notInstalled`
  /// - `partialDownload` (paused/interrupted downloader task or incomplete files)
  /// - `downloadedUnverified` (all files present, SHA-256 marker missing)
  /// - `verifiedUnintegrated` (SHA-256 verified, EdgeAI integration interrupted)
  /// - `ready`
  Future<AiModelStatus> inspect(AiModelSpec spec, {String? lastError}) async {
    final dirPath = _resolveDirPath(spec);
    final dir = Directory(dirPath);

    final downloaderRecords = await FileDownloader().database.allRecords(
      group: _groupFor(spec),
    );
    final activeOrPausedRecords = downloaderRecords
        .where((r) => r.status != TaskStatus.complete)
        .toList();

    if (!await dir.exists() && activeOrPausedRecords.isEmpty) {
      return AiModelStatus(
        spec: spec,
        phase: lastError != null
            ? AiModelInstallPhase.failed
            : AiModelInstallPhase.notInstalled,
        errorMessage: lastError,
      );
    }

    int downloadedBytes = 0;
    bool hasAnyArtifactOrTask = activeOrPausedRecords.isNotEmpty;
    bool allFilesPresent = true;

    for (final artifact in spec.artifacts) {
      final finalFile = File(p.join(dirPath, artifact.fileName));
      final matchingRecord = downloaderRecords
          .where((r) => r.taskId == _taskIdFor(spec, artifact))
          .firstOrNull;

      if (await finalFile.exists() &&
          (matchingRecord == null ||
              matchingRecord.status == TaskStatus.complete)) {
        hasAnyArtifactOrTask = true;
        final len = await finalFile.length();

        downloadedBytes += len;

        if (artifact.expectedBytes > 0 && len < artifact.expectedBytes) {
          allFilesPresent = false;
        }
      } else {
        allFilesPresent = false;

        if (matchingRecord != null && artifact.expectedBytes > 0) {
          downloadedBytes +=
              (matchingRecord.progress.clamp(0.0, 1.0) * artifact.expectedBytes)
                  .round();
        }
      }
    }

    if (!hasAnyArtifactOrTask) {
      return AiModelStatus(
        spec: spec,
        phase: lastError != null
            ? AiModelInstallPhase.failed
            : AiModelInstallPhase.notInstalled,
        errorMessage: lastError,
      );
    }

    if (!allFilesPresent || activeOrPausedRecords.isNotEmpty) {
      return AiModelStatus(
        spec: spec,
        phase: lastError != null
            ? AiModelInstallPhase.failed
            : AiModelInstallPhase.partialDownload,
        downloadedBytes: downloadedBytes,
        errorMessage: lastError,
      );
    }

    final verifiedMarker = File(p.join(dirPath, _verifiedMarkerFile));
    if (!await verifiedMarker.exists()) {
      return AiModelStatus(
        spec: spec,
        phase: lastError != null
            ? AiModelInstallPhase.failed
            : AiModelInstallPhase.downloadedUnverified,
        downloadedBytes: downloadedBytes,
        errorMessage: lastError,
      );
    }

    final integratedMarker = File(p.join(dirPath, _integratedMarkerFile));
    if (!await integratedMarker.exists()) {
      return AiModelStatus(
        spec: spec,
        phase: lastError != null
            ? AiModelInstallPhase.failed
            : AiModelInstallPhase.verifiedUnintegrated,
        downloadedBytes: downloadedBytes,
        errorMessage: lastError,
      );
    }

    return AiModelStatus(
      spec: spec,
      phase: AiModelInstallPhase.ready,
      downloadedBytes: downloadedBytes,
    );
  }

  /// Runs the 3-step pipeline:
  /// 1. Download (resumes paused/interrupted tasks via `background_downloader`)
  /// 2. Verify SHA-256 digests
  /// 3. Integrate into `flutter_edge_ai`
  Future<void> provision(
    AiModelSpec spec, {
    String? authToken,
    bool requiresWiFi = false,
    void Function(ProvisionPhase phase)? onPhaseChanged,
    MyReviewerTaskProgressCallback? onProgress,
  }) async {
    onProgress?.call(const TaskProgress.preparing());

    final counter = TaskProgressCounter(total: 100, onProgress: onProgress);

    final dir = await _storageService.ensureDirectory(
      spec.relativeSubDirectories,
      root: spec.storageRoot,
    );
    final dirPath = dir.path;

    // Step 1: Download files (0 -> 80)
    onPhaseChanged?.call(ProvisionPhase.downloading);
    await _downloadArtifacts(
      spec,
      dirPath: dirPath,
      authToken: authToken,
      requiresWiFi: requiresWiFi,
      counter: counter,
    );

    // Step 2: Verify SHA-256 checksums (80 -> 90)
    onPhaseChanged?.call(ProvisionPhase.verifying);
    await _verifyArtifacts(spec, dirPath: dirPath, counter: counter);

    // Step 3: Integrate into runtime (90 -> 100)
    onPhaseChanged?.call(ProvisionPhase.integrating);
    await _integrateArtifacts(spec, dirPath: dirPath, counter: counter);

    onProgress?.call(const TaskProgress.finishing());
  }

  Future<void> deleteModelFiles(AiModelSpec spec) async {
    final group = _groupFor(spec);
    final records = await FileDownloader().database.allRecords(group: group);
    if (records.isNotEmpty) {
      final taskIds = records.map((r) => r.taskId).toList();
      await FileDownloader().cancelTasksWithIds(taskIds);
      await FileDownloader().database.deleteRecordsWithIds(taskIds);
    }

    for (final integrator in _integrators) {
      if (integrator.supports(spec)) {
        await integrator.unintegrate(spec);
      }
    }

    await _storageService.delete(_resolveDirPath(spec), recursive: true);
  }

  Future<void> _downloadArtifacts(
    AiModelSpec spec, {
    required String dirPath,
    String? authToken,
    required bool requiresWiFi,
    required TaskProgressCounter counter,
  }) async {
    final totalBytes = spec.totalBytes;
    int completedBytesBeforeCurrent = 0;

    for (final artifact in spec.artifacts) {
      final finalPath = p.join(dirPath, artifact.fileName);
      final finalFile = File(finalPath);
      final taskId = _taskIdFor(spec, artifact);
      final existingRecord = await FileDownloader().database.recordForId(
        taskId,
      );

      if (await finalFile.exists() &&
          (existingRecord == null ||
              existingRecord.status == TaskStatus.complete)) {
        final len = await finalFile.length();
        if (artifact.expectedBytes <= 0 || len == artifact.expectedBytes) {
          completedBytesBeforeCurrent += len;
          continue;
        }
        await finalFile.delete();
      }

      // Any new/resumed download invalidates prior verification/integration markers.
      _storageService.deleteQuietlyBatch([
        p.join(dirPath, _verifiedMarkerFile),
        p.join(dirPath, _integratedMarkerFile),
      ]);

      final freshTask = DownloadTask(
        taskId: taskId,
        group: _groupFor(spec),
        url: artifact.downloadUrl,
        filename: artifact.fileName,
        directory: dirPath,
        baseDirectory: BaseDirectory.root,
        requiresWiFi: requiresWiFi,
        allowPause: true,
        updates: Updates.statusAndProgress,
        headers: {
          if (authToken != null && authToken.isNotEmpty)
            HttpHeaders.authorizationHeader: 'Bearer $authToken',
        },
      );

      final existingTask = existingRecord?.task;
      final canResume =
          existingRecord != null &&
          (existingRecord.status == TaskStatus.paused ||
              existingRecord.status == TaskStatus.failed) &&
          existingTask is DownloadTask &&
          await FileDownloader().taskCanResume(existingTask);

      final finalUpdate = await _enqueueOrResumeAndAwait(
        freshTask: freshTask,
        resumableTask: canResume ? existingTask : null,
        onProgress: (fraction) => _reportDownloadProgress(
          fraction: fraction,
          artifactBytes: artifact.expectedBytes,
          completedBefore: completedBytesBeforeCurrent,
          totalBytes: totalBytes,
          counter: counter,
        ),
      );

      if (finalUpdate.status != TaskStatus.complete) {
        throw StateError(
          finalUpdate.exception?.description ??
              'Download failed for ${artifact.fileName} '
                  '(${finalUpdate.status.name})',
        );
      }

      completedBytesBeforeCurrent += await File(finalPath).length();
    }
  }

  /// Enqueues [freshTask]—or resumes [resumableTask] via `FileDownloader().resume(task)`—
  /// and listens to `FileDownloader().updates` until that `taskId` reaches a final
  /// `TaskStatus` (`complete`, `failed`, `canceled`, `notFound`).
  Future<TaskStatusUpdate> _enqueueOrResumeAndAwait({
    required DownloadTask freshTask,
    DownloadTask? resumableTask,
    required void Function(double fraction) onProgress,
  }) async {
    final completer = Completer<TaskStatusUpdate>();
    final targetTaskId = freshTask.taskId;

    late final StreamSubscription<TaskUpdate> sub;
    sub = FileDownloader().updates.listen(
      (update) {
        if (update.task.taskId != targetTaskId) {
          return;
        }

        switch (update) {
          case TaskProgressUpdate(:final progress):
            onProgress(progress);
          case TaskStatusUpdate(:final status):
            if (status.isFinalState && !completer.isCompleted) {
              completer.complete(update);
            }
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
    );

    try {
      bool started = false;

      if (resumableTask != null) {
        started = await FileDownloader().resume(resumableTask);
      }

      if (!started) {
        // Clean up any stale non-resumable DB record before enqueueing fresh.
        await FileDownloader().database.deleteRecordWithId(targetTaskId);

        started = await FileDownloader().enqueue(freshTask);
      }

      if (!started) {
        throw StateError('Failed to enqueue download task $targetTaskId');
      }

      return await completer.future;
    } finally {
      await sub.cancel();
    }
  }

  void _reportDownloadProgress({
    required double fraction,
    required int artifactBytes,
    required int completedBefore,
    required int totalBytes,
    required TaskProgressCounter counter,
  }) {
    if (totalBytes <= 0 || fraction < 0) {
      return;
    }

    final currentTotal =
        completedBefore + (fraction.clamp(0.0, 1.0) * artifactBytes).round();
    // 0% -> 80% of overall TaskDialog progress bar allocated to download.
    final step = ((currentTotal / totalBytes) * 80).round().clamp(1, 80);

    counter.set(step);
  }

  Future<void> _verifyArtifacts(
    AiModelSpec spec, {
    required String dirPath,
    required TaskProgressCounter counter,
  }) async {
    final verifiedMarker = File(p.join(dirPath, _verifiedMarkerFile));

    if (await verifiedMarker.exists()) {
      counter.set(90);
      return;
    }

    for (var i = 0; i < spec.artifacts.length; i++) {
      final artifact = spec.artifacts[i];
      final file = File(p.join(dirPath, artifact.fileName));

      if (!await file.exists()) {
        throw FileSystemException('Missing downloaded artifact', file.path);
      }

      final expectedSha = artifact.sha256?.trim().toLowerCase();
  
      if (expectedSha != null && expectedSha.isNotEmpty) {
        final digest = await sha256.bind(file.openRead()).first;
  
        if (digest.toString().toLowerCase() != expectedSha) {
          _storageService.deleteQuietly(file.path);
          await FileDownloader().database.deleteRecordWithId(
            _taskIdFor(spec, artifact),
          );
  
          throw StateError(
            'Checksum mismatch for ${artifact.fileName} '
            '(expected $expectedSha, got $digest)',
          );
        }
      }

      final step = 80 + (((i + 1) / spec.artifacts.length) * 10).round();
      counter.set(step);
    }

    await verifiedMarker.writeAsString(
      jsonEncode({'verifiedAt': DateTime.now().toIso8601String()}),
      flush: true,
    );
  }

  Future<void> _integrateArtifacts(
    AiModelSpec spec, {
    required String dirPath,
    required TaskProgressCounter counter,
  }) async {
    final integratedMarker = File(p.join(dirPath, _integratedMarkerFile));

    if (await integratedMarker.exists()) {
      counter.set(100);
  
      return;
    }

    counter.set(92);

    final resolvedPaths = <AiModelFileRole, String>{
      for (final artifact in spec.artifacts)
        artifact.role: p.join(dirPath, artifact.fileName),
    };

    final integrator = _integrators.firstWhere(
      (candidate) => candidate.supports(spec),
      orElse: () =>
          throw StateError('No model integrator registered for ${spec.id}'),
    );

    await integrator.integrate(spec, resolvedPaths);

    await integratedMarker.writeAsString(
      jsonEncode({'integratedAt': DateTime.now().toIso8601String()}),
      flush: true,
    );

    counter.set(100);
  }

  String _groupFor(AiModelSpec spec) => 'ai_model_${spec.id}';

  String _taskIdFor(AiModelSpec spec, AiModelArtifact artifact) =>
      '${spec.id}__${artifact.id}';

  String _resolveDirPath(AiModelSpec spec) =>
      _storageService.resolveAbsolutePath(
        p.joinAll(spec.relativeSubDirectories),
        root: spec.storageRoot,
      );
}
