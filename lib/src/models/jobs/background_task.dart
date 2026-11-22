enum BackgroundTaskState {
  queued,
  active,
  paused,
  completed,
  failed,
  cancelled,
}

class BackgroundTaskProgress {
  const BackgroundTaskProgress({
    required this.id,
    required this.title,
    required this.reason,
    required this.state,
    this.current = 0,
    this.total = 0,
    this.bytesPerSecond,
    this.estimatedRemaining,
    this.canCancel = true,
  });

  final String id;
  final String title;
  final String reason;
  final BackgroundTaskState state;

  /// Bytes downloaded (for downloads) or pages completed (for transcription).
  final int current;
  final int total;

  final double? bytesPerSecond;
  final Duration? estimatedRemaining;
  final bool canCancel;

  /// Null when total is unknown so progress indicators render as indeterminate.
  double? get fraction =>
      total > 0 ? (current / total).clamp(0.0, 1.0) : null;
}