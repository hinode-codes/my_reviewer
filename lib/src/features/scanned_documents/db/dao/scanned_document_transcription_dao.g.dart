// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanned_document_transcription_dao.dart';

// ignore_for_file: type=lint
mixin _$ScannedDocumentTranscriptionDaoMixin on DatabaseAccessor<AppDatabase> {
  $ScannedDocumentGroupsDbModelTable get scannedDocumentGroupsDbModel =>
      attachedDatabase.scannedDocumentGroupsDbModel;
  $ScannedDocumentsDbModelTable get scannedDocumentsDbModel =>
      attachedDatabase.scannedDocumentsDbModel;
  $ScannedDocumentTranscriptionsDbModelTable
  get scannedDocumentTranscriptionsDbModel =>
      attachedDatabase.scannedDocumentTranscriptionsDbModel;
  ScannedDocumentTranscriptionDaoManager get managers =>
      ScannedDocumentTranscriptionDaoManager(this);
}

class ScannedDocumentTranscriptionDaoManager {
  final _$ScannedDocumentTranscriptionDaoMixin _db;
  ScannedDocumentTranscriptionDaoManager(this._db);
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
  $$ScannedDocumentTranscriptionsDbModelTableTableManager
  get scannedDocumentTranscriptionsDbModel =>
      $$ScannedDocumentTranscriptionsDbModelTableTableManager(
        _db.attachedDatabase,
        _db.scannedDocumentTranscriptionsDbModel,
      );
}
