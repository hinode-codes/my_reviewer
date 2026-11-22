import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'i_job_notification_service.dart';

typedef NotificationPreferenceReader = Future<bool> Function();

@pragma('vm:entry-point')
void _jobNotificationKeepAliveCallback() {}

class AndroidJobNotificationService implements IJobNotificationService {
  AndroidJobNotificationService({required this._isUserNotificationEnabled});

  final NotificationPreferenceReader _isUserNotificationEnabled;

  /// Fixed service/notification ID ensures OS updates the existing notification
  /// in place rather than spawning duplicate tray entries.
  static const int _notificationId = 401;

  bool _initialized = false;
  bool _isRunning = false;

  @override
  void initialize() {
    if (_initialized || !Platform.isAndroid) {
      return;
    }

    _initialized = true;

    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'my_reviewer_transcription',
        channelName: 'Document Transcription',
        channelDescription:
            'Keeps offline page transcription running in the background.',
        channelImportance: NotificationChannelImportance.DEFAULT,
        priority: NotificationPriority.DEFAULT,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        allowWakeLock: true,
      ),
    );
  }

  Future<bool> _canNotify() async {
    if (!Platform.isAndroid) {
      return false;
    }

    final userEnabled = await _isUserNotificationEnabled();

    if (!userEnabled) {
      return false;
    }

    final permission =
        await FlutterForegroundTask.checkNotificationPermission();

    return permission == NotificationPermission.granted;
  }

  @override
  Future<void> showOrUpdate({
    required String title,
    required String body,
    int? current,
    int? total,
  }) async {
    if (!await _canNotify()) {
      if (_isRunning) {
        await dismiss();
      }
      return;
    }

    final formattedBody = (current != null && total != null && total > 0)
        ? '$body ($current/$total)'
        : body;

    // Guard against duplicate startService calls: check both local state and
    // native service state so an existing notification is always updated.
    if (_isRunning || await FlutterForegroundTask.isRunningService) {
      _isRunning = true;

      await FlutterForegroundTask.updateService(
        notificationTitle: title,
        notificationText: formattedBody,
      );

      return;
    }

    _isRunning = true;
    await FlutterForegroundTask.startService(
      serviceId: _notificationId,
      serviceTypes: [ForegroundServiceTypes.dataSync],
      notificationTitle: title,
      notificationText: formattedBody,
      callback: _jobNotificationKeepAliveCallback,
    );
  }

  @override
  Future<void> dismiss() async {
    if (!_isRunning && !(await FlutterForegroundTask.isRunningService)) {
      return;
    }

    _isRunning = false;
    await FlutterForegroundTask.stopService();
  }
}
