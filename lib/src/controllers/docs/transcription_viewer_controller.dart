import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:my_reviewer/src/db/app_database.dart';
import 'package:my_reviewer/src/db/models/jobs_model.dart';
import 'package:my_reviewer/src/models/docs/view_models.dart';
import 'package:my_reviewer/src/models/selection_state.dart';
import 'package:my_reviewer/src/models/transcription_models.dart';
import 'package:my_reviewer/src/repositories/jobs/interface.dart';
import 'package:my_reviewer/src/repositories/scanned_document/interface.dart';
import 'package:my_reviewer/src/repositories/transcription/interface.dart';
import 'package:my_reviewer/src/services/file_change_journal.dart';
import 'package:my_reviewer/src/services/file_storage_service.dart';
import 'package:my_reviewer/src/utils/string.dart';

const int _readingWordsPerMinute = 200;
const int _msPerMinute = 60000;

typedef TranscriptionViewerArgs = ({
  String groupId,
  String docId,
  List<ScannedDocumentModel>? initialDocuments,
});

enum TranscriptionViewStatus { idle, queued, streaming, ready, failed }

class TranscriptionViewerController extends ChangeNotifier {
  TranscriptionViewerController({
    required this._groupId,
    required this._docId,
    required this._documentRepo,
    required this._transcriptionRepo,
    required this._jobQueue,
    required this._storage,
    List<ScannedDocumentModel>? initialDocuments,
  }) {
    if (initialDocuments != null) {
      _setDocs(initialDocuments);
    }
  }

  final String _groupId;
  final String _docId;
  final IScannedDocumentRepository _documentRepo;
  final ITranscriptionRepository _transcriptionRepo;
  final IJobQueue _jobQueue;
  final FileStorageService _storage;

  StreamSubscription<ScannedDocumentTranscriptionModel?>? _transcriptionSub;
  StreamSubscription<List<Job>>? _jobsSub;

  ItemsStatus _pageStatus = ItemsStatus.loading;
  ItemsStatus get pageStatus => _pageStatus;

  List<ScannedDocumentModel> _docs = const [];
  List<ScannedDocumentModel> get docs => _docs;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  ScannedDocumentModel get currentDoc => _docs[_currentIndex];

  ScannedDocumentTranscriptionModel? _savedTranscription;
  ScannedDocumentTranscriptionModel? get savedTranscription =>
      _savedTranscription;

  Job? _activeJob;
  Job? get activeJob => _activeJob;

  String _markdown = '';
  String get markdown => _markdown;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _disposed = false;

  TranscriptionViewStatus get viewStatus {
    final job = _activeJob;
    if (job != null) {
      if (job.status == JobStatus.queued) return TranscriptionViewStatus.queued;
      if (job.status == JobStatus.running) {
        return TranscriptionViewStatus.streaming;
      }
      if (job.status == JobStatus.dead && _savedTranscription == null) {
        return TranscriptionViewStatus.failed;
      }
    }

    if (_savedTranscription != null) {
      return TranscriptionViewStatus.ready;
    }

    return TranscriptionViewStatus.idle;
  }

  Future<void> initialize() async {
    if (_pageStatus == ItemsStatus.loading) {
      try {
        final fetched = await _documentRepo.getScannedDocumentsByGroupId(
          _groupId,
        );

        if (_disposed) {
          return;
        }

        _setDocs(fetched);
      } catch (err) {
        debugPrint('Failed to load docs for transcription viewer: $err');

        if (_disposed) {
          return;
        }

        _pageStatus = ItemsStatus.failed;

        notifyListeners();

        return;
      }
    }

    _transcriptionSub = _transcriptionRepo
        .watchByDocId(_docId)
        .listen(_onSavedTranscriptionChanged);
    _jobsSub = _jobQueue.watchAll().listen(_onJobsChanged);

    notifyListeners();
  }

  void _setDocs(List<ScannedDocumentModel> docs) {
    final idx = docs.indexWhere((d) => d.id == _docId);

    if (idx < 0) {
      _pageStatus = ItemsStatus.failed;

      return;
    }

    _docs = List.unmodifiable(docs);
    _currentIndex = idx;
    _pageStatus = ItemsStatus.ready;
  }

