import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/docs_ui_constants.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/models/selection_state.dart';

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
    final strings = t.common.selection.tile;

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
        ItemSelection.unselected => strings.select,
        ItemSelection.selected => strings.deselect,
      },
      onLongPressHint: switch (_selection) {
        ItemSelection.unavailable => strings.startSelecting,
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
          duration: DocsUiConstants.animationDuration,
          opacity: switch (_selection) {
            ItemSelection.unselected => DocsUiConstants.unselectedOpacity,
            ItemSelection.unavailable ||
            ItemSelection.selected => DocsUiConstants.selectedOpacity,
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: DocsUiConstants.animationDuration,
                padding: const EdgeInsets.all(DocsUiConstants.spacingSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    DocsUiConstants.spacingMedium,
                  ),
                  border: Border.all(
                    color: switch (_selection) {
                      ItemSelection.selected => colorScheme.primary,
                      // Primary at zero alpha, not Colors.transparent (black
                      // at zero alpha): the border fades out in its own
                      // colour instead of darkening on the way.
                      ItemSelection.unavailable ||
                      ItemSelection.unselected => colorScheme.primary
                          .withValues(alpha: 0),
                    },
                    width: DocsUiConstants.selectedBorderWidth,
                  ),
                ),
                child: _child,
              ),
              switch (_selection) {
                ItemSelection.unavailable => const SizedBox.shrink(),
                ItemSelection.unselected ||
                ItemSelection.selected => _SelectionBadge(
                  selection: _selection,
                ),
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
      top: DocsUiConstants.spacingSmall,
      right: DocsUiConstants.spacingSmall,
      child: AnimatedContainer(
        duration: DocsUiConstants.badgeAnimationDuration,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? colorScheme.primary
              : colorScheme.scrim.withValues(
                  alpha: DocsUiConstants.badgeScrimOpacity,
                ),
          border: Border.all(
            color: colorScheme.surface,
            width: DocsUiConstants.badgeBorderWidth,
          ),
        ),
        padding: const EdgeInsets.all(DocsUiConstants.spacingTiny),
        child: Icon(
          isSelected ? Icons.check_outlined : null,
          size: DocsUiConstants.badgeIconSize,
          color: colorScheme.onPrimary,
        ),
      ),
    );
  }
}