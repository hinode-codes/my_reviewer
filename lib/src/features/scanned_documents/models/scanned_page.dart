import 'package:my_reviewer/src/features/scanned_documents/models/pending_scan_page.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_model.dart';

sealed class ScannedPage {
  const ScannedPage();

  String get id;
  String get name;

  ScannedPage withName(String newName);
}

final class StoredScannedPage extends ScannedPage {
  const StoredScannedPage(this.doc);

  final ScannedDocumentModel doc;

  @override
  String get id => doc.id;

  @override
  String get name => doc.name;

  @override
  StoredScannedPage withName(String newName) =>
      StoredScannedPage(doc.copyWith(name: newName));

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is StoredScannedPage && other.doc == doc;

  @override
  int get hashCode => doc.hashCode;
}

final class EphemeralScannedPage extends ScannedPage {
  const EphemeralScannedPage(this.pending);

  final PendingScanPage pending;

  @override
  String get id => pending.id;

  @override
  String get name => pending.name;

  @override
  EphemeralScannedPage withName(String newName) =>
      EphemeralScannedPage(pending.copyWith(name: newName));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EphemeralScannedPage && other.pending == pending;

  @override
  int get hashCode => pending.hashCode;
}
