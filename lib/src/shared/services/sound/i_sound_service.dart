import 'package:my_reviewer/src/shared/models/sound.dart';

/// Plays short UI sounds. Sound is a nicety: nothing here ever throws into
/// the UI, and a sound that cannot play is simply skipped.
abstract interface class ISoundService {
  Future<void> initialize();
  void play(UiSound sound);
  void dispose();
}
