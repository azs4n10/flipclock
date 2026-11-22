import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'background_photo_store.dart';

BackgroundPhotoStore createBackgroundPhotoStore(SharedPreferences prefs) =>
    Platform.isAndroid || Platform.isIOS
        ? FileBackgroundPhotoStore(getApplicationDocumentsDirectory)
        : PrefsBackgroundPhotoStore(prefs);

/// Keeps the photo as a single file, read once at launch.
class FileBackgroundPhotoStore implements BackgroundPhotoStore {
  FileBackgroundPhotoStore(this._directory);

  /// Looked up on each use rather than held, so a test can point it at a
  /// temporary directory.
  final Future<Directory> Function() _directory;

  static const String fileName = 'background_photo.jpg';

  Future<File> _file() async =>
      File('${(await _directory()).path}${Platform.pathSeparator}$fileName');

  @override
  Future<Uint8List?> read() async {
    final file = await _file();
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();
    return bytes.isEmpty ? null : bytes;
  }

  @override
  Future<void> write(Uint8List jpeg) async {
    final file = await _file();
    // Write beside the target and rename over it, so a crash mid-write
    // cannot leave half a picture behind.
    final temp = File('${file.path}.tmp');
    await temp.writeAsBytes(jpeg, flush: true);
    await temp.rename(file.path);
  }

  @override
  Future<void> clear() async {
    final file = await _file();
    if (await file.exists()) await file.delete();
  }
}
