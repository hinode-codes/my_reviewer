// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanned_document_groups_dao.dart';

// ignore_for_file: type=lint
mixin _$ScannedDocumentGroupsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ScannedDocumentGroupsDbModelTable get scannedDocumentGroupsDbModel =>
      attachedDatabase.scannedDocumentGroupsDbModel;
  $ScannedDocumentsDbModelTable get scannedDocumentsDbModel =>
      attachedDatabase.scannedDocumentsDbModel;
  $ScannedDocumentGroupCountView get scannedDocumentGroupCount =>
      attachedDatabase.scannedDocumentGroupCount;
  ScannedDocumentGroupsDaoManager get managers =>
      ScannedDocumentGroupsDaoManager(this);
}

class ScannedDocumentGroupsDaoManager {
  final _$ScannedDocumentGroupsDaoMixin _db;
  ScannedDocumentGroupsDaoManager(this._db);
  $$ScannedDocumentGroupsDbModelTableTableManager
  get scannedDocumentGroupsDbModel =>
      $$ScannedDocumentGroupsDbModelTableTableManager(
        _db.attachedDatabase,
        _db.scannedDocumentGroupsDbModel,
      );
  $$ScannedDocumentsDbModelTableTableManager get scannedDocumentsDbModel =>
      $$ScannedDocumentsDbModelTableTableManager(
        _db.attachedDatabase,
        _db.scannedDocumentsDbModel,
      );
}
