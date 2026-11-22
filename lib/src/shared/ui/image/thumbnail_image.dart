import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/shared/constants/stacked_cards_constants.dart';

/// A saved page image at thumbnail resolution.
class ThumbnailImage extends StatelessWidget {
  const ThumbnailImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
  });

  final String path;

  /// Cover for grid cards; contain where the whole page must show, as in
  /// the viewer while its full image loads.
  final BoxFit fit;

  /// The provider every thumbnail of [path] uses. Shared so anything else
  /// that needs the thumbnail (such as its size) hits the same cache entry
  /// instead of decoding the file again.
  static ImageProvider providerFor(String path) => ResizeImage(
    FileImage(File(path)),
    width: StackedCardsConstants.thumbnailCacheWidth,
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Image(
      image: providerFor(path),
      fit: fit,
      // Keeps the old frame while a rebuilt list re-resolves the same file,
      // so thumbnails do not blink on every stream emission.
      gaplessPlayback: true,
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
