import 'package:my_reviewer/src/shared/db/models/jobs_db_model.dart';
import 'package:my_reviewer/src/shared/models/job_model.dart';

abstract interface class IJobReadRepository {
  Future<JobModel?> getById(String id);
  Future<JobModel?> getActiveByItemKey(String itemKey);

  Future<List<JobModel>> getByStatus(JobStatus status);
  Stream<List<JobModel>> watchByStatus(JobStatus status);

  Stream<JobModel?> watchLatestByItemKey(String itemKey);
  Stream<List<JobModel>> watchActiveByGroupKey(String groupKey);

  Stream<List<JobModel>> watchByGroupKey(String groupKey);

  /// Convenience stream for inspecting the Dead-Letter Queue.
  Stream<List<JobModel>> watchDeadJobs();

  /// Earliest `runAfter` among queued jobs, or null when nothing is queued.
  ///
  /// A cheap wake-up signal for the worker: it carries one value instead of
  /// full rows. Pair it with `.distinct()` so writes that do not change the
  /// value (such as checkpoints of the running job) do not wake the worker.
  Stream<DateTime?> watchNextRunAfter();

  /// One-shot version of [watchNextRunAfter].
  Future<DateTime?> getNextRunAfter();

  /// Number of queued jobs, including ones whose `runAfter` is still in the
  /// future.
  Future<int> countQueued();
}
