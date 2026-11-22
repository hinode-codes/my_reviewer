import 'dart:async';

import 'package:flutter/foundation.dart';

class Throttle {
  Throttle({this.interval = const Duration(milliseconds: 60)});

  final Duration interval;

  DateTime _lastRun = DateTime.fromMillisecondsSinceEpoch(0);
  Timer? _trailingTimer;
  VoidCallback? _pendingAction;

  /// Runs [action] immediately if [interval] has elapsed since the last run;
  /// otherwise schedules it to run once at the end of the current window.
  /// Pass [force] = true to bypass throttling (e.g., on stage changes or completion).
  void call(VoidCallback action, {bool force = false}) {
    if (force) {
      _cancelPending();
      _execute(action);

      return;
    }

    final elapsed = DateTime.now().difference(_lastRun);
    if (elapsed >= interval) {
      _cancelPending();
      _execute(action);
    } else {
      _pendingAction = action;
      _trailingTimer ??= Timer(interval - elapsed, () {
        final pending = _pendingAction;
        _trailingTimer = null;
        _pendingAction = null;

        if (pending != null) {
          _execute(pending);
        }
      });
    }
  }

  void _execute(VoidCallback action) {
    _lastRun = DateTime.now();

    action();
  }

  void _cancelPending() {
    _trailingTimer?.cancel();

    _trailingTimer = null;
    _pendingAction = null;
  }

  void dispose() {
    _cancelPending();
  }
}
