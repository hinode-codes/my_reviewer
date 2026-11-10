import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/docs_ui_constants.dart';
import 'package:my_reviewer/src/controllers/docs_controller.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';
import 'package:my_reviewer/src/models/docs_models.dart';
import 'package:my_reviewer/src/routes/docs_router.dart';
import 'package:my_reviewer/src/widgets/stacked_thumbnail_card.dart';
import 'package:provider/provider.dart';

class DocsGroupTile extends StatelessWidget {
  const DocsGroupTile({super.key, required this.group});

  final ScannedDocumentGroupModel group;

  @override
  Widget build(BuildContext context) {
    // Rebuilds ONLY when this specific tile's selection state or selection mode changes
    final isSelectionMode = context.select<DocsController, bool>(
      (c) => c.selectionMode.isActive,
    );
    final isSelected = context.select<DocsController, bool>(
      (c) => c.isGroupSelected(group.id),
    );
    final colorScheme = Theme.of(context).colorScheme;

    final targetOpacity = isSelectionMode
        ? (isSelected
              ? DocsUiConstants.selectedOpacity
              : DocsUiConstants.unselectedOpacity)
        : DocsUiConstants.selectedOpacity;

    return GestureDetector(
      onTap: () {
        final controller = context.read<DocsController>();
        if (isSelectionMode) {
          controller.toggleGroupSelection(group.id);
        } else {
          DocsDetailRoute(
            docId: group.id,
            docName: group.groupName,
          ).push(context);
        }
      },
      onLongPress: () {
        final controller = context.read<DocsController>();
        if (!isSelectionMode) {
          controller.enterSelectionMode(group.id);
        } else {
          controller.toggleGroupSelection(group.id);
        }
      },
      child: AnimatedOpacity(
        duration: DocsUiConstants.animationDuration,
        opacity: targetOpacity,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Border wraps the ENTIRE tile container (thumbnail + metadata)
            AnimatedContainer(
              duration: DocsUiConstants.animationDuration,
              padding: const EdgeInsets.all(DocsUiConstants.spacingSmall),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  DocsUiConstants.spacingMedium,
                ),
                border: Border.all(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  width: DocsUiConstants.selectedBorderWidth,
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: RepaintBoundary(
                      key: ValueKey(group.id),
                      child: StackedThumbnailCard(
                        heroPrefix: group.id,
                        imagePaths: group.documents
                            .map((doc) => doc.absoluteFilePath)
                            .take(3)
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: DocsUiConstants.spacingSmall),
                  Text(
                    group.groupName,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: DocsUiConstants.spacingTiny),
                  Text(
                    t.docs.main.documentCount(n: group.documents.length),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: DocsUiConstants.spacingTiny),
                  Text(
                    DateFormat('MM-dd-yyyy HH:mm').format(group.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelectionMode)
              Positioned(
                top: DocsUiConstants.spacingSmall,
                right: DocsUiConstants.spacingSmall,
                child: AnimatedContainer(
                  duration: DocsUiConstants.badgeAnimationDuration,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.scrim.withValues(alpha: 0.26),
                    border: Border.all(
                      color: colorScheme.surface,
                      width: DocsUiConstants.badgeBorderWidth,
                    ),
                  ),
                  padding: const EdgeInsets.all(DocsUiConstants.spacingTiny),
                  child: Icon(
                    isSelected ? Icons.check : null,
                    size: DocsUiConstants.badgeIconSize,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
