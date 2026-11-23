import 'package:flutter/foundation.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_group_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_scanned_document_read_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/use_cases/delete_scanned_groups_use_case.dart';
import 'package:my_reviewer/src/shared/controllers/selection/selectable_items.dart';
import 'package:my_reviewer/src/shared/controllers/task_controller.dart';
import 'package:my_reviewer/src/shared/models/task.dart';

class DocsMainController extends ChangeNotifier {
  DocsMainController({
    required this.readRepository,
    required this._deleteGroupsUseCase,
  }) : groups = SelectableItems(
         items: readRepository.watchScannedDocumentGroups().distinct(
           (previous, current) => listEquals(previous, current),
         ),
         keyOf: (group) => group.id,
       ) {
    deleteTask = TaskController<void>(_deleteSelected);
    groups.addListener(notifyListeners);
  }

  final IScannedDocumentReadRepository readRepository;
  final DeleteScannedGroupsUseCase _deleteGroupsUseCase;
  final SelectableItems<ScannedDocumentGroupModel> groups;
  late final TaskController<void> deleteTask;

  Future<void> _deleteSelected(
    MyReviewerTaskProgressCallback onProgress,
  ) async {
    await _deleteGroupsUseCase([
      for (final group in groups.selectedItems) group.id,
    ], onProgress: onProgress);

    groups.exitSelectionMode();
  }

  @override
  void dispose() {
    groups
      ..removeListener(notifyListeners)
      ..dispose();
    deleteTask.dispose();
    super.dispose();
  }
}
