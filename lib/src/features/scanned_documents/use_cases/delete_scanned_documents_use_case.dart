import 'package:my_reviewer/src/features/scanned_documents/repositories/i_scanned_document_read_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_scanned_document_write_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_transcription_write_repository.dart';
import 'package:my_reviewer/src/shared/models/deletion.dart';
import 'package:my_reviewer/src/shared/models/task.dart';
import 'package:my_reviewer/src/shared/models/use_case.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/i_job_write_repository.dart';

import 'delete_scanned_group_use_case.dart';

typedef DeleteDocumentsParams = ({
  String groupId,
  List<String> documentIds,
  EmptyGroupPolicy emptyGroup,
});

class DeleteScannedDocumentsUseCase
    implements UseCase<DeleteDocumentsParams, DeletionOutcome> {
  const DeleteScannedDocumentsUseCase({
    required this._readRepo,
    required this._writeRepo,
    required this._transcriptionWriteRepo,
    required this._jobWriteRepo,
    required this._deleteGroup,
  });

  final IScannedDocumentReadRepository _readRepo;
  final IScannedDocumentWriteRepository _writeRepo;
  final ITranscriptionWriteRepository _transcriptionWriteRepo;
  final IJobWriteRepository _jobWriteRepo;
  final DeleteScannedGroupUseCase _deleteGroup;

  @override
  Future<DeletionOutcome> call(
    DeleteDocumentsParams params, {
    MyReviewerTaskProgressCallback? onProgress,
  }) async {
    final (:groupId, :documentIds, :emptyGroup) = params;

    if (documentIds.isEmpty) {
      return DeletionOutcome.itemsDeleted;
    }

    onProgress?.call(const TaskProgress.preparing());

    final hasCleanupStep = emptyGroup == EmptyGroupPolicy.deleteGroup;
    final counter = TaskProgressCounter(
      total: 1 + documentIds.length + (hasCleanupStep ? 1 : 0),
      onProgress: onProgress,
    );

    counter.next();
    // A running job notices the cancellation at its next checkpoint.
    await _jobWriteRepo.cancelByItemKeys(documentIds.toSet());

    for (final id in documentIds) {
      counter.next();
      await _transcriptionWriteRepo.deleteByDocId(id);
      await _writeRepo.deleteScannedDocument(id);
    }

    final outcome = switch (emptyGroup) {
      EmptyGroupPolicy.keepGroup => DeletionOutcome.itemsDeleted,
      EmptyGroupPolicy.deleteGroup => await _resolveEmptyGroup(
        groupId,
        counter,
      ),
    };

    onProgress?.call(const TaskProgress.finishing());
    return outcome;
  }

  Future<DeletionOutcome> _resolveEmptyGroup(
    String groupId,
    TaskProgressCounter counter,
  ) async {
    counter.next();
    if (await _readRepo.hasDocuments(groupId)) {
      return DeletionOutcome.itemsDeleted;
    }

    await _deleteGroup(groupId);
    return DeletionOutcome.parentDeleted;
  }
}
