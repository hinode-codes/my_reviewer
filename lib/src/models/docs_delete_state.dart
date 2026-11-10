enum DeleteStatus { idle, deleting, deleted, failed }

enum DeleteStage { preparing, deletingFiles, finishing }

class DeleteProgress {
  final DeleteStage stage;
  final int currentGroup;
  final int totalGroups;

  const DeleteProgress({
    required this.stage,
    this.currentGroup = 0,
    this.totalGroups = 0,
  });
}

typedef DeleteProgressCallback = void Function(DeleteProgress progress);
