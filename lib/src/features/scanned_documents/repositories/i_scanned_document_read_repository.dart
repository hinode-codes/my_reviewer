import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_group_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_model.dart';

abstract interface class IScannedDocumentReadRepository {
  Future<List<ScannedDocumentGroupModel>> getAllScannedDocumentGroups();

  Future<ScannedDocumentGroupModel> getScannedDocumentGroup(String groupId);

  Future<List<ScannedDocumentModel>> getScannedDocumentsByGroupId(
    String groupId,
  );

  Future<bool> hasDocuments(String groupId);

  Stream<List<ScannedDocumentGroupModel>> watchScannedDocumentGroups();

  Stream<List<ScannedDocumentModel>> watchScannedDocumentsByGroupId(
    String groupId,
  );

  Stream<String?> watchScannedDocumentGroupName(String groupId);
}
