import 'package:audioplayers/audioplayers.dart';

/// A selectable background track. [asset] is null for "None".
class BgmTrack {
  const BgmTrack(this.id, this.name, this.asset);
  final String id;
  final String name;
  final String? asset;
}

const List<BgmTrack> bgmTracks = [
  BgmTrack('none', 'None', null),
  BgmTrack('pink_noise', 'Pink Noise', 'bgm/pink_noise.wav'),
  BgmTrack('brown_noise', 'Brown Noise', 'bgm/brown_noise.wav'),
  BgmTrack('ocean', 'Ocean', 'bgm/ocean.wav'),
  BgmTrack('rain', 'Rain', 'bgm/rain.wav'),
  BgmTrack('dream_pad', 'Dream Pad', 'bgm/dream_pad.wav'),
];

BgmTrack bgmById(String id) =>
    bgmTracks.firstWhere((t) => t.id == id, orElse: () => bgmTracks.first);

/// What the app state needs from a background-sound player; narrow so a test
/// can stand in for the real one.
abstract class BgmPlayer {
  /// Stops whatever is playing and starts [id]. Returns false when playback
  /// could not start, as when a browser is still waiting for a user gesture.
  Future<bool> play(String id);
}

/// Loops the selected calm background track. A single shared player; selecting
/// a new track stops the old one. Browsers only start audio after a user
/// gesture, so there a saved track waits for the first tap (see AppState).
class BgmController implements BgmPlayer {
  BgmController._();
  static final BgmController instance = BgmController._();

  final AudioPlayer _player = AudioPlayer();
  bool _configured = false;

  // Mix with other audio so the app's BGM layers over the user's own music
  // (Spotify / Apple Music) instead of stopping it.
  Future<void> _configure() async {
    if (_configured) return;
    _configured = true;
    try {
      await _player.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {AVAudioSessionOptions.mixWithOthers},
          ),
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );
    } catch (_) {}
  }

  @override
  Future<bool> play(String id) async {
    final track = bgmById(id);
    try {
      await _configure();
      await _player.stop();
      if (track.asset == null) return true;
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource(track.asset!), volume: 0.6);
      return true;
    } catch (_) {
      // Unsupported platform / autoplay blocked.
      return false;
    }
  }
}
