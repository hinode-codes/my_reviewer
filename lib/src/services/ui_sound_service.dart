import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:my_reviewer/src/models/ui_sound.dart';

/// Plays short UI sounds. Sound is a nicety: nothing here ever throws into
/// the UI, and a sound that cannot play is simply skipped.
abstract interface class IUiSoundService {
  /// Starts the audio engine and loads every [UiSound]. Until it finishes,
  /// [play] is silent.
  Future<void> init();

  /// Plays [sound] as soon as possible. Fire and forget.
  void play(UiSound sound);
}

/// [IUiSoundService] on flutter_soloud, whose `play` starts a preloaded
/// sound at the next output buffer, the lowest latency it offers.
///
/// The sounds are decoration, so they must never disturb the device's own
/// audio: music and podcasts from other apps keep playing underneath, and
/// the iPhone's Silent switch mutes them.
class SoLoudUiSoundService implements IUiSoundService {
  SoLoudUiSoundService({SoLoud? soloud}) : _soloud = soloud ?? SoLoud.instance;

  final SoLoud _soloud;
  final Map<UiSound, AudioSource> _sources = {};

  /// Output buffer in frames. A sound starts on a buffer boundary, so this
  /// bounds the delay: about 23 ms at 44.1 kHz, against about 46 ms for the
  /// engine's default of 2048. Smaller risks crackle on slow devices.
  static const int _bufferSizeFrames = 1024;

  /// How long the output stays open after the last sound. The engine's
  /// default of 500 ms closes it between almost every pair of navigations,
  /// and reopening it delays the next sound. Long enough to stay open while
  /// someone browses; short enough not to hold it all session.
  static const Duration _deviceIdleTimeout = Duration(seconds: 30);

  /// iOS ambient: mixes with other apps' audio instead of interrupting it,
  /// and is silenced by the Silent switch and screen lock.
  ///
  /// The session is deliberately never activated with setActive(true): on
  /// Android that requests audio focus, which pauses other apps' music.
  /// SoLoud plays without asking for focus, so it simply mixes.
  static const AudioSessionConfiguration _politeSession =
      AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.ambient,
      );

  @override
  Future<void> init() async {
    try {
      // flutter_soloud leaves the OS audio session alone, so the app sets
      // it. Before the engine starts, so the engine never opens the output
      // under iOS's default category, which interrupts other apps' audio.
      final session = await AudioSession.instance;
      await session.configure(_politeSession);

      await _soloud.init(bufferSize: _bufferSizeFrames);

      // And again after it, as audio_session advises applying the app's
      // configuration once other audio code has loaded, in case the
      // engine's backend set a category of its own while starting.
      await session.configure(_politeSession);

      _soloud.setAudioDeviceIdleTimeout(_deviceIdleTimeout);

      // Loaded together, and fully into memory (the default mode), so
      // playing one later does no decoding or disk work.
      final sources = await [
        for (final sound in UiSound.values) _soloud.loadAsset(sound.asset),
      ].wait;

      for (final (index, sound) in UiSound.values.indexed) {
        _sources[sound] = sources[index];
      }
    } catch (err) {
      // No output device, a missing asset, or a session that could not be
      // made polite: the app works the same, silent. Nothing is loaded, so
      // play stays a no-op rather than risk disturbing other audio.
      debugPrint('UI sounds unavailable: $err');
    }
  }

  @override
  void play(UiSound sound) {
    final source = _sources[sound];

    debugPrint("\n\nPLAYING SOUNDS!\n\n");

    if (source == null || !_soloud.isInitialized) {
      return;
    }

    try {
    debugPrint("\n\nPLAYING SOUNDS NOW!\n\n");
      _soloud.play(source);
    } catch (err) {
      debugPrint('UI sound $sound failed to play: $err');
    }
  }
}
