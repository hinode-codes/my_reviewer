/// What the scanner is doing right now.
enum DocsScanStatus {
  /// The screen has mounted but the first scan has not been requested yet.
  notStarted,

  /// The ML Kit scanner is open.
  scanning,

  /// At least one scan attempt has finished and none is running.
  idle,
}

/// How a single scan attempt ended.
enum DocsScanOutcome {
  /// One or more pages were added.
  captured,

  /// The user left the scanner without capturing anything.
  cancelled,

  /// The scanner threw.
  failed,

  /// The request was ignored because a scan was already running, or the
  /// initial scan had already been started.
  skipped,
}

/// Which body the scan screen shows. Derived from the status and the pages
/// captured so far, so the screen never has to combine flags itself.
enum DocsScanView { loading, empty, preview }

enum SaveStatus { idle, saving, saved, failed }

enum SaveOutcome { saved, failed, nothingToSave, skipped }

/// Whether leaving the scan screen needs confirmation first.
enum DocsScanExitGuard {
  /// Nothing staged — popping loses nothing.
  allowed,

  /// Pages are staged and would be lost; confirm before popping.
  confirmNeeded,
}
