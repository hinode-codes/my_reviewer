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

  Stream<List<JobsDbModelData>> watchByGroupKey(String groupKey) {
    return (select(jobsDbModel)
          ..where((t) => t.groupKey.isNotNull() & t.groupKey.equals(groupKey))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
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

  /// Earliest [runAfter] among queued jobs, or null when nothing is queued.
  ///
  /// Used as a cheap wake-up signal for the worker: it carries one value
  /// instead of full rows (payload, partialOutput), so a checkpoint write on
  /// the running job re-runs a tiny aggregate rather than a full-row select.
  /// Pair the stream with `.distinct()` so unchanged values do not emit.
  Stream<DateTime?> watchNextRunAfter() => _nextRunAfterQuery().watchSingle();

  Future<DateTime?> getNextRunAfter() => _nextRunAfterQuery().getSingle();

  // An aggregate select without GROUP BY always yields exactly one row
  // (null when no job is queued), so the *Single variants are safe.
  Selectable<DateTime?> _nextRunAfterQuery() {
    final earliest = jobsDbModel.runAfter.min();
    final query = selectOnly(jobsDbModel)
      ..addColumns([earliest])
      ..where(jobsDbModel.status.equalsValue(JobStatus.queued));
    return query.map((row) => row.read(earliest));
  }

  /// Number of queued jobs, including ones whose [runAfter] is still in the
  /// future. Replaces taking `.length` of a full watched list.
  Future<int> countQueued() {
    final total = countAll();
    final query = selectOnly(jobsDbModel)
      ..addColumns([total])
      ..where(jobsDbModel.status.equalsValue(JobStatus.queued));
    return query.map((row) => row.read(total)!).getSingle();
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
          ..orderBy([(t) => OrderingTerm.asc(t.updatedAt)]))
        .get();
  }

  Stream<List<JobsDbModelData>> watchByStatus(JobStatus status) {
    return (select(jobsDbModel)
          ..where((t) => t.status.equalsValue(status))
          ..orderBy([
            (t) => OrderingTerm.asc(t.updatedAt),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .watch();
  }

  Stream<JobsDbModelData?> watchLatestByItemKey(String itemKey) {
    return (select(jobsDbModel)
          ..where((t) => t.itemKey.equals(itemKey))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
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

  /// Bulk update for running jobs whose heartbeat is missing or older than
  /// [heartbeatCutoff] and that have used up all their attempts.
  /// Disjoint from [updateStaleRunningRetryable]. Returns rows affected.
  Future<int> updateStaleRunningExhausted(
    DateTime heartbeatCutoff,
    JobsDbModelCompanion changes,
  ) {
    return (update(jobsDbModel)..where(
          (t) =>
              t.status.equalsValue(JobStatus.running) &
              (t.heartbeatAt.isNull() |
                  t.heartbeatAt.isSmallerThanValue(heartbeatCutoff)) &
              t.attempts.isBiggerOrEqual(t.maxAttempts),
        ))
        .write(changes);
  }

  /// Bulk update for stale running jobs that still have attempts left.
  /// Disjoint from [updateStaleRunningExhausted]. Returns rows affected.
  Future<int> updateStaleRunningRetryable(
    DateTime heartbeatCutoff,
    JobsDbModelCompanion changes,
  ) {
    return (update(jobsDbModel)..where(
          (t) =>
              t.status.equalsValue(JobStatus.running) &
              (t.heartbeatAt.isNull() |
                  t.heartbeatAt.isSmallerThanValue(heartbeatCutoff)) &
              t.attempts.isSmallerThan(t.maxAttempts),
        ))
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
