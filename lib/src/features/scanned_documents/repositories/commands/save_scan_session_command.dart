import 'package:drift/drift.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_dao.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_groups_dao.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/pending_scan_page.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/scanned_document_layout.dart';
import 'package:my_reviewer/src/features/scanned_documents/utils/unique_name_allocator.dart';
import 'package:my_reviewer/src/shared/db/app_database.dart';
import 'package:my_reviewer/src/shared/models/task.dart';
import 'package:my_reviewer/src/shared/services/storage/file_journal.dart';
import 'package:my_reviewer/src/shared/services/storage/i_file_storage_service.dart';

class SaveScanSessionCommand {
  const SaveScanSessionCommand({
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

  Future<void> execute({
    required String groupId,
    required String groupName,
    required List<PendingScanPage> pages,
    String? customFolderName,
    MyReviewerTaskProgressCallback? onProgress,
  }) async {
    if (pages.isEmpty) {
      throw ArgumentError('Pages list cannot be empty');
    }

    onProgress?.call(const TaskProgress.preparing());

    final folderName = await layout.claimFolderName(
      customFolderName ?? groupName,
      groupId,
    );
    final groupDir = await storage.ensureDirectory(
      layout.folderSegments(folderName),
    );
    final GroupFolder folder = (
      name: folderName,
      relative: layout.relativePath(folderName),
      absolute: groupDir.path,
    );
    final journal = FileJournal(storage);

    try {
      final planned = layout.planNewPages(
        pages,
        groupName: groupName,
        folder: folder,
        names: UniqueNameAllocator(const []),
      );
      final counter = TaskProgressCounter(
        total: planned.length,
        onProgress: onProgress,
      );

      await db.transaction(() async {
        await groupsDao.insertGroup(
          ScannedDocumentGroupsDbModelCompanion.insert(
            id: Value(groupId),
            name: groupName,
            relativePath: folder.relative,
          ),
        );

        await docsDao.insertDocuments([
          for (final page in planned) _insertCompanion(groupId, page),
        ]);

        for (final page in planned) {
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

      storage.deleteQuietlyBatch(pages.map((p) => p.sourceAbsolutePath));
    } catch (_) {
      await journal.rollback();
      storage.deleteQuietly(folder.relative, recursive: true);

      rethrow;
    }
  }

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
