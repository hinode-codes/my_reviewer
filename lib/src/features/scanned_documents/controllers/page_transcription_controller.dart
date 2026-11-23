import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/ocr_job_payload.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/page_transcription_state.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_transcription_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/repositories/i_transcription_read_repository.dart';
import 'package:my_reviewer/src/features/scanned_documents/utils/strings.dart';
import 'package:my_reviewer/src/shared/db/models/jobs_db_model.dart';
import 'package:my_reviewer/src/shared/models/job_model.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/i_job_read_repository.dart';
import 'package:my_reviewer/src/shared/services/jobs/i_job_dispatcher.dart';
import 'package:my_reviewer/src/shared/services/storage/i_file_storage_service.dart';
import 'package:my_reviewer/src/shared/utils/strings.dart';

/// Reactively tracks per-page transcription states (`notQueued`, `queued`,
/// `transcribing`, `transcribed`, `failed`) via Drift streams from
/// [ITranscriptionReadRepository] and [IJobReadRepository], loading saved
/// Markdown content from disk via [IFileStorageService].
class PageTranscriptionController extends ChangeNotifier {
  PageTranscriptionController({
    required this._groupId,
    required this._transcriptionReadRepo,
    required this._jobReadRepo,
    required this._jobDispatcher,
    required this._storageService,
  }) {
    _transcriptionsSub = _transcriptionReadRepo
        .watchByGroupId(_groupId)
        .listen(_onTranscriptionsChanged);

    _queuedSub = _jobReadRepo
        .watchByStatus(JobStatus.queued)
        .listen(_onQueuedJobsChanged);
  }

  final String _groupId;
  final ITranscriptionReadRepository _transcriptionReadRepo;
  final IJobReadRepository _jobReadRepo;
  final IJobDispatcher _jobDispatcher;
  final IFileStorageService _storageService;

  final Map<String, ScannedDocumentTranscriptionModel> _savedByDocId = {};
  final Map<String, String> _cleanedMarkdownByKey = {};
  final Set<String> _readingKeys = {};

  final Map<String, JobModel?> _latestJobByDocId = {};
  final Map<String, StreamSubscription<JobModel?>> _jobSubsByDocId = {};
  final Map<String, int> _queuePositionsByJobId = {};

  StreamSubscription<List<ScannedDocumentTranscriptionModel>>?
  _transcriptionsSub;
  StreamSubscription<List<JobModel>>? _queuedSub;
  bool _disposed = false;

  PageTranscriptionState stateFor(ScannedDocumentModel doc) {
    // 1. Saved transcription takes precedence once persisted.
    final saved = _savedByDocId[doc.id];

    if (saved != null) {
      final cacheKey = _cacheKeyFor(saved);
      final cachedMarkdown = _cleanedMarkdownByKey[cacheKey];

      if (cachedMarkdown != null) {
        return TranscriptionReady(
          markdown: cachedMarkdown,
          wordCount: saved.wordCount,
          timeMsToRead: saved.timeMsToRead,
          timeMsToTranscribe: saved.timeMsToTranscribe,
        );
      }

      unawaited(_loadMarkdownFromDisk(saved));

      final jobPartial = _latestJobByDocId[doc.id]?.partialOutput;

      return TranscriptionReady(
        markdown: jobPartial != null ? cleanOcrMarkdown(jobPartial) : '',
        wordCount: saved.wordCount,
        timeMsToRead: saved.timeMsToRead,
        timeMsToTranscribe: saved.timeMsToTranscribe,
      );
    }

    // 2. Lazily attach a Drift watcher for this doc's latest job if not yet bound.
    _ensureWatchingJob(doc.id);

    final job = _latestJobByDocId[doc.id];

    if (job == null) {
      return const TranscriptionNotQueued();
    }

    final partial = job.partialOutput != null
        ? cleanStreamingOcrMarkdown(job.partialOutput!)
        : '';
    final nonEmptyPartial = partial.isNotEmpty ? partial : null;

    return switch (job.status) {
      JobStatus.running => TranscriptionInProgress(
        jobId: job.id,
        streamingMarkdown: partial,
        wordCount: countWords(partial),
        elapsedMs: job.elapsedMs,
      ),
      JobStatus.queued => TranscriptionQueued(
        jobId: job.id,
        queuePosition: _queuePositionsByJobId[job.id],
        partialMarkdown: nonEmptyPartial,
      ),
      JobStatus.dead => TranscriptionFailed(
        jobId: job.id,
        partialMarkdown: nonEmptyPartial,
        errorMessage: job.lastError,
      ),
      JobStatus.succeeded ||
      JobStatus.cancelled => const TranscriptionNotQueued(),
    };
  }

