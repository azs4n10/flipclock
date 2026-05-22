import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flipclock/widgets/seasonal_overlay.dart';

void main() {
  testWidgets('sakura petals render as notched petals', (tester) async {
    tester.view.physicalSize = const Size(600, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: ColoredBox(
          color: Color(0xFFFCE7F3),
          child: SeasonalOverlay(season: Season.sakura),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));

    await expectLater(
      find.byType(SeasonalOverlay),
      matchesGoldenFile('goldens/sakura.png'),
    );

    // Replace the widget so its Ticker is disposed before teardown.
    await tester.pumpWidget(const SizedBox());
  });
}
