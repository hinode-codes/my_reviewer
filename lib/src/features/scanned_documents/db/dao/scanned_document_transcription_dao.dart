import 'package:drift/drift.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/models/scanned_document_transcriptions_db_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/models/scanned_documents_db_model.dart';
import 'package:my_reviewer/src/shared/db/app_database.dart';

part 'scanned_document_transcription_dao.g.dart';

@DriftAccessor(
  tables: [ScannedDocumentTranscriptionsDbModel, ScannedDocumentsDbModel],
)
class ScannedDocumentTranscriptionDao extends DatabaseAccessor<AppDatabase>
    with _$ScannedDocumentTranscriptionDaoMixin {
  ScannedDocumentTranscriptionDao(super.db);

  Future<ScannedDocumentTranscriptionsDbModelData?> getByDocId(String docId) {
    return (select(
      scannedDocumentTranscriptionsDbModel,
    )..where((t) => t.docId.equals(docId))).getSingleOrNull();
  }

  Stream<ScannedDocumentTranscriptionsDbModelData?> watchByDocId(String docId) {
    return (select(
      scannedDocumentTranscriptionsDbModel,
    )..where((t) => t.docId.equals(docId))).watchSingleOrNull();
  }

  Future<List<ScannedDocumentTranscriptionsDbModelData>> getByGroupId(
    String groupId,
  ) {
    final query = select(scannedDocumentTranscriptionsDbModel).join([
      innerJoin(
        scannedDocumentsDbModel,
        scannedDocumentsDbModel.id.equalsExp(
          scannedDocumentTranscriptionsDbModel.docId,
        ),
      ),
    ])..where(scannedDocumentsDbModel.groupId.equals(groupId));

    return query
        .map((row) => row.readTable(scannedDocumentTranscriptionsDbModel))
        .get();
  }

  Stream<List<ScannedDocumentTranscriptionsDbModelData>> watchByGroupId(
    String groupId,
  ) {
    final query = select(scannedDocumentTranscriptionsDbModel).join([
      innerJoin(
        scannedDocumentsDbModel,
        scannedDocumentsDbModel.id.equalsExp(
          scannedDocumentTranscriptionsDbModel.docId,
        ),
      ),
    ])..where(scannedDocumentsDbModel.groupId.equals(groupId));

    return query
        .map((row) => row.readTable(scannedDocumentTranscriptionsDbModel))
        .watch();
  }

  Future<bool> hasTranscription(String docId) async {
    final count =
        await (selectOnly(scannedDocumentTranscriptionsDbModel)
              ..addColumns([scannedDocumentTranscriptionsDbModel.id.count()])
              ..where(scannedDocumentTranscriptionsDbModel.docId.equals(docId)))
            .map(
              (row) =>
                  row.read(scannedDocumentTranscriptionsDbModel.id.count()) ??
                  0,
            )
            .getSingle();

    return count > 0;
  }

  Future<void> upsertTranscription(
    ScannedDocumentTranscriptionsDbModelCompanion entry,
  ) {
    return into(scannedDocumentTranscriptionsDbModel).insert(
      entry,
      onConflict: DoUpdate(
        (_) => entry,
        target: [scannedDocumentTranscriptionsDbModel.docId],
      ),
    );
  }

  Future<void> updateTranscription(
    String docId,
    ScannedDocumentTranscriptionsDbModelCompanion entry,
  ) {
    return (update(
      scannedDocumentTranscriptionsDbModel,
    )..where((t) => t.docId.equals(docId))).write(entry);
  }

  Future<int> deleteByDocId(String docId) {
    return (delete(
      scannedDocumentTranscriptionsDbModel,
    )..where((t) => t.docId.equals(docId))).go();
  }
}
