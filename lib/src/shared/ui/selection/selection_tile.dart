import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/shared/constants/ui_constants.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/models/selection.dart';

class SelectionTile extends StatelessWidget {
  const SelectionTile({
    super.key,
    required this._selection,
    required this._onTap,
    required this._onLongPress,
    required this._child,
  });

  final ItemSelection _selection;
  final VoidCallback _onTap;
  final VoidCallback _onLongPress;
  final Widget _child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final strings = t.common.selection;

    // Not a container, so the tile's texts (name, count, date) merge into
    // this node as its label, together with the GestureDetector's actions.
    return Semantics(
      button: true,
      // Null outside selection mode: a screen reader then announces no
      // selected state, rather than "not selected" on every tile.
      selected: switch (_selection) {
        ItemSelection.unavailable => null,
        ItemSelection.unselected => false,
        ItemSelection.selected => true,
      },
      // Outside selection mode the caller decides what a tap does (open a
      // group, or nothing), so the default hint is kept.
      onTapHint: switch (_selection) {
        ItemSelection.unavailable => null,
        ItemSelection.unselected => strings.semantics.select,
        ItemSelection.selected => strings.semantics.deselect,
      },
      onLongPressHint: switch (_selection) {
        ItemSelection.unavailable => strings.semantics.startSelecting,
        ItemSelection.unselected || ItemSelection.selected => null,
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _onTap();
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _onLongPress();
        },
        child: AnimatedOpacity(
          duration: AnimationConstants.md,
          opacity: switch (_selection) {
            ItemSelection.unselected => SelectionConstants.unselectedOpacity,
            ItemSelection.unavailable ||
            ItemSelection.selected => SelectionConstants.selectedOpacity,
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: AnimationConstants.md,
                padding: const EdgeInsets.all(AppPadding.all),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: switch (_selection) {
                      ItemSelection.selected => colorScheme.primary,
                      // Primary at zero alpha, not Colors.transparent (black
                      // at zero alpha): the border fades out in its own
                      // colour instead of darkening on the way.
                      ItemSelection.unavailable || ItemSelection.unselected =>
                        colorScheme.primary.withValues(alpha: 0),
                    },
                    width: SelectionConstants.selectedBorderWidth,
                  ),
                ),
                child: _child,
              ),
              switch (_selection) {
                ItemSelection.unavailable => const SizedBox.shrink(),
                ItemSelection.unselected || ItemSelection.selected =>
                  _SelectionBadge(selection: _selection),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionBadge extends StatelessWidget {
  const _SelectionBadge({required this.selection});

  final ItemSelection selection;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = selection == ItemSelection.selected;

    return Positioned(
      top: AppSpacing.sm,
      right: AppSpacing.sm,
      child: AnimatedContainer(
        duration: AnimationConstants.sm,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? colorScheme.primary
              : colorScheme.scrim.withValues(
                  alpha: SelectionConstants.unselectedScrimOpacity,
                ),
          border: Border.all(
            color: colorScheme.surface,
            width: SelectionConstants.unselectedBorderWidth,
          ),
        ),
        padding: const EdgeInsets.all(AppPadding.sm),
        child: Icon(
          isSelected ? Icons.check_outlined : null,
          size: SelectionConstants.scrimIconSize,
          color: colorScheme.onPrimary,
        ),
      ),
    );
  }
}
