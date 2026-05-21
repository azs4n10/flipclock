import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import '../state/app_state.dart';

/// Plays the chime and triggers haptics when a timer or pomodoro phase ends,
/// respecting the user's sound/vibration toggles.
class Alerts {
  Alerts._();

  static final AudioPlayer _player = AudioPlayer();

  static Future<void> notify(AppState state) async {
    if (state.remindSoundEnabled) {
      try {
        await _player.stop();
        await _player.play(AssetSource('sounds/chime.wav'));
      } catch (_) {
        // Audio can fail on some platforms (e.g. web autoplay policy); ignore.
      }
    }
    if (state.vibrationEnabled) {
      // HapticFeedback is a no-op on platforms without a vibrator (e.g. web).
      await HapticFeedback.heavyImpact();
      await Future<void>.delayed(const Duration(milliseconds: 120));
      await HapticFeedback.mediumImpact();
    }
  }
}
