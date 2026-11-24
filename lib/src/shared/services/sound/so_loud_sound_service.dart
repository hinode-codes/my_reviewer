import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:my_reviewer/src/shared/models/sound.dart';
import 'package:my_reviewer/src/shared/services/sound/i_sound_service.dart';

class SoLoudSoundService implements ISoundService {
  SoLoudSoundService({SoLoud? soloud}) : _soloud = soloud ?? SoLoud.instance;

  final SoLoud _soloud;
  final Map<UiSound, AudioSource> _sources = {};

  /// How long the output stays open after the last sound. The engine's
  /// default of 500 ms closes it between almost every pair of navigations,
  /// and reopening it delays the next sound. Long enough to stay open while
  /// someone browses; short enough not to hold it all session.
  static const Duration _deviceIdleTimeout = Duration(seconds: 15);

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
  Future<void> initialize() async {
    try {
      // flutter_soloud leaves the OS audio session alone, so the app sets
      // it. Before the engine starts, so the engine never opens the output
      // under iOS's default category, which interrupts other apps' audio.
      final session = await AudioSession.instance;

      await session.configure(_politeSession);
      _soloud.setAudioDeviceIdleTimeout(_deviceIdleTimeout);

      await _soloud.init();
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

    if (source == null || !_soloud.isInitialized) {
      return;
    }

    try {
      _soloud.play(source);
    } catch (err) {
      debugPrint('UI sound $sound failed to play: $err');
    }
  }

  @override
  void dispose() {
    _soloud.deinit();
  }
}
