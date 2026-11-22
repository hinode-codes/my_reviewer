import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/shared/models/task.dart';
import 'package:my_reviewer/src/shared/utils/throttle.dart';

class TaskController<D> extends ChangeNotifier {
  TaskController(
    this._task, {
    this.onCancel,
    Duration throttleInterval = const Duration(milliseconds: 60),
  }) : _throttle = Throttle(interval: throttleInterval);

  final Future<D> Function(MyReviewerTaskProgressCallback onProgress) _task;
  final VoidCallback? onCancel;
  final Throttle _throttle;

  TaskStatus _status = TaskStatus.idle;
  TaskStatus get status => _status;

  TaskProgress? _progress;
  TaskProgress? get progress => _progress;

  D? _result;
  D? get result => _result;

  Object? _error;
  Object? get error => _error;

  bool _disposed = false;

  Future<TaskStatus> run() async {
    if (_status == TaskStatus.running) {
      return _status;
    }

    _status = TaskStatus.running;
    _progress = const TaskProgress(stage: TaskStage.preparing);
    _result = null;
    _error = null;

    notifyListeners();

    try {
      _result = await _task(_report);
      _status = TaskStatus.succeeded;
    } catch (err, stackTrace) {
      debugPrint('Task failed: $err\n$stackTrace');

      _error = err;
      _status = TaskStatus.failed;
    }

    _throttle.dispose();

    if (!_disposed) {
      notifyListeners();
    }

    return _status;
  }

  void cancel() {
    if (_status == TaskStatus.running) {
      onCancel?.call();
    }
  }

  void _report(TaskProgress progress) {
    if (_disposed) {
      return;
    }

    final stageChanged = _progress?.stage != progress.stage;
    final isComplete = progress.total > 0 && progress.current >= progress.total;

    _progress = progress;

    _throttle(() {
      if (!_disposed) {
        notifyListeners();
      }
    }, force: stageChanged || isComplete);
  }

  @override
  void dispose() {
    _disposed = true;

    _throttle.dispose();
    super.dispose();
  }
}
