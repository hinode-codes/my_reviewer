import 'package:drift/drift.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_dao.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_groups_dao.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/pending_scan_page.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/scanned_document_layout.dart';
import 'package:my_reviewer/src/features/scanned_documents/utils/unique_name_allocator.dart';
import 'package:my_reviewer/src/shared/db/app_database.dart';
import 'package:my_reviewer/src/shared/models/task.dart';
import 'package:my_reviewer/src/shared/services/storage/file_journal.dart';
import 'package:my_reviewer/src/shared/services/storage/i_file_storage_service.dart';
import 'package:path/path.dart' as p;

class UpdateScanSessionCommand {
  const UpdateScanSessionCommand({
    required this.db,
    required this.groupsDao,
    required this.docsDao,
    required this.storage,
    required this.layout,
  });

  final AppDatabase db;
  final ScannedDocumentGroupsDao groupsDao;
  final ScannedDocumentDao docsDao;
  final IFileStorageService storage;
  final ScannedDocumentLayout layout;

  Future<List<String>> execute({
    required String groupId,
    required String groupName,
    required List<ScannedDocumentModel> existingDocuments,
    required List<PendingScanPage> newPages,
    MyReviewerTaskProgressCallback? onProgress,
  }) async {
    onProgress?.call(const TaskProgress.preparing());

    final group = await groupsDao.getGroup(groupId);
    final storedRows = {
      for (final row in await docsDao.getDocumentsForGroup(groupId))
        row.id: row,
    };

    final oldFolderName = p.basename(group.relativePath);
    final folderName = await layout.claimFolderName(
      groupName,
      groupId,
      current: oldFolderName,
    );
    final relativePath = layout.relativePath(folderName);
    final GroupFolder folder = (
      name: folderName,
      relative: relativePath,
      absolute: await storage.resolveAbsolutePath(relativePath),
    );

    final names = UniqueNameAllocator(const []);
    final existingPlanned = layout.planExistingPages(
      existingDocuments,
      groupName: groupName,
      folder: folder,
      names: names,
    );
    final newPlanned = layout.planNewPages(
      newPages,
      groupName: groupName,
      folder: folder,
      names: names,
      indexOffset: existingDocuments.length,
    );

    final renamedPages = [
      for (final page in existingPlanned)
        if (page.currentFileNameWithExtension !=
            page.targetFileNameWithExtension)
          page,
    ];

    final keptIds = {for (final doc in existingDocuments) doc.id};
    final removedRows = [
      for (final row in storedRows.values)
        if (!keptIds.contains(row.id)) row,
    ];
    final removedIds = [for (final row in removedRows) row.id];
    final removedFiles = [
      for (final row in removedRows)
        (
          from: p.join(folder.relative, p.basename(row.relativePath)),
          staging: p.join(folder.relative, '.renaming_${row.id}'),
        ),
    ];

    final now = DateTime.now();
    final groupUpdate =
        (group.name == groupName && folder.name == oldFolderName)
        ? null
        : ScannedDocumentGroupsDbModelCompanion(
            name: Value(groupName),
            relativePath: Value(folder.relative),
            updatedAt: Value(now),
          );

    final documentUpdates = {
      for (final page in existingPlanned)
        if (_hasChanged(storedRows[page.id], page))
          page.id: ScannedDocumentsDbModelCompanion(
            name: Value(page.name),
            relativePath: Value(page.relativePath),
            updatedAt: Value(now),
          ),
    };

    final counter = TaskProgressCounter(
      total: removedFiles.length + renamedPages.length + newPlanned.length,
      onProgress: onProgress,
    );
    final journal = FileJournal(storage);

    try {
      await db.transaction(() async {
        if (groupUpdate != null) {
          await groupsDao.updateGroup(groupId, groupUpdate);
        }

        for (final id in removedIds) {
          await docsDao.deleteDocument(id);
        }

        for (final entry in documentUpdates.entries) {
          await docsDao.updateDocument(entry.key, entry.value);
        }

        if (newPlanned.isNotEmpty) {
          await docsDao.insertDocuments([
            for (final page in newPlanned) _insertCompanion(groupId, page),
          ]);
        }

        if (folder.relative != group.relativePath) {
          await journal.move(group.relativePath, folder.relative);
        }

        for (final file in removedFiles) {
          counter.next();
          await journal.move(file.from, file.staging);
        }

        await journal.moveAllViaStaging([
          for (final page in renamedPages)
            (
              from: p.join(folder.relative, page.currentFileNameWithExtension),
              staging: p.join(folder.relative, '.renaming_${page.id}'),
              to: page.relativePath,
            ),
        ], onEachFinalMove: counter.next);

        for (final page in newPlanned) {
          counter.next();

          final createdRelativePath = await storage.saveFile(
            page.sourceAbsolutePath!,
            layout.folderSegments(folder.name),
            fileNameWithoutExtension: page.fileNameWithoutExtension,
          );

          journal.recordCreated(createdRelativePath);
        }
      });

      onProgress?.call(const TaskProgress.finishing());

      // Staged removed files live in storage root (relative paths),
      // while temp scan captures live outside storage root (absolute paths).
      storage.deleteQuietlyBatch([
        for (final file in removedFiles)
          await storage.resolveAbsolutePath(file.staging),
        ...newPages.map((p) => p.sourceAbsolutePath),
      ]);

      return removedIds;
    } catch (_) {
      await journal.rollback();

      rethrow;
    }
  }

  bool _hasChanged(ScannedDocumentsDbModelData? stored, PlannedPage page) =>
      stored == null ||
      stored.name != page.name ||
      stored.relativePath != page.relativePath;

  ScannedDocumentsDbModelCompanion _insertCompanion(
    String groupId,
    PlannedPage page,
  ) {
    return ScannedDocumentsDbModelCompanion.insert(
      id: Value(page.id),
      groupId: groupId,
      name: page.name,
      relativePath: page.relativePath,
      ext: page.ext,
    );
  }
}