  String _cacheKeyFor(ScannedDocumentTranscriptionModel transcription) {
    final timestamp = transcription.updatedAt ?? transcription.createdAt;

    return '${transcription.id}:${timestamp.millisecondsSinceEpoch}';
  }

  Future<void> _loadMarkdownFromDisk(
    ScannedDocumentTranscriptionModel transcription,
  ) async {
    final cacheKey = _cacheKeyFor(transcription);

    if (_disposed ||
        _cleanedMarkdownByKey.containsKey(cacheKey) ||
        _readingKeys.contains(cacheKey)) {
      return;
    }

    _readingKeys.add(cacheKey);

    try {
      final absolutePath = _storageService.resolveAbsolutePath(
        transcription.relativePath,
      );
      final file = File(absolutePath);
      final raw = await file.exists() ? await file.readAsString() : '';

      if (_disposed) {
        return;
      }

      _cleanedMarkdownByKey[cacheKey] = cleanOcrMarkdown(raw);

      notifyListeners();
    } catch (err) {
      debugPrint(
        'Failed to read transcription file ${transcription.relativePath}: $err',
      );
    } finally {
      _readingKeys.remove(cacheKey);
    }
  }

  void _ensureWatchingJob(String docId) {
    if (_disposed || _jobSubsByDocId.containsKey(docId)) {
      return;
    }

    _jobSubsByDocId[docId] = _jobReadRepo.watchLatestByItemKey(docId).listen((
      job,
    ) {
      if (_disposed) {
        return;
      }
      _latestJobByDocId[docId] = job;
      notifyListeners();
    });
  }

  void _onTranscriptionsChanged(
    List<ScannedDocumentTranscriptionModel> transcriptions,
  ) {
    if (_disposed) {
      return;
    }

    _savedByDocId
      ..clear()
      ..addEntries(transcriptions.map((t) => MapEntry(t.docId, t)));

    for (final transcription in transcriptions) {
      unawaited(_loadMarkdownFromDisk(transcription));
    }

    notifyListeners();
  }

  void _onQueuedJobsChanged(List<JobModel> queuedJobs) {
    if (_disposed) {
      return;
    }

    // `watchByStatus(JobStatus.queued)` orders by `updatedAt DESC`; reverse so
    // oldest-queued is #1.
    _queuePositionsByJobId.clear();

    final total = queuedJobs.length;

    for (var i = 0; i < total; i++) {
      _queuePositionsByJobId[queuedJobs[i].id] = total - i;
    }

    notifyListeners();
  }

  /// Enqueues an OCR transcription job for a document not yet in the queue.
  Future<void> enqueue(ScannedDocumentModel doc) async {
    final payload = OcrJobPayload(
      groupId: doc.groupId,
      docId: doc.id,
      relativePath: doc.relativePath,
    );

    await _jobDispatcher.dispatch(
      id: generateId(),
      payload: payload.toRawJson(),
      groupKey: doc.groupId,
      itemKey: doc.id,
    );
  }

  /// Retries / requeues a failed or dead-letter job, preserving any saved
  /// `partialOutput` checkpoint so Qwen-VL resumes from prefill.
  Future<void> requeue(ScannedDocumentModel doc) async {
    final existingJob = _latestJobByDocId[doc.id];

    if (existingJob != null) {
      final requeued = await _jobDispatcher.retryDeadJob(existingJob.id);

      if (requeued) {
        return;
      }
    }

    await enqueue(doc);
  }

  @override
  void dispose() {
    _disposed = true;

    _transcriptionsSub?.cancel();
    _queuedSub?.cancel();

    for (final sub in _jobSubsByDocId.values) {
      sub.cancel();
    }

    _jobSubsByDocId.clear();
    super.dispose();
  }
}
