import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/controllers/docs/group_controller.dart';
import 'package:my_reviewer/src/controllers/progress_task.dart';
import 'package:my_reviewer/src/controllers/selection/selectable_items.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/models/deletion.dart';
import 'package:my_reviewer/src/models/docs/view_models.dart';
import 'package:my_reviewer/src/models/selection_state.dart';
import 'package:my_reviewer/src/routes.dart';
import 'package:my_reviewer/src/widgets/common/selection/selection_app_bar.dart';
import 'package:my_reviewer/src/widgets/common/selection/selection_pop_scope.dart';
import 'package:my_reviewer/src/widgets/docs/document_grid_tile.dart';
import 'package:my_reviewer/src/widgets/docs/grid_view.dart';
import 'package:provider/provider.dart';

class DocsGroupScreen extends StatelessWidget {
  const DocsGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selection = context
        .select<DocsGroupController, SelectableItems<ScannedDocumentModel>>(
          (c) => c.documents,
        );
    final deleteTask = context
        .select<DocsGroupController, ProgressTask<DeletionOutcome>>(
          (value) => value.deleteTask,
        );
    // Selected, not read through `selection`: that instance never changes,
    // so a status read through it would not rebuild this screen when
    // loading finishes.
    final status = context.select<DocsGroupController, ItemsStatus>(
      (c) => c.documents.itemsStatus,
    );
    final groupName = context.select<DocsGroupController, String>(
      (c) => c.groupName ?? t.common.status.loading,
    );

    return SelectionPopScope(
      selection: selection,
      child: switch (status) {
        ItemsStatus.loading => Center(
          child: CircularProgressIndicator.adaptive(
            semanticsLabel: t.common.status.loading,
          ),
        ),
        ItemsStatus.ready || ItemsStatus.failed => Scaffold(
          appBar: SelectionAppBar(
            title: groupName,
            deleteTask: deleteTask,
            selection: selection,
            onDeleted: (outcome) => _onDeleted(context, outcome),
          ),
          floatingActionButton: const _EditFab(),
          body: DocsGridView(
            selection: selection,
            emptyMessage: t.docs.detail.noDocs,
            tileBuilder: (context, item) {
              return DocsDocumentGridTile(selection: selection, doc: item);
            },
          ),
        ),
      },
    );
  }

  void _onDeleted(BuildContext context, DeletionOutcome outcome) {
    switch (outcome) {
      case DeletionOutcome.parentDeleted:
        final navigator = Navigator.of(context);

        if (navigator.canPop()) {
          navigator.pop();
        }
      case DeletionOutcome.itemsDeleted:
        break;
    }
  }
}

/// Opens the group in the editor; hidden while pages are being selected.
class _EditFab extends StatelessWidget {
  const _EditFab();

  @override
  Widget build(BuildContext context) {
    // Selected here, not in DocsGroupScreen: the mode read through the
    // stable `documents` instance there never triggered a rebuild, so the
    // FAB never hid. This also keeps the rebuild to the FAB alone.
    final mode = context.select((DocsGroupController c) => c.documents.mode);

    if (mode.isActive) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      onPressed: () {
        DocsGroupEditRouteData(groupId: context.read<DocsGroupController>().docId)
            .push(context);
      },
      tooltip: t.docs.detail.edit.tooltip,
      icon: const Icon(Icons.edit_outlined),
      label: Text(t.docs.detail.edit.label),
    );
  }
}
