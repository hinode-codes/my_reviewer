import 'package:flutter/foundation.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/pending_scan_page.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_group_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_page.dart';

/// The editable state of a scan session as one immutable value. Every edit
/// replaces it, so undo and redo are a matter of keeping old values.
///
/// Value equality lets the edit flow compare the draft with what it loaded.
class ScanSessionSnapshot {
  const ScanSessionSnapshot({
    required this.groupId,
    required this.groupName,
    required this.pages,
  });

  ScanSessionSnapshot.stored(ScannedDocumentGroupModel group)
    : groupId = group.id,
      groupName = group.name,
      pages = List.unmodifiable([
        for (final doc in group.documents) StoredScannedPage(doc),
      ]);

  final String groupId;
  final String groupName;
  final List<ScannedPage> pages;

  static const ScanSessionSnapshot empty = ScanSessionSnapshot(
    groupId: '',
    groupName: '',
    pages: [],
  );

  bool get isEmpty => this == empty;

  /// Existing persisted documents in page order.
  List<ScannedDocumentModel> get storedDocuments => [
    for (final page in pages)
      if (page is StoredScannedPage) page.doc,
  ];

  /// Newly scanned unsaved pages in page order.
  List<PendingScanPage> get pendingPages => [
    for (final page in pages)
      if (page is EphemeralScannedPage) page.pending,
  ];

  // Value equality, so a draft edited back to its stored values (delete a
  // letter, type it back) matches the baseline again, not only the exact
  // instance that undo/redo restores. Pages compare with ScannedPage's value
  // equality, so a page renamed back to its stored name also matches.
  ScanSessionSnapshot copyWith({
    String? groupId,
    String? groupName,
    List<ScannedPage>? pages,
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
