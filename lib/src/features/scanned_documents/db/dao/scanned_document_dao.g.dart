// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanned_document_dao.dart';

// ignore_for_file: type=lint
mixin _$ScannedDocumentDaoMixin on DatabaseAccessor<AppDatabase> {
  $ScannedDocumentGroupsDbModelTable get scannedDocumentGroupsDbModel =>
      attachedDatabase.scannedDocumentGroupsDbModel;
  $ScannedDocumentsDbModelTable get scannedDocumentsDbModel =>
      attachedDatabase.scannedDocumentsDbModel;
  ScannedDocumentDaoManager get managers => ScannedDocumentDaoManager(this);
}

class ScannedDocumentDaoManager {
  final _$ScannedDocumentDaoMixin _db;
  ScannedDocumentDaoManager(this._db);
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
