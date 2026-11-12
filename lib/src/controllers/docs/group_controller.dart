import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:my_reviewer/src/controllers/progress_task.dart';
import 'package:my_reviewer/src/controllers/selection/selectable_items.dart';
import 'package:my_reviewer/src/models/deletion.dart';
import 'package:my_reviewer/src/models/docs/view_models.dart';
import 'package:my_reviewer/src/models/operation.dart';
import 'package:my_reviewer/src/repositories/scanned_document/interface.dart';

typedef DocsGroupArgs = ({
  String docId,
  List<ScannedDocumentModel>? initialDocuments,
});

class DocsGroupController extends ChangeNotifier {
  DocsGroupController({
    required this._repository,
    required this.docId,
    List<ScannedDocumentModel>? initialDocuments,
  }) : documents = SelectableItems(
         items: _repository
             .watchScannedDocumentsByGroupId(docId)
             .distinct((prev, curr) => listEquals(prev, curr)),
         keyOf: (doc) => doc.id,
         initialItems: initialDocuments,
       ) {
    deleteTask = ProgressTask<DeletionOutcome>(_deleteSelected);

    documents.addListener(notifyListeners);

    // Watched rather than fetched once: this screen stays mounted under
    // the edit route, and a rename there must show up on return.
    _nameSubscription = _repository
        .watchScannedDocumentGroupName(docId)
        .distinct()
        .listen(_onNameChanged);
  }

  final IScannedDocumentRepository _repository;
  final SelectableItems<ScannedDocumentModel> documents;
  final String docId;

  late final ProgressTask<DeletionOutcome> deleteTask;
  late final StreamSubscription<String?> _nameSubscription;

  String? _groupName;
  String? get groupName => _groupName;

  void _onNameChanged(String? name) {
    _groupName = name;
    notifyListeners();
  }

  Future<DeletionOutcome> _deleteSelected(
    OperationProgressCallback onProgress,
  ) async {
    final outcome = await _repository.deleteScannedDocuments(
      docId,
      [for (final doc in documents.selectedItems) doc.id],
      emptyGroup: EmptyGroupPolicy.deleteGroup,
      onProgress: onProgress,
    );

    documents.exitSelectionMode();

    return outcome;
  }

  @override
  void dispose() {
    _nameSubscription.cancel();
    documents.dispose();
    deleteTask.dispose();
    super.dispose();
  }
}
