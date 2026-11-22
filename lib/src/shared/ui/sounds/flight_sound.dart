import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/locator.dart';
import 'package:my_reviewer/src/shared/models/sound.dart';
import 'package:my_reviewer/src/shared/services/sound/i_sound_service.dart';

/// The sound for each direction of a hero flight.
typedef FlightSounds = ({UiSound push, UiSound pop});

/// Plays the sound for [direction] once, when the flight it sits in starts.
///
/// Put it at the root of a flightShuttleBuilder's result: a shuttle is built
/// once per flight, so this state's initState is the flight's first frame.
/// The shuttle lives in the navigator's overlay, outside the route's
/// providers, so the service comes from the locator.
class FlightSound extends StatefulWidget {
  const FlightSound({
    super.key,
    required this.sounds,
    required this.direction,
    required this.child,
  });

  final FlightSounds sounds;
  final HeroFlightDirection direction;
  final Widget child;

  @override
  State<FlightSound> createState() => _FlightSoundState();
}

class _FlightSoundState extends State<FlightSound> {
  @override
  void initState() {
    super.initState();

    getIt<ISoundService>().play(switch (widget.direction) {
      HeroFlightDirection.push => widget.sounds.push,
      HeroFlightDirection.pop => widget.sounds.pop,
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
