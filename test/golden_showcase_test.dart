import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flipclock/theme/fonts.dart' show DigitFont;
import 'package:flipclock/theme/skin.dart';
import 'package:flipclock/theme/skins.dart';
import 'package:flipclock/widgets/flip_card_row.dart';
import 'package:flipclock/widgets/pill_button.dart';
import 'package:flipclock/widgets/segmented_tabs.dart';

// Plain font that avoids google_fonts' runtime network fetch in tests.
final DigitFont _testFont = DigitFont(
  id: 'test',
  name: 'Test',
  build: (s, c) => TextStyle(
    fontSize: s,
    color: c,
    fontWeight: FontWeight.w800,
    height: 1.0,
    letterSpacing: -2,
  ),
);

Widget _showcase(Skin skin) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: skin.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SegmentedTabs(
                items: const ['Pomodoro', 'Clock', 'Timer'],
                selectedIndex: 1,
                onChanged: (_) {},
                skin: skin,
              ),
              const SizedBox(height: 24),
              Text(
                'May 21, 2026  Thu',
                style: TextStyle(
                  fontSize: 16,
                  color: skin.primaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              FlipCardRow(
                values: const ['14', '38', '02'],
                skin: skin,
                font: _testFont,
              ),
              const SizedBox(height: 18),
              Text(
                'less is more',
                style: TextStyle(
                  fontSize: 14,
                  color: skin.subTextColor,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  PillButton(
                    label: 'Start Focus',
                    onPressed: () {},
                    skin: skin,
                    icon: Icons.play_arrow,
                  ),
                  PillButton(
                    label: 'Reset',
                    onPressed: () {},
                    skin: skin,
                    outlined: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('showcase yumekawa', (tester) async {
    tester.view.physicalSize = const Size(860, 1864);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_showcase(yumekawaSkin));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/showcase_yumekawa.png'),
    );
  });

  testWidgets('showcase night_star', (tester) async {
    tester.view.physicalSize = const Size(860, 1864);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_showcase(nightStarSkin));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/showcase_night_star.png'),
    );
  });
}
