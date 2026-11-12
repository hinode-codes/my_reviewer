import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/controllers/selection/selectable_items.dart';

class SelectionPopScope extends StatelessWidget {
  const SelectionPopScope({
    super.key,
    required this.selection,
    required this.child,
  });

  final SelectableItems<Object?> selection;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: selection,
      builder: (context, _) {
        final isSelectionActive = selection.mode.isActive;
        // TickerMode is true when this tab is active/visible, and false when hidden offstage in IndexedStack
        final isTabVisible = TickerMode.valuesOf(context).enabled;
        // Only intercept pop events when selection mode is active AND this tab is currently visible
        final shouldInterceptPop = isSelectionActive && isTabVisible;

        return PopScope(
          canPop: !shouldInterceptPop,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && shouldInterceptPop) {
              selection.exitSelectionMode();
            }
          },
          child: child,
        );
      },
    );
  }
}
