import 'package:my_reviewer/src/models/deletion.dart';
import 'package:my_reviewer/src/models/docs/view_models.dart';
import 'package:my_reviewer/src/models/operation.dart';

abstract class IScannedDocumentRepository {
  Future<void> saveScannedDocuments({
    required String groupID,
    required String groupName,
    required List<ScannedDocumentModel> documents,
    String? customFolderName,
    OperationProgressCallback? onProgress,
  });

  /// Renames the group and [existingDocuments] (in the DB and on disk) and
  /// inserts [newDocuments], all or nothing.
  Future<void> updateScannedDocumentGroup({
    required String groupId,
    required String groupName,
    required List<ScannedDocumentModel> existingDocuments,
    required List<ScannedDocumentModel> newDocuments,
    OperationProgressCallback? onProgress,
  });
  Stream<List<ScannedDocumentGroupModel>> watchScannedDocumentGroups();
  Stream<List<ScannedDocumentModel>> watchScannedDocumentsByGroupId(
    String groupId,
  );
  Future<List<ScannedDocumentGroupModel>> getAllScannedDocumentGroups();
  Future<ScannedDocumentGroupModel> getScannedDocumentGroup(String groupId);
  Future<List<ScannedDocumentModel>> getScannedDocumentsByGroupId(
    String groupId,
  );
  Future<void> deleteScannedDocument(
    String documentId);
  Future<DeletionOutcome> deleteScannedDocuments(
    String groupId,
    List<String> documentIds, {
    required EmptyGroupPolicy emptyGroup,
    OperationProgressCallback? onProgress,
  });
  Future<void> deleteScannedDocumentGroup(
    String groupId, 
  );
Stream<String?> watchScannedDocumentGroupName(String groupId);
  Future<void> deleteScannedDocumentGroups(
    List<String> groupIds, {
    OperationProgressCallback? onProgress,
  });
  Future<void> updateScannedDocumentGroupName({
    required String groupId,
    required String newGroupName,
  });
  Future<void> updateScannedDocument({
    required String documentId,
    required String newDocumentName,
  });
}
