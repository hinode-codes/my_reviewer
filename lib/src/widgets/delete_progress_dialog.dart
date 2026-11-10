import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/ui_constants.dart';
import 'package:my_reviewer/src/controllers/docs_controller.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/models/docs_delete_state.dart';
import 'package:provider/provider.dart';

/// Shown while deleting document groups and until the user acknowledges the result.
class DeleteProgressDialog extends StatelessWidget {
  const DeleteProgressDialog({super.key});

  /// Shows the dialog bound to [controller] and resolves to terminal status when closed.
  static Future<DeleteStatus> show(
    BuildContext context, {
    required DocsController controller,
  }) async {
    final status = await showDialog<DeleteStatus>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeNotifierProvider<DocsController>.value(
        value: controller,
        child: const DeleteProgressDialog(),
      ),
    );

    return status ?? controller.deleteStatus;
  }

  /// Starts deletion on [controller] and displays this progress dialog over it.
  static Future<DeleteStatus> run(
    BuildContext context, {
    required DocsController controller,
  }) {
    unawaited(controller.deleteSelectedGroups());
    return show(context, controller: controller);
  }

  @override
  Widget build(BuildContext context) {
    final status = context.select(
      (DocsController controller) => controller.deleteStatus,
    );
    final progress = context.select(
      (DocsController controller) => controller.deleteProgress,
    );

    final isDeleting =
        status == DeleteStatus.idle || status == DeleteStatus.deleting;

    return PopScope<void>(
      canPop: !isDeleting,
      child: AlertDialog(
        content: switch (status) {
          DeleteStatus.deleted => _ResultContent(
            icon: Icons.check_circle_outline,
            iconColor: Theme.of(context).colorScheme.primary,
            message: t.docs.selection.delete.done,
          ),
          DeleteStatus.failed => _ResultContent(
            icon: Icons.error_outline,
            iconColor: Theme.of(context).colorScheme.error,
            message: t.docs.selection.delete.failed,
          ),
          DeleteStatus.idle || DeleteStatus.deleting => _ProgressContent(
            value: _barValue(progress),
            message: _stageMessage(progress),
          ),
        },
        actions: switch (status) {
          DeleteStatus.deleted => [
            TextButton(
              onPressed: () => Navigator.pop(context, status),
              child: Text(t.docs.selection.delete.closeAction),
            ),
          ],
          DeleteStatus.failed => [
            TextButton(
              onPressed: () => Navigator.pop(context, status),
              child: Text(t.docs.selection.delete.closeAction),
            ),
            TextButton(
              onPressed: () => unawaited(
                context.read<DocsController>().deleteSelectedGroups(),
              ),
              child: Text(t.docs.selection.delete.retryAction),
            ),
          ],
          DeleteStatus.idle || DeleteStatus.deleting => null,
        },
      ),
    );
  }

  double? _barValue(DeleteProgress? progress) {
    if (progress == null ||
        progress.stage != DeleteStage.deletingFiles ||
        progress.totalGroups <= 0) {
      return null;
    }

    return progress.currentGroup / progress.totalGroups;
  }

  String _stageMessage(DeleteProgress? progress) {
    final strings = t.docs.selection.delete;
    final current =
        progress ?? const DeleteProgress(stage: DeleteStage.preparing);

    return switch (current.stage) {
      DeleteStage.preparing => strings.preparing,
      DeleteStage.deletingFiles => strings.deletingFiles(
        current: current.currentGroup.toString(),
        total: current.totalGroups.toString(),
      ),
      DeleteStage.finishing => strings.finishing,
    };
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
