import 'package:drift/drift.dart';
import 'package:my_reviewer/src/shared/db/app_database.dart';
import 'package:my_reviewer/src/shared/db/models/jobs_db_model.dart';

part 'jobs_dao.g.dart';

@DriftAccessor(tables: [JobsDbModel])
class JobDao extends DatabaseAccessor<AppDatabase> with _$JobDaoMixin {
  JobDao(super.db);

  Future<JobsDbModelData?> getById(String id) {
    return (select(
      jobsDbModel,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<JobsDbModelData?> getActiveByItemKey(String itemKey) {
    return (select(jobsDbModel)
          ..where(
            (t) =>
                t.itemKey.equals(itemKey) &
                t.status.isInValues([JobStatus.queued, JobStatus.running]),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  Future<JobsDbModelData?> getNextRunnable(DateTime now) {
    return (select(jobsDbModel)
          ..where(
            (t) =>
                t.status.equalsValue(JobStatus.queued) &
                t.runAfter.isSmallerOrEqualValue(now),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.runAfter),
            (t) => OrderingTerm.asc(t.createdAt),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<JobsDbModelData>> getStaleRunning(DateTime heartbeatCutoff) {
    return (select(jobsDbModel)..where(
          (t) =>
              t.status.equalsValue(JobStatus.running) &
              (t.heartbeatAt.isNull() |
                  t.heartbeatAt.isSmallerThanValue(heartbeatCutoff)),
        ))
        .get();
  }

  Future<List<JobsDbModelData>> getByStatus(JobStatus status) {
    return (select(jobsDbModel)
          ..where((t) => t.status.equalsValue(status))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  Stream<List<JobsDbModelData>> watchByStatus(JobStatus status) {
    return (select(jobsDbModel)
          ..where((t) => t.status.equalsValue(status))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  Stream<JobsDbModelData?> watchLatestByItemKey(String itemKey) {
    return (select(jobsDbModel)
          ..where((t) => t.itemKey.equals(itemKey))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Stream<List<JobsDbModelData>> watchActiveByGroupKey(String groupKey) {
    return (select(jobsDbModel)
          ..where(
            (t) =>
                t.groupKey.equals(groupKey) &
                t.status.isInValues([JobStatus.queued, JobStatus.running]),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<void> insertJob(JobsDbModelCompanion entry) {
    return into(jobsDbModel).insert(entry);
  }

  /// Conditional update by [id] and expected [currentStatuses] (for optimistic
  /// locking on claim, checkpoint, completion, or cancellation).
  /// Returns the number of rows affected (0 or 1).
  Future<int> updateJobWhereStatus(
    String id, {
    required List<JobStatus> currentStatuses,
    required JobsDbModelCompanion changes,
  }) {
    return (update(
          jobsDbModel,
        )..where((t) => t.id.equals(id) & t.status.isInValues(currentStatuses)))
        .write(changes);
  }

  Future<int> updateActiveByGroupKey(
    String groupKey,
    JobsDbModelCompanion changes,
  ) {
    return (update(jobsDbModel)..where(
          (t) =>
              t.groupKey.equals(groupKey) &
              t.status.isInValues([JobStatus.queued, JobStatus.running]),
        ))
        .write(changes);
  }

  Future<int> updateActiveByItemKeys(
    Iterable<String> itemKeys,
    JobsDbModelCompanion changes,
  ) {
    final keys = itemKeys.toSet();
    if (keys.isEmpty) return Future.value(0);

    return (update(jobsDbModel)..where(
          (t) =>
              t.itemKey.isIn(keys) &
              t.status.isInValues([JobStatus.queued, JobStatus.running]),
        ))
        .write(changes);
  }

  Future<int> deleteJob(String id) {
    return (delete(jobsDbModel)..where((t) => t.id.equals(id))).go();
  }
}
