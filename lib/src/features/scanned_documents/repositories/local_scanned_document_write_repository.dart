import "package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_dao.dart";
import "package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_groups_dao.dart";
import "package:my_reviewer/src/features/scanned_documents/models/pending_scan_page.dart";

import "package:my_reviewer/src/features/scanned_documents/models/scanned_document_model.dart";
import "package:my_reviewer/src/features/scanned_documents/repositories/commands/save_scan_session_command.dart";
import "package:my_reviewer/src/features/scanned_documents/repositories/commands/update_scan_session_command.dart";
import "package:my_reviewer/src/shared/db/app_database.dart";

import "package:my_reviewer/src/shared/models/task.dart";
import "package:my_reviewer/src/shared/services/storage/i_file_storage_service.dart";

import "i_scanned_document_write_repository.dart";
import "scanned_document_layout.dart";

class LocalScannedDocumentWriteRepository
    implements IScannedDocumentWriteRepository {
  LocalScannedDocumentWriteRepository({
    required this.db,
    required this.groupsDao,
    required this.docsDao,
    required this.storageService,
  }) : _layout = ScannedDocumentLayout(storageService);

  final AppDatabase db;
  final ScannedDocumentGroupsDao groupsDao;
  final ScannedDocumentDao docsDao;
  final IFileStorageService storageService;
  final ScannedDocumentLayout _layout;

  @override
  Future<void> deleteScannedDocument(String documentId) async {
    await db.transaction(() async {
      final doc = await docsDao.getDocument(documentId);

      await docsDao.deleteDocument(documentId);

      final absolutePath = await storageService.resolveAbsolutePath(
        doc.relativePath,
      );

      await storageService.delete(absolutePath);
    });
  }

  @override
  Future<void> deleteScannedDocumentGroup(String groupId) async {
    await db.transaction(() async {
      final group = await groupsDao.getGroup(groupId);

      await groupsDao.deleteGroup(groupId);

      final absolutePath = await storageService.resolveAbsolutePath(
        group.relativePath,
      );

      await storageService.delete(absolutePath, recursive: true);
    });
  }

  @override
  Future<void> saveScannedDocuments({
    required String groupId,
    required String groupName,
    required List<PendingScanPage> pages,
    String? customFolderName,
    MyReviewerTaskProgressCallback? onProgress,
  }) {
    return SaveScanSessionCommand(
      db: db,
      groupsDao: groupsDao,
      docsDao: docsDao,
      storage: storageService,
      layout: _layout,
    ).execute(
      groupId: groupId,
      groupName: groupName,
      pages: pages,
      customFolderName: customFolderName,
      onProgress: onProgress,
    );
  }

  @override
  Future<void> updateScannedDocument({
    required String documentId,
    required String newDocumentName,
  }) => docsDao.updateDocumentName(documentId, newDocumentName);

  @override
  Future<List<String>> updateScannedDocumentGroup({
    required String groupId,
    required String groupName,
    required List<ScannedDocumentModel> existingDocuments,
    required List<PendingScanPage> newPages,
    MyReviewerTaskProgressCallback? onProgress,
  }) {
    return UpdateScanSessionCommand(
      db: db,
      groupsDao: groupsDao,
      docsDao: docsDao,
      storage: storageService,
      layout: _layout,
    ).execute(
      groupId: groupId,
      groupName: groupName,
      existingDocuments: existingDocuments,
      newPages: newPages,
      onProgress: onProgress,
    );
  }

  @override
  Future<void> updateScannedDocumentGroupName({
    required String groupId,
    required String newGroupName,
  }) => groupsDao.updateGroupName(groupId, newGroupName);
}
