import 'package:my_reviewer/src/shared/models/task.dart';
import 'package:my_reviewer/src/shared/models/use_case.dart';

import 'delete_scanned_group_use_case.dart';

class DeleteScannedGroupsUseCase implements UseCase<List<String>, void> {
  const DeleteScannedGroupsUseCase(this._deleteGroup);

  final DeleteScannedGroupUseCase _deleteGroup;

  @override
  Future<void> call(
    List<String> groupIds, {
    MyReviewerTaskProgressCallback? onProgress,
  }) async {
    if (groupIds.isEmpty) {
      return;
    }

    onProgress?.call(const TaskProgress.preparing());

    final counter = TaskProgressCounter(
      total: groupIds.length,
      onProgress: onProgress,
    );

    for (final id in groupIds) {
      counter.next();
      await _deleteGroup(id);
    }

    onProgress?.call(const TaskProgress.finishing());
  }
}
