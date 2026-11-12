import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/utils/stack_layout.dart';

/// Flies a stacked card while untilting it from [pose].
///
/// One formula serves both directions because Flutter runs the animation
/// 0 → 1 on push and 1 → 0 on pop. Only the stack side defines a shuttle,
/// and Flutter uses the destination's shuttle, else the source's, so this
/// one is used both ways.
HeroFlightShuttleBuilder stackCardShuttle({
  required CardPose pose,
  required Widget card,
}) {
  return (flightContext, animation, direction, fromHeroContext, toHeroContext) {
    return AnimatedBuilder(
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
  };
}
