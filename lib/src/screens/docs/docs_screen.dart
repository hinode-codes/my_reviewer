import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/controllers/docs/docs_controller.dart';
import 'package:my_reviewer/src/controllers/progress_task.dart';
import 'package:my_reviewer/src/controllers/selection/selectable_items.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/models/docs/view_models.dart';
import 'package:my_reviewer/src/routes.dart';
import 'package:my_reviewer/src/widgets/common/selection/selection_app_bar.dart';
import 'package:my_reviewer/src/widgets/common/selection/selection_pop_scope.dart';
import 'package:my_reviewer/src/widgets/docs/grid_view.dart';
import 'package:my_reviewer/src/widgets/docs/group_grid_tile.dart';
import 'package:provider/provider.dart';

class DocsScreen extends StatelessWidget {
  const DocsScreen({super.key, this.query});

  final String? query;

  @override
  Widget build(BuildContext context) {
    final selection = context
        .select<DocsController, SelectableItems<ScannedDocumentGroupModel>>(
          (c) => c.groups,
        );
    final deleteTask = context.select<DocsController, ProgressTask<void>>(
      (value) => value.deleteTask,
    );

    return SelectionPopScope(
      selection: selection,
      child: Scaffold(
        appBar: SelectionAppBar(
          title: t.common.title,
          selection: selection,
          deleteTask: deleteTask,
        ),
        floatingActionButton: const _ScanFab(),
        body: DocsGridView(
          selection: selection,
          emptyMessage: t.docs.main.noDocs,
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
    // Selected here, not in DocsScreen: `groups` is the same instance for
    // the controller's lifetime, so a mode read through it there never
    // triggered a rebuild, and the FAB never hid. This also keeps the
    // rebuild to the FAB alone.
    final mode = context.select((DocsController c) => c.groups.mode);

    if (mode.isActive) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      onPressed: () => DocsScanPreviewRouteData().push(context),
      label: Text(t.docs.scan.title),
      icon: const Icon(Icons.camera_outlined),
      tooltip: t.docs.scan.title,
    );
  }
}