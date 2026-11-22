import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_transcription_model.dart';
import 'package:my_reviewer/src/shared/db/app_database.dart';
import 'package:path/path.dart' as p;

class TranscriptionRowMapper {
  const TranscriptionRowMapper();

  ScannedDocumentTranscriptionModel? maybeModel(
    ScannedDocumentTranscriptionsDbModelData? row,
  ) {
    return row == null ? null : model(row);
  }

  ScannedDocumentTranscriptionModel model(
    ScannedDocumentTranscriptionsDbModelData row,
  ) {
    return ScannedDocumentTranscriptionModel(
      id: row.id,
      docId: row.docId,
      relativePath: row.relativePath,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      ext: p.extension(row.relativePath).replaceFirst('.', ''),
      timeMsToTranscribe: row.timeMsToTranscribe,
      timeMsToRead: row.timeMsToRead,
      wordCount: row.wordCount,
    );
  }

  List<ScannedDocumentTranscriptionModel> models(
    List<ScannedDocumentTranscriptionsDbModelData> rows,
  ) {
    return [for (final row in rows) model(row)];
  }
}