  Future<void> _onSavedTranscriptionChanged(
    ScannedDocumentTranscriptionModel? model,
  ) async {
    _savedTranscription = model;

    if (model != null) {
      try {
        final absPath = await _storage.resolveAbsolutePath(
          model.relativeFilePath,
          root: StorageRoot.documents,
        );
        final file = File(absPath);

        if (await file.exists()) {
          _markdown = await file.readAsString();
        }
      } catch (err) {
        debugPrint('Failed to read saved markdown for $_docId: $err');
      }
    }

    if (!_disposed) {
      notifyListeners();
    }
  }

  void _onJobsChanged(List<Job> jobs) {
    Job? matched;

    for (final job in jobs) {
      if (job.type != JobType.transcribe) {
        continue;
      }

      if (_extractDocId(job.payload) == _docId) {
        matched = job;

        break;
      }
    }

    _activeJob = matched;

    if (matched != null) {
      if (matched.status == JobStatus.running &&
          matched.partialOutput != null &&
          matched.partialOutput!.isNotEmpty) {
        _markdown = sanitizeStreaming(matched.partialOutput!);
      } else if (matched.status == JobStatus.dead) {
        _errorMessage = matched.lastError;
      }
    }

    if (!_disposed) {
      notifyListeners();
    }
  }

  String? _extractDocId(String rawPayload) {
    try {
      final map = jsonDecode(rawPayload);
      if (map is Map<String, dynamic>) {
        return map['docId'] as String?;
      }
    } catch (_) {}
    return null;
  }

  Future<void> startTranscription() async {
    if (_pageStatus != ItemsStatus.ready) {
      return;
    }

    final doc = currentDoc;
    final payload = TranscribePagePayload(
      docId: doc.id,
      groupId: doc.groupId,
      documentName: doc.name,
      imageRelativePath: doc.relativeFilePath,
    );

    _errorMessage = null;

    await _jobQueue.enqueue(
      JobType.transcribe,
      payload: payload.toJsonString(),
      groupKey: doc.groupId,
    );
  }

  Future<void> cancelTranscription() async {
    final job = _activeJob;

    if (job == null) {
      return;
    }

    await _jobQueue.cancel(job.id);
  }

  Future<void> retryTranscription() async {
    final job = _activeJob;

    if (job != null && job.status == JobStatus.dead) {
      await _jobQueue.retry(job.id);
    } else {
      await startTranscription();
    }
  }

  /// Atomically persists user corrections back to `<docId>.md` and updates
  /// word count / read time in the repository.
  Future<void> saveCorrectedMarkdown(String updatedMarkdown) async {
    final existing = _savedTranscription;

    if (existing == null) {
      return;
    }

    final absPath = await _storage.resolveAbsolutePath(
      existing.relativeFilePath,
      root: StorageRoot.documents,
    );
    final tempPath = '$absPath.tmp';
    final journal = FileChangeJournal(_storage);

    try {
      await File(tempPath).writeAsString(updatedMarkdown, flush: true);
      journal.recordCreated(tempPath);
      if (await File(absPath).exists()) {
        await _storage.delete(absPath);
      }
      await journal.move(tempPath, absPath);

      final words = countWords(updatedMarkdown);
      final readTimeMs = ((words / _readingWordsPerMinute) * _msPerMinute)
          .round();

      final updatedModel = existing.copyWith(
        absoluteFilePath: absPath,
        updatedAt: DateTime.now(),
        wordCount: words,
        timeMsToRead: readTimeMs,
      );

      await _transcriptionRepo.upsert(updatedModel);
      _markdown = updatedMarkdown;
      _savedTranscription = updatedModel;

      if (!_disposed) {
        notifyListeners();
      }
    } catch (_) {
      await journal.rollback();
      rethrow;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _transcriptionSub?.cancel();
    _jobsSub?.cancel();
    super.dispose();
  }
}
