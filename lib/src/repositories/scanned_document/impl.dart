import 'package:drift/drift.dart';
import 'package:my_reviewer/src/db/app_database.dart';
import 'package:my_reviewer/src/db/dao/docs_dao.dart';
import 'package:my_reviewer/src/models/deletion.dart';
import 'package:my_reviewer/src/models/docs/view_models.dart';
import 'package:my_reviewer/src/models/operation.dart';
import 'package:my_reviewer/src/services/file_change_journal.dart';
import 'package:my_reviewer/src/services/file_storage_service.dart';
import 'package:my_reviewer/src/utils/unique_name_allocator.dart';
import 'package:path/path.dart' as p;

import 'interface.dart';
import 'layout.dart';
import 'row_mapper.dart';

/// Scanned documents as drift rows plus one image file per page, in one
/// folder per group.
///
/// Every write touches both the database and the disk. The DAO runs the disk
/// work from inside its transaction (`onFileStorage`), and each disk change
/// goes through a [FileChangeJournal] so it can be undone if the write fails.
/// Naming lives in [ScannedDocumentLayout], row mapping in
/// [ScannedDocumentRowMapper].
class LocalScannedDocumentRepository implements IScannedDocumentRepository {
  LocalScannedDocumentRepository({
    required this.dao,
    required this.storageService,
  }) : _layout = ScannedDocumentLayout(storageService),
       _mapper = ScannedDocumentRowMapper(dao: dao, storage: storageService);

  final ScannedDocumentsDao dao;
  final FileStorageService storageService;
  final ScannedDocumentLayout _layout;
  final ScannedDocumentRowMapper _mapper;

  @override
  Stream<String?> watchScannedDocumentGroupName(String groupId) {
    return dao.watchGroupName(groupId);
  }

  /// Saves a new group from freshly scanned pages.
  ///
  /// Claims a folder, copies each scanner temp file into it, then deletes
  /// the temp files. On failure, the copies and the folder are removed.
  @override
  Future<void> saveScannedDocuments({
    required String groupID,
    required String groupName,
    required List<ScannedDocumentModel> documents,
    String? customFolderName,
    OperationProgressCallback? onProgress,
  }) async {
    if (documents.isEmpty) {
      throw ArgumentError('Documents list cannot be empty');
    }

    onProgress?.call(const OperationProgress(stage: OperationStage.preparing));

    final folderName = await _layout.claimFolderName(
      customFolderName ?? groupName,
      groupID,
    );
    final groupDir = await storageService.ensureDirectory(
      _layout.folderSegments(folderName),
    );
    final GroupFolder folder = (
      name: folderName,
      relative: _layout.relativeFolderPath(folderName),
      absolute: groupDir.path,
    );
    final journal = FileChangeJournal(storageService);

    try {
      final pages = _layout.planPages(
        documents,
        groupName: groupName,
        folder: folder,
        names: UniqueNameAllocator(const []),
      );

      await dao.saveScanSession(
        group: ScannedDocumentsGroupsCompanion.insert(
          id: Value(groupID),
          name: groupName,
          relativeFolderPath: folder.relative,
          absoluteFolderPath: folder.absolute,
        ),
        documents: [for (final page in pages) _insertCompanion(groupID, page)],
        onFileStorage: () => _copyPages(
          pages,
          folder: folder,
          journal: journal,
          counter: ProgressCounter(total: pages.length, onProgress: onProgress),
        ),
      );

      onProgress?.call(
        const OperationProgress(stage: OperationStage.finishing),
      );

      storageService.deleteQuietlyBatch(
        documents.map((d) => d.absoluteFilePath),
      );
    } catch (err) {
      await journal.rollback();
      storageService.deleteQuietly(groupDir.path, recursive: true);

      rethrow;
    }
  }

