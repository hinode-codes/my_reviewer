import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:my_reviewer/src/shared/db/models/jobs_db_model.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/models/job_cancelled_exception.dart';
import 'package:my_reviewer/src/shared/models/job_dispatch_request.dart';
import 'package:my_reviewer/src/shared/models/job_model.dart';
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
    this.onQueueIdle,
    required this._notifications,
    this.staleLeaseThreshold = const Duration(seconds: 30),
    this.pollInterval = const Duration(seconds: 5),
    this.retryBackoff = const Duration(seconds: 5),
    this.executionTimeout = const Duration(minutes: 5),
  });

  final IJobReadRepository _readRepo;
  final IJobWriteRepository _writeRepo;
  final IJobHandler _handler;
  final IJobNotificationService _notifications;
  final Future<void> Function()? onQueueIdle;

  final Duration staleLeaseThreshold;
  final Duration pollInterval;
  final Duration retryBackoff;
  final Duration executionTimeout;

  Future<void>? _initFuture;
  bool _isProcessing = false;
  bool _isSweeping = false;
  bool _disposed = false;

  Timer? _pollTimer;

  int _sessionCompleted = 0;

  @override
  Future<void> initialize() {
    if (_disposed) {
      return Future.value();
    }

    return _initFuture ??= _doInitialize();
  }

  Future<void> _doInitialize() async {
    // On fresh process start, any job still marked `running` was interrupted by
    // an app kill/crash and must be recovered immediately before draining.
    await _writeRepo.recoverStaleJobs(staleThreshold: Duration.zero);

    if (_disposed) {
      return;
    }

    _pollTimer = Timer.periodic(pollInterval, (_) async {
      if (_disposed || _isSweeping) {
        return;
      }

      _isSweeping = true;
      try {
        if (!_isProcessing) {
          await _writeRepo.recoverStaleJobs(
            staleThreshold: staleLeaseThreshold,
          );
        }

        if (!_disposed) {
          unawaited(_drain());
        }
      } finally {
        _isSweeping = false;
      }
    });

    unawaited(_drain());
  }

  Future<void> triggerDrain() async {
    await initialize();

    if (_isProcessing) {
      await _syncNotificationWithQueue();
      return;
    }

    unawaited(_drain());
  }

  /// Re-evaluates notification state immediately (e.g., after external cancellation).
  Future<void> syncNotifications() => _syncNotificationWithQueue();

  @override
  Future<void> dispose() async {
    _disposed = true;

    _pollTimer?.cancel();
    _pollTimer = null;

    _handler.dispose();

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
    await initialize();

    final jobId = await _writeRepo.enqueue(
      id: id,
      payload: payload,
      groupKey: groupKey,
      itemKey: itemKey,
      runAfter: runAfter,
      maxAttempts: maxAttempts,
      deduplicateActiveByItemKey: deduplicateActiveByItemKey,
    );

    _notifyMainIsolate(jobId: jobId, itemKey: itemKey, groupKey: groupKey);
    unawaited(_drain());

    return jobId;
  }

  @override
  Future<List<String>> dispatchAll(List<JobDispatchRequest> requests) async {
    if (requests.isEmpty) {
      return const [];
    }

    await initialize();

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
      _notifyMainIsolate(
        jobId: jobId,
        itemKey: req.itemKey,
        groupKey: req.groupKey,
      );
    }

    unawaited(_drain());

    return ids;
  }

  @override
  Future<int> cancelGroup(String groupKey) async {
    final cancelled = await _writeRepo.cancelByGroupKey(groupKey);

    _notifyMainIsolate(groupKey: groupKey);
    await _syncNotificationWithQueue();

    return cancelled;
  }

  @override
  Future<int> cancelItems(Iterable<String> itemKeys) async {
    final keys = itemKeys.toList();
    final cancelled = await _writeRepo.cancelByItemKeys(keys);

    for (final key in keys) {
      _notifyMainIsolate(itemKey: key);
    }
    await _syncNotificationWithQueue();

    return cancelled;
  }

  @override
  Future<bool> retryDeadJob(String jobId, {bool resetProgress = false}) async {
    await initialize();

    final requeued = await _writeRepo.requeueDeadJob(
      jobId,
      resetProgress: resetProgress,
    );

    if (requeued) {
      _notifyMainIsolate(jobId: jobId, status: JobStatus.queued.name);
      unawaited(_drain());
    }

    return requeued;
  }

  void _notifyMainIsolate({
    String? jobId,
    String? itemKey,
    String? groupKey,
    String? status,
    String? lastError,
  }) {
    try {
      FlutterForegroundTask.sendDataToMain({
        'type': 'job_updated',
        'jobId': ?jobId,
        'itemKey': ?itemKey,
        'groupKey': ?groupKey,
        'status': ?status,
        'lastError': ?lastError,
      });
    } catch (_) {
      // Safe no-op if running in the main isolate or before task port binds.
    }
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

        // Wake the UI isolate immediately when a job transitions to `running`,
        // before warmUp() or vision prefill blocks for several seconds.
        _notifyMainIsolate(
          jobId: job.id,
          itemKey: job.itemKey,
          groupKey: job.groupKey,
          status: JobStatus.running.name,
        );

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

            final stillActive = await _writeRepo.checkpoint(
              jobId: job.id,
              partialOutput: partialOutput,
              elapsedMs: elapsedMs,
            );

            _notifyMainIsolate(
              jobId: job.id,
              itemKey: job.itemKey,
              groupKey: job.groupKey,
              status: stillActive
                  ? JobStatus.running.name
                  : JobStatus.cancelled.name,
            );

            if (stillActive) {
              await _syncNotificationWithQueue();
            }

            return stillActive;
          },
        );

        var terminalStatus = JobStatus.running;
        String? terminalError;

        try {
          await _handler
              .execute(job, context)
              .timeout(
                executionTimeout,
                onTimeout: () => throw TimeoutException(
                  'Job execution exceeded ${executionTimeout.inMinutes}-minute timeout',
                  executionTimeout,
                ),
              );
          await _writeRepo.markSucceeded(
            job.id,
            finalOutput: latestPartial,
            elapsedMs: latestElapsedMs,
          );

          terminalStatus = JobStatus.succeeded;
          _sessionCompleted++;
        } on JobCancelledException {
          terminalStatus = JobStatus.cancelled;
        } catch (error) {
          terminalError = error.toString();

          await _writeRepo.recordFailure(
            jobId: job.id,
            errorMessage: terminalError,
            retryDelay: retryBackoff * (job.attempts + 1),
            partialOutput: latestPartial,
            elapsedMs: latestElapsedMs,
          );

          final updated = await _readRepo.getById(job.id);
          terminalStatus = updated?.status ?? JobStatus.dead;
        } finally {
          _notifyMainIsolate(
            jobId: job.id,
            itemKey: job.itemKey,
            groupKey: job.groupKey,
            status: terminalStatus.name,
            lastError: terminalError,
          );
        }
      }
    } finally {
      _isProcessing = false;

      await _syncNotificationWithQueue();

      final queued = await _readRepo.getByStatus(JobStatus.queued);
      final running = await _readRepo.getByStatus(JobStatus.running);
      if (!_disposed && queued.isEmpty && running.isEmpty) {
        await onQueueIdle?.call();
      }
    }
  }

  Future<void> _syncNotificationWithQueue() async {
    if (_disposed) {
      return;
    }

    final queued = await _readRepo.getByStatus(JobStatus.queued);
    final running = await _readRepo.getByStatus(JobStatus.running);

    if (queued.isEmpty && running.isEmpty) {
      _sessionCompleted = 0;

      await _notifications.dismiss();
    } else if (_isProcessing && running.isNotEmpty) {
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
