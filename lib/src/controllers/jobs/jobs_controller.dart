import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:my_reviewer/src/controllers/background_progress_banner_controller.dart';
import 'package:my_reviewer/src/db/app_database.dart';
import 'package:my_reviewer/src/db/models/jobs_model.dart';
import 'package:my_reviewer/src/models/jobs/background_task.dart';
import 'package:my_reviewer/src/models/qwen_ocr_model_spec.dart';
import 'package:my_reviewer/src/repositories/jobs/interface.dart';

enum JobFilter { all, active, failed }

class JobItemViewModel {
  const JobItemViewModel({
    required this.id,
    required this.type,
    required this.title,
    required this.status,
    required this.progress,
    required this.attempts,
    required this.maxAttempts,
    required this.createdAt,
    this.reason,
    this.groupId,
    this.docId,
    this.lastError,
    this.partialOutput,
    this.currentBytes = 0,
    this.totalBytes = 0,
    this.bytesPerSecond,
    this.estimatedRemaining,
    this.isModelDownload = false,
  });

  final String id;
  final JobType type;
  final String title;
  final JobStatus status;
  final double progress;
  final int attempts;
  final int maxAttempts;
  final DateTime createdAt;
  final String? reason;
  final String? groupId;
  final String? docId;
  final String? lastError;
  final String? partialOutput;
  final int currentBytes;
  final int totalBytes;
  final double? bytesPerSecond;
  final Duration? estimatedRemaining;
  final bool isModelDownload;

  bool get isActive =>
      status == JobStatus.queued || status == JobStatus.running;

  bool get canCancel =>
      status == JobStatus.queued || status == JobStatus.running;
  bool get canRetry =>
      status == JobStatus.dead ||
      (isModelDownload && status == JobStatus.cancelled);

  bool get canDelete =>
      !isModelDownload &&
      (status == JobStatus.succeeded ||
          status == JobStatus.dead ||
          status == JobStatus.cancelled);
}

class JobsController extends ChangeNotifier {
  JobsController(
    this._queue,
    this._bannerController,
    this._downloader, {
    this._authToken,
  }) {
    _sub = _queue.watchAll().listen(_onJobsUpdated);
    _bannerController.addListener(_onDownloadsUpdated);
    // Hydrate immediately so initial frame already includes active downloads
    _rebuildMergedList(notify: false);
  }

  final IJobQueue _queue;
  final BackgroundProgressBannerController _bannerController;
  final IModelDownloader _downloader;
  final String? _authToken;

  StreamSubscription<List<Job>>? _sub;

  List<Job> _queueRows = const [];
  List<JobItemViewModel> _allJobs = const [];
  JobFilter _filter = JobFilter.all;
  bool _isLoading = true;

  bool get isLoading => _isLoading && _allJobs.isEmpty;
  JobFilter get filter => _filter;

  List<JobItemViewModel> get jobs => switch (_filter) {
    JobFilter.all => _allJobs,
    JobFilter.active => _allJobs.where((j) => j.isActive).toList(),
    JobFilter.failed =>
      _allJobs.where((j) => j.status == JobStatus.dead).toList(),
  };

  int get activeCount => _allJobs.where((j) => j.isActive).length;

  bool get hasFinishedJobs => _allJobs.any((j) => j.canDelete);

  void setFilter(JobFilter next) {
    if (_filter == next) return;
    _filter = next;
    notifyListeners();
  }

  Future<void> cancelJob(String jobId) {
    if (_isDownloadId(jobId)) {
      return _downloader.cancel(jobId);
    }
    return _queue.cancel(jobId);
  }

  Future<void> retryJob(String jobId) {
    if (_isDownloadId(jobId)) {
      return _downloader.ensureDownloaded(
        qwenOcrModelSpec,
        authToken: _authToken,
      );
    }
    return _queue.retry(jobId);
  }

  Future<void> deleteJob(String jobId) {
    if (_isDownloadId(jobId)) {
      _bannerController.dismiss(jobId);
      return Future.value();
    }
    return _queue.delete(jobId);
  }

  Future<void> clearFinished() => _queue.deleteFinished();

  bool _isDownloadId(String id) =>
      _bannerController.allTasks.any((t) => t.id == id);

  void _onJobsUpdated(List<Job> rows) {
    _queueRows = rows;
    _isLoading = false;
    _rebuildMergedList();
  }

  void _onDownloadsUpdated() {
    _rebuildMergedList();
  }

  void _rebuildMergedList({bool notify = true}) {
    final downloadItems = _bannerController.allTasks
        .map(_mapDownloadToViewModel)
        .toList();
    final queueItems = _queueRows.map(_mapToViewModel).toList();

    _allJobs = List.unmodifiable([...downloadItems, ...queueItems]);
    if (notify) {
      notifyListeners();
    }
  }

  JobItemViewModel _mapDownloadToViewModel(BackgroundTaskProgress task) {
    final mappedStatus = switch (task.state) {
      BackgroundTaskState.queued => JobStatus.queued,
      BackgroundTaskState.active ||
      BackgroundTaskState.paused => JobStatus.running,
      BackgroundTaskState.completed => JobStatus.succeeded,
      BackgroundTaskState.failed => JobStatus.dead,
      BackgroundTaskState.cancelled => JobStatus.cancelled,
    };

    return JobItemViewModel(
      id: task.id,
      type: JobType.download,
      title: task.title,
      reason: task.reason,
      status: mappedStatus,
      progress: task.fraction ?? 0.0,
      attempts: 1,
      maxAttempts: 3,
      createdAt: DateTime.now(),
      currentBytes: task.current,
      totalBytes: task.total,
      bytesPerSecond: task.bytesPerSecond,
      estimatedRemaining: task.estimatedRemaining,
      lastError: task.state == BackgroundTaskState.failed ? task.reason : null,
      isModelDownload: true,
    );
  }

  JobItemViewModel _mapToViewModel(Job row) {
    Map<String, dynamic> data = const {};
    try {
      final decoded = jsonDecode(row.payload);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {}

    final title = switch (row.type) {
      JobType.download => (data['displayName'] as String?) ?? row.type.name,
      JobType.transcribe =>
        (data['documentName'] as String?) ?? row.groupKey ?? row.id,
    };

    final reason = switch (row.type) {
      JobType.download => data['reason'] as String?,
      JobType.transcribe => 'Offline handwriting transcription',
    };

    return JobItemViewModel(
      id: row.id,
      type: row.type,
      title: title,
      reason: reason,
      status: row.status,
      progress: row.progress,
      attempts: row.attempts,
      maxAttempts: row.maxAttempts,
      createdAt: row.createdAt,
      groupId: data['groupId'] as String?,
      docId: data['docId'] as String?,
      lastError: row.lastError,
      partialOutput: row.partialOutput,
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _bannerController.removeListener(_onDownloadsUpdated);
    super.dispose();
  }
}
