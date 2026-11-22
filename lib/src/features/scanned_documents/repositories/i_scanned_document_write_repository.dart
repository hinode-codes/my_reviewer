import 'package:my_reviewer/src/features/scanned_documents/models/pending_scan_page.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_model.dart';
import 'package:my_reviewer/src/shared/models/task.dart';

abstract interface class IScannedDocumentWriteRepository {
  Future<void> deleteScannedDocument(String documentId);

  Future<void> deleteScannedDocumentGroup(String groupId);

  Future<void> saveScannedDocuments({
    required String groupId,
    required String groupName,
    required List<PendingScanPage> pages,
    String? customFolderName,
    MyReviewerTaskProgressCallback? onProgress,
  });

  Future<void> updateScannedDocument({
    required String documentId,
    required String newDocumentName,
  });

  Future<List<String>> updateScannedDocumentGroup({
    required String groupId,
    required String groupName,
    required List<ScannedDocumentModel> existingDocuments,
    required List<PendingScanPage> newPages,
    MyReviewerTaskProgressCallback? onProgress,
  });

  Future<void> updateScannedDocumentGroupName({
    required String groupId,
    required String newGroupName,
  });
}
