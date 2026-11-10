import 'package:drift/drift.dart';
import 'package:my_reviewer/src/db/app_database.dart';
import 'package:my_reviewer/src/db/dao/docs_dao.dart';
import 'package:my_reviewer/src/models/docs_delete_state.dart';
import 'package:my_reviewer/src/models/docs_models.dart';
import 'package:my_reviewer/src/models/save_progress.dart';
import 'package:my_reviewer/src/repositories/scanned_document_repository.dart';
import 'package:my_reviewer/src/services/file_storage_service.dart';
import 'package:my_reviewer/src/utils/string.dart';
import 'package:path/path.dart' as p;

class _FileSavePayload {
  final String tmpSrc;
  final String fileNameWithoutExt;

  const _FileSavePayload({
    required this.tmpSrc,
    required this.fileNameWithoutExt,
  });
}

class LocalScannedDocumentRepository implements IScannedDocumentRespository {
  final ScannedDocumentsDao dao;
  final FileStorageService storageService;

  static const String _rootFolder = 'scanned_documents';

  const LocalScannedDocumentRepository({
    required this.dao,
    required this.storageService,
  });

  @override
  Future<void> saveScannedDocuments({
    required String groupID,
    required String groupName,
    required List<ScannedDocumentModel> documents,
    String? customFolderName,
    SaveProgressCallback? onProgress,
  }) async {
    if (documents.isEmpty) {
      throw ArgumentError('Documents list cannot be empty');
    }

    onProgress?.call(const SaveProgress(stage: SaveStage.preparing));

    final folderName = sanitizeFileName(customFolderName ?? groupName, groupID);
    final relativeFolderPath = p.join(_rootFolder, folderName);
    final groupDir = await storageService.ensureDirectory([
      _rootFolder,
      folderName,
    ]);
    final createdFiles = <String>[];

    try {
      final groupCompanion = ScannedDocumentsGroupsCompanion.insert(
        id: Value(groupID),
        name: groupName,
        relativeFolderPath: relativeFolderPath,
        absoluteFolderPath: groupDir.path,
      );

      final docCompanions = <ScannedDocumentsCompanion>[];
      final fileSavePayloads = <_FileSavePayload>[];

      for (int i = 0; i < documents.length; ++i) {
        final doc = documents[i];
        final docID = doc.id;
        final safeFileName = sanitizeFileName(
          doc.name,
          ScannedDocumentModel.fallbackFileName(groupName, i),
        );
        final fileNameWithExt = '$safeFileName.${doc.ext}';
        final relativeFilePath = p.join(relativeFolderPath, fileNameWithExt);
        final absoluteFilePath = p.join(groupDir.path, fileNameWithExt);

        docCompanions.add(
          ScannedDocumentsCompanion.insert(
            id: Value(docID),
            groupId: groupID,
            name: doc.name,
            relativeImagePath: relativeFilePath,
            absoluteImagePath: absoluteFilePath,
          ),
        );

        fileSavePayloads.add(
          _FileSavePayload(
            tmpSrc: doc.absoluteFilePath,
            fileNameWithoutExt: safeFileName,
          ),
        );
      }

      await dao.saveScanSession(
        group: groupCompanion,
        documents: docCompanions,
        onFileStorage: () async {
          for (int i = 0; i < fileSavePayloads.length; ++i) {
            final payload = fileSavePayloads[i];

            onProgress?.call(
              SaveProgress(
                stage: SaveStage.savingFiles,
                currentFile: i + 1,
                totalFiles: fileSavePayloads.length,
              ),
            );

            final result = await storageService.saveFile(
              sourcePath: payload.tmpSrc,
              targetSubDirectories: [_rootFolder, folderName],
              fileNameWithoutExtension: payload.fileNameWithoutExt,
            );

            createdFiles.add(result.absolutePath);
          }
        },
      );

      onProgress?.call(const SaveProgress(stage: SaveStage.finishing));

      storageService.deleteQuietlyBatch(
        documents.map((d) => d.absoluteFilePath),
      );
    } catch (err) {
      storageService.deleteQuietlyBatch(createdFiles);
      storageService.deleteQuietly(groupDir.path, recursive: true);

      rethrow;
    }
  }

