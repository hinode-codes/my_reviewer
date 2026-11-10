/// A stage of the save pipeline, in order. The repository emits one of these
/// as it works so the UI can describe what is happening.
enum SaveStage { preparing, savingFiles, finishing }

/// A snapshot of save progress. [currentFile] and [totalFiles] are meaningful
/// only during [SaveStage.savingFiles]; they are 0 otherwise.
///
/// A small class rather than a bare enum because the saving stage carries the
/// file counts the message needs.
class SaveProgress {
  const SaveProgress({
    required this.stage,
    this.currentFile = 0,
    this.totalFiles = 0,
  });

  final SaveStage stage;
  final int currentFile;
  final int totalFiles;
}

/// Reports save progress back to the caller. Optional, so a caller that does
/// not care about progress passes nothing.
typedef SaveProgressCallback = void Function(SaveProgress progress);
