import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/shared/constants/image_constants.dart';
import 'package:my_reviewer/src/shared/constants/stack_constants.dart';
import 'package:my_reviewer/src/shared/models/sound.dart';
import 'package:my_reviewer/src/shared/ui/sounds/flight_sound.dart';
import 'package:my_reviewer/src/shared/utils/stack_layout.dart';

import 'stack_card_shuttle.dart';
import 'thumbnail_card.dart';

/// The stack opening into its group, and gathering back.
const FlightSounds _stackSounds = (
  push: UiSound.stackSpread,
  pop: UiSound.stackGather,
);

/// Up to [StackConstants.maxVisibleCards] page images fanned out as a
/// stack, each a hero that untilts as it flies to the page view.
class StackedThumbnailCard extends StatelessWidget {
  const StackedThumbnailCard({
    super.key,
    required this.imagePaths,
    required this.heroTags,
    this.width,
    this.height,
    this.cardAspectRatio = ImageConstants.defaultCardAspectRatio,
  }) : assert(
         imagePaths.length == heroTags.length,
         'Every image needs exactly one hero tag.',
       );

  final List<String> imagePaths;

  /// One hero tag per entry in [imagePaths], same order.
  final List<String> heroTags;
  final double? width;
  final double? height;

  /// Document aspect ratio (width / height).
  final double cardAspectRatio;

  @override
  Widget build(BuildContext context) {
    if (imagePaths.isEmpty) {
      return _StackPlaceholder(width: width, height: height);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final displayPaths = imagePaths
            .take(StackConstants.maxVisibleCards)
            .toList();
        final layout = computeStackLayout(
          available: Size(
            width ?? constraints.maxWidth,
            height ?? constraints.maxHeight,
          ),
          count: displayPaths.length,
          cardAspectRatio: cardAspectRatio,
        );
        final frontIndex = displayPaths.length - 1;

        return Center(
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              for (final (index, path) in displayPaths.indexed)
                _StackCardHero(
                  tag: heroTags[index],
                  pose: layout.poses[index],
                  // Every card flies at once; only the front one sounds.
                  sounds: index == frontIndex ? _stackSounds : null,
                  card: ThumbnailCard(
                    path: path,
                    width: layout.cardSize.width,
                    height: layout.cardSize.height,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// One card of the stack, posed, as a hero.
class _StackCardHero extends StatelessWidget {
  const _StackCardHero({
    required this.tag,
    required this.pose,
    required this.sounds,
    required this.card,
  });

  final String tag;
  final CardPose pose;
  final FlightSounds? sounds;
  final Widget card;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: stackCardShuttle(
        pose: pose,
        card: card,
        sounds: sounds,
      ),
      transitionOnUserGestures: true,
      // The pose lives inside the Hero. A transform above it would bake the
      // tilt into the rect the flight measures, so the shuttle (which adds
      // the pose itself) and the resting card would disagree, and the cards
      // beneath the top one would snap into place when a pop lands.
      child: Transform.translate(
        offset: pose.offset,
        child: Transform.rotate(angle: pose.angle, child: card),
      ),
    );
  }
}

/// Shown for a group with no pages.
class _StackPlaceholder extends StatelessWidget {
  const _StackPlaceholder({required this.width, required this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: width ?? constraints.maxWidth,
          height: height ?? constraints.maxHeight,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(
              StackConstants.placeholderRadius,
            ),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Icon(
            Icons.folder_open,
            size: StackConstants.placeholderIconSize,
            color: colorScheme.onSurfaceVariant,
          ),
        );
      },
    );
  }
}
