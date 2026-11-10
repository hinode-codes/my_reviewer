// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'docs_dao.dart';

// ignore_for_file: type=lint
mixin _$ScannedDocumentsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ScannedDocumentsGroupsTable get scannedDocumentsGroups =>
      attachedDatabase.scannedDocumentsGroups;
  $ScannedDocumentsTable get scannedDocuments =>
      attachedDatabase.scannedDocuments;
  $ScannedDocumentsViewView get scannedDocumentsView =>
      attachedDatabase.scannedDocumentsView;
  $ScannedGroupDocCountView get scannedGroupDocCount =>
      attachedDatabase.scannedGroupDocCount;
  ScannedDocumentsDaoManager get managers => ScannedDocumentsDaoManager(this);
}

class ScannedDocumentsDaoManager {
  final _$ScannedDocumentsDaoMixin _db;
  ScannedDocumentsDaoManager(this._db);
  $$ScannedDocumentsGroupsTableTableManager get scannedDocumentsGroups =>
      $$ScannedDocumentsGroupsTableTableManager(
        _db.attachedDatabase,
        _db.scannedDocumentsGroups,
      );
  $$ScannedDocumentsTableTableManager get scannedDocuments =>
      $$ScannedDocumentsTableTableManager(
        _db.attachedDatabase,
        _db.scannedDocuments,
      );
}
