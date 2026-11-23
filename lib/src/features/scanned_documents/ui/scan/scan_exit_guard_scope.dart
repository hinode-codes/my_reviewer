import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanner.dart';
import 'package:my_reviewer/src/shared/controllers/task_controller.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/models/confirmation.dart';
import 'package:my_reviewer/src/shared/models/task.dart';
import 'package:my_reviewer/src/shared/ui/dialogs/confirmation_dialog.dart';
import 'package:my_reviewer/src/shared/ui/dialogs/task_dialog.dart';

/// Guards leaving a scan session: with unsaved work, a back press asks
/// whether to discard, keep editing, or save and then leave.
class ScanExitGuardScope extends StatelessWidget {
  const ScanExitGuardScope({
    super.key,
    required this.exitGuard,
    required this.saveTask,
    required this.child,
  });

  final ScanExitGuard exitGuard;
  final TaskController<void> saveTask;
  final Widget child;

  /// Leaves the scan screen [context] belongs to, if there is one to leave.
  static void leave(BuildContext context) {
    final navigator = Navigator.of(context);

    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: exitGuard == ScanExitGuard.allowed,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }

        _onExitRequested(context);
      },
      child: child,
    );
  }

  // [context] is this widget's own element, so `context.mounted` turns false
  // once the screen is gone; check it after every await before using it.
  Future<void> _onExitRequested(BuildContext context) async {
    final strings = t.docs.scan.dialogs.discard;

    final choice = await ConfirmationDialog.show(
      context,
      title: strings.title,
      message: strings.message,
      confirmLabel: strings.actions.confirm, // Discard
      cancelLabel: t.common.actions.cancel, // Keep editing
      tertiaryLabel: strings.actions.save, // Save
      tone: ConfirmTone.destructive,
    );

    if (!context.mounted) {
      return;
    }

    switch (choice) {
      case ConfirmChoice.confirm:
        leave(context);
      case ConfirmChoice.tertiary:
        await _saveThenExit(context);
      case ConfirmChoice.cancel:
      case null:
        break;
    }
  }

  Future<void> _saveThenExit(BuildContext context) async {
    final status = await TaskDialog.run(
      context,
      task: saveTask,
      kind: TaskKind.save,
    );

    if (!context.mounted) {
      return;
    }

    if (status == TaskStatus.succeeded) {
      leave(context);
    }
  }
}
