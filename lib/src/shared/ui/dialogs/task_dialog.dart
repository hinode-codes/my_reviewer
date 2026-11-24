import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/shared/constants/ui_constants.dart';
import 'package:my_reviewer/src/shared/controllers/task_controller.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/models/task.dart';
import 'package:provider/provider.dart';

typedef TaskProcessingMessageBuilder = String Function(int current, int total);

class TaskDialogMessages {
  const TaskDialogMessages({
    this.preparing,
    this.processing,
    this.finishing,
    this.succeeded,
    this.failed,
  });

  final String? preparing;
  final TaskProcessingMessageBuilder? processing;
  final String? finishing;
  final String? succeeded;
  final String? failed;
}

class TaskDialog extends StatelessWidget {
  const TaskDialog({super.key, required this.kind, this.messages});

  final TaskKind kind;
  final TaskDialogMessages? messages;

  static Future<TaskStatus> run(
    BuildContext context, {
    required TaskController<Object?> task,
    required TaskKind kind,
    TaskDialogMessages? messages,
  }) async {
    unawaited(task.run());

    final status = await showDialog<TaskStatus>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeNotifierProvider<TaskController<Object?>>.value(
        value: task,
        child: TaskDialog(kind: kind, messages: messages),
      ),
    );

    return status ?? task.status;
  }

  @override
  Widget build(BuildContext context) {
    final status = context.select<TaskController<Object?>, TaskStatus>(
      (t) => t.status,
    );
    final progress = context.select<TaskController<Object?>, TaskProgress?>(
      (t) => t.progress,
    );
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope<void>(
      canPop: switch (status) {
        TaskStatus.idle || TaskStatus.running => false,
        TaskStatus.succeeded || TaskStatus.failed => true,
      },
      child: AlertDialog(
        content: switch (status) {
          TaskStatus.succeeded => _ResultContent(
            icon: Icons.check_outlined,
            iconColor: colorScheme.primary,
            message: messages?.succeeded ?? t.common.status.success,
          ),
          TaskStatus.failed => _ResultContent(
            icon: Icons.error_outline_outlined,
            iconColor: colorScheme.error,
            message: messages?.failed ?? t.common.status.failed,
          ),
          TaskStatus.idle || TaskStatus.running => _ProgressContent(
            value: switch (progress?.fraction) {
              null || <= 0 => null,
              final f => f,
            },
            message: switch (progress?.stage) {
              null || TaskStage.preparing =>
                messages?.preparing ?? t.common.status.preparing,
              TaskStage.processing =>
                messages?.processing?.call(progress!.current, progress.total) ??
                    t.common.status.processing(
                      count: progress!.current,
                      total: progress.total,
                    ),
              TaskStage.finishing =>
                messages?.finishing ?? t.common.status.finishing,
            },
          ),
        },
        actions: switch (status) {
          TaskStatus.succeeded => [
            TextButton(
              onPressed: () => Navigator.pop(context, status),
              child: Text(t.common.actions.done),
            ),
          ],
          TaskStatus.failed => [
            TextButton(
              onPressed: () => Navigator.pop(context, status),
              child: Text(t.common.actions.close),
            ),
            TextButton(
              onPressed: () =>
                  unawaited(context.read<TaskController<Object?>>().run()),
              child: Text(t.common.actions.retry),
            ),
          ],
          TaskStatus.idle || TaskStatus.running => null,
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
