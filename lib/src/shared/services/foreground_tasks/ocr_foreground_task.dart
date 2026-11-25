import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:my_reviewer/src/locators/background_locator.dart';
import 'package:my_reviewer/src/routes.dart';
import 'package:my_reviewer/src/shared/models/job_cancelled_exception.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/i_job_read_repository.dart';
import 'package:my_reviewer/src/shared/repositories/jobs/i_job_write_repository.dart';
import 'package:my_reviewer/src/shared/services/jobs/i_job_handler.dart';
import 'package:my_reviewer/src/shared/services/jobs/job_execution_context.dart';

@pragma("vm:entry-point")
void startOcrForegroundTask() {
  FlutterForegroundTask.setTaskHandler(OcrForegroundTask());
}

class OcrForegroundTask extends TaskHandler {
  late bool _isProcessing = false;
  late int _current = 0;
  late int _total = 0;
  late int _completed = 0;

  @override
  Future<void> onDestroy(
    Comparable<DateTime> timestamp,
    bool isTimeout,
  ) async {}

  @override
  void onRepeatEvent(DateTime timestamp) async {
    if (kDebugMode) {
      debugPrint("Calling onRepeatEvent in OcrForegroundTask");
    }

    if (_isProcessing) {
      return;
    }

    _isProcessing = true;

    final job = await getItBackground<IJobWriteRepository>().claimNextJob();

    if (job == null) {
      debugPrint("No more jobs");

      _isProcessing = false;

      FlutterForegroundTask.stopService();

      return;
    }

    if (kDebugMode) {
      debugPrint("Processing ${job.id.toString()}");
    }

    final retryBackoff = Duration(seconds: 5);
    final queuedRemaining = await getItBackground<IJobReadRepository>()
        .countQueued();

    _current = _completed + 1;
    _total = _current + queuedRemaining;

    final updateStatus = await FlutterForegroundTask.updateService(
      notificationText: "Transcribing $_current / $_total",
      notificationInitialRoute: DocsPageViewerTranscriptionRouteData(
        // bad
        groupId: job.groupKey ?? "",
        docId: job.id,
      ).location,
    );

    if (updateStatus is ServiceRequestFailure) {
      if (kDebugMode) {
        debugPrint(updateStatus.error.toString());
      }
    }

    String? latestPartial = job.partialOutput;
    int latestElapsedMs = job.elapsedMs;

    final context = JobExecutionContext(
      onCheckpoint: ({String? partialOutput, int? elapsedMs}) async {
        final isContinued = await getItBackground<IJobWriteRepository>()
            .checkpoint(
              jobId: job.id,
              partialOutput: partialOutput,
              elapsedMs: elapsedMs,
            );

        if (isContinued) {
          latestPartial = partialOutput ?? latestPartial;
          latestElapsedMs = elapsedMs ?? latestElapsedMs;
        }

        return isContinued;
      },
    );

    try {
      final jobHandler = getItBackground<IJobHandler>();
      final executionTimeout = Duration(seconds: 10);

      await jobHandler
          .execute(job, context)
          .timeout(
            executionTimeout,
            onTimeout: () => throw TimeoutException(
              'Job execution exceeded ${executionTimeout.inMinutes}-minute timeout',
              executionTimeout,
            ),
          );

      _completed += 1;
    } on JobCancelledException {
      if (kDebugMode) {
        debugPrint("\nJob ${job.payload} has been cancelled!\n");
      }
    } catch (error) {
      final terminalError = error.toString();

      if (kDebugMode) {
        debugPrint("Error transcribing $terminalError");
      }

      await getItBackground<IJobWriteRepository>().recordFailure(
        jobId: job.id,
        errorMessage: terminalError,
        retryDelay: retryBackoff * (job.attempts + 1),
        partialOutput: latestPartial,
        elapsedMs: latestElapsedMs,
      );

      final updateStatus = await FlutterForegroundTask.updateService(
        notificationText: "Failed because: $terminalError",
        notificationInitialRoute: DocsRouteData().location,
      );

      if (updateStatus is ServiceRequestFailure) {
        if (kDebugMode) {
          debugPrint(updateStatus.error.toString());
        }
      }
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    if (kDebugMode) {
      debugPrint("Calling onStart() in OcrForegroundTask");
    }

    await setupBackgroundLocator();

    await getItBackground<IJobWriteRepository>().recoverStaleJobs(
      staleThreshold: Duration(seconds: 30),
    );
  }
}
