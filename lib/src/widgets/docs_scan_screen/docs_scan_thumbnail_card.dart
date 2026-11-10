import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/docs_scan_constants.dart';
import 'package:my_reviewer/src/constants/ui_constants.dart';
import 'package:my_reviewer/src/widgets/page_number_badge.dart';

/// How strongly a thumbnail stands out from its siblings.
enum ThumbnailEmphasis {
  normal(borderWidth: DocsScanConstants.thumbnailBorderWidth),
  selected(borderWidth: DocsScanConstants.thumbnailSelectedBorderWidth);

  const ThumbnailEmphasis({required this.borderWidth});

  final double borderWidth;

  Color borderColor(ColorScheme colorScheme) => switch (this) {
    ThumbnailEmphasis.normal => colorScheme.outlineVariant,
    ThumbnailEmphasis.selected => colorScheme.primary,
  };
}

/// One scanned page in the group sheet: the image with its page number, and
/// the page's name as a caption beneath it.
class DocsScanThumbnailCard extends StatelessWidget {
  const DocsScanThumbnailCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.pageNumber,
    required this.emphasis,
    required this.onTap,
  });

  final String imagePath;
  final String name;
  final int pageNumber;
  final ThumbnailEmphasis emphasis;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: AppDurations.fast,
            width: DocsScanConstants.thumbnailWidth,
            height: DocsScanConstants.thumbnailHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: emphasis.borderColor(colorScheme),
                width: emphasis.borderWidth,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(File(imagePath), fit: BoxFit.cover),
                Positioned(
                  bottom: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: PageNumberBadge(pageNumber: pageNumber),
                ),
              ],
            ),
          ),
          if (name.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              width: DocsScanConstants.thumbnailWidth,
              child: _ThumbnailName(name: name),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThumbnailName extends StatelessWidget {
  const _ThumbnailName({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      name,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }
}
