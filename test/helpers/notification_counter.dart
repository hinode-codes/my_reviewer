import 'package:flutter/foundation.dart';

/// Counts how many times [listenable] notifies, so a test can assert that
/// one logical change sends exactly one notification.
class NotificationCounter {
  NotificationCounter(this._listenable) {
    _listenable.addListener(_onNotify);
  }

  final Listenable _listenable;

  int _count = 0;
  int get count => _count;

  void _onNotify() => _count++;

  void reset() => _count = 0;

  void dispose() => _listenable.removeListener(_onNotify);
}