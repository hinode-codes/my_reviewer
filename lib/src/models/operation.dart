/// The progress dialog picks its copy from this, so a new long-running
/// operation is a new value plus its strings, never a new dialog class.
enum OperationKind { save, delete }

enum OperationStage { preparing, processing, finishing }

class OperationProgress {
  const OperationProgress({
    required this.stage,
    this.current = 0,
    this.total = 0,
  });

  final OperationStage stage;
  final int current;
  final int total;

  /// Null makes the bar indeterminate: the preparing and finishing stages
  /// have nothing to count.
  double? get fraction => switch (stage) {
    OperationStage.processing when total > 0 => current / total,
    OperationStage.preparing ||
    OperationStage.processing ||
    OperationStage.finishing => null,
  };
}

typedef OperationProgressCallback = void Function(OperationProgress progress);

enum OperationStatus { idle, running, succeeded, failed }

/// Reports `processing` progress one step at a time, out of a known total.
class ProgressCounter {
  ProgressCounter({required this.total, required this.onProgress});
 
  final int total;
  final OperationProgressCallback? onProgress;
  int _current = 0;
 
  void next() {
    _current++;

    onProgress?.call(
      OperationProgress(
        stage: OperationStage.processing,
        current: _current,
        total: total,
      ),
    );
  }
}
 

