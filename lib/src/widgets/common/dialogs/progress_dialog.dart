import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/ui_constants.dart';
import 'package:my_reviewer/src/controllers/progress_task.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/models/operation.dart';
import 'package:provider/provider.dart';

/// Shown while a [ProgressTask] runs and until the user acknowledges the
/// result. It does NOT close on its own, so the user sees the outcome:
///   - success: a check icon and a button that closes it.
///   - failure: an error icon, a Try-again button that re-runs the task in
///     place, and a Close button.
class ProgressDialog extends StatelessWidget {
  const ProgressDialog({super.key, required this.kind});

  final OperationKind kind;

  /// Starts [task] and shows this dialog over it, resolving to the terminal
  /// status once the user closes the result. The caller decides what to do
  /// with that status (e.g. leave on success).
  static Future<OperationStatus> run(
    BuildContext context, {
    required ProgressTask<Object?> task,
    required OperationKind kind,
  }) {
    unawaited(task.run());
    return show(context, task: task, kind: kind);
  }

  /// A modal route is built outside the screen's provider subtree, so the
  /// task is re-exposed here for the dialog to watch.
  static Future<OperationStatus> show(
    BuildContext context, {
    required ProgressTask<Object?> task,
    required OperationKind kind,
  }) async {
    final status = await showDialog<OperationStatus>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeNotifierProvider<ProgressTask<Object?>>.value(
        value: task,
        child: ProgressDialog(kind: kind),
      ),
    );

    return status ?? task.status;
  }

  @override
  Widget build(BuildContext context) {
    final status = context.select((ProgressTask<Object?> task) => task.status);
    final progress = context.select(
      (ProgressTask<Object?> task) => task.progress,
    );
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope<void>(
      canPop: switch (status) {
        OperationStatus.idle || OperationStatus.running => false,
        OperationStatus.succeeded || OperationStatus.failed => true,
      },
      child: AlertDialog(
        content: switch (status) {
          OperationStatus.succeeded => _ResultContent(
            icon: Icons.check_circle_outline,
            iconColor: colorScheme.primary,
            message: t.common.status.success,
          ),
          OperationStatus.failed => _ResultContent(
            icon: Icons.error_outline,
            iconColor: colorScheme.error,
            message: t.common.status.failed,
          ),
          OperationStatus.idle || OperationStatus.running => _ProgressContent(
            value: progress?.fraction,
            message: progress != null
                ? switch (progress.stage) {
                    OperationStage.preparing => t.common.status.preparing,
                    OperationStage.processing => t.common.status.processing(
                      count: progress.current,
                      total: progress.total,
                    ),
                    OperationStage.finishing => t.common.status.finishing
                  }
                : t.common.status.preparing,
          ),
        },
        actions: switch (status) {
          OperationStatus.succeeded => [
            TextButton(
              onPressed: () => Navigator.pop(context, status),
              child: Text(t.common.buttons.done),
            ),
          ],
          OperationStatus.failed => [
            TextButton(
              onPressed: () => Navigator.pop(context, status),
              child: Text(t.common.buttons.close),
            ),
            TextButton(
              onPressed: () =>
                  unawaited(context.read<ProgressTask<Object?>>().run()),
              child: Text(t.common.buttons.retry),
            ),
          ],
          OperationStatus.idle || OperationStatus.running => null,
        },
      ),
    );
  }
}

class _ProgressContent extends StatelessWidget {
  const _ProgressContent({required this.value, required this.message});

  final double? value;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: value),
        const SizedBox(height: AppSpacing.md),
        Text(message),
      ],
    );
  }
}

class _ResultContent extends StatelessWidget {
  const _ResultContent({
    required this.icon,
    required this.iconColor,
    required this.message,
  });

  final IconData icon;
  final Color iconColor;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: AppSizes.icon),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(message)),
      ],
    );
  }
}
