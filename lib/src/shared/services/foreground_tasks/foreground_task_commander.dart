import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:my_reviewer/src/shared/services/foreground_tasks/foreground_task_type.dart';

enum ForegroundTaskStartOutcome { started, alreadyRunning, failed }

class ForegroundTaskCommander {
  ForegroundTaskCommander._internal() {
    if (kDebugMode) {
      debugPrint("Created ForegroundTaskCommander");
    }
  }

  static final ForegroundTaskCommander _instance =
      ForegroundTaskCommander._internal();

  factory ForegroundTaskCommander() {
    return _instance;
  }

  ForegroundTaskType? _activeType;

  void initSetup() async {
    debugPrint("Called initSetup() in ForegroundTaskCommander");

    FlutterForegroundTask.initCommunicationPort();

    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();

    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      // Android 12+, there are restrictions on starting a foreground service.
      //
      // To restart the service on device reboot or unexpected problem, you need to allow below permission.
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
    }
  }

  void init() {
    debugPrint("Called init() in ForegroundTaskCommander");

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'my_reiewer',
        channelName: 'MyReviewer Background Worker',
        channelDescription: 'MyReviewer is performing some tasks...',
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
      ),
    );
  }

  Future<ForegroundTaskStartOutcome> start(ForegroundTaskType type) async {
    if (kDebugMode) {
      debugPrint("Called start($type) in ForegroundTaskCommander");
    }

    final bool isRunning = await FlutterForegroundTask.isRunningService;

    // This does not accommodate the fact that on app restarts,
    // the value of _activeType would be null regardless.
    // Therefore, if a non-knowing caller were to call the same task type,
    // this guard does not work as intended, resetting the task.
    if (isRunning) {
      if (_activeType == type) {
        return ForegroundTaskStartOutcome.alreadyRunning;
      }

      // Only one service exists at a time, so a different type (or one
      // auto-started on boot, where _activeType is unknown) is stopped first.
      await FlutterForegroundTask.stopService();

      _activeType = null;
    }

    final ServiceRequestResult result =
        await FlutterForegroundTask.startService(
          serviceId: type.serviceId,
          notificationTitle: type.notificationTitle,
          notificationText: type.notificationText,
          callback: type.callback,
          serviceTypes: [ForegroundServiceTypes.dataSync],
        );

    if (result is ServiceRequestSuccess) {
      _activeType = type;

      return ForegroundTaskStartOutcome.started;
    }

    return ForegroundTaskStartOutcome.failed;
  }

  Future<void> stop() async {
    await FlutterForegroundTask.stopService();

    _activeType = null;
  }
}
