import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/group_edit_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/scan_preview_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanner.dart';
import 'package:my_reviewer/src/features/scanned_documents/ui/scan/scan_exit_guard_scope.dart';
import 'package:my_reviewer/src/features/scanned_documents/ui/scan_preview.dart';
import 'package:my_reviewer/src/shared/controllers/task_controller.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/models/selection.dart';
import 'package:provider/provider.dart';

class GroupEditScreen extends StatelessWidget {
  const GroupEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exitGuard = context.select<GroupEditController, ScanExitGuard>(
      (c) => c.exitGuard,
    );
    final saveTask = context.select<GroupEditController, TaskController<void>>(
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
        child: ScanPreview(
          controller: controller,
          saveTask: saveTask,
          // The session is finished once saved (see ScanSessionPhase), so
          // the screen must leave instead of accepting more edits.
          onSaved: (_) => ScanExitGuardScope.leave(context),
          saveAvailability: saveAvailability,
          emptyMessage: t.docs.scan.empty.message,
        ),
      ),
    };
  }
}
