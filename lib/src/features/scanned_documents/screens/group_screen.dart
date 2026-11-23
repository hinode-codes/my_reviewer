import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/features/scanned_documents/controllers/group_controller.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/ui/document_grid_tile.dart';
import 'package:my_reviewer/src/features/scanned_documents/ui/grid_view.dart';
import 'package:my_reviewer/src/routes.dart';
import 'package:my_reviewer/src/shared/controllers/selection/selectable_items.dart';
import 'package:my_reviewer/src/shared/controllers/task_controller.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/models/deletion.dart';
import 'package:my_reviewer/src/shared/models/selection.dart';
import 'package:my_reviewer/src/shared/ui/selection/selection_app_bar.dart';
import 'package:my_reviewer/src/shared/ui/selection/selection_pop_scope.dart';
import 'package:provider/provider.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selection = context
        .select<GroupController, SelectableItems<ScannedDocumentModel>>(
          (c) => c.documents,
        );
    final deleteTask = context
        .select<GroupController, TaskController<DeletionOutcome>>(
          (c) => c.deleteTask,
        );
    // Selected, not read through `selection`: that instance never changes,
    // so a status read through it would not rebuild this screen when
    // loading finishes.
    final status = context.select<GroupController, ItemsStatus>(
      (c) => c.documents.itemsStatus,
    );
    final groupName = context.select<GroupController, String>(
      (c) => c.groupName ?? t.common.status.loading,
    );

    return SelectionPopScope(
      selection: selection,
      child: switch (status) {
        ItemsStatus.loading => Scaffold(
          body: Center(
            child: CircularProgressIndicator.adaptive(
              semanticsLabel: t.common.status.loading,
            ),
          ),
        ),
        ItemsStatus.ready || ItemsStatus.failed => Scaffold(
          appBar: SelectionAppBar<DeletionOutcome>(
            title: groupName,
            deleteTask: deleteTask,
            selection: selection,
            onDeleted: (outcome) => _onDeleted(context, outcome),
          ),
          floatingActionButton: const _EditFab(),
          body: DocsGridView(
            selection: selection,
            emptyMessage: t.docs.detail.empty.message,
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
    // Selected here, not in GroupScreen: the mode read through the
    // stable `documents` instance there never triggered a rebuild, so the
    // FAB never hid. This also keeps the rebuild to the FAB alone.
    final mode = context.select((GroupController c) => c.documents.mode);

    if (mode.isActive) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      onPressed: () {
        DocsGroupEditRouteData(groupId: context.read<GroupController>().groupId)
            .push(context);
      },
      tooltip: t.docs.detail.tooltips.edit,
      icon: const Icon(Icons.edit_outlined),
      label: Text(t.docs.detail.actions.edit),
    );
  }
}
