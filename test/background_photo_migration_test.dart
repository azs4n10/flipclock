import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flipclock/services/background_photo_store.dart';
import 'package:flipclock/services/background_photo_store_io.dart';
import 'package:flipclock/state/app_state.dart';

/// A store whose disk is full until [broken] is cleared.
class _FlakyStore implements BackgroundPhotoStore {
  _FlakyStore(this._inner);

  final BackgroundPhotoStore _inner;
  bool broken = true;

  @override
  Future<Uint8List?> read() => _inner.read();

  @override
  Future<void> write(Uint8List jpeg) =>
      broken ? throw const FileSystemException('full') : _inner.write(jpeg);

  @override
  Future<void> clear() => _inner.clear();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final photo = Uint8List.fromList(List<int>.generate(4096, (i) => i % 251));
  late Directory dir;
  late FileBackgroundPhotoStore store;
  File photoFile() => File(
      '${dir.path}${Platform.pathSeparator}${FileBackgroundPhotoStore.fileName}');

  setUp(() {
    dir = Directory.systemTemp.createTempSync('flipclock_photo');
    store = FileBackgroundPhotoStore(() async => dir);
  });

  tearDown(() => dir.deleteSync(recursive: true));

  test('a photo saved by an earlier version moves into a file, once',
      () async {
    SharedPreferences.setMockInitialValues({
      legacyBackgroundPhotoKey: base64Encode(photo),
      'bg_scrim': 50,
    });

    final state = await AppState.create(photoStore: store);
    expect(state.backgroundImage, photo); // still shown on the first launch
    expect(photoFile().readAsBytesSync(), photo);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(legacyBackgroundPhotoKey), isFalse);
    expect(state.backgroundScrim, 50); // the other settings are untouched

    // The next launch has only the file to go on.
    final next = await AppState.create(photoStore: store);
    expect(next.backgroundImage, photo);
    expect(prefs.containsKey(legacyBackgroundPhotoKey), isFalse);
  });

  test('a launch with nothing saved creates nothing', () async {
    SharedPreferences.setMockInitialValues({});
    final state = await AppState.create(photoStore: store);
    expect(state.backgroundImage, isNull);
    expect(photoFile().existsSync(), isFalse);
  });

  test('an unreadable old entry is dropped rather than carried over',
      () async {
    SharedPreferences.setMockInitialValues({
      legacyBackgroundPhotoKey: 'not base64 at all!',
    });
    final state = await AppState.create(photoStore: store);
    expect(state.backgroundImage, isNull);
    expect(photoFile().existsSync(), isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(legacyBackgroundPhotoKey), isFalse);
  });

  test('if the file cannot be written the old copy stays and is still shown',
      () async {
    SharedPreferences.setMockInitialValues({
      legacyBackgroundPhotoKey: base64Encode(photo),
    });
    final flaky = _FlakyStore(store);
    final state = await AppState.create(photoStore: flaky);
    expect(state.backgroundImage, photo);
    final prefs = await SharedPreferences.getInstance();
    // Left in place so the next launch can try the move again.
    expect(prefs.containsKey(legacyBackgroundPhotoKey), isTrue);
    expect(photoFile().existsSync(), isFalse);

    // A photo chosen in the meantime must not be undone by that old copy
    // being migrated over it on the following launch.
    flaky.broken = false;
    final chosen = Uint8List.fromList([5, 4, 3, 2, 1]);
    await state.setBackgroundImage(chosen);
    expect(prefs.containsKey(legacyBackgroundPhotoKey), isFalse);
    expect((await AppState.create(photoStore: flaky)).backgroundImage, chosen);
  });

  test('where the settings are the store, nothing is moved', () async {
    SharedPreferences.setMockInitialValues({
      legacyBackgroundPhotoKey: base64Encode(photo),
    });
    final prefs = await SharedPreferences.getInstance();
    final state =
        await AppState.create(photoStore: PrefsBackgroundPhotoStore(prefs));
    expect(state.backgroundImage, photo);
    expect(prefs.getString(legacyBackgroundPhotoKey), base64Encode(photo));
  });

  test('choosing and removing a photo goes through the file', () async {
    SharedPreferences.setMockInitialValues({});
    final state = await AppState.create(photoStore: store);
    final prefs = await SharedPreferences.getInstance();

    await state.setBackgroundImage(photo);
    expect(state.backgroundImage, photo);
    expect(photoFile().readAsBytesSync(), photo);
    expect(prefs.containsKey(legacyBackgroundPhotoKey), isFalse);
    expect(File('${photoFile().path}.tmp').existsSync(), isFalse);

    final replacement = Uint8List.fromList([9, 8, 7, 6]);
    await state.setBackgroundImage(replacement);
    expect(photoFile().readAsBytesSync(), replacement);

    await state.clearBackgroundImage();
    expect(state.backgroundImage, isNull);
    expect(photoFile().existsSync(), isFalse);
    expect((await AppState.create(photoStore: store)).backgroundImage, isNull);
  });
}
