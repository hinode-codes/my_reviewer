import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/models/operation.dart';

/// One long-running operation as an object (the Command pattern).
///
/// The task, not the screen's controller, owns the idle → running → done
/// cycle, so `ProgressDialog` can show and retry any operation without
/// knowing which controller started it. The repository only reports
/// progress through the callback it is handed.
class ProgressTask<R> extends ChangeNotifier {
  ProgressTask(this._operation);

  final Future<R> Function(OperationProgressCallback onProgress) _operation;

  OperationStatus _status = OperationStatus.idle;
  OperationStatus get status => _status;

  OperationProgress? _progress;
  OperationProgress? get progress => _progress;

  R? _result;

  /// Set when the last run succeeded, e.g. whether a deletion also removed
  /// the parent group.
  R? get result => _result;

  Future<OperationStatus> run() async {
    // A second tap on Save or Retry while the first run is still going
    // would otherwise write everything twice.
    if (_status == OperationStatus.running) {
      return _status;
    }

    _status = OperationStatus.running;
    _progress = const OperationProgress(stage: OperationStage.preparing);
    _result = null;

    notifyListeners();

    try {
      _result = await _operation(_report);
      _status = OperationStatus.succeeded;
    } catch (err, stackTrace) {
      debugPrint('Operation failed: $err\n$stackTrace');
      _status = OperationStatus.failed;
    }

    notifyListeners();

    return _status;
  }

  void _report(OperationProgress progress) {
    _progress = progress;
    notifyListeners();
  }
}
