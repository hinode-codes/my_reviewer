import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/docs_ui_constants.dart';

/// A saved page image at thumbnail resolution.
class ThumbnailImage extends StatelessWidget {
  const ThumbnailImage({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Image.file(
      File(path),
      fit: BoxFit.cover,
      // Keeps the old frame while a rebuilt list re-resolves the same file,
      // so thumbnails do not blink on every stream emission.
      gaplessPlayback: true,
      cacheWidth: DocsUiConstants.thumbnailCacheWidth,
      errorBuilder: (_, _, _) => ColoredBox(
        color: colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.broken_image_outlined,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
