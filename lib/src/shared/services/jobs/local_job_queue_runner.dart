import 'dart:async';

import 'package:my_reviewer/src/shared/db/models/jobs_db_model.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/models/job_cancelled_exception.dart';
import 'package:my_reviewer/src/shared/models/job_dispatch_request.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/i_job_read_repository.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/i_job_write_repository.dart';
import 'package:my_reviewer/src/shared/services/jobs/job_execution_context.dart';
import 'package:my_reviewer/src/shared/services/notifications/i_job_notification_service.dart';

import 'i_job_dispatcher.dart';
import 'i_job_handler.dart';

class LocalJobQueueRunner implements IJobDispatcher {
  LocalJobQueueRunner({
    required this._readRepo,
    required this._writeRepo,
    required this._handler,
    required this._notifications,
    this.staleLeaseThreshold = const Duration(seconds: 30),
    this.pollInterval = const Duration(seconds: 5),
    this.retryBackoff = const Duration(seconds: 5),
  });

  final IJobReadRepository _readRepo;
  final IJobWriteRepository _writeRepo;
  final IJobHandler _handler;
  final IJobNotificationService _notifications;

  final Duration staleLeaseThreshold;
  final Duration pollInterval;
  final Duration retryBackoff;

  bool _started = false;
  bool _isProcessing = false;
  bool _disposed = false;
  Timer? _pollTimer;

  int _sessionCompleted = 0;

  /// Call once during app initialization after DB & DI setup.
  Future<void> start() async {
    if (_started || _disposed) {
      return;
    }

    _started = true;

    await _writeRepo.recoverStaleJobs(staleThreshold: staleLeaseThreshold);

    _pollTimer = Timer.periodic(pollInterval, (_) => _drain());

    unawaited(_drain());
  }

  Future<void> dispose() async {
    _disposed = true;

    _pollTimer?.cancel();
    _pollTimer = null;

    await _notifications.dismiss();
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

    unawaited(_drain());

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

    unawaited(_drain());

    return ids;
  }

  @override
  Future<int> cancelGroup(String groupKey) async {
    final cancelled = await _writeRepo.cancelByGroupKey(groupKey);

    await _syncNotificationWithQueue();

    return cancelled;
  }

  @override
  Future<int> cancelItems(Iterable<String> itemKeys) async {
    final cancelled = await _writeRepo.cancelByItemKeys(itemKeys);

    await _syncNotificationWithQueue();

    return cancelled;
  }

  @override
  Future<bool> retryDeadJob(String jobId, {bool resetProgress = false}) async {
    final requeued = await _writeRepo.requeueDeadJob(
      jobId,
      resetProgress: resetProgress,
    );

    if (requeued) {
      unawaited(_drain());
    }

    return requeued;
  }

  Future<void> _drain() async {
    if (_isProcessing || _disposed) {
      return;
    }

    _isProcessing = true;

    try {
      while (!_disposed) {
        final job = await _writeRepo.claimNextJob();

        if (job == null) {
          break;
        }

        final queuedRemaining = (await _readRepo.getByStatus(JobStatus.queued))
            .length;
        final current = _sessionCompleted + 1;
        final total = current + queuedRemaining;

        await _notifications.showOrUpdate(
          title: t.jobs.transcription.title,
          body: job.canResumeFromPrefill
              ? t.jobs.transcription.status.resuming
              : t.jobs.transcription.status.processing,
          current: current,
          total: total,
        );

        String? latestPartial = job.partialOutput;
        int latestElapsedMs = job.elapsedMs;

        final context = JobExecutionContext(
          onCheckpoint: ({String? partialOutput, int? elapsedMs}) async {
            if (partialOutput != null) {
              latestPartial = partialOutput;
            }

            if (elapsedMs != null) {
              latestElapsedMs = elapsedMs;
            }

            return _writeRepo.checkpoint(
              jobId: job.id,
              partialOutput: partialOutput,
              elapsedMs: elapsedMs,
            );
          },
        );

        try {
          await _handler.execute(job, context);
          await _writeRepo.markSucceeded(
            job.id,
            finalOutput: latestPartial,
            elapsedMs: latestElapsedMs,
          );
          _sessionCompleted++;
        } on JobCancelledException {
          // Job was already marked `cancelled` externally; do nothing.
        } catch (error) {
          await _writeRepo.recordFailure(
            jobId: job.id,
            errorMessage: error.toString(),
            retryDelay: retryBackoff * job.attempts,
            partialOutput: latestPartial,
            elapsedMs: latestElapsedMs,
          );
        }
      }
    } finally {
      _isProcessing = false;

      await _syncNotificationWithQueue();
    }
  }

  Future<void> _syncNotificationWithQueue() async {
    final queued = await _readRepo.getByStatus(JobStatus.queued);
    final running = await _readRepo.getByStatus(JobStatus.running);

    if (queued.isEmpty && running.isEmpty) {
      _sessionCompleted = 0;

      await _notifications.dismiss();
    } else if (_isProcessing && running.isNotEmpty) {
      // Mid-batch cancellation occurred while another job is still running:
      // immediately shrink the notification denominator to match the DB.
      final current = _sessionCompleted + 1;
      final total = _sessionCompleted + running.length + queued.length;

      await _notifications.showOrUpdate(
        title: t.jobs.transcription.title,
        body: t.jobs.transcription.status.processing,
        current: current,
        total: total,
      );
    } else if (!_isProcessing && queued.isNotEmpty) {
      // Jobs exist with a future `runAfter` backoff delay.
      final total = _sessionCompleted + queued.length;

      await _notifications.showOrUpdate(
        title: t.jobs.transcription.title,
        body: t.jobs.transcription.status.waitingToRetry(n: queued.length),
        current: _sessionCompleted,
        total: total,
      );
    }
  }
}
