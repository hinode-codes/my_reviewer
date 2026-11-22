import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_transcription_model.dart';

abstract interface class ITranscriptionWriteRepository {
  Future<ScannedDocumentTranscriptionModel> saveTranscription({
    required String groupId,
    required String docId,
    required String content,
    required int timeMsToTranscribe,
    required int timeMsToRead,
    required int wordCount,
    String ext = 'txt',
  });

  Future<void> updateTranscriptionContent({
    required String docId,
    required String content,
    required int timeMsToRead,
    required int wordCount,
  });

  Future<void> deleteByDocId(String docId);
  Future<void> deleteGroupFolder(String groupId);
}
