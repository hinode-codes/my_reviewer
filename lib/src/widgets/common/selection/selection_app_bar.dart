import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/controllers/progress_task.dart';
import 'package:my_reviewer/src/controllers/selection/selectable_items.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/models/operation.dart';
import 'package:my_reviewer/src/models/selection_state.dart';
import 'package:my_reviewer/src/widgets/common/dialogs/progress_dialog.dart';
import 'package:my_reviewer/src/widgets/common/dialogs/confirmation_dialog.dart';

class SelectionAppBar<R> extends StatelessWidget implements PreferredSizeWidget {
  const SelectionAppBar({
    super.key,
    required this._title,
    required this._selection,
    required this._deleteTask,
    this._onDeleted,
  });

  final String _title;
  final SelectableItems<Object?> _selection;
  final ProgressTask<R> _deleteTask;
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
        SelectionMode.active => _ActiveSelectionAppBar(
          selection: _selection,
          deleteTask: _deleteTask,
          onDeleted: _onDeleted,
        ),
      },
    );
  }
}

class _InactiveSelectionAppBar extends StatelessWidget {
  const _InactiveSelectionAppBar({required this._title, required this._selection});

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
          tooltip: t.common.selection.delete.inactive.tooltip,
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
  final ProgressTask<R> _deleteTask;
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
        tooltip: t.common.selection.close.tooltip,
      ),
      title: Text(t.common.selection.label(count: count, total: total)),
      actions: [
        IconButton(
          icon: Icon(switch (coverage) {
            SelectionCoverage.all => Icons.deselect_outlined,
            SelectionCoverage.partial => Icons.select_all_outlined,
          }),
          tooltip: switch (coverage) {
            SelectionCoverage.all =>
              t.common.selection.selectAllButton.deselectAll.tooltip,
            SelectionCoverage.partial =>
              t.common.selection.selectAllButton.selectAll.tooltip,
          },
          onPressed: _selection.toggleSelectAll,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: t.common.selection.delete.active.tooltip,
          onPressed: count == 0 ? null : () => _confirmAndDelete(context),
          color: Theme.of(context).colorScheme.error,
        ),
      ],
    );
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final choice = await ConfirmationDialog.show(
      context,
      title: t.common.selection.delete.confirmationDialog.title(
        n: _selection.selectedCount,
      ),
      message: t.common.selection.delete.confirmationDialog.message,
      confirmLabel: t.common.buttons.confirm,
      cancelLabel: t.common.buttons.cancel,
      tone: ConfirmTone.destructive,
    );

    if (choice != ConfirmChoice.confirm || !context.mounted) {
      return;
    }

    final status = await ProgressDialog.run(
      context,
      task: _deleteTask,
      kind: OperationKind.delete,
    );

    if (status == OperationStatus.succeeded) {
      _onDeleted?.call(_deleteTask.result as R);
    }
  }
}
