import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/models/ai_model.dart';
import 'package:my_reviewer/src/shared/models/artifact_download.dart';
import 'package:my_reviewer/src/shared/models/task.dart';
import 'package:my_reviewer/src/shared/services/ai_models/background_artifact_downloader.dart';
import 'package:my_reviewer/src/shared/services/ai_models/i_artifact_downloader.dart';
import 'package:my_reviewer/src/shared/services/notifications/i_job_notification_service.dart';
import 'package:my_reviewer/src/shared/services/notifications/no_op_job_notification_service.dart';
import 'package:my_reviewer/src/shared/services/storage/i_file_storage_service.dart';
import 'package:my_reviewer/src/shared/utils/retry.dart';
import 'package:path/path.dart' as p;

import 'artifact_integrity_verifier.dart';
import 'i_ai_model_integrator.dart';

/// Granular lifecycle stages reported while [AiModelProvisioner.provision]
/// executes its download, checksum verification, and runtime integration steps.
enum ProvisionPhase {
  /// Downloading one or more model artifacts.
  downloading,

  /// Streaming downloaded files to verify their SHA-256 digests.
  verifying,

  /// Registering verified artifact paths with the active [IAiModelIntegrator].
  integrating,
}

/// Orchestrates inspection, 3-stage provisioning, and cleanup for [AiModelSpec]
/// bundles using injectable [IArtifactDownloader], [ArtifactIntegrityVerifier],
/// and [IAiModelIntegrator] collaborators.
class AiModelProvisioner {
  AiModelProvisioner({
    required this._storageService,
    required this._integrators,
    IArtifactDownloader? downloader,
    this._verifier = const ArtifactIntegrityVerifier(),
    this._notifications = const NoopJobNotificationService(),
  }) : _downloader = downloader ?? BackgroundArtifactDownloader();

  final IFileStorageService _storageService;
  final List<IAiModelIntegrator> _integrators;
  final IArtifactDownloader _downloader;
  final ArtifactIntegrityVerifier _verifier;
  final IJobNotificationService _notifications;

  static const String _verifiedMarkerFile = '.verified';
  static const String _integratedMarkerFile = '.integrated';
  static const int _maxTransientDownloadAttempts = 3;

  /// Inspects local storage and downloader task records to determine the
  /// current [AiModelStatus] for [spec].
  Future<AiModelStatus> inspect(AiModelSpec spec, {String? lastError}) async {
    final dirPath = _resolveDirPath(spec);
    final dir = Directory(dirPath);
    final records = await _downloader.recordsForGroup(_groupFor(spec));

    if (!await dir.exists() && records.isEmpty) {
      return _status(
        spec,
        phase: AiModelInstallPhase.notInstalled,
        lastError: lastError,
      );
    }

    var downloadedBytes = 0;
    var hasAnyArtifactOrTask = false;
    var allFilesPresent = true;

    for (final artifact in spec.artifacts) {
      final taskId = _taskIdFor(spec, artifact);
      final file = File(p.join(dirPath, artifact.fileName));
      final record = records.where((r) => r.taskId == taskId).firstOrNull;

      final fileExists = await file.exists();
      final len = fileExists ? await file.length() : 0;
      final isComplete = _isArtifactComplete(
        artifact: artifact,
        fileLength: len,
        recordComplete: record?.isComplete ?? false,
      );

      if (isComplete) {
        hasAnyArtifactOrTask = true;
        downloadedBytes += len;
        if (record != null && !record.isComplete) {
          await _downloader.deleteRecord(taskId);
        }
      } else {
        allFilesPresent = false;
        if (len > 0) {
          hasAnyArtifactOrTask = true;
          downloadedBytes += len;
        } else if (record != null) {
          hasAnyArtifactOrTask = true;
          if (artifact.expectedBytes > 0) {
            downloadedBytes +=
                (record.progress.clamp(0.0, 1.0) * artifact.expectedBytes)
                    .round();
          }
        }
      }
    }

    if (!hasAnyArtifactOrTask) {
      return _status(
        spec,
        phase: AiModelInstallPhase.notInstalled,
        lastError: lastError,
      );
    }
    if (!allFilesPresent) {
      return _status(
        spec,
        phase: AiModelInstallPhase.partialDownload,
        downloadedBytes: downloadedBytes,
        lastError: lastError,
      );
    }
    if (!await File(p.join(dirPath, _verifiedMarkerFile)).exists()) {
      return _status(
        spec,
        phase: AiModelInstallPhase.downloadedUnverified,
        downloadedBytes: downloadedBytes,
        lastError: lastError,
      );
    }
    if (!await File(p.join(dirPath, _integratedMarkerFile)).exists()) {
      return _status(
        spec,
        phase: AiModelInstallPhase.verifiedUnintegrated,
        downloadedBytes: downloadedBytes,
        lastError: lastError,
      );
    }

    return AiModelStatus(
      spec: spec,
      phase: AiModelInstallPhase.ready,
      downloadedBytes: downloadedBytes,
    );
  }

