import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:my_reviewer/src/shared/db/models/jobs_db_model.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/models/job_dispatch_request.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/i_job_read_repository.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/i_job_write_repository.dart';
import 'package:my_reviewer/src/shared/services/jobs/i_job_dispatcher.dart';

import 'ocr_foreground_task_handler.dart';

class ForegroundTaskJobDispatcher implements IJobDispatcher {
  ForegroundTaskJobDispatcher({
    required this._readRepo,
    required this._writeRepo,
  });

  final IJobReadRepository _readRepo;
  final IJobWriteRepository _writeRepo;

  @override
  Future<void> initialize() async {
    // Only start the background worker on app launch if unfinished jobs exist
    // in SQLite (e.g., after an OS kill or device reboot).
    final queued = await _readRepo.getByStatus(JobStatus.queued);
    final running = await _readRepo.getByStatus(JobStatus.running);

    if (queued.isNotEmpty || running.isNotEmpty) {
      await _ensureWorkerRunning();
    }
  }

  @override
  Future<void> dispose() async {
    // Never stop the background worker when the UI isolate disposes.
  }

  @override
  Future<String> dispatch({
    required String id,
    required String payload,
    String? groupKey,
    String? itemKey,
    DateTime? runAfter,
    int maxAttempts = 3,
    bool deduplicateActiveByItemKey = true,
  }) async {
    final jobId = await _writeRepo.enqueue(
      id: id,
      payload: payload,
      groupKey: groupKey,
      itemKey: itemKey,
      runAfter: runAfter,
      maxAttempts: maxAttempts,
      deduplicateActiveByItemKey: deduplicateActiveByItemKey,
    );

    await _ensureWorkerRunning();
    return jobId;
  }

  @override
  Future<List<String>> dispatchAll(List<JobDispatchRequest> requests) async {
    if (requests.isEmpty) {
      return const [];
    }

    final ids = <String>[];
    for (final req in requests) {
      final jobId = await _writeRepo.enqueue(
        id: req.id,
        payload: req.payload,
        groupKey: req.groupKey,
        itemKey: req.itemKey,
        runAfter: req.runAfter,
        maxAttempts: req.maxAttempts,
        deduplicateActiveByItemKey: req.deduplicateActiveByItemKey,
      );
      ids.add(jobId);
    }

    await _ensureWorkerRunning();
    return ids;
  }

  @override
  Future<int> cancelGroup(String groupKey) async {
    final cancelled = await _writeRepo.cancelByGroupKey(groupKey);
    FlutterForegroundTask.sendDataToTask(OcrTaskCommands.sync);
    return cancelled;
  }

  @override
  Future<int> cancelItems(Iterable<String> itemKeys) async {
    final cancelled = await _writeRepo.cancelByItemKeys(itemKeys);
    FlutterForegroundTask.sendDataToTask(OcrTaskCommands.sync);
    return cancelled;
  }

  @override
  Future<bool> retryDeadJob(String jobId, {bool resetProgress = false}) async {
    final requeued = await _writeRepo.requeueDeadJob(
      jobId,
      resetProgress: resetProgress,
    );

    if (requeued) {
      await _ensureWorkerRunning();
    }

    return requeued;
  }

  Future<void> _ensureWorkerRunning() async {
    final isRunning = await FlutterForegroundTask.isRunningService;

    if (isRunning) {
      FlutterForegroundTask.sendDataToTask(OcrTaskCommands.drain);

      return;
    }

    await FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: t.jobs.transcription.title,
      notificationText: t.jobs.transcription.status.processing,
      callback: startOcrBackgroundTask,
    );
  }
}
