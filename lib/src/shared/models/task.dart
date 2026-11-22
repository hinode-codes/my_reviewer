enum TaskKind { save, delete, update, download }

enum TaskStage { preparing, processing, finishing }

enum TaskStatus { idle, running, succeeded, failed }

typedef MyReviewerTaskProgressCallback = void Function(TaskProgress progress);

class TaskProgress {
  const TaskProgress({required this.stage, this.current = 0, this.total = 0});

  const TaskProgress.preparing() : this(stage: TaskStage.preparing);

  const TaskProgress.finishing() : this(stage: TaskStage.finishing);

  final TaskStage stage;
  final int current;
  final int total;

  double? get fraction => switch (stage) {
    TaskStage.processing when total > 0 => (current / total).clamp(0.0, 1.0),
    TaskStage.preparing || TaskStage.processing || TaskStage.finishing => null,
  };
}

class TaskProgressCounter {
  TaskProgressCounter({required this.total, required this.onProgress});

  final int total;
  final MyReviewerTaskProgressCallback? onProgress;

  int _current = 0;

  // Advances by 1 (for item-by-item loops like saving or deleting files).
  void next() => set(_current + 1);

  /// Jumps to an exact value (for byte-based callbacks like downloads).
  void set(int current) {
    _current = current;
    onProgress?.call(
      TaskProgress(
        stage: TaskStage.processing,
        current: _current,
        total: total,
      ),
    );
  }
}
