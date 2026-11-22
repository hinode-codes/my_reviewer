import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:my_reviewer/src/models/jobs/background_task.dart';

class BackgroundProgressBannerController extends ChangeNotifier {
  final Map<String, BackgroundTaskProgress> _tasks = {};
  final Set<String> _dismissedIds = {};
  final List<StreamSubscription<BackgroundTaskProgress>> _subscriptions = [];

  bool _suppressedOnJobsRoute = false;
  bool get isSuppressedOnJobsRoute => _suppressedOnJobsRoute;

  /// Exposes all tracked background tasks (used by JobsController so `/jobs`
  /// displays active model downloads alongside queued transcription jobs).
  List<BackgroundTaskProgress> get allTasks => List.unmodifiable(_tasks.values);

  BackgroundTaskProgress? get visibleTask {
    if (_suppressedOnJobsRoute) return null;

    final candidates = _tasks.values.where((task) {
      if (_dismissedIds.contains(task.id)) {
        return false;
      }

      return task.state == BackgroundTaskState.active ||
          task.state == BackgroundTaskState.paused ||
          task.state == BackgroundTaskState.queued;
    }).toList();

    if (candidates.isEmpty) {
      return null;
    }

    candidates.sort((a, b) {
      final pA = _priority(a.state);
      final pB = _priority(b.state);

      if (pA != pB) {
        return pA.compareTo(pB);
      }

      return a.id.compareTo(b.id);
    });

    return candidates.first;
  }

  int _priority(BackgroundTaskState state) => switch (state) {
    BackgroundTaskState.active => 0,
    BackgroundTaskState.paused => 1,
    BackgroundTaskState.queued => 2,
    _ => 3,
  };

  void observe(Stream<BackgroundTaskProgress> stream) {
    final sub = stream.listen((progress) {
      _tasks[progress.id] = progress;

      // Once a task completes/cancels/fails, clear its dismissal flag so a
      // future retry or re-download will be visible again.
      if (progress.state == BackgroundTaskState.completed ||
          progress.state == BackgroundTaskState.cancelled ||
          progress.state == BackgroundTaskState.failed) {
        _dismissedIds.remove(progress.id);
      }

      notifyListeners();
    });
    _subscriptions.add(sub);
  }

  /// Called by the user tapping the close button on the banner.
  void dismiss(String taskId) {
    if (_dismissedIds.add(taskId)) {
      notifyListeners();
    }
  }

  /// Called by MainPageScreen when switching tabs or routes into/out of `/jobs`.
  void setSuppressedOnJobsRoute(bool suppressed) {
    if (_suppressedOnJobsRoute == suppressed) {
      return;
    }

    _suppressedOnJobsRoute = suppressed;

    notifyListeners();
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}