  @override
  Stream<List<ScannedDocumentGroupModel>> watchScannedDocumentGroups() {
    return dao.watchActiveGroups().asyncMap((groupRows) async {
      final result = <ScannedDocumentGroupModel>[];

      for (final group in groupRows) {
        final docRows = await dao.getDocumentsForGroup(group.id);
        final docs = await _mapDocRowsToModels(docRows);

        result.add(
          ScannedDocumentGroupModel(
            id: group.id,
            groupName: group.name,
            relativeFolderPath: group.relativeFolderPath,
            absoluteFolderPath: group.absoluteFolderPath,
            documents: docs,
            createdAt: group.createdAt,
            updatedAt: group.updatedAt,
          ),
        );
      }

      return result;
    });
  }

  @override
  Stream<List<ScannedDocumentModel>> watchScannedDocumentsByGroupId(
    String groupId,
  ) {
    return dao
        .watchDocumentsForGroup(groupId)
        .asyncMap((docRows) => _mapDocRowsToModels(docRows));
  }

  @override
  Future<List<ScannedDocumentGroupModel>> getAllScannedDocumentGroups() async {
    final groupRows = await dao.getAllActiveGroups();
    final result = <ScannedDocumentGroupModel>[];

    for (final group in groupRows) {
      final docRows = await dao.getDocumentsForGroup(group.id);
      final docs = await _mapDocRowsToModels(docRows);

      result.add(
        ScannedDocumentGroupModel(
          id: group.id,
          groupName: group.name,
          relativeFolderPath: group.relativeFolderPath,
          absoluteFolderPath: group.absoluteFolderPath,
          documents: docs,
          createdAt: group.createdAt,
          updatedAt: group.updatedAt,
        ),
      );
    }

    return result;
  }

  @override
  Future<List<ScannedDocumentModel>> getScannedDocumentsByGroupId(
    String groupId,
  ) async {
    final docRows = await dao.getDocumentsForGroup(groupId);
    return _mapDocRowsToModels(docRows);
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
  Future<void> deleteScannedDocument(
    String documentId, {
    bool softDelete = false,
  }) async {
    if (softDelete) {
      await dao.softDeleteDocument(documentId);
    } else {
      await dao.hardDeleteDocument(
        documentId,
        onDeleteFile: (relativeOrAbsolutePath) async {
          final absolutePath = await storageService.resolveAbsolutePath(
            relativeOrAbsolutePath,
          );
          await storageService.delete(absolutePath);
        },
      );
    }
  }

  Future<void> deleteScannedDocumentGroups(
    List<String> groupIds, {
    bool softDelete = false,
    DeleteProgressCallback? onProgress,
  }) async {
    if (groupIds.isEmpty) {
      return;
    }

    onProgress?.call(const DeleteProgress(stage: DeleteStage.preparing));

    try {
      for (int i = 0; i < groupIds.length; ++i) {
        final id = groupIds[i];
        onProgress?.call(
          DeleteProgress(
            stage: DeleteStage.deletingFiles,
            currentGroup: i + 1,
            totalGroups: groupIds.length,
          ),
        );

        await deleteScannedDocumentGroup(id, softDelete: softDelete);
      }

      onProgress?.call(const DeleteProgress(stage: DeleteStage.finishing));
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> deleteScannedDocumentGroup(
    String groupId, {
    bool softDelete = false,
  }) async {
    if (softDelete) {
      await dao.softDeleteGroup(groupId);
    } else {
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
  }

  /// Maps database entities to domain models while dynamically resolving runtime absolute paths.
  Future<List<ScannedDocumentModel>> _mapDocRowsToModels(
    List<ScannedDocument> rows,
  ) async {
    final models = <ScannedDocumentModel>[];

    for (final row in rows) {
      final runtimeAbsolutePath = await storageService.resolveAbsolutePath(
        row.relativeImagePath,
      );

      final ext = p.extension(row.relativeImagePath).replaceFirst('.', '');

      models.add(
        ScannedDocumentModel(
          id: row.id,
          groupId: row.groupId,
          name: row.name,
          relativeFilePath: row.relativeImagePath,
          absoluteFilePath: runtimeAbsolutePath,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
          ext: ext,
        ),
      );
    }

    return models;
  }
}
