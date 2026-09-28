import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flipclock/screens/home_screen.dart';
import 'package:flipclock/services/background_image.dart';
import 'package:flipclock/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a phone-sized photo is shrunk enough to store', () {
    final big = img.Image(width: 3024, height: 4032);
    for (var y = 0; y < big.height; y += 8) {
      for (var x = 0; x < big.width; x += 8) {
        big.setPixelRgb(x, y, x % 255, y % 255, (x + y) % 255);
      }
    }
    final out = shrink(img.encodeJpg(big, quality: 95));
    final decoded = img.decodeImage(out)!;

    expect(decoded.height, BackgroundImage.maxEdge); // long edge capped
    expect(decoded.width, lessThan(decoded.height));
    // Well under the space a browser gives the whole settings store.
    expect(out.lengthInBytes, lessThan(1024 * 1024));
  });

  testWidgets('the photo is kept and shown behind the clock', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = await AppState.create();
    expect(state.backgroundImage, isNull);

    final jpeg = img.encodeJpg(img.Image(width: 40, height: 40), quality: 80);
    await state.setBackgroundImage(jpeg);
    expect(state.backgroundImage, isNotNull);

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(450, 950);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
      value: state,
      child: const MaterialApp(home: HomeScreen()),
    ));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(Image), findsWidgets);

    // A fresh state reads the same photo back out of storage.
    final reloaded = await AppState.create();
    expect(reloaded.backgroundImage, isNotNull);
    expect(reloaded.backgroundImage!.lengthInBytes, jpeg.lengthInBytes);

    await state.clearBackgroundImage();
    expect(state.backgroundImage, isNull);

    await tester.pumpWidget(const SizedBox());
  });
}
