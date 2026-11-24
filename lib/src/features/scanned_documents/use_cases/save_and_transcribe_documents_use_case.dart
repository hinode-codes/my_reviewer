import 'package:my_reviewer/src/features/scanned_documents/models/ocr_job_payload.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/pending_scan_page.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_scanned_document_read_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_scanned_document_write_repository.dart';
import 'package:my_reviewer/src/shared/models/job_dispatch_request.dart';
import 'package:my_reviewer/src/shared/models/task.dart';
import 'package:my_reviewer/src/shared/models/use_case.dart';
import 'package:my_reviewer/src/shared/services/jobs/i_job_dispatcher.dart';
import 'package:my_reviewer/src/shared/utils/strings.dart';

typedef SaveScannedGroupParams = ({
  String groupId,
  String groupName,
  List<PendingScanPage> pages,
});

/// Persists a newly scanned document group and immediately dispatches
/// background OCR transcription jobs for every saved page.
class SaveScannedGroupUseCase implements UseCase<SaveScannedGroupParams, void> {
  const SaveScannedGroupUseCase({
    required this._readRepo,
    required this._writeRepo,
    required this._jobDispatcher,
  });

  final IScannedDocumentReadRepository _readRepo;
  final IScannedDocumentWriteRepository _writeRepo;
  final IJobDispatcher _jobDispatcher;

  @override
  Future<void> call(
    SaveScannedGroupParams params, {
    MyReviewerTaskProgressCallback? onProgress,
  }) async {
    final (:groupId, :groupName, :pages) = params;

    if (pages.isEmpty) {
      return;
    }

    await _writeRepo.saveScannedDocuments(
      groupId: groupId,
      groupName: groupName,
      pages: pages,
      onProgress: onProgress,
    );

    final savedDocs = await _readRepo.getScannedDocumentsByGroupId(groupId);

    if (savedDocs.isNotEmpty) {
      await _jobDispatcher.dispatchAll([
        for (final doc in savedDocs)
          JobDispatchRequest(
            id: generateId(),
            groupKey: groupId,
            itemKey: doc.id,
            payload: OcrJobPayload(
              docId: doc.id,
              groupId: groupId,
              relativePath: doc.relativePath,
              ext: 'md',
            ).toRawJson(),
          ),
      ]);
    }
  }
}
