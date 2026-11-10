import 'package:drift/drift.dart';
import 'package:my_reviewer/src/db/app_database.dart';
import 'package:my_reviewer/src/db/models/docs_models.dart';
import 'package:my_reviewer/src/db/views/docs_views.dart';

part "docs_dao.g.dart";

@DriftAccessor(
  tables: [ScannedDocuments, ScannedDocumentsGroups],
  views: [ScannedDocumentsView, ScannedGroupDocCount],
)
class ScannedDocumentsDao extends DatabaseAccessor<AppDatabase>
    with _$ScannedDocumentsDaoMixin {
  ScannedDocumentsDao(super.attachedDatabase);

  /// Saves session records to SQLite and executes file operations inside the transaction.
  /// If [onFileStorage] throws an error, SQLite automatically rolls back all DB writes.
  Future<void> saveScanSession({
    required ScannedDocumentsGroupsCompanion group,
    required List<ScannedDocumentsCompanion> documents,
    required Future<void> Function() onFileStorage,
  }) async {
    await transaction(() async {
      await into(scannedDocumentsGroups).insert(group);
      await batch((b) {
        b.insertAll(scannedDocuments, documents);
      });
      await onFileStorage();
    });
  }

  /// Permanently deletes an individual document from DB and disk atomically.
  Future<void> hardDeleteDocument(
    String docId, {
    required Future<void> Function(String absolutePath) onDeleteFile,
  }) async {
    await transaction(() async {
      final doc = await (select(
        scannedDocuments,
      )..where((t) => t.id.equals(docId))).getSingle();

      await (delete(scannedDocuments)..where((t) => t.id.equals(docId))).go();
      await onDeleteFile(doc.absoluteImagePath);
    });
  }

  /// Permanently deletes a group and all associated documents from DB and disk atomically.
  /// The [onDeleteFiles] callback is invoked with the
  /// absolute paths of all documents and the group's folder path for cleanup.
  Future<void> hardDeleteGroup(
    String groupId, {
    required Future<void> Function(
      List<String> absolutePaths,
      String groupFolderPath,
    )
    onDeleteFiles,
  }) async {
    await transaction(() async {
      final group = await (select(
        scannedDocumentsGroups,
      )..where((t) => t.id.equals(groupId))).getSingle();
      final docs = await (select(
        scannedDocuments,
      )..where((t) => t.groupId.equals(groupId))).get();
      final filePaths = docs.map((d) => d.absoluteImagePath).toList();

      await (delete(
        scannedDocumentsGroups,
      )..where((t) => t.id.equals(groupId))).go();
      await onDeleteFiles(filePaths, group.absoluteFolderPath);
    });
  }

  /// Fetch all active (non-deleted) groups ordered by creation date.
  Future<List<ScannedDocumentsGroup>> getAllActiveGroups() {
    return (select(scannedDocumentsGroups)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Reactive stream of active groups for continuous UI updates.
  Stream<List<ScannedDocumentsGroup>> watchActiveGroups() {
    return (select(scannedDocumentsGroups)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Get non-deleted documents for a specific group.
  Future<List<ScannedDocument>> getDocumentsForGroup(String groupId) {
    return (select(scannedDocuments)
          ..where((t) => t.groupId.equals(groupId) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Reactive stream of documents in a specific group.
  Stream<List<ScannedDocument>> watchDocumentsForGroup(String groupId) {
    return (select(scannedDocuments)
          ..where((t) => t.groupId.equals(groupId) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  /// Query groups along with their live document count via `ScannedGroupDocCount` view.
  Stream<List<ScannedGroupDocCountData>> watchGroupsWithDocCount() {
    return select(scannedGroupDocCount).watch();
  }

  Future<int> updateGroupName(String groupId, String newName) {
    return (update(
      scannedDocumentsGroups,
    )..where((t) => t.id.equals(groupId))).write(
      ScannedDocumentsGroupsCompanion(
        name: Value(newName),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update document name and set `updatedAt` timestamp.
  Future<int> updateDocumentName(String docId, String newName) {
    return (update(scannedDocuments)..where((t) => t.id.equals(docId))).write(
      ScannedDocumentsCompanion(
        name: Value(newName),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Soft-delete a group and all associated documents in a transaction.
  Future<void> softDeleteGroup(String groupId) async {
    final now = DateTime.now();
    await transaction(() async {
      await (update(
        scannedDocumentsGroups,
      )..where((t) => t.id.equals(groupId))).write(
        ScannedDocumentsGroupsCompanion(
          isDeleted: const Value(true),
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await (update(
        scannedDocuments,
      )..where((t) => t.groupId.equals(groupId))).write(
        ScannedDocumentsCompanion(
          isDeleted: const Value(true),
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    });
  }

  /// Soft-delete an individual document.
  Future<int> softDeleteDocument(String docId) {
    final now = DateTime.now();
    return (update(scannedDocuments)..where((t) => t.id.equals(docId))).write(
      ScannedDocumentsCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }
}
