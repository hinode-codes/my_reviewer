import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/shared/ui/sounds/flight_sound.dart';
import 'package:my_reviewer/src/shared/utils/stack_layout.dart';

/// Flies a stacked card while untilting it from [pose].
///
/// One formula serves both directions because Flutter runs the animation
/// 0 → 1 on push and 1 → 0 on pop. Only the stack side defines a shuttle,
/// and Flutter uses the destination's shuttle, else the source's, so this
/// one is used both ways.
///
/// [sounds] plays once per flight. Every card of a stack flies at the same
/// time, so give it to one card only, or the sound plays once per card.
HeroFlightShuttleBuilder stackCardShuttle({
  required CardPose pose,
  required Widget card,
  FlightSounds? sounds,
}) {
  return (flightContext, animation, direction, fromHeroContext, toHeroContext) {
    final shuttle = AnimatedBuilder(
      animation: animation,
      child: card,
      builder: (context, child) {
        final current = pose.lerpTo(CardPose.rest, animation.value);

        return Transform.translate(
          offset: current.offset,
          child: Transform.rotate(angle: current.angle, child: child),
        );
      },
    );

    return switch (sounds) {
      null => shuttle,
      final sounds => FlightSound(
        sounds: sounds,
        direction: direction,
        child: shuttle,
      ),
    };
  };
}
