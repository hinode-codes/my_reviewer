import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/ui_constants.dart';
import 'package:my_reviewer/src/controllers/docs_scan_controller.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/models/docs_scan_state.dart';
import 'package:my_reviewer/src/models/save_progress.dart';
import 'package:provider/provider.dart';

/// Shown while a save runs and until the user acknowledges the result.
///
/// While saving it shows a progress bar and the current stage. When the save
/// finishes it shows the outcome and does NOT close on its own, so the user
/// sees it and dismisses it themselves:
///   - success: a check icon and a button that leaves.
///   - failure: an error icon, a Try-again button that re-runs the save in
///     place, and a Close button that keeps the staged scans.
/// [show] resolves to the terminal status once the user closes it, letting the
/// caller decide whether to leave the screen.
class SaveProgressDialog extends StatelessWidget {
  const SaveProgressDialog({super.key});

  /// Shows the dialog bound to [controller] and resolves to the save's
  /// terminal status once the user closes it.
  ///
  /// A modal route is built outside the screen's provider subtree, so the
  /// controller is re-exposed here for the dialog to watch.
  static Future<SaveStatus> show(
    BuildContext context, {
    required DocsScanController controller,
  }) async {
    final status = await showDialog<SaveStatus>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeNotifierProvider<DocsScanController>.value(
        value: controller,
        child: const SaveProgressDialog(),
      ),
    );

    return status ?? controller.saveStatus;
  }

  @override
  Widget build(BuildContext context) {
    final status = context.select(
      (DocsScanController controller) => controller.saveStatus,
    );
    final progress = context.select(
      (DocsScanController controller) => controller.saveProgress,
    );

    final isSaving = status == SaveStatus.idle || status == SaveStatus.saving;

    return PopScope<void>(
      // Block back while the save is in flight; once it is done the user may
      // dismiss with a button or the back gesture.
      canPop: !isSaving,
      child: AlertDialog(
        content: switch (status) {
          SaveStatus.saved => _ResultContent(
            icon: Icons.check_circle_outline,
            iconColor: Theme.of(context).colorScheme.primary,
            message: t.docs.scan.save.done,
          ),
          SaveStatus.failed => _ResultContent(
            icon: Icons.error_outline,
            iconColor: Theme.of(context).colorScheme.error,
            message: t.docs.scan.save.failed,
          ),
          SaveStatus.idle || SaveStatus.saving => _ProgressContent(
            value: _barValue(progress),
            message: _stageMessage(progress),
          ),
        },
        actions: switch (status) {
          SaveStatus.saved => [
            TextButton(
              onPressed: () => Navigator.pop(context, status),
              child: Text(t.docs.scan.save.backAction),
            ),
          ],
          SaveStatus.failed => [
            TextButton(
              onPressed: () => Navigator.pop(context, status),
              child: Text(t.docs.scan.save.closeAction),
            ),
            TextButton(
              onPressed: () =>
                  unawaited(context.read<DocsScanController>().save()),
              child: Text(t.docs.scan.save.retryAction),
            ),
          ],
          SaveStatus.idle || SaveStatus.saving => null,
        },
      ),
    );
  }

  /// Starts a save on [controller] and shows this dialog over it, resolving to
  /// the terminal status once the user closes the result. The caller decides
  /// what to do with that status (e.g. leave on success).
  static Future<SaveStatus> run(
    BuildContext context, {
    required DocsScanController controller,
  }) {
    unawaited(controller.save());
    return show(context, controller: controller);
  }

  /// Fraction complete while saving files, or null (indeterminate) for the
  /// prepare and finish stages that have no count.
  double? _barValue(SaveProgress? progress) {
    if (progress == null ||
        progress.stage != SaveStage.savingFiles ||
        progress.totalFiles <= 0) {
      return null;
    }

    return progress.currentFile / progress.totalFiles;
  }

  String _stageMessage(SaveProgress? progress) {
    final strings = t.docs.scan.save;
    final current = progress ?? const SaveProgress(stage: SaveStage.preparing);

    return switch (current.stage) {
      SaveStage.preparing => strings.preparing,
      SaveStage.savingFiles => strings.savingFiles(
        current: current.currentFile.toString(),
        total: current.totalFiles.toString(),
      ),
      SaveStage.finishing => strings.finishing,
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
