import 'package:my_reviewer/src/shared/db/models/jobs_db_model.dart';
import 'package:my_reviewer/src/shared/models/job_model.dart';

abstract interface class IJobReadRepository {
  Future<JobModel?> getById(String id);
  Future<JobModel?> getActiveByItemKey(String itemKey);

  Future<List<JobModel>> getByStatus(JobStatus status);
  Stream<List<JobModel>> watchByStatus(JobStatus status);

  Stream<JobModel?> watchLatestByItemKey(String itemKey);
  Stream<List<JobModel>> watchActiveByGroupKey(String groupKey);

  /// Convenience stream for inspecting the Dead-Letter Queue.
  Stream<List<JobModel>> watchDeadJobs();
}
