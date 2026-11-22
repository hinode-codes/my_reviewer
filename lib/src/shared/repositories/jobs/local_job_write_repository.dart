import 'package:drift/drift.dart';
import 'package:my_reviewer/src/shared/db/app_database.dart';
import 'package:my_reviewer/src/shared/db/dao/jobs_dao.dart';
import 'package:my_reviewer/src/shared/db/models/jobs_db_model.dart';
import 'package:my_reviewer/src/shared/models/job_model.dart';

import 'i_job_write_repository.dart';
import 'job_row_mapper.dart';

class LocalJobWriteRepository implements IJobWriteRepository {
  const LocalJobWriteRepository({required this.db, required this.dao})
    : _mapper = const JobRowMapper();

  final AppDatabase db;
  final JobDao dao;
  final JobRowMapper _mapper;

  @override
  Future<String> enqueue({
    required String id,
    required String payload,
    String? groupKey,
    String? itemKey,
    DateTime? runAfter,
    int maxAttempts = 3,
    bool deduplicateActiveByItemKey = true,
  }) {
    return db.transaction(() async {
      if (deduplicateActiveByItemKey && itemKey != null) {
        final existing = await dao.getActiveByItemKey(itemKey);

        if (existing != null) {
          return existing.id;
        }
      }

      final now = DateTime.now();

      await dao.insertJob(
        JobsDbModelCompanion.insert(
          id: Value(id),
          groupKey: Value(groupKey),
          itemKey: Value(itemKey),
          payload: payload,
          maxAttempts: Value(maxAttempts),
          runAfter: runAfter ?? now,
          createdAt: Value(now),
        ),
      );

      return id;
    });
  }

  @override
  Future<int> recoverStaleJobs({
    required Duration staleThreshold,
    String crashReason = 'Worker lease expired before completion',
  }) {
    return db.transaction(() async {
      final now = DateTime.now();
      final staleRows = await dao.getStaleRunning(now.subtract(staleThreshold));

      for (final row in staleRows) {
        final exhausted = row.attempts >= row.maxAttempts;

        await dao.updateJobWhereStatus(
          row.id,
          currentStatuses: const [JobStatus.running],
          changes: JobsDbModelCompanion(
            status: Value(exhausted ? JobStatus.dead : JobStatus.queued),
            heartbeatAt: const Value(null),
            runAfter: Value(now),
            lastError: Value(crashReason),
            updatedAt: Value(now),
          ),
        );
      }

      return staleRows.length;
    });
  }

  @override
  Future<JobModel?> claimNextJob() {
    return db.transaction(() async {
      final now = DateTime.now();
      final candidate = await dao.getNextRunnable(now);

      if (candidate == null) {
        return null;
      }

      final updated = await dao.updateJobWhereStatus(
        candidate.id,
        currentStatuses: const [JobStatus.queued],
        changes: JobsDbModelCompanion(
          status: const Value(JobStatus.running),
          attempts: Value(candidate.attempts + 1),
          heartbeatAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      if (updated == 0) {
        return null;
      }

      return _mapper.maybeModel(await dao.getById(candidate.id));
    });
  }

  @override
  Future<bool> checkpoint({
    required String jobId,
    String? partialOutput,
    int? elapsedMs,
  }) async {
    final now = DateTime.now();

    final updated = await dao.updateJobWhereStatus(
      jobId,
      currentStatuses: const [JobStatus.running],
      changes: JobsDbModelCompanion(
        heartbeatAt: Value(now),
        partialOutput: partialOutput != null
            ? Value(partialOutput)
            : const Value.absent(),
        elapsedMs: elapsedMs != null ? Value(elapsedMs) : const Value.absent(),
        updatedAt: Value(now),
      ),
    );

    return updated > 0;
  }

  @override
  Future<bool> markSucceeded(
    String jobId, {
    String? finalOutput,
    int? elapsedMs,
  }) async {
    final now = DateTime.now();
    final updated = await dao.updateJobWhereStatus(
      jobId,
      currentStatuses: const [JobStatus.running],
      changes: JobsDbModelCompanion(
        status: const Value(JobStatus.succeeded),
        heartbeatAt: const Value(null),
        partialOutput: finalOutput != null
            ? Value(finalOutput)
            : const Value.absent(),
        elapsedMs: elapsedMs != null ? Value(elapsedMs) : const Value.absent(),
        lastError: const Value(null),
        updatedAt: Value(now),
      ),
    );

    return updated > 0;
  }

  @override
  Future<JobStatus> recordFailure({
    required String jobId,
    required String errorMessage,
    Duration retryDelay = const Duration(seconds: 5),
    String? partialOutput,
    int? elapsedMs,
  }) {
    return db.transaction(() async {
      final row = await dao.getById(jobId);

      if (row == null || row.status != JobStatus.running) {
        return row?.status ?? JobStatus.cancelled;
      }

      final now = DateTime.now();
      final nextStatus = row.attempts >= row.maxAttempts
          ? JobStatus.dead
          : JobStatus.queued;

      await dao.updateJobWhereStatus(
        jobId,
        currentStatuses: const [JobStatus.running],
        changes: JobsDbModelCompanion(
          status: Value(nextStatus),
          heartbeatAt: const Value(null),
          runAfter: Value(
            nextStatus == JobStatus.queued ? now.add(retryDelay) : now,
          ),
          partialOutput: partialOutput != null
              ? Value(partialOutput)
              : const Value.absent(),
          elapsedMs: elapsedMs != null
              ? Value(elapsedMs)
              : const Value.absent(),
          lastError: Value(errorMessage),
          updatedAt: Value(now),
        ),
      );

      return nextStatus;
    });
  }

  @override
  Future<int> cancelByGroupKey(String groupKey) {
    return dao.updateActiveByGroupKey(
      groupKey,
      JobsDbModelCompanion(
        status: const Value(JobStatus.cancelled),
        heartbeatAt: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<int> cancelByItemKeys(Iterable<String> itemKeys) {
    return dao.updateActiveByItemKeys(
      itemKeys,
      JobsDbModelCompanion(
        status: const Value(JobStatus.cancelled),
        heartbeatAt: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<bool> requeueDeadJob(
    String jobId, {
    bool resetProgress = false,
  }) async {
    final now = DateTime.now();

    final updated = await dao.updateJobWhereStatus(
      jobId,
      currentStatuses: const [JobStatus.dead],
      changes: JobsDbModelCompanion(
        status: const Value(JobStatus.queued),
        attempts: const Value(0),
        runAfter: Value(now),
        heartbeatAt: const Value(null),
        lastError: const Value(null),
        partialOutput: resetProgress ? const Value(null) : const Value.absent(),
        elapsedMs: resetProgress ? const Value(0) : const Value.absent(),
        updatedAt: Value(now),
      ),
    );

    return updated > 0;
  }

  @override
  Future<void> deleteJob(String id) async {
    await dao.deleteJob(id);
  }
}
