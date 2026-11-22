import 'package:drift/drift.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/models/scanned_document_groups_db_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/models/scanned_documents_db_model.dart';
import 'package:my_reviewer/src/shared/db/app_database.dart';

part "scanned_document_dao.g.dart";

@DriftAccessor(tables: [ScannedDocumentsDbModel, ScannedDocumentGroupsDbModel])
class ScannedDocumentDao extends DatabaseAccessor<AppDatabase>
    with _$ScannedDocumentDaoMixin {
  ScannedDocumentDao(super.attachedDatabase);

  Future<int> deleteDocument(String docId) {
    return (delete(
      scannedDocumentsDbModel,
    )..where((t) => t.id.equals(docId))).go();
  }

  Future<ScannedDocumentsDbModelData> getDocument(String docId) {
    return (select(
      scannedDocumentsDbModel,
    )..where((t) => t.id.equals(docId))).getSingle();
  }

  Future<List<ScannedDocumentsDbModelData>> getDocumentsForGroup(
    String groupId,
  ) {
    return (select(scannedDocumentsDbModel)
          ..where((t) => t.groupId.equals(groupId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<bool> hasDocuments(String groupId) async {
    final exists = existsQuery(
      select(scannedDocumentsDbModel)..where((t) => t.groupId.equals(groupId)),
    );
    final row = await selectExpressions([exists]).getSingle();

    return row.read(exists)!;
  }

  Future<void> insertDocuments(
    List<ScannedDocumentsDbModelCompanion> documents,
  ) async {
    if (documents.isEmpty) {
      return;
    }

    await batch((b) {
      b.insertAll(scannedDocumentsDbModel, documents);
    });
  }

  Future<int> updateDocument(
    String docId,
    ScannedDocumentsDbModelCompanion companion,
  ) {
    return (update(
      scannedDocumentsDbModel,
    )..where((t) => t.id.equals(docId))).write(companion);
  }

  Future<int> updateDocumentName(String docId, String newName) {
    return updateDocument(
      docId,
      ScannedDocumentsDbModelCompanion(
        name: Value(newName),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Stream<List<ScannedDocumentsDbModelData>> watchDocumentsForGroup(
    String groupId,
  ) {
    return (select(scannedDocumentsDbModel)
          ..where((t) => t.groupId.equals(groupId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }
}
