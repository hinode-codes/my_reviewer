import 'package:my_reviewer/src/features/scanned_documents/repositories/i_scanned_document_write_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_transcription_write_repository.dart';
import 'package:my_reviewer/src/shared/models/task.dart';
import 'package:my_reviewer/src/shared/models/use_case.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/i_job_write_repository.dart';

class DeleteScannedGroupUseCase implements UseCase<String, void> {
  const DeleteScannedGroupUseCase({
    required this._writeRepo,
    required this._transcriptionWriteRepo,
    required this._jobWriteRepository,
  });

  final IScannedDocumentWriteRepository _writeRepo;
  final ITranscriptionWriteRepository _transcriptionWriteRepo;
  final IJobWriteRepository _jobWriteRepository;

  @override
  Future<void> call(
    String groupId, {
    MyReviewerTaskProgressCallback? onProgress,
  }) async {
    onProgress?.call(const TaskProgress.preparing());

    final counter = TaskProgressCounter(total: 3, onProgress: onProgress);

    counter.next();
    await _jobWriteRepository.cancelByGroupKey(groupId);

    counter.next();
    await _transcriptionWriteRepo.deleteGroupFolder(groupId);

    counter.next();
    await _writeRepo.deleteScannedDocumentGroup(groupId);

    onProgress?.call(const TaskProgress.finishing());
  }
}
