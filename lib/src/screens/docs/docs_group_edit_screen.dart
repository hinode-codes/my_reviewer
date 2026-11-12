import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/controllers/docs/group_edit_controller.dart';
import 'package:my_reviewer/src/controllers/docs/scan_preview_controller.dart';
import 'package:my_reviewer/src/controllers/progress_task.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/models/docs/scan_view_models.dart';
import 'package:my_reviewer/src/models/selection_state.dart';
import 'package:my_reviewer/src/widgets/docs/scan_preview.dart';
import 'package:my_reviewer/src/widgets/docs/scan_preview/scan_exit_guard_scope.dart';
import 'package:provider/provider.dart';

class DocsGroupEditScreen extends StatelessWidget {
  const DocsGroupEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exitGuard = context.select<GroupEditController, ScanExitGuard>(
      (c) => c.exitGuard,
    );
    final saveTask = context.select<GroupEditController, ProgressTask<void>>(
      (c) => c.saveTask,
    );
    final controller = context
        .select<GroupEditController, ScanPreviewController>(
          (c) => c.previewController,
        );
    final saveAvailability = context
        .select<GroupEditController, SaveAvailability>(
          (c) => c.saveAvailability,
        );
    final status = context.select<GroupEditController, ItemsStatus>(
      (c) => c.status,
    );

    return switch (status) {
      ItemsStatus.loading => Scaffold(
        body: Center(
          child: CircularProgressIndicator.adaptive(
            semanticsLabel: t.common.status.loading,
          ),
        ),
      ),
      ItemsStatus.failed => Scaffold(
        body: Center(child: Text(t.common.status.failed)),
      ),
      ItemsStatus.ready => ScanExitGuardScope(
        exitGuard: exitGuard,
        saveTask: saveTask,
        child: DocsScanPreview(
          controller: controller,
          saveTask: saveTask,
          // The session is finished once saved (see ScanSessionPhase), so
          // the screen must leave instead of accepting more edits.
          onSaved: (_) => ScanExitGuardScope.leave(context),
          saveAvailability: saveAvailability,
          emptyMessage: t.docs.scan.noDocsCaptured,
        ),
      ),
    };
  }
}