  /// Saves an edit of an existing group: a new name, removed, renamed or
  /// reordered pages, and pages added from the scanner.
  ///
  /// 1. Plan: claim the folder name and every page's file name up front.
  /// 2. Diff: only rows whose name or path changed are written; stored rows
  ///    missing from [existingDocuments] are the pages the user removed.
  /// 3. Write: inside the DAO's transaction, move the folder if its name
  ///    changed, move removed pages aside, rename pages through staging
  ///    names, copy the new pages.
  /// 4. Clean up: delete the removed pages' files and the new pages'
  ///    scanner temp files.
  ///
  /// If anything fails, the journal puts the disk back to match the rolled
  /// back database.
  @override
  Future<void> updateScannedDocumentGroup({
    required String groupId,
    required String groupName,
    required List<ScannedDocumentModel> existingDocuments,
    required List<ScannedDocumentModel> newDocuments,
    OperationProgressCallback? onProgress,
  }) async {
    onProgress?.call(const OperationProgress(stage: OperationStage.preparing));

    final group = await dao.getGroup(groupId);
    final storedRows = {
      for (final row in await dao.getDocumentsForGroup(groupId)) row.id: row,
    };

    final oldFolderName = p.basename(group.relativeFolderPath);
    final folderName = await _layout.claimFolderName(
      groupName,
      groupId,
      current: oldFolderName,
    );
    final oldFolderPath = await storageService.resolveAbsolutePath(
      group.relativeFolderPath,
    );
    final relativeFolderPath = _layout.relativeFolderPath(folderName);
    final GroupFolder folder = (
      name: folderName,
      relative: relativeFolderPath,
      absolute: await storageService.resolveAbsolutePath(relativeFolderPath),
    );

    // Planned from a clean slate rather than from what is on disk, so two
    // pages can trade names. Safe because the folder holds only this group.
    final names = UniqueNameAllocator(const []);
    final existingPages = _layout.planPages(
      existingDocuments,
      groupName: groupName,
      folder: folder,
      names: names,
    );
    final newPages = _layout.planPages(
      newDocuments,
      groupName: groupName,
      folder: folder,
      names: names,
      indexOffset: existingDocuments.length,
    );
    final renamedPages = [
      for (final page in existingPages)
        if (page.currentFileNameWithExtension !=
            page.targetFileNameWithExtension)
          page,
    ];

    // Stored rows the draft no longer has: the pages the user removed.
    final keptIds = {for (final doc in existingDocuments) doc.id};
    final removedRows = [
      for (final row in storedRows.values)
        if (!keptIds.contains(row.id)) row,
    ];
    // Each removed page's file, from its current name inside the (possibly
    // moved) folder to the staging path where it waits for the commit.
    final removedFiles = [
      for (final row in removedRows)
        (
          from: p.join(folder.absolute, p.basename(row.relativeImagePath)),
          staging: _layout.stagingPathFor(folder, row.id),
        ),
    ];

    final now = DateTime.now();
    final groupUpdate = _groupUpdate(
      group,
      groupName: groupName,
      folder: folder,
      oldFolderName: oldFolderName,
      now: now,
    );
    final documentUpdates = _documentUpdates(existingPages, storedRows, now);

    final counter = ProgressCounter(
      total: removedFiles.length + renamedPages.length + newPages.length,
      onProgress: onProgress,
    );
    final journal = FileChangeJournal(storageService);

    try {
      await dao.updateScanSession(
        groupId: groupId,
        group: groupUpdate,
        removedDocumentIds: [for (final row in removedRows) row.id],
        documentUpdates: documentUpdates,
        newDocuments: [
          for (final page in newPages) _insertCompanion(groupId, page),
        ],
        onFileStorage: () async {
          if (folder.absolute != oldFolderPath) {
            await journal.move(oldFolderPath, folder.absolute);
          }

          // Before the renames: a kept page may be renamed to a removed
          // page's file name, which must be free by then. Moved rather than
          // deleted, so a failed save can put them back.
          for (final file in removedFiles) {
            counter.next();
            await journal.move(file.from, file.staging);
          }

          // Paths are built after the folder move, inside its new location.
          await journal.moveAllViaStaging([
            for (final page in renamedPages)
              (
                from: p.join(
                  folder.absolute,
                  page.currentFileNameWithExtension,
                ),
                staging: _layout.stagingPathFor(folder, page.document.id),
                to: page.absolutePath,
              ),
          ], onEachFinalMove: counter.next);

          await _copyPages(
            newPages,
            folder: folder,
            journal: journal,
            counter: counter,
          );
        },
      );

      onProgress?.call(
        const OperationProgress(stage: OperationStage.finishing),
      );

      // Clean up. Only the new pages' sources are scanner temp files; the
      // existing pages' paths are the saved images themselves. Removed
      // pages' files are deleted only now that the database has committed.
      storageService.deleteQuietlyBatch([
        ...newDocuments.map((d) => d.absoluteFilePath),
        ...removedFiles.map((file) => file.staging),
      ]);
    } catch (err) {
      await journal.rollback();

      rethrow;
    }
  }

  @override
  Future<void> updateScannedDocumentGroupName({
    required String groupId,
    required String newGroupName,
  }) async {
    await dao.updateGroupName(groupId, newGroupName);
  }

  @override
  Future<void> updateScannedDocument({
    required String documentId,
    required String newDocumentName,
  }) async {
    await dao.updateDocumentName(documentId, newDocumentName);
  }

  @override
  Stream<List<ScannedDocumentGroupModel>> watchScannedDocumentGroups() {
    return dao.watchActiveGroups().asyncMap(_mapper.groups);
  }

  @override
  Stream<List<ScannedDocumentModel>> watchScannedDocumentsByGroupId(
    String groupId,
  ) {
    return dao.watchDocumentsForGroup(groupId).asyncMap(_mapper.documents);
  }

  @override
  Future<List<ScannedDocumentGroupModel>> getAllScannedDocumentGroups() async {
    return _mapper.groups(await dao.getAllActiveGroups());
  }

  @override
  Future<ScannedDocumentGroupModel> getScannedDocumentGroup(
    String groupId,
  ) async {
    return _mapper.group(await dao.getGroup(groupId));
  }

