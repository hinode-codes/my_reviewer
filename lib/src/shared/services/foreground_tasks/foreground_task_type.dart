import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';

import 'ocr_foreground_task.dart';

enum ForegroundTaskType {
  ocr(serviceId: 1001, callback: startOcrForegroundTask);

  const ForegroundTaskType({required this.serviceId, required this.callback});

  /// Must be unique per type; identifies the service/notification.
  final int serviceId;

  /// Top-level `@pragma("vm:entry-point")` function that calls
  /// `FlutterForegroundTask.setTaskHandler(...)`.
  final void Function() callback;

  // Exhaustive: adding a value forces you to add its strings here.
  String get notificationTitle => switch (this) {
    ForegroundTaskType.ocr => t.jobs.transcription.title,
  };

  String get notificationText => switch (this) {
    ForegroundTaskType.ocr => t.jobs.transcription.message,
  };
}
