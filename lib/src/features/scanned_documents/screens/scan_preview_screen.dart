import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/scan_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/scan_preview_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanner.dart';
import 'package:my_reviewer/src/features/scanned_documents/ui/scan/scan_exit_guard_scope.dart';
import 'package:my_reviewer/src/features/scanned_documents/ui/scan_preview.dart';
import 'package:my_reviewer/src/shared/controllers/task_controller.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:provider/provider.dart';

class ScanPreviewScreen extends StatefulWidget {
  const ScanPreviewScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ScanPreviewScreenState();
  }
}

class _ScanPreviewScreenState extends State<ScanPreviewScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInitialScan();
    });
  }

  Future<void> _startInitialScan() async {
    if (!mounted) {
      return;
    }

    final outcome = await context
        .read<ScanController>()
        .previewController
        .scan();

    switch (outcome) {
      case ScanOutcome.cancelled || ScanOutcome.failed:
        // needed for when a user changes device orientation that
        // would require flutter to rebuild.
        // without this, it would run during render, causing
        // null pointer errors.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }

          _pop();
        });
        break;
      case ScanOutcome.captured || ScanOutcome.skipped:
        break;
    }
  }

  void _onSaved(Object? _) {
    _pop();
  }

  void _pop() {
    ScanExitGuardScope.leave(context);
  }

  @override
  Widget build(BuildContext context) {
    final exitGuard = context.select<ScanController, ScanExitGuard>(
      (c) => c.exitGuard,
    );
    final scannerStatus = context.select<ScanController, ScannerStatus>(
      (c) => c.previewController.scannerStatus,
    );
    final controller = context.select<ScanController, ScanPreviewController>(
      (value) => value.previewController,
    );
    final saveTask = context.select<ScanController, TaskController<void>>(
      (val) => val.saveTask,
    );
    final saveAvailability = context.select<ScanController, SaveAvailability>(
      (c) => c.saveAvailability,
    );

    return ScanExitGuardScope(
      exitGuard: exitGuard,
      saveTask: saveTask,
      child: switch (scannerStatus) {
        ScannerStatus.idle => ScanPreview(
          controller: controller,
          saveTask: saveTask,
          onSaved: _onSaved,
          emptyMessage: t.docs.scan.empty.message,
          saveAvailability: saveAvailability,
        ),
        ScannerStatus.scanning => Center(
          child: CircularProgressIndicator.adaptive(
            semanticsLabel: t.common.status.loading,
          ),
        ),
      },
    );
  }
}
