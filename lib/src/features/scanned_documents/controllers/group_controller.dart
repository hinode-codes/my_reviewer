import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_scanned_document_read_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/use_cases/delete_scanned_documents_use_case.dart';
import 'package:my_reviewer/src/shared/controllers/selection/selectable_items.dart';
import 'package:my_reviewer/src/shared/controllers/task_controller.dart';
import 'package:my_reviewer/src/shared/models/deletion.dart';
import 'package:my_reviewer/src/shared/models/task.dart';

typedef GroupRouteArgs = ({
  String groupId,
  List<ScannedDocumentModel>? initialDocuments,
});

class GroupController extends ChangeNotifier {
  GroupController({
    required this.readRepository,
    required this._deleteDocumentsUseCase,
    required this.groupId,
    List<ScannedDocumentModel>? initialDocuments,
  }) : documents = SelectableItems(
         items: readRepository
             .watchScannedDocumentsByGroupId(groupId)
             .distinct((previous, next) => listEquals(previous, next)),
         keyOf: (doc) => doc.id,
         initialItems: initialDocuments,
       ) {
    deleteTask = TaskController<DeletionOutcome>(_deleteSelected);
    documents.addListener(notifyListeners);

    // Watched rather than fetched once: this screen stays mounted under
    // the edit route, and a rename there must show up on return.
    _groupNameSubscription = readRepository
        .watchScannedDocumentGroupName(groupId)
        .distinct()
        .listen(_onGroupNameChanged);
  }

  final IScannedDocumentReadRepository readRepository;
  final DeleteScannedDocumentsUseCase _deleteDocumentsUseCase;
  final String groupId;
  final SelectableItems<ScannedDocumentModel> documents;

  late final TaskController<DeletionOutcome> deleteTask;
  late final StreamSubscription<String?> _groupNameSubscription;

  String? _groupName;
  String? get groupName => _groupName;

  bool _disposed = false;

  void _onGroupNameChanged(String? name) {
    if (_disposed || _groupName == name) {
      return;
    }

    _groupName = name;
    notifyListeners();
  }

  Future<DeletionOutcome> _deleteSelected(
    MyReviewerTaskProgressCallback onProgress,
  ) async {
    final outcome = await _deleteDocumentsUseCase((
      groupId: groupId,
      documentIds: [for (final doc in documents.selectedItems) doc.id],
      emptyGroup: EmptyGroupPolicy.deleteGroup,
    ), onProgress: onProgress);

    if (!_disposed) {
      documents.exitSelectionMode();
    }

    return outcome;
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_groupNameSubscription.cancel());
    documents
      ..removeListener(notifyListeners)
      ..dispose();
    deleteTask.dispose();
    super.dispose();
  }
}
