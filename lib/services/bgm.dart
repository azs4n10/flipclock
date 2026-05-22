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

/// Loops the selected calm background track. A single shared player; selecting
/// a new track stops the old one. Browsers only start audio after a user
/// gesture, so playback begins when the user picks a track in settings.
class BgmController {
  BgmController._();
  static final BgmController instance = BgmController._();

  final AudioPlayer _player = AudioPlayer();

  Future<void> play(String id) async {
    final track = bgmById(id);
    try {
      await _player.stop();
      if (track.asset == null) return;
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource(track.asset!), volume: 0.6);
    } catch (_) {
      // Unsupported platform / autoplay blocked — ignore.
    }
  }
}
