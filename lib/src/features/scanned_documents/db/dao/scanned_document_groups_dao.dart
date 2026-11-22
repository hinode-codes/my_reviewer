import 'package:drift/drift.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/views/scanned_document_group_count.dart';
import 'package:my_reviewer/src/shared/db/app_database.dart';

import '../models/scanned_document_groups_db_model.dart';

part "scanned_document_groups_dao.g.dart";

@DriftAccessor(
  tables: [ScannedDocumentGroupsDbModel],
  views: [ScannedDocumentGroupCount],
)
class ScannedDocumentGroupsDao extends DatabaseAccessor<AppDatabase>
    with _$ScannedDocumentGroupsDaoMixin {
  ScannedDocumentGroupsDao(super.attachedDatabase);

  Future<int> deleteGroup(String groupId) {
    return (delete(
      scannedDocumentGroupsDbModel,
    )..where((t) => t.id.equals(groupId))).go();
  }

  /// Fetch all groups ordered by creation date.
  Future<List<ScannedDocumentGroupsDbModelData>> getAllActiveGroups() {
    return (select(
      scannedDocumentGroupsDbModel,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  Future<ScannedDocumentGroupsDbModelData> getGroup(String groupId) {
    return (select(
      scannedDocumentGroupsDbModel,
    )..where((t) => t.id.equals(groupId))).getSingle();
  }

  Future<void> insertGroup(ScannedDocumentGroupsDbModelCompanion group) {
    return into(scannedDocumentGroupsDbModel).insert(group);
  }

  Future<int> updateGroup(
    String groupId,
    ScannedDocumentGroupsDbModelCompanion companion,
  ) {
    return (update(
      scannedDocumentGroupsDbModel,
    )..where((t) => t.id.equals(groupId))).write(companion);
  }

  Future<int> updateGroupName(String groupId, String newName) {
    return updateGroup(
      groupId,
      ScannedDocumentGroupsDbModelCompanion(
        name: Value(newName),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Stream<String?> watchGroupName(String groupId) {
    return (select(scannedDocumentGroupsDbModel)
          ..where((t) => t.id.equals(groupId)))
        .map((row) => row.name)
        .watchSingleOrNull();
  }

  Stream<List<ScannedDocumentGroupsDbModelData>> watchAllActiveGroups() {
    return (select(
      scannedDocumentGroupsDbModel,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  Stream<List<ScannedDocumentGroupCountData>> watchGroupsWithDocCount() {
    return select(scannedDocumentGroupCount).watch();
  }
}
