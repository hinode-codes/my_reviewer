import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:my_reviewer/src/locator.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/services/jobs/i_job_dispatcher.dart';
import 'package:my_reviewer/src/shared/services/jobs/local_job_queue_runner.dart';
import 'package:my_reviewer/src/shared/services/notifications/i_job_notification_service.dart';

abstract final class OcrTaskCommands {
  static const String drain = 'drain';
  static const String sync = 'sync';
}

@pragma('vm:entry-point')
void startOcrBackgroundTask() {
  FlutterForegroundTask.setTaskHandler(OcrForegroundTaskHandler());
}

class OcrForegroundTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    WidgetsFlutterBinding.ensureInitialized();
    LocaleSettings.useDeviceLocale();

    await setupLocator(isBackgroundWorker: true);

    getIt<IJobNotificationService>().initialize();

    await getIt<IJobDispatcher>().initialize();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Periodic safety kick in case an event was missed.
    if (getIt.isRegistered<LocalJobQueueRunner>()) {
      unawaited(getIt<LocalJobQueueRunner>().triggerDrain());
    }
  }

  @override
  void onReceiveData(Object data) {
    if (!getIt.isRegistered<LocalJobQueueRunner>()) {
      return;
    }

    if (data == OcrTaskCommands.drain) {
      unawaited(getIt<LocalJobQueueRunner>().triggerDrain());
    } else if (data == OcrTaskCommands.sync) {
      unawaited(getIt<LocalJobQueueRunner>().syncNotifications());
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    if (getIt.isRegistered<IJobDispatcher>()) {
      getIt<IJobDispatcher>().dispose();
    }
    await getIt.reset();
  }
}
