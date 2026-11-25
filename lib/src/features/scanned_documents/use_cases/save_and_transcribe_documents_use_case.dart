import 'package:my_reviewer/src/features/scanned_documents/models/ocr_job_payload.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/pending_scan_page.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_scanned_document_read_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_scanned_document_write_repository.dart';
import 'package:my_reviewer/src/locators/main_locator.dart';
import 'package:my_reviewer/src/shared/models/task.dart';
import 'package:my_reviewer/src/shared/models/use_case.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/i_job_write_repository.dart';
import 'package:my_reviewer/src/shared/services/foreground_tasks/foreground_task_commander.dart';
import 'package:my_reviewer/src/shared/services/foreground_tasks/foreground_task_type.dart';
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
    required this._jobWriteRepo,
  });

  final IScannedDocumentReadRepository _readRepo;
  final IScannedDocumentWriteRepository _writeRepo;
  final IJobWriteRepository _jobWriteRepo;

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
      for (final doc in savedDocs) {
        await _jobWriteRepo.enqueue(
          id: generateId(),
          payload: OcrJobPayload(
            docId: doc.id,
            groupId: doc.groupId,
            relativePath: doc.relativePath,
          ).toRawJson(),
          groupKey: doc.groupId,
          itemKey: doc.id,
          maxAttempts: 3,
          deduplicateActiveByItemKey: true,
        );
      }

      getIt<ForegroundTaskCommander>().start(ForegroundTaskType.ocr);
    }
  }
}
