import 'package:flutter/foundation.dart';
import 'package:my_reviewer/src/controllers/progress_task.dart';
import 'package:my_reviewer/src/controllers/selection/selectable_items.dart';
import 'package:my_reviewer/src/models/docs/view_models.dart';
import 'package:my_reviewer/src/models/operation.dart';
import 'package:my_reviewer/src/repositories/scanned_document/interface.dart';

class DocsController extends ChangeNotifier {
  DocsController(this._repository)
    : groups = SelectableItems(
        items: _repository.watchScannedDocumentGroups().distinct(
          (previous, current) => listEquals(previous, current),
        ),
        keyOf: (group) => group.id,
      ) {
    deleteTask = ProgressTask<void>(_deleteSelected);

    groups.addListener(notifyListeners);
  }

  final IScannedDocumentRepository _repository;

  final SelectableItems<ScannedDocumentGroupModel> groups;
  late final ProgressTask<void> deleteTask;

  Future<void> _deleteSelected(
    OperationProgressCallback onProgress,
  ) async {
    await _repository.deleteScannedDocumentGroups(
      [for (final group in groups.selectedItems) group.id],
      onProgress: onProgress,
    );

    groups.exitSelectionMode();
  }

  @override
  void dispose() {
    groups.dispose();
    deleteTask.dispose();
    super.dispose();
  }
}