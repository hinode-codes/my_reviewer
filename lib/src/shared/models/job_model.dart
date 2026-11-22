import 'package:my_reviewer/src/shared/db/models/jobs_db_model.dart';

class JobModel {
  const JobModel({
    required this.id,
    required this.payload,
    required this.status,
    required this.attempts,
    required this.maxAttempts,
    required this.runAfter,
    required this.createdAt,
    this.groupKey,
    this.itemKey,
    this.heartbeatAt,
    this.partialOutput,
    this.elapsedMs = 0,
    this.lastError,
    this.updatedAt,
  });

  final String id;
  final String? groupKey;
  final String? itemKey;
  final String payload;
  final JobStatus status;
  final int attempts;
  final int maxAttempts;
  final DateTime runAfter;
  final DateTime? heartbeatAt;
  final String? partialOutput;
  final int elapsedMs;
  final String? lastError;
  final DateTime createdAt;
  final DateTime? updatedAt;

  bool get isActive =>
      status == JobStatus.queued || status == JobStatus.running;

  bool get canResumeFromPrefill =>
      partialOutput != null && partialOutput!.isNotEmpty;
}