  /// Executes the 3-stage provisioning pipeline: Download (0–100%), Verify
  /// (indeterminate), and Integrate (indeterminate).
  Future<void> provision(
    AiModelSpec spec, {
    String? authToken,
    bool requiresWiFi = false,
    void Function(ProvisionPhase phase)? onPhaseChanged,
    MyReviewerTaskProgressCallback? onProgress,
  }) async {
    onProgress?.call(const TaskProgress.preparing());

    final downloadCounter = TaskProgressCounter(
      total: 100,
      onProgress: onProgress,
    );
    final dir = await _storageService.ensureDirectory(
      spec.relativeSubDirectories,
      root: spec.storageRoot,
    );
    final dirPath = dir.path;
    final notif = t.settings.main.notifications.download;

    try {
      onPhaseChanged?.call(ProvisionPhase.downloading);
      await _downloadArtifacts(
        spec,
        dirPath: dirPath,
        authToken: authToken,
        requiresWiFi: requiresWiFi,
        counter: downloadCounter,
      );

      onPhaseChanged?.call(ProvisionPhase.verifying);
      onProgress?.call(const TaskProgress.processing(current: 0, total: 0));
      await _notifications.showOrUpdate(
        title: notif.setupTitle(name: spec.displayName),
        body: notif.status.verifying,
        current: 0,
        total: 0,
      );
      await _verifyArtifacts(spec, dirPath: dirPath);

      onPhaseChanged?.call(ProvisionPhase.integrating);
      onProgress?.call(const TaskProgress.processing(current: 0, total: 0));
      await _notifications.showOrUpdate(
        title: notif.setupTitle(name: spec.displayName),
        body: notif.status.integrating,
        current: 0,
        total: 0,
      );
      await _integrateArtifacts(spec, dirPath: dirPath);

      onProgress?.call(const TaskProgress.finishing());
    } finally {
      await _notifications.dismiss();
    }
  }

  /// Cancels active downloader tasks, unintegrates [spec], and deletes all
  /// model files on disk.
  Future<void> deleteModelFiles(AiModelSpec spec) async {
    await _downloader.cancelAndDeleteGroup(_groupFor(spec));

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
    final group = _groupFor(spec);
    
    _downloader.configureGroupNotifications(
      group: group,
      displayName: spec.displayName,
    );

    final totalBytes = spec.totalBytes;
    var completedBytesBeforeCurrent = 0;

    for (final artifact in spec.artifacts) {
      final finalPath = p.join(dirPath, artifact.fileName);
      final finalFile = File(finalPath);
      final taskId = _taskIdFor(spec, artifact);
      final existingRecord = await _downloader.recordForTask(taskId);

      if (await finalFile.exists()) {
        final len = await finalFile.length();
        final recordComplete = existingRecord?.isComplete ?? false;

        if (_isArtifactComplete(
          artifact: artifact,
          fileLength: len,
          recordComplete: recordComplete,
        )) {
          if (existingRecord != null && !recordComplete) {
            await _downloader.deleteRecord(taskId);
          }

          completedBytesBeforeCurrent += len;

          continue;
        }
        await finalFile.delete();
      }

      _storageService.deleteQuietlyBatch([
        p.join(dirPath, _verifiedMarkerFile),
        p.join(dirPath, _integratedMarkerFile),
      ]);

      final result = await retryAsync<ArtifactDownloadResult>(
        (_) => _downloader.downloadOrResume(
          group: group,
          taskId: taskId,
          url: artifact.downloadUrl,
          fileName: artifact.fileName,
          directoryPath: dirPath,
          requiresWiFi: requiresWiFi,
          authToken: authToken,
          onProgress: (fraction) => _reportDownloadProgress(
            fraction: fraction,
            artifactBytes: artifact.expectedBytes,
            completedBefore: completedBytesBeforeCurrent,
            totalBytes: totalBytes,
            counter: counter,
          ),
        ),
        maxAttempts: _maxTransientDownloadAttempts,
        shouldRetry: (r) => !r.isComplete && r.isTransientFailure,
      );

      if (!result.isComplete) {
        throw StateError(
          result.errorDescription ?? 'Download failed for ${artifact.fileName}',
        );
      }

      completedBytesBeforeCurrent += await File(finalPath).length();
    }
  }

  Future<void> _verifyArtifacts(
    AiModelSpec spec, {
    required String dirPath,
  }) async {
    final verifiedMarker = File(p.join(dirPath, _verifiedMarkerFile));

    if (await verifiedMarker.exists()) {
      return;
    }

    await _verifier.verifyAll(
      artifacts: spec.artifacts,
      directoryPath: dirPath,
      onCorruptedArtifact: (artifact, filePath) async {
        _storageService.deleteQuietly(filePath);
        await _downloader.deleteRecord(_taskIdFor(spec, artifact));
      },
    );

    await verifiedMarker.writeAsString(
      jsonEncode({'verifiedAt': DateTime.now().toIso8601String()}),
      flush: true,
    );
  }

  Future<void> _integrateArtifacts(
    AiModelSpec spec, {
    required String dirPath,
  }) async {
    final integratedMarker = File(p.join(dirPath, _integratedMarkerFile));
    if (await integratedMarker.exists()) return;

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
  }

  bool _isArtifactComplete({
    required AiModelArtifact artifact,
    required int fileLength,
    required bool recordComplete,
  }) {
    if (fileLength <= 0) {
      return false;
    }

    final sizeMatches =
        artifact.expectedBytes <= 0 || fileLength >= artifact.expectedBytes;

    return recordComplete || sizeMatches;
  }

  AiModelStatus _status(
    AiModelSpec spec, {
    required AiModelInstallPhase phase,
    int downloadedBytes = 0,
    String? lastError,
  }) => AiModelStatus(
    spec: spec,
    phase: lastError != null ? AiModelInstallPhase.failed : phase,
    downloadedBytes: downloadedBytes,
    errorMessage: lastError,
  );

  void _reportDownloadProgress({
    required double fraction,
    required int artifactBytes,
    required int completedBefore,
    required int totalBytes,
    required TaskProgressCounter counter,
  }) {
    if (totalBytes <= 0 || fraction < 0) return;

    final currentTotal =
        completedBefore + (fraction.clamp(0.0, 1.0) * artifactBytes).round();
    final step = ((currentTotal / totalBytes) * 100).round().clamp(1, 100);

    counter.set(step);
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
