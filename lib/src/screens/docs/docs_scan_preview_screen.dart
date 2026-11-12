import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/controllers/docs/docs_scan_controller.dart';
import 'package:my_reviewer/src/controllers/docs/scan_preview_controller.dart';
import 'package:my_reviewer/src/controllers/progress_task.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/models/docs/scan_view_models.dart';
import 'package:my_reviewer/src/widgets/docs/scan_preview.dart';
import 'package:my_reviewer/src/widgets/docs/scan_preview/scan_exit_guard_scope.dart';
import 'package:provider/provider.dart';

class DocsScanPreviewScreen extends StatefulWidget {
  const DocsScanPreviewScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DocsScanPreviewState();
  }
}

class _DocsScanPreviewState extends State<DocsScanPreviewScreen> {
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
        .read<DocsScanController>()
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
    final exitGuard = context.select<DocsScanController, ScanExitGuard>(
      (c) => c.exitGuard,
    );
    final scannerStatus = context.select<DocsScanController, ScannerStatus>(
      (c) => c.previewController.scannerStatus,
    );
    final controller = context
        .select<DocsScanController, ScanPreviewController>(
          (value) => value.previewController,
        );
    final saveTask = context.select<DocsScanController, ProgressTask<void>>(
      (val) => val.saveTask,
    );
    final saveAvailability = context
        .select<DocsScanController, SaveAvailability>(
          (c) => c.saveAvailability,
        );

    return ScanExitGuardScope(
      exitGuard: exitGuard,
      saveTask: saveTask,
      child: switch (scannerStatus) {
        ScannerStatus.idle => DocsScanPreview(
          controller: controller,
          saveTask: saveTask,
          onSaved: _onSaved,
          emptyMessage: t.docs.scan.noDocsCaptured,
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
