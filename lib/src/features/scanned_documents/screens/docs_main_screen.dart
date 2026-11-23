import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/docs_main_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_group_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/ui/grid_view.dart';
import 'package:my_reviewer/src/features/scanned_documents/ui/group_grid_tile.dart';
import 'package:my_reviewer/src/routes.dart';
import 'package:my_reviewer/src/shared/controllers/selection/selectable_items.dart';
import 'package:my_reviewer/src/shared/controllers/task_controller.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/ui/selection/selection_app_bar.dart';
import 'package:my_reviewer/src/shared/ui/selection/selection_pop_scope.dart';
import 'package:provider/provider.dart';

class DocsMainScreen extends StatelessWidget {
  const DocsMainScreen({super.key, this.query});

  final String? query;

  @override
  Widget build(BuildContext context) {
    final selection = context
        .select<DocsMainController, SelectableItems<ScannedDocumentGroupModel>>(
          (c) => c.groups,
        );
    final deleteTask = context.select<DocsMainController, TaskController<void>>(
      (c) => c.deleteTask,
    );

    return SelectionPopScope(
      selection: selection,
      child: Scaffold(
        appBar: SelectionAppBar<void>(
          title: t.docs.main.title,
          selection: selection,
          deleteTask: deleteTask,
        ),
        floatingActionButton: const _ScanFab(),
        body: DocsGridView(
          selection: selection,
          emptyMessage: t.docs.main.empty.message,
          tileBuilder: (context, item) {
            return DocsGroupGridTile(selection: selection, group: item);
          },
        ),
      ),
    );
  }
}

class _ScanFab extends StatelessWidget {
  const _ScanFab();

  @override
  Widget build(BuildContext context) {
    // Selected here, not in DocsMainScreen: `groups` is the same instance for
    // the controller's lifetime, so a mode read through it there never
    // triggered a rebuild, and the FAB never hid. This also keeps the
    // rebuild to the FAB alone.
    final mode = context.select((DocsMainController c) => c.groups.mode);

    if (mode.isActive) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      onPressed: () => const DocsScanPreviewRouteData().push(context),
      label: Text(t.docs.scan.title),
      icon: const Icon(Icons.camera_outlined),
      tooltip: t.docs.scan.title,
    );
  }
}
