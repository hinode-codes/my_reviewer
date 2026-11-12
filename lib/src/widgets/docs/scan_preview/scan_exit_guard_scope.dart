import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/controllers/progress_task.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/models/docs/scan_view_models.dart';
import 'package:my_reviewer/src/models/operation.dart';
import 'package:my_reviewer/src/widgets/common/dialogs/confirmation_dialog.dart';
import 'package:my_reviewer/src/widgets/common/dialogs/progress_dialog.dart';

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
  final ProgressTask<void> saveTask;
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
    final strings = t.docs.scan.discard;

    final choice = await ConfirmationDialog.show(
      context,
      title: strings.title,
      message: strings.message,
      confirmLabel: strings.confirm, // Discard
      cancelLabel: strings.cancel, // Keep editing
      tertiaryLabel: strings.save, // Save
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
    final status = await ProgressDialog.run(
      context,
      task: saveTask,
      kind: OperationKind.save,
    );

    if (!context.mounted) {
      return;
    }

    if (status == OperationStatus.succeeded) {
      leave(context);
    }
  }
}