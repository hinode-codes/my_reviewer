import 'dart:io';
import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/shared/constants/image_constants.dart';
import 'package:my_reviewer/src/shared/constants/stack_constants.dart';
import 'package:my_reviewer/src/shared/constants/ui_constants.dart';
import 'package:my_reviewer/src/shared/models/sound.dart';
import 'package:my_reviewer/src/shared/ui/image/page_aspect_builder.dart';
import 'package:my_reviewer/src/shared/ui/image/thumbnail_image.dart';
import 'package:my_reviewer/src/shared/ui/sounds/flight_sound.dart';

const FlightSounds _pageSounds = (
  push: UiSound.pageOpen,
  pop: UiSound.pageClose,
);

/// Flies one page image between the grid's card and the full-screen viewer.
/// Excludes transient flight geometry from semantics and honors Reduce Motion.
HeroFlightShuttleBuilder buildPageFlightShuttle(String absolutePath) {
  return (flightContext, animation, direction, fromHeroContext, toHeroContext) {
    final colorScheme = Theme.of(flightContext).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(flightContext);

    return ExcludeSemantics(
      child: FlightSound(
        sounds: _pageSounds,
        direction: direction,
        child: PageAspectBuilder(
          path: absolutePath,
          builder: (context, pageAspectRatio) => AnimatedBuilder(
            animation: animation,
            child: ThumbnailImage(path: absolutePath),
            builder: (context, image) {
              // Snap immediately to target shape when Reduce Motion is enabled.
              final t = reduceMotion ? 1.0 : animation.value;
              final frame = 1 - t;
              final radius = BorderRadius.circular(
                StackConstants.cardRadius * frame,
              );

              return Center(
                child: AspectRatio(
                  aspectRatio: lerpDouble(
                    ImageConstants.defaultCardAspectRatio,
                    pageAspectRatio,
                    t,
                  )!,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(
                            alpha: StackConstants.cardShadowOpacity * frame,
                          ),
                          blurRadius: StackConstants.cardShadowBlur,
                          offset: StackConstants.cardShadowOffset,
                        ),
                      ],
                    ),
                    foregroundDecoration: BoxDecoration(
                      borderRadius: radius,
                      border: Border.all(
                        color: colorScheme.surface.withValues(alpha: frame),
                        width: StackConstants.cardBorderWidth,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: image,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  };
}

/// The page at full resolution, fading in over its cached thumbnail once ready.
/// Marked decorative internally because parent [ZoomablePage] provides the
/// structured page semantic label.
class FullPageImage extends StatelessWidget {
  const FullPageImage({super.key, required this.absolutePath});

  final String absolutePath;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return ExcludeSemantics(
      child: Image.file(
        File(absolutePath),
        fit: BoxFit.contain,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || reduceMotion) {
            return child;
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              ThumbnailImage(path: absolutePath, fit: BoxFit.contain),
              AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: AnimationConstants.sm,
                child: child,
              ),
            ],
          );
        },
      ),
    );
  }
}
