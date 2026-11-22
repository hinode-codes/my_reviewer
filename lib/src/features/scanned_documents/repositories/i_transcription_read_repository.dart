import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_transcription_model.dart';

abstract interface class ITranscriptionReadRepository {
  Future<ScannedDocumentTranscriptionModel?> getByDocId(String docId);
  Stream<ScannedDocumentTranscriptionModel?> watchByDocId(String docId);

  Future<List<ScannedDocumentTranscriptionModel>> getByGroupId(String groupId);
  Stream<List<ScannedDocumentTranscriptionModel>> watchByGroupId(
    String groupId,
  );

  Future<bool> hasTranscription(String docId);
}
