import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_reviewer/src/controllers/progress_task.dart';
import 'package:my_reviewer/src/models/operation.dart';

import '../../helpers/notification_counter.dart';

void main() {
  group('ProgressTask', () {
    test('starts idle, with no progress and no result', () {
      final task = ProgressTask<int>((_) async => 1);
      addTearDown(task.dispose);

      expect(task.status, OperationStatus.idle);
      expect(task.progress, isNull);
      expect(task.result, isNull);
    });

    test('a successful run ends succeeded with its result', () async {
      final task = ProgressTask<int>((_) async => 42);
      addTearDown(task.dispose);

      final status = await task.run();

      expect(status, OperationStatus.succeeded);
      expect(task.status, OperationStatus.succeeded);
      expect(task.result, 42);
    });

    test('a throwing run ends failed with no result', () async {
      final task = ProgressTask<int>((_) async => throw StateError('boom'));
      addTearDown(task.dispose);

      final status = await task.run();

      expect(status, OperationStatus.failed);
      expect(task.result, isNull);
    });

    test('is running, and preparing, as soon as run is called', () async {
      final gate = Completer<int>();
      final task = ProgressTask<int>((_) => gate.future);
      addTearDown(task.dispose);

      final running = task.run();

      expect(task.status, OperationStatus.running);
      expect(task.progress?.stage, OperationStage.preparing);

      gate.complete(1);
      await running;
    });

    test('a second run while running is ignored', () async {
      final gate = Completer<int>();
      var calls = 0;
      final task = ProgressTask<int>((_) {
        calls++;
        return gate.future;
      });
      addTearDown(task.dispose);

      final first = task.run();
      final second = await task.run();

      expect(second, OperationStatus.running);
      expect(calls, 1);

      gate.complete(1);
      expect(await first, OperationStatus.succeeded);
      expect(calls, 1);
    });

    test('progress reported by the operation is exposed and notified',
        () async {
      final gate = Completer<int>();
      final task = ProgressTask<int>((onProgress) async {
        onProgress(const OperationProgress(stage: OperationStage.finishing));
        return gate.future;
      });
      addTearDown(task.dispose);
      final notifications = NotificationCounter(task);
      addTearDown(notifications.dispose);

      final running = task.run();
      await Future<void>.delayed(Duration.zero);

      expect(task.progress?.stage, OperationStage.finishing);
      // One for running, one for the progress report.
      expect(notifications.count, 2);

      gate.complete(1);
      await running;
      expect(notifications.count, 3);
    });

    test('a run without progress reports notifies twice: start and end',
        () async {
      final task = ProgressTask<int>((_) async => 1);
      addTearDown(task.dispose);
      final notifications = NotificationCounter(task);
      addTearDown(notifications.dispose);

      await task.run();

      expect(notifications.count, 2);
    });

    test('a retry after a failure can succeed', () async {
      var attempt = 0;
      final task = ProgressTask<int>((_) async {
        attempt++;
        if (attempt == 1) {
          throw StateError('first attempt fails');
        }
        return attempt;
      });
      addTearDown(task.dispose);

      expect(await task.run(), OperationStatus.failed);
      expect(await task.run(), OperationStatus.succeeded);
      expect(task.result, 2);
    });

    test('a new run clears the previous result', () async {
      var attempt = 0;
      final task = ProgressTask<int>((_) async {
        attempt++;
        if (attempt == 2) {
          throw StateError('second attempt fails');
        }
        return attempt;
      });
      addTearDown(task.dispose);

      await task.run();
      expect(task.result, 1);

      await task.run();
      expect(task.result, isNull);
    });
  });
}