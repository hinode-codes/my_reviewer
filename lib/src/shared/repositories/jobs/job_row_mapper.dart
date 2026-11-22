import 'package:my_reviewer/src/shared/db/app_database.dart';
import 'package:my_reviewer/src/shared/models/job_model.dart';

class JobRowMapper {
  const JobRowMapper();

  JobModel? maybeModel(JobsDbModelData? row) => row == null ? null : model(row);

  JobModel model(JobsDbModelData row) {
    return JobModel(
      id: row.id,
      groupKey: row.groupKey,
      itemKey: row.itemKey,
      payload: row.payload,
      status: row.status,
      attempts: row.attempts,
      maxAttempts: row.maxAttempts,
      runAfter: row.runAfter,
      heartbeatAt: row.heartbeatAt,
      partialOutput: row.partialOutput,
      elapsedMs: row.elapsedMs,
      lastError: row.lastError,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  List<JobModel> models(List<JobsDbModelData> rows) => [
    for (final row in rows) model(row),
  ];
}
