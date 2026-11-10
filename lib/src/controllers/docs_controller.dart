import 'package:flutter/foundation.dart';
import 'package:my_reviewer/src/models/docs_delete_state.dart';
import 'package:my_reviewer/src/models/docs_models.dart';
import 'package:my_reviewer/src/models/docs_selection_mode.dart';
import 'package:my_reviewer/src/repositories/scanned_document_repository.dart';

class DocsController extends ChangeNotifier {
  final IScannedDocumentRespository _repository;

  DocsController(this._repository);

  Stream<List<ScannedDocumentGroupModel>> watchScannedDocumentGroups() {
    return _repository.watchScannedDocumentGroups().distinct(
      (previous, current) => listEquals(previous, current),
    );
  }

  DocsSelectionMode _selectionMode = DocsSelectionMode.inactive;
  final Set<String> _selectedGroupIds = {};

  DocsSelectionMode get selectionMode => _selectionMode;
  Set<String> get selectedGroupIds => Set.unmodifiable(_selectedGroupIds);

  bool isGroupSelected(String id) => _selectedGroupIds.contains(id);

  void enterSelectionMode([String? initialId]) {
    _selectionMode = DocsSelectionMode.active;

    if (initialId != null) {
      _selectedGroupIds.add(initialId);
    }

    notifyListeners();
  }

  void exitSelectionMode() {
    _selectionMode = DocsSelectionMode.inactive;
    _selectedGroupIds.clear();

    notifyListeners();
  }

  void toggleGroupSelection(String id) {
    if (_selectedGroupIds.contains(id)) {
      _selectedGroupIds.remove(id);
    } else {
      _selectedGroupIds.add(id);
    }
    notifyListeners();
  }

  void toggleSelectAll(List<String> allGroupIds) {
    if (_selectedGroupIds.length == allGroupIds.length) {
      _selectedGroupIds.clear();
    } else {
      _selectedGroupIds.addAll(allGroupIds);
    }

    notifyListeners();
  }

  DeleteStatus _deleteStatus = DeleteStatus.idle;
  DeleteProgress? _deleteProgress;

  DeleteStatus get deleteStatus => _deleteStatus;
  DeleteProgress? get deleteProgress => _deleteProgress;

  Future<void> deleteSelectedGroups() async {
    if (_selectedGroupIds.isEmpty) {
      return;
    }

    final idsToDelete = _selectedGroupIds.toList();
    _deleteStatus = DeleteStatus.deleting;
    _deleteProgress = const DeleteProgress(stage: DeleteStage.preparing);

    notifyListeners();

    try {
      await _repository.deleteScannedDocumentGroups(
        idsToDelete,
        onProgress: (progress) {
          _deleteProgress = progress;
          notifyListeners();
        },
      );

      _deleteStatus = DeleteStatus.deleted;
      exitSelectionMode();
    } catch (_) {
      _deleteStatus = DeleteStatus.failed;
      notifyListeners();
    }
  }
}
