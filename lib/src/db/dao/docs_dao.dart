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
  Stream<String?> watchGroupName(String groupId) {
    return (select(scannedDocumentsGroups)..where((t) => t.id.equals(groupId)))
        .map((row) => row.name)
        .watchSingleOrNull();
  }

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

  /// Updates an existing group, deletes its removed documents, updates the
  /// kept ones and inserts new documents in one transaction, running
  /// [onFileStorage] inside it so a failed file operation rolls every DB
  /// write back.
  Future<void> updateScanSession({
    required String groupId,
    required ScannedDocumentsGroupsCompanion? group,
    required List<String> removedDocumentIds,
    required Map<String, ScannedDocumentsCompanion> documentUpdates,
    required List<ScannedDocumentsCompanion> newDocuments,
    required Future<void> Function() onFileStorage,
  }) async {
    await transaction(() async {
      if (group != null) {
        await (update(
          scannedDocumentsGroups,
        )..where((t) => t.id.equals(groupId))).write(group);
      }

      // Rows only: the caller's onFileStorage moves the files aside, and
      // deletes them once this transaction has committed.
      for (final docId in removedDocumentIds) {
        await (delete(scannedDocuments)..where((t) => t.id.equals(docId))).go();
      }

      for (final entry in documentUpdates.entries) {
        await (update(
          scannedDocuments,
        )..where((t) => t.id.equals(entry.key))).write(entry.value);
      }

      if (newDocuments.isNotEmpty) {
        await batch((b) {
          b.insertAll(scannedDocuments, newDocuments);
        });
      }

      await onFileStorage();
    });
  }

  Future<ScannedDocumentsGroup> getGroup(String groupId) {
    return (select(
      scannedDocumentsGroups,
    )..where((t) => t.id.equals(groupId))).getSingle();
  }

  /// Permanently deletes an individual document from DB and disk atomically.
  ///
  /// [onDeleteFile] gets the stored relative path: the stored absolute path
  /// goes stale on iOS, whose app container path changes across updates.
  Future<void> hardDeleteDocument(
    String docId, {
    required Future<void> Function(String relativePath) onDeleteFile,
  }) async {
    await transaction(() async {
      final doc = await (select(
        scannedDocuments,
      )..where((t) => t.id.equals(docId))).getSingle();

      await (delete(scannedDocuments)..where((t) => t.id.equals(docId))).go();
      await onDeleteFile(doc.relativeImagePath);
    });
  }

  /// Permanently deletes a group and all associated documents from DB and disk atomically.
  /// The [onDeleteFiles] callback is invoked with the relative paths of all
  /// documents and the group's relative folder path for cleanup (relative for
  /// the same iOS reason as [hardDeleteDocument]).
  Future<void> hardDeleteGroup(
    String groupId, {
    required Future<void> Function(
      List<String> relativePaths,
      String relativeGroupFolderPath,
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
      final filePaths = docs.map((d) => d.relativeImagePath).toList();

      await (delete(
        scannedDocumentsGroups,
      )..where((t) => t.id.equals(groupId))).go();
      await onDeleteFiles(filePaths, group.relativeFolderPath);
    });
  }

  /// Fetch all groups ordered by creation date.
  Future<List<ScannedDocumentsGroup>> getAllActiveGroups() {
    return (select(
      scannedDocumentsGroups,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  /// Reactive stream of groups for continuous UI updates.
  Stream<List<ScannedDocumentsGroup>> watchActiveGroups() {
    return customSelect(
      'SELECT 1',
      readsFrom: {scannedDocumentsGroups, scannedDocuments},
    ).watch().asyncMap((_) => getAllActiveGroups());
  }

  /// Get the documents of a specific group.
  Future<List<ScannedDocument>> getDocumentsForGroup(String groupId) {
    return (select(scannedDocuments)
          ..where((t) => t.groupId.equals(groupId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Whether [groupId] still has at least one document.
  ///
  /// A `SELECT EXISTS (...)`: SQLite stops at the first matching row instead
  /// of loading and mapping every document just to check for emptiness.
  Future<bool> hasDocuments(String groupId) async {
    final exists = existsQuery(
      select(scannedDocuments)..where((t) => t.groupId.equals(groupId)),
    );
    final row = await selectExpressions([exists]).getSingle();

    // EXISTS always yields 0 or 1, never NULL.
    return row.read(exists)!;
  }

  /// Reactive stream of documents in a specific group.
  Stream<List<ScannedDocument>> watchDocumentsForGroup(String groupId) {
    return (select(scannedDocuments)
          ..where((t) => t.groupId.equals(groupId))
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
}
