import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/models/artifact_download.dart';

import 'i_artifact_downloader.dart';

/// Production [IArtifactDownloader] backed by `background_downloader`.
class BackgroundArtifactDownloader implements IArtifactDownloader {
  BackgroundArtifactDownloader({FileDownloader? downloader})
    : _downloader = downloader ?? FileDownloader();

  final FileDownloader _downloader;

  @override
  Future<List<ArtifactDownloadRecord>> recordsForGroup(String group) async {
    final records = await _downloader.database.allRecords(group: group);

    return records.map(_mapRecord).toList();
  }

  @override
  Future<ArtifactDownloadRecord?> recordForTask(String taskId) async {
    final record = await _downloader.database.recordForId(taskId);

    return record == null ? null : _mapRecord(record);
  }

  @override
  Future<void> deleteRecord(String taskId) =>
      _downloader.database.deleteRecordWithId(taskId);

  @override
  Future<void> cancelAndDeleteGroup(String group) async {
    final records = await _downloader.database.allRecords(group: group);

    if (records.isEmpty) {
      return;
    }

    final taskIds = records.map((r) => r.taskId).toList();

    await _downloader.cancelTasksWithIds(taskIds);
    await _downloader.database.deleteRecordsWithIds(taskIds);
  }

  @override
  void configureGroupNotifications({
    required String group,
    required String displayName,
  }) {
    final notif = t.settings.main.notifications.download;

    _downloader.configureNotificationForGroup(
      group,
      running: TaskNotification(
        notif.title(name: displayName),
        '{filename} ({progress})',
      ),
      error: TaskNotification(notif.failed(name: displayName), '{filename}'),
      paused: TaskNotification(notif.paused(name: displayName), '{filename}'),
      canceled: TaskNotification(
        notif.canceled(name: displayName),
        '{filename}',
      ),
      progressBar: true,
      groupNotificationId: group,
    );
  }

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
    final latestRecord = await _downloader.database.recordForId(taskId);
    final latestTask = latestRecord?.task;
    final canResume =
        latestRecord != null &&
        (latestRecord.status == TaskStatus.paused ||
            latestRecord.status == TaskStatus.failed) &&
        latestTask is DownloadTask &&
        await _downloader.taskCanResume(latestTask);

    final freshTask = DownloadTask(
      taskId: taskId,
      group: group,
      url: url,
      filename: fileName,
      directory: directoryPath,
      baseDirectory: BaseDirectory.root,
      requiresWiFi: requiresWiFi,
      allowPause: true,
      updates: Updates.statusAndProgress,
      headers: {
        if (authToken != null && authToken.isNotEmpty)
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
      },
    );

    final completer = Completer<TaskStatusUpdate>();

    _downloader.registerCallbacks(
      group: group,
      taskStatusCallback: (update) {
        if (update.task.taskId == taskId &&
            update.status.isFinalState &&
            !completer.isCompleted) {
          completer.complete(update);
        }
      },
      taskProgressCallback: (update) {
        if (update.task.taskId == taskId) {
          onProgress(update.progress);
        }
      },
    );

    try {
      var started = false;

      if (canResume) {
        started = await _downloader.resume(latestTask);
      }

      if (!started) {
        await _downloader.database.deleteRecordWithId(taskId);

        started = await _downloader.enqueue(freshTask);
      }

      if (!started) {
        throw StateError('Failed to enqueue download task $taskId');
      }

      final update = await completer.future;

      return ArtifactDownloadResult(
        isComplete: update.status == TaskStatus.complete,
        isTransientFailure: _isTransientNetworkDrop(update),
        errorDescription:
            update.exception?.description ??
            'Download failed for $fileName (${update.status.name})',
      );
    } finally {
      _downloader.unregisterCallbacks(group: group);
    }
  }

  ArtifactDownloadRecord _mapRecord(TaskRecord record) =>
      ArtifactDownloadRecord(
        taskId: record.taskId,
        isComplete: record.status == TaskStatus.complete,
        progress: record.progress,
      );

  bool _isTransientNetworkDrop(TaskStatusUpdate update) {
    if (update.status != TaskStatus.failed) {
      return false;
    }

    final description = update.exception?.description.toLowerCase() ?? '';

    return description.contains('unexpected end of stream') ||
        description.contains('connection reset') ||
        description.contains('socketexception') ||
        description.contains('broken pipe') ||
        description.contains('timeout');
  }
}
