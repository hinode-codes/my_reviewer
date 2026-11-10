import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/controllers/docs_controller.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/models/docs_models.dart';
import 'package:my_reviewer/src/models/docs_selection_mode.dart';
import 'package:my_reviewer/src/widgets/confirmation_dialog.dart';
import 'package:my_reviewer/src/widgets/delete_progress_dialog.dart';
import 'package:provider/provider.dart';

class DocsSelectionAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const DocsSelectionAppBar({super.key, required this.groups});

  final List<ScannedDocumentGroupModel> groups;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final selectionMode = context.select<DocsController, DocsSelectionMode>(
      (c) => c.selectionMode,
    );

    return switch (selectionMode) {
      DocsSelectionMode.active => _ActiveSelectionAppBar(groups: groups),
      DocsSelectionMode.inactive => const _InactiveSelectionAppBar(),
    };
  }
}

class _InactiveSelectionAppBar extends StatelessWidget {
  const _InactiveSelectionAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(t.docs.main.title),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: t.docs.selection.enterSelectionTooltip,
          onPressed: () => context.read<DocsController>().enterSelectionMode(),
          color: Theme.of(context).colorScheme.error,
        ),
      ],
    );
  }
}

class _ActiveSelectionAppBar extends StatelessWidget {
  const _ActiveSelectionAppBar({required this.groups});

  final List<ScannedDocumentGroupModel> groups;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedCount = context.select<DocsController, int>(
      (c) => c.selectedGroupIds.length,
    );
    final totalCount = groups.length;
    final isAllSelected = selectedCount == totalCount;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close_outlined),
        tooltip: t.docs.selection.cancelTooltip,
        onPressed: () => context.read<DocsController>().exitSelectionMode(),
      ),
      title: Text(
        t.docs.selection.selectedLabel(count: selectedCount, total: totalCount),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isAllSelected ? Icons.deselect_outlined : Icons.select_all_outlined,
          ),
          tooltip: isAllSelected
              ? t.docs.selection.deselectAllTooltip
              : t.docs.selection.selectAllTooltip,
          onPressed: () {
            final groupIds = groups.map((g) => g.id).toList();
            context.read<DocsController>().toggleSelectAll(groupIds);
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: t.docs.selection.deleteTooltip,
          onPressed: selectedCount == 0
              ? null
              : () => _confirmAndDelete(context),
          color: colorScheme.error,
        ),
      ],
    );
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final controller = context.read<DocsController>();
    final count = controller.selectedGroupIds.length;

    final choice = await ConfirmationDialog.show(
      context,
      title: t.docs.selection.deleteConfirmTitle(n: count),
      message: t.docs.selection.deleteConfirmMessage,
      confirmLabel: t.docs.selection.deleteButton,
      cancelLabel: t.docs.selection.cancelButton,
      tone: ConfirmTone.destructive,
    );

    if (choice == ConfirmChoice.confirm && context.mounted) {
      await DeleteProgressDialog.run(context, controller: controller);
    }
  }
}
