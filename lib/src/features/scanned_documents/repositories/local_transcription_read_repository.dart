import 'package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_transcription_dao.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_transcription_model.dart';

import 'i_transcription_read_repository.dart';
import 'transcription_row_mapper.dart';

class LocalTranscriptionReadRepository implements ITranscriptionReadRepository {
  const LocalTranscriptionReadRepository({required this.dao})
    : _mapper = const TranscriptionRowMapper();

  final ScannedDocumentTranscriptionDao dao;
  final TranscriptionRowMapper _mapper;

  @override
  Future<ScannedDocumentTranscriptionModel?> getByDocId(String docId) async =>
      _mapper.maybeModel(await dao.getByDocId(docId));

  @override
  Stream<ScannedDocumentTranscriptionModel?> watchByDocId(String docId) =>
      dao.watchByDocId(docId).map(_mapper.maybeModel);

  @override
  Future<List<ScannedDocumentTranscriptionModel>> getByGroupId(
    String groupId,
  ) async => _mapper.models(await dao.getByGroupId(groupId));

  @override
  Stream<List<ScannedDocumentTranscriptionModel>> watchByGroupId(
    String groupId,
  ) => dao.watchByGroupId(groupId).map(_mapper.models);

  @override
  Future<bool> hasTranscription(String docId) => dao.hasTranscription(docId);
}
