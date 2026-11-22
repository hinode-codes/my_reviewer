import 'package:my_reviewer/src/features/scanned_documents/models/ocr_job_payload.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/pending_scan_page.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_scanned_document_read_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_scanned_document_write_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_transcription_write_repository.dart';
import 'package:my_reviewer/src/shared/models/job_dispatch_request.dart';
import 'package:my_reviewer/src/shared/models/task.dart';
import 'package:my_reviewer/src/shared/models/use_case.dart';
import 'package:my_reviewer/src/shared/services/jobs/i_job_dispatcher.dart';
import 'package:my_reviewer/src/shared/utils/strings.dart';

typedef UpdateScannedGroupParams = ({
  String groupId,
  String groupName,
  List<ScannedDocumentModel> existingDocuments,
  List<PendingScanPage> newPages,
});

class UpdateScannedGroupUseCase
    implements UseCase<UpdateScannedGroupParams, void> {
  const UpdateScannedGroupUseCase({
    required this._readRepo,
    required this._writeRepo,
    required this._transcriptionWriteRepo,
    required this._jobDispatcher,
  });

  final IScannedDocumentReadRepository _readRepo;
  final IScannedDocumentWriteRepository _writeRepo;
  final ITranscriptionWriteRepository _transcriptionWriteRepo;
  final IJobDispatcher _jobDispatcher;

  @override
  Future<void> call(
    UpdateScannedGroupParams params, {
    MyReviewerTaskProgressCallback? onProgress,
  }) async {
    final (:groupId, :groupName, :existingDocuments, :newPages) = params;

    final stored = await _readRepo.getScannedDocumentsByGroupId(groupId);
    final keptIds = {for (final d in existingDocuments) d.id};
    final removedIds = {
      for (final d in stored)
        if (!keptIds.contains(d.id)) d.id,
    };

    if (removedIds.isNotEmpty) {
      await _jobDispatcher.cancelItems(removedIds);
    }

    final deletedIds = await _writeRepo.updateScannedDocumentGroup(
      groupId: groupId,
      groupName: groupName,
      existingDocuments: existingDocuments,
      newPages: newPages,
      onProgress: onProgress,
    );

    for (final id in deletedIds) {
      await _transcriptionWriteRepo.deleteByDocId(id);
    }

    if (newPages.isNotEmpty) {
      final updatedDocs = await _readRepo.getScannedDocumentsByGroupId(groupId);
      final newlyCreatedDocs = updatedDocs
          .where((doc) => !keptIds.contains(doc.id))
          .toList();

      if (newlyCreatedDocs.isNotEmpty) {
        await _jobDispatcher.dispatchAll([
          for (final doc in newlyCreatedDocs)
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
}
