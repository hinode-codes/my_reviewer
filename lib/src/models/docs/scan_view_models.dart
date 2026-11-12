import 'package:flutter/foundation.dart';
import 'package:my_reviewer/src/models/docs/view_models.dart';

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

enum ScanPageType {
  // new; not stored yet
  ephemeral,
  // already stored
  stored,
}

class ScanPage {
  final ScannedDocumentModel doc;
  final ScanPageType pageType;

  const ScanPage({required this.doc, required this.pageType});

  ScanPage withName(String name) => ScanPage(
    doc: doc.copyWith(name: name),
    pageType: pageType,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanPage && other.doc == doc && other.pageType == pageType;

  @override
  int get hashCode => Object.hash(doc, pageType);
}

/// The editable state of a scan session as one immutable value. Every edit
/// replaces it, so undo and redo are a matter of keeping old values.
///
/// Value equality lets the edit flow compare the draft with what it loaded.
class ScanSessionSnapshot {
  final String groupId;
  final String groupName;
  final List<ScanPage> pages;

  static const ScanSessionSnapshot empty = ScanSessionSnapshot(
    groupId: '',
    groupName: '',
    pages: [],
  );

  bool isEmpty() {
    return this == empty;
  }

  const ScanSessionSnapshot({
    required this.groupId,
    required this.groupName,
    required this.pages,
  });

  ScanSessionSnapshot.stored(ScannedDocumentGroupModel group)
    : groupId = group.id,
      groupName = group.groupName,
      pages = List.unmodifiable([
        for (final doc in group.documents)
          ScanPage(doc: doc, pageType: ScanPageType.stored),
      ]);

  /// The documents of the pages with [pageType], in page order.
  List<ScannedDocumentModel> docsWithPageType(ScanPageType pageType) => [
    for (final page in pages)
      if (page.pageType == pageType) page.doc,
  ];
  
  // Value equality, so a draft edited back to its stored values (delete a
  // letter, type it back) matches the baseline again, not only the exact
  // instance that undo/redo restores. Pages compare with ScanPage's value
  // equality, so a page renamed back to its stored name also matches.
  ScanSessionSnapshot copyWith({
    String? groupId,
    String? groupName,
    List<ScanPage>? pages,
  }) => ScanSessionSnapshot(
    groupId: groupId ?? this.groupId,
    groupName: groupName ?? this.groupName,
    pages: pages == null ? this.pages : List.unmodifiable(pages),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanSessionSnapshot &&
          other.groupId == groupId &&
          other.groupName == groupName &&
          listEquals(other.pages, pages);

  @override
  int get hashCode => Object.hash(groupId, groupName, Object.hashAll(pages));
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
