import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import 'background_photo_store_web.dart'
    if (dart.library.io) 'background_photo_store_io.dart' as impl;

/// Where the user's background photo (an already shrunk JPEG) is kept.
abstract class BackgroundPhotoStore {
  Future<Uint8List?> read();
  Future<void> write(Uint8List jpeg);
  Future<void> clear();
}

/// The preference the photo used to live in on every platform, as base64.
const String legacyBackgroundPhotoKey = 'bg_image';

/// A file in the app's documents directory on Android and iOS; the settings
/// store everywhere else (in a browser that is localStorage).
BackgroundPhotoStore createBackgroundPhotoStore(SharedPreferences prefs) =>
    impl.createBackgroundPhotoStore(prefs);

/// Keeps the photo as a base64 string beside the other settings. Every
/// launch then loads and decodes it with them, which is why phones use a
/// file instead.
class PrefsBackgroundPhotoStore implements BackgroundPhotoStore {
  PrefsBackgroundPhotoStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<Uint8List?> read() async => decodeLegacyBackgroundPhoto(_prefs);

  @override
  Future<void> write(Uint8List jpeg) =>
      _prefs.setString(legacyBackgroundPhotoKey, base64Encode(jpeg));

  @override
  Future<void> clear() => _prefs.remove(legacyBackgroundPhotoKey);
}

Uint8List? decodeLegacyBackgroundPhoto(SharedPreferences prefs) {
  final stored = prefs.getString(legacyBackgroundPhotoKey);
  if (stored == null || stored.isEmpty) return null;
  try {
    return base64Decode(stored);
  } catch (_) {
    return null;
  }
}

/// Moves a photo saved by an earlier version out of the settings and into
/// [store]. Runs once: the old entry is removed only after the copy has been
/// written, so a failure part-way leaves the photo where it was for the next
/// launch to try again.
Future<void> migrateLegacyBackgroundPhoto(
  SharedPreferences prefs,
  BackgroundPhotoStore store,
) async {
  if (store is PrefsBackgroundPhotoStore) return; // already where it belongs
  if (!prefs.containsKey(legacyBackgroundPhotoKey)) return;
  final bytes = decodeLegacyBackgroundPhoto(prefs);
  if (bytes != null) await store.write(bytes);
  await prefs.remove(legacyBackgroundPhotoKey);
}
