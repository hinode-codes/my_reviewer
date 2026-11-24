/// Snapshot of a persisted or in-flight download record for a single artifact.
class ArtifactDownloadRecord {
  const ArtifactDownloadRecord({
    required this.taskId,
    required this.isComplete,
    required this.progress,
  });

  final String taskId;
  final bool isComplete;
  final double progress;
}

/// Terminal outcome of a single artifact download or resume attempt.
class ArtifactDownloadResult {
  const ArtifactDownloadResult({
    required this.isComplete,
    required this.isTransientFailure,
    this.errorDescription,
  });

  final bool isComplete;
  final bool isTransientFailure;
  final String? errorDescription;
}
