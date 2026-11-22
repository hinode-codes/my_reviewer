import 'package:my_reviewer/src/shared/models/job_dispatch_request.dart';

abstract interface class IJobDispatcher {
  /// Enqueues a job, wakes the background runner immediately, and updates the
  /// persistent notification (if enabled by the user).
  Future<String> dispatch({
    required String id,
    required String payload,
    String? groupKey,
    String? itemKey,
    DateTime? runAfter,
    int maxAttempts = 3,
    bool deduplicateActiveByItemKey = true,
  });

  /// Batch-enqueues multiple jobs in a single flow and wakes the runner once.
  Future<List<String>> dispatchAll(List<JobDispatchRequest> requests);

  /// Cancels all queued/running jobs for [groupKey] and updates/dismisses the
  /// notification if the queue becomes empty.
  Future<int> cancelGroup(String groupKey);

  /// Cancels all queued/running jobs for [itemKeys] and updates/dismisses the
  /// notification if the queue becomes empty.
  Future<int> cancelItems(Iterable<String> itemKeys);

  /// Re-queues a dead-letter job and wakes the runner.
  Future<bool> retryDeadJob(String jobId, {bool resetProgress = false});
}
