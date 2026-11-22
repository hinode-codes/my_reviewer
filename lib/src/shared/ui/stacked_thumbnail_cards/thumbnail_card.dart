import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/shared/constants/stack_constants.dart';
import 'package:my_reviewer/src/shared/ui/image/thumbnail_image.dart';

/// A page image framed as a card: rounded, bordered and shadowed.
///
/// Both the group stack and the page grid draw pages with this, so a page
/// flying between them as a hero looks the same at both ends.
class ThumbnailCard extends StatelessWidget {
  const ThumbnailCard({super.key, required this.path, this.width, this.height});

  final String path;

  /// Null fills the incoming constraints.
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(StackConstants.cardRadius);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(
              alpha: StackConstants.cardShadowOpacity,
            ),
            blurRadius: StackConstants.cardShadowBlur,
            offset: StackConstants.cardShadowOffset,
          ),
        ],
      ),
      // In front of the image, so the image's corners never cover it.
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: colorScheme.surface,
          width: StackConstants.cardBorderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ThumbnailImage(path: path),
    );
  }
}
