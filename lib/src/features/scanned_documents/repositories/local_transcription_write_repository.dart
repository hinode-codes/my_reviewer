import 'package:drift/drift.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_transcription_dao.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_transcription_model.dart';
import 'package:my_reviewer/src/shared/db/app_database.dart';
import 'package:my_reviewer/src/shared/services/storage/file_journal.dart';
import 'package:my_reviewer/src/shared/services/storage/i_file_storage_service.dart';
import 'package:path/path.dart' as p;

import 'i_transcription_write_repository.dart';
import 'transcription_row_mapper.dart';

class LocalTranscriptionWriteRepository
    implements ITranscriptionWriteRepository {
  const LocalTranscriptionWriteRepository({
    required this.db,
    required this.dao,
    required this.storageService,
  }) : _mapper = const TranscriptionRowMapper();

  final AppDatabase db;
  final ScannedDocumentTranscriptionDao dao;
  final IFileStorageService storageService;
  final TranscriptionRowMapper _mapper;

  static const String rootFolder = 'transcriptions';

  List<String> _groupSegments(String groupId) => [rootFolder, groupId];

  String _groupRelativePath(String groupId) => p.join(rootFolder, groupId);

  @override
  Future<ScannedDocumentTranscriptionModel> saveTranscription({
    required String groupId,
    required String docId,
    required String content,
    required int timeMsToTranscribe,
    required int timeMsToRead,
    required int wordCount,
    String ext = 'txt',
  }) async {
    final existing = await dao.getByDocId(docId);
    final journal = FileJournal(storageService);
    final now = DateTime.now();

    try {
      await db.transaction(() async {
        final createdRelativePath = await storageService.saveText(
          content,
          _groupSegments(groupId),
          fileNameWithExtension: '$docId.$ext',
        );
        journal.recordCreated(createdRelativePath);

        await dao.upsertTranscription(
          ScannedDocumentTranscriptionsDbModelCompanion.insert(
            id: existing != null ? Value(existing.id) : Value.absent(),
            docId: docId,
            relativePath: createdRelativePath,
            ext: ext,
            timeMsToTranscribe: Value(timeMsToTranscribe),
            timeMsToRead: Value(timeMsToRead),
            wordCount: Value(wordCount),
            updatedAt: Value(existing != null ? now : null),
          ),
        );
      });

      if (existing != null && existing.ext != ext) {
        storageService.deleteQuietly(existing.relativePath);
      }

      final saved = await dao.getByDocId(docId);

      return _mapper.model(saved!);
    } catch (_) {
      await journal.rollback();

      rethrow;
    }
  }

  @override
  Future<void> updateTranscriptionContent({
    required String docId,
    required String content,
    required int timeMsToRead,
    required int wordCount,
  }) async {
    final existing = await dao.getByDocId(docId);

    if (existing == null) {
      return;
    }

    await db.transaction(() async {
      await storageService.saveText(
        content,
        p.split(p.dirname(existing.relativePath)),
        fileNameWithExtension: p.basename(existing.relativePath),
      );

      await dao.updateTranscription(
        docId,
        ScannedDocumentTranscriptionsDbModelCompanion(
          timeMsToRead: Value(timeMsToRead),
          wordCount: Value(wordCount),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  @override
  Future<void> deleteByDocId(String docId) async {
    await db.transaction(() async {
      final existing = await dao.getByDocId(docId);

      if (existing != null) {
        await dao.deleteByDocId(docId);
        await storageService.delete(existing.relativePath);
      }
    });
  }

  @override
  Future<void> deleteGroupFolder(String groupId) async {
    await storageService.delete(_groupRelativePath(groupId), recursive: true);
  }
}
