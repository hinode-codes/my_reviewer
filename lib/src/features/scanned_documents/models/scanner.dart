/// Whether the ML Kit scanner is open.
enum ScannerStatus { idle, scanning }

/// How a single scan attempt ended.
enum ScanOutcome {
  /// One or more pages were added.
  captured,

  /// The user left the scanner without capturing anything.
  cancelled,

  /// The scanner threw.
  failed,

  /// Ignored because a scan was already running, or the session had
  /// already been started.
  skipped,
}

/// Whether leaving the scan screen needs confirmation first.
enum ScanExitGuard {
  /// Nothing unsaved — popping loses nothing.
  allowed,

  /// Unsaved work would be lost; confirm before popping.
  confirmNeeded,
}

/// Whether the scan screen's Save button can do anything.
enum SaveAvailability {
  /// There are unsaved changes; Save writes them.
  available,

  /// Nothing differs from what is stored; Save is disabled.
  nothingToSave,
}

/// Whether a scan preview session can still be saved. A saved session is
/// finished: its ephemeral pages point at temp files the save already moved,
/// so saving it again would fail, duplicate or lose pages.
///
/// Both flows rely on the preview screen leaving right after a successful
/// save. If it ever stays open, two things break:
/// - Pages saved as ephemeral still point at their deleted temp files, so
///   any page not already in the image cache shows as broken.
/// - The preview still accepts scans, renames and removals, but Save stays
///   disabled in this state, so those edits are silently lost on exit.
///
/// Each controller's `_save` says what that flow would need instead.
enum ScanSessionPhase { editing, saved }
