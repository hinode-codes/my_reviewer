import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/shared/controllers/selection/selectable_items.dart';
import 'package:my_reviewer/src/shared/controllers/task_controller.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/models/confirmation.dart';
import 'package:my_reviewer/src/shared/models/selection.dart';
import 'package:my_reviewer/src/shared/models/task.dart';
import 'package:my_reviewer/src/shared/ui/dialogs/confirmation_dialog.dart';
import 'package:my_reviewer/src/shared/ui/dialogs/task_dialog.dart';

class SelectionAppBar<R> extends StatelessWidget
    implements PreferredSizeWidget {
  const SelectionAppBar({
    super.key,
    required this._title,
    required this._selection,
    required this._deleteTask,
    this._onDeleted,
  });

  final String _title;
  final SelectableItems<Object?> _selection;
  final TaskController<R> _deleteTask;
  final ValueChanged<R>? _onDeleted;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _selection,
      builder: (context, _) => switch (_selection.mode) {
        SelectionMode.inactive => _InactiveSelectionAppBar(
          title: _title,
          selection: _selection,
        ),
        SelectionMode.active => _ActiveSelectionAppBar<R>(
          selection: _selection,
          deleteTask: _deleteTask,
          onDeleted: _onDeleted,
        ),
      },
    );
  }
}

class _InactiveSelectionAppBar extends StatelessWidget {
  const _InactiveSelectionAppBar({
    required this._title,
    required this._selection,
  });

  final String _title;
  final SelectableItems<Object?> _selection;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(_title),
      actions: [
        IconButton(
          onPressed: _selection.items.isEmpty
              ? null
              : _selection.enterSelectionMode,
          icon: const Icon(Icons.delete_outline),
          color: Theme.of(context).colorScheme.error,
          tooltip: t.common.selection.tooltips.deleteInactive,
        ),
      ],
    );
  }
}

class _ActiveSelectionAppBar<R> extends StatelessWidget {
  const _ActiveSelectionAppBar({
    required this._selection,
    required this._deleteTask,
    this._onDeleted,
  });

  final SelectableItems<Object?> _selection;
  final TaskController<R> _deleteTask;
  final ValueChanged<R>? _onDeleted;

  @override
  Widget build(BuildContext context) {
    final count = _selection.selectedCount;
    final total = _selection.totalCount;
    final coverage = _selection.coverage;

    return AppBar(
      leading: IconButton(
        onPressed: _selection.exitSelectionMode,
        icon: const Icon(Icons.close_outlined),
        tooltip: t.common.selection.tooltips.close,
      ),
      title: Text(
        t.common.selection.status.selected(count: count, total: total),
      ),
      actions: [
        IconButton(
          icon: Icon(switch (coverage) {
            SelectionCoverage.all => Icons.deselect_outlined,
            SelectionCoverage.partial => Icons.select_all_outlined,
          }),
          tooltip: switch (coverage) {
            SelectionCoverage.all => t.common.selection.tooltips.deselectAll,
            SelectionCoverage.partial => t.common.selection.tooltips.selectAll,
          },
          onPressed: _selection.toggleSelectAll,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: t.common.selection.tooltips.deleteActive,
          onPressed: count == 0 ? null : () => _confirmAndDelete(context),
          color: Theme.of(context).colorScheme.error,
        ),
      ],
    );
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final choice = await ConfirmationDialog.show(
      context,
      title: t.common.selection.dialogs.delete.title(
        n: _selection.selectedCount,
      ),
      message: t.common.selection.dialogs.delete.message,
      confirmLabel: t.common.actions.confirm,
      cancelLabel: t.common.actions.cancel,
      tone: ConfirmTone.destructive,
    );

    if (choice != ConfirmChoice.confirm || !context.mounted) {
      return;
    }

    final status = await TaskDialog.run(
      context,
      task: _deleteTask,
      kind: TaskKind.delete,
    );

    if (status == TaskStatus.succeeded) {
      _onDeleted?.call(_deleteTask.result as R);
    }
  }
}