  @override
  Future<List<ScannedDocumentModel>> getScannedDocumentsByGroupId(
    String groupId,
  ) async {
    return _mapper.documents(await dao.getDocumentsForGroup(groupId));
  }

  @override
  Future<void> deleteScannedDocument(String documentId) async {
    await dao.hardDeleteDocument(
      documentId,
      onDeleteFile: (relativePath) async {
        final absolutePath = await storageService.resolveAbsolutePath(
          relativePath,
        );
        await storageService.delete(absolutePath);
      },
    );
  }

  @override
  Future<DeletionOutcome> deleteScannedDocuments(
    String groupId,
    List<String> documentIds, {
    required EmptyGroupPolicy emptyGroup,
    OperationProgressCallback? onProgress,
  }) async {
    onProgress?.call(const OperationProgress(stage: OperationStage.preparing));

    final counter = ProgressCounter(
      total: documentIds.length,
      onProgress: onProgress,
    );

    for (final id in documentIds) {
      counter.next();
      await deleteScannedDocument(id);
    }

    final outcome = await _applyEmptyGroupPolicy(groupId, emptyGroup);

    onProgress?.call(const OperationProgress(stage: OperationStage.finishing));

    return outcome;
  }

  @override
  Future<void> deleteScannedDocumentGroups(
    List<String> groupIds, {
    OperationProgressCallback? onProgress,
  }) async {
    if (groupIds.isEmpty) {
      return;
    }

    onProgress?.call(const OperationProgress(stage: OperationStage.preparing));

    final counter = ProgressCounter(
      total: groupIds.length,
      onProgress: onProgress,
    );

    try {
      for (final id in groupIds) {
        counter.next();

        await deleteScannedDocumentGroup(id);
      }

      onProgress?.call(
        const OperationProgress(stage: OperationStage.finishing),
      );
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> deleteScannedDocumentGroup(String groupId) async {
    await dao.hardDeleteGroup(
      groupId,
      onDeleteFiles: (relativePaths, relativeGroupFolderPath) async {
        final absoluteFolderPath = await storageService.resolveAbsolutePath(
          relativeGroupFolderPath,
        );
        await storageService.delete(absoluteFolderPath, recursive: true);
      },
    );
  }

  Future<DeletionOutcome> _applyEmptyGroupPolicy(
    String groupId,
    EmptyGroupPolicy policy,
  ) async {
    switch (policy) {
      case EmptyGroupPolicy.keepGroup:
        return DeletionOutcome.itemsDeleted;
      case EmptyGroupPolicy.deleteGroup:
        if (await dao.hasDocuments(groupId)) {
          return DeletionOutcome.itemsDeleted;
        }

        await deleteScannedDocumentGroup(groupId);

        return DeletionOutcome.parentDeleted;
    }
  }

  /// Null when neither the name nor the folder changed.
  ScannedDocumentsGroupsCompanion? _groupUpdate(
    ScannedDocumentsGroup group, {
    required String groupName,
    required GroupFolder folder,
    required String oldFolderName,
    required DateTime now,
  }) {
    if (group.name == groupName && folder.name == oldFolderName) {
      return null;
    }

    return ScannedDocumentsGroupsCompanion(
      name: Value(groupName),
      relativeFolderPath: Value(folder.relative),
      absoluteFolderPath: Value(folder.absolute),
      updatedAt: Value(now),
    );
  }

  /// Rows for the pages whose name or path changed, keyed by document id.
  Map<String, ScannedDocumentsCompanion> _documentUpdates(
    List<PlannedPage> pages,
    Map<String, ScannedDocument> storedRows,
    DateTime now,
  ) {
    return {
      for (final page in pages)
        if (_hasChanged(storedRows[page.document.id], page))
          page.document.id: ScannedDocumentsCompanion(
            name: Value(page.document.name),
            relativeImagePath: Value(page.relativePath),
            absoluteImagePath: Value(page.absolutePath),
            updatedAt: Value(now),
          ),
    };
  }

  bool _hasChanged(ScannedDocument? stored, PlannedPage page) =>
      stored == null ||
      stored.name != page.document.name ||
      stored.relativeImagePath != page.relativePath;

  ScannedDocumentsCompanion _insertCompanion(String groupId, PlannedPage page) {
    return ScannedDocumentsCompanion.insert(
      id: Value(page.document.id),
      groupId: groupId,
      name: page.document.name,
      relativeImagePath: page.relativePath,
      absoluteImagePath: page.absolutePath,
    );
  }

  Future<void> _copyPages(
    List<PlannedPage> pages, {
    required GroupFolder folder,
    required FileChangeJournal journal,
    required ProgressCounter counter,
  }) async {
    for (final page in pages) {
      counter.next();

      final result = await storageService.saveFile(
        sourcePath: page.document.absoluteFilePath,
        targetSubDirectories: _layout.folderSegments(folder.name),
        fileNameWithoutExtension: page.fileNameWithoutExtension,
      );

      journal.recordCreated(result.absolutePath);
    }
  }
}