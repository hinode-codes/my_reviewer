import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/ocr_job_payload.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/page_transcription_state.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_transcription_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_transcription_read_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/utils/strings.dart';
import 'package:my_reviewer/src/locators/main_locator.dart';
import 'package:my_reviewer/src/shared/db/models/jobs_db_model.dart';
import 'package:my_reviewer/src/shared/models/job_model.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/i_job_read_repository.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/i_job_write_repository.dart';
import 'package:my_reviewer/src/shared/services/foreground_tasks/foreground_task_commander.dart';
import 'package:my_reviewer/src/shared/services/foreground_tasks/foreground_task_type.dart';
import 'package:my_reviewer/src/shared/services/storage/i_file_storage_service.dart';
import 'package:my_reviewer/src/shared/utils/strings.dart';

class PageTranscriptionController extends ChangeNotifier {
  PageTranscriptionController({
    required this._groupId,
    required this._transcriptionReadRepository,
    required this._jobReadRepository,
    required this._jobWriteRepository,
    required this._storageService,
  }) {
    _jobSub = _jobReadRepository
        .watchByGroupKey(_groupId)
        .listen(_onJobGroupChange);
  }

  final String _groupId;
  final ITranscriptionReadRepository _transcriptionReadRepository;
  final IJobReadRepository _jobReadRepository;
  final IJobWriteRepository _jobWriteRepository;
  final IFileStorageService _storageService;

  late final StreamSubscription<List<JobModel>> _jobSub;

  final Map<String, ScannedDocumentTranscriptionModel> _cachedTranscriptions =
      {};
  final Map<String, String> _cachedMarkdown = {};
  final Map<String, String> _partialOutputPerJob = {};
  List<JobModel> _jobs = List.unmodifiable([]);

  PageTranscriptionState stateFor(ScannedDocumentModel doc) {
    try {
      final indexOf = _jobs.indexWhere(
        (j) => j.itemKey != null && j.itemKey == doc.id,
      );

      if (indexOf == -1) {
        return TranscriptionNotQueued();
      }

      final jobForDoc = _jobs[indexOf];

      return switch (jobForDoc.status) {
        JobStatus.running => TranscriptionInProgress(
          jobId: jobForDoc.id,
          streamingMarkdown: jobForDoc.partialOutput ?? "",
          wordCount: countWords(jobForDoc.partialOutput ?? ""),
          elapsedMs: jobForDoc.elapsedMs,
        ),
        JobStatus.queued
            when jobForDoc.lastError != null &&
                jobForDoc.lastError!.isNotEmpty =>
          TranscriptionFailed(
            jobId: jobForDoc.id,
            partialMarkdown: jobForDoc.partialOutput ?? "",
            errorMessage: jobForDoc.lastError,
          ),
        JobStatus.queued => TranscriptionQueued(
          jobId: jobForDoc.id,
          queuePosition: indexOf + 1,
          partialMarkdown: jobForDoc.partialOutput ?? "",
        ),
        JobStatus.dead => TranscriptionFailed(
          jobId: jobForDoc.id,
          partialMarkdown: jobForDoc.partialOutput ?? "",
          errorMessage: jobForDoc.lastError,
        ),
        JobStatus.succeeded => _success(jobForDoc),
        JobStatus.cancelled => const TranscriptionNotQueued(),
      };
    } on StateError {
      return const TranscriptionNotQueued();
    }
  }

  final Set<String> _fetchingTranscriptionIds = {};

  PageTranscriptionState _success(JobModel job) {
    final docId = job.itemKey;

    if (docId == null) {
      debugPrint("Succeeded non-itemKey value job ${job.id}");
      return const TranscriptionNotQueued();
    }

    final cached = _cachedTranscriptions[docId];

    if (cached == null) {
      _fetchTranscriptionRecord(docId);

      return TranscriptionInProgress(
        streamingMarkdown: job.partialOutput ?? "",
        wordCount: countWords(job.partialOutput ?? ""),
        elapsedMs: job.elapsedMs,
        jobId: job.id,
      );
    }

    final cachedMarkdown = _cachedMarkdown[docId];

    if (cachedMarkdown != null) {
      return TranscriptionReady(
        markdown: cachedMarkdown,
        wordCount: cached.wordCount,
        timeMsToRead: cached.timeMsToRead,
        timeMsToTranscribe: cached.timeMsToTranscribe,
      );
    }

    unawaited(_loadMarkdownFromDisk(cached));

    return TranscriptionReady(
      markdown: job.partialOutput ?? "",
      wordCount: cached.wordCount,
      timeMsToRead: cached.timeMsToRead,
      timeMsToTranscribe: cached.timeMsToTranscribe,
    );
  }

  Future<void> _fetchTranscriptionRecord(String docId) async {
    if (_fetchingTranscriptionIds.contains(docId)) return;
    _fetchingTranscriptionIds.add(docId);

    try {
      final transcription = await _transcriptionReadRepository.getByDocId(
        docId,
      );
      if (transcription != null) {
        _cachedTranscriptions[docId] = transcription;
        notifyListeners(); // <-- Triggers rebuild to load markdown & show TranscriptionReady
      }
    } finally {
      _fetchingTranscriptionIds.remove(docId);
    }
  }

  Future<void> _loadMarkdownFromDisk(
    ScannedDocumentTranscriptionModel transcription,
  ) async {
    if (_cachedMarkdown.containsKey(transcription.docId)) {
      return;
    }

    try {
      final absolutePath = _storageService.resolveAbsolutePath(
        transcription.relativePath,
      );
      final file = File(absolutePath);
      final raw = await file.exists() ? await file.readAsString() : "";

      _cachedMarkdown[transcription.docId] = raw;

      notifyListeners();
    } catch (err) {
      debugPrint(
        'Failed to read transcription file ${transcription.relativePath}: $err',
      );
    } finally {}
  }

  void _onJobGroupChange(List<JobModel> jobs) {
    for (final job in jobs) {
      if (job.itemKey != null) {
        _partialOutputPerJob[job.itemKey!] = job.partialOutput ?? "";
      }
    }

    _jobs = List.unmodifiable(jobs);

    notifyListeners();
  }

  Future<void> enqueue(ScannedDocumentModel doc) async {
    try {
      final payload = OcrJobPayload(
        groupId: doc.groupId,
        docId: doc.id,
        relativePath: doc.relativePath,
      );

      await _jobWriteRepository.enqueue(
        id: generateId(),
        payload: payload.toRawJson(),
        groupKey: doc.groupId,
        itemKey: doc.id,
        maxAttempts: 3,
        deduplicateActiveByItemKey: true,
      );
    } catch (_) {
      rethrow;
    } finally {
      getIt<ForegroundTaskCommander>().start(ForegroundTaskType.ocr);
    }
  }

  Future<void> requeue(ScannedDocumentModel doc) async {
    final existingJobIndex = _jobs.indexWhere(
      (j) => j.itemKey != null && j.itemKey == doc.id,
    );

    if (existingJobIndex != -1) {
      try {
        final requeued = await _jobWriteRepository.requeueDeadJob(
          _jobs[existingJobIndex].id,
        );

        if (requeued) {
          getIt<ForegroundTaskCommander>().start(ForegroundTaskType.ocr);
          return;
        }
      } catch (_) {
        notifyListeners();
        rethrow;
      }
    }

    await enqueue(doc);
  }

  @override
  void dispose() {
    _jobSub.cancel();

    super.dispose();
  }
}
