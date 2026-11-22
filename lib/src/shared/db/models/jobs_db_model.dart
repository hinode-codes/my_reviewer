import 'package:drift/drift.dart';
import 'package:my_reviewer/src/shared/db/models/date_metadata_mixin.dart';
import 'package:my_reviewer/src/shared/db/models/id_metadata_mixin.dart';

enum JobStatus { queued, running, succeeded, dead, cancelled }

@TableIndex(name: 'idx_jobs_status_run_after', columns: {#status, #runAfter})
@TableIndex(name: 'idx_jobs_group_key', columns: {#groupKey})
@TableIndex(name: 'idx_jobs_item_key', columns: {#itemKey})
class JobsDbModel extends Table with IdMetadataMixin, DateMetadataMixin {
  /// Optional logical bucket for batch cancellation (e.g., `groupId`).
  TextColumn get groupKey => text().nullable()();

  /// Optional deduplication / lookup key for the target item (e.g., `docId`).
  TextColumn get itemKey => text().nullable()();

  /// Serialized job input (e.g., JSON with `relativePath`, `docId`, `groupId`).
  TextColumn get payload => text()();

  TextColumn get status =>
      textEnum<JobStatus>().withDefault(Constant(JobStatus.queued.name))();

  /// for DLQ
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get maxAttempts => integer().withDefault(const Constant(3))();

  DateTimeColumn get runAfter => dateTime()();
  DateTimeColumn get heartbeatAt => dateTime().nullable()();

  /// Checkpointed partial output (e.g., streamed OCR text for Qwen-VL prefill
  /// resumption after an interruption or app restart).
  TextColumn get partialOutput => text().nullable()();

  /// Cumulative active execution time in milliseconds across attempts.
  IntColumn get elapsedMs => integer().withDefault(const Constant(0))();

  TextColumn get lastError => text().nullable()();
}
