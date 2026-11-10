import 'package:my_reviewer/src/models/docs_delete_state.dart';
import 'package:my_reviewer/src/models/docs_models.dart';
import 'package:my_reviewer/src/models/save_progress.dart';

abstract class IScannedDocumentRespository {
  Future<void> saveScannedDocuments({
    required String groupID,
    required String groupName,
    required List<ScannedDocumentModel> documents,
    String? customFolderName,
    SaveProgressCallback? onProgress,
  });
  Stream<List<ScannedDocumentGroupModel>> watchScannedDocumentGroups();
  Stream<List<ScannedDocumentModel>> watchScannedDocumentsByGroupId(
    String groupId,
  );
  Future<List<ScannedDocumentGroupModel>> getAllScannedDocumentGroups();
  Future<List<ScannedDocumentModel>> getScannedDocumentsByGroupId(
    String groupId,
  );
  Future<void> deleteScannedDocument(
    String documentId, {
    bool softDelete = false,
  });
  Future<void> deleteScannedDocumentGroup(
    String groupId, {
    bool softDelete = false,
  });
  Future<void> deleteScannedDocumentGroups(
    List<String> groupIds, {
    bool softDelete = false,
    DeleteProgressCallback? onProgress,
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
