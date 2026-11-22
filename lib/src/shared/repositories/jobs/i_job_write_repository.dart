import 'package:my_reviewer/src/shared/db/models/jobs_db_model.dart';
import 'package:my_reviewer/src/shared/models/job_model.dart';

abstract interface class IJobWriteRepository {
  /// Enqueues a job. If [deduplicateActiveByItemKey] is `true` and an active
  /// (`queued` or `running`) job already exists for [itemKey], returns the
  /// existing active job ID instead of inserting a duplicate.
  Future<String> enqueue({
    required String id,
    required String payload,
    String? groupKey,
    String? itemKey,
    DateTime? runAfter,
    int maxAttempts = 3,
    bool deduplicateActiveByItemKey = true,
  });

  /// Reclaims `running` jobs whose [heartbeatAt] is older than [staleThreshold].
  /// Jobs at `attempts >= maxAttempts` move to [JobStatus.dead] (DLQ); others
  /// return to [JobStatus.queued] with [partialOutput] and [elapsedMs] intact.
  /// Returns the count of recovered jobs.
  Future<int> recoverStaleJobs({
    required Duration staleThreshold,
    String crashReason = 'Worker lease expired before completion',
  });

  /// Atomically claims the next eligible `queued` job (`runAfter <= now`),
  /// transitions it to `running`, increments `attempts`, and sets `heartbeatAt`.
  Future<JobModel?> claimNextJob();

  /// Updates `heartbeatAt` and persists streamed [partialOutput] + cumulative
  /// [elapsedMs]. Returns `false` if the job was cancelled or preempted while
  /// running so the worker can abort immediately.
  Future<bool> checkpoint({
    required String jobId,
    String? partialOutput,
    int? elapsedMs,
  });

  /// Marks a `running` job as `succeeded` and clears its lease.
  Future<bool> markSucceeded(
    String jobId, {
    String? finalOutput,
    int? elapsedMs,
  });

  /// Records an execution failure, preserving [partialOutput] and [elapsedMs].
  /// Moves to [JobStatus.dead] if `attempts >= maxAttempts`, or re-queues after
  /// [retryDelay]. Returns the resulting [JobStatus].
  Future<JobStatus> recordFailure({
    required String jobId,
    required String errorMessage,
    Duration retryDelay = const Duration(seconds: 5),
    String? partialOutput,
    int? elapsedMs,
  });

  /// Cancels all `queued` or `running` jobs for [groupKey].
  Future<int> cancelByGroupKey(String groupKey);

  /// Cancels all `queued` or `running` jobs matching [itemKeys].
  Future<int> cancelByItemKeys(Iterable<String> itemKeys);

  /// Re-queues a `dead` DLQ job with `attempts = 0`. Set [resetProgress] to
  /// `true` to discard [partialOutput] and restart from token 0.
  Future<bool> requeueDeadJob(String jobId, {bool resetProgress = false});

  Future<void> deleteJob(String id);
}
