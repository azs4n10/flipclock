import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flipclock/main.dart';
import 'package:flipclock/screens/home_screen.dart';
import 'package:flipclock/state/app_state.dart';
import 'package:flipclock/theme/skin.dart';
import 'package:flipclock/theme/skin_theme.dart';
import 'package:flipclock/theme/skins.dart';

void main() {
  const light = [
    yumekawaSkin,
    lavenderSkin,
    mintPeachSkin,
    beigeRoseSkin,
    sugarPinkSkin,
  ];
  const dark = [
    nightStarSkin,
    midnightPlumSkin,
    cocoaNightSkin,
    galaxySkin,
    charcoalRoseSkin,
  ];

  test('every bundled skin is classified, light or dark', () {
    expect({...light, ...dark}, allSkins.toSet());
    for (final s in light) {
      expect(s.brightness, Brightness.light, reason: s.name);
    }
    for (final s in dark) {
      expect(s.brightness, Brightness.dark, reason: s.name);
    }
  });

  test('the theme and the system bar icons follow the skin', () {
    for (final Skin s in allSkins) {
      final theme = themeForSkin(s);
      expect(theme.brightness, s.brightness, reason: s.name);
      expect(theme.colorScheme.brightness, s.brightness, reason: s.name);
      // The skin's own colours are untouched by the change of brightness.
      expect(theme.scaffoldBackgroundColor, s.background);
      expect(theme.colorScheme.primary, s.buttonColor);
      expect(theme.colorScheme.surface, s.background);

      final bars = overlayStyleForSkin(s);
      final icons =
          s.brightness == Brightness.dark ? Brightness.light : Brightness.dark;
      expect(bars.statusBarIconBrightness, icons, reason: s.name);
      expect(bars.systemNavigationBarIconBrightness, icons, reason: s.name);
      expect(bars.statusBarBrightness, s.brightness, reason: s.name);
      expect(bars.systemNavigationBarColor, s.background, reason: s.name);
    }
  });

  testWidgets('a custom skin is judged by its own background', (tester) async {
    SharedPreferences.setMockInitialValues({
      'skin_id': 'custom',
      'custom_bg': 0xFF101018,
    });
    final darkCustom = await AppState.create();
    expect(darkCustom.skin.brightness, Brightness.dark);

    await darkCustom.setCustomColors(bg: const Color(0xFFFFF8F0));
    expect(darkCustom.skin.brightness, Brightness.light);
  });

  testWidgets('the running app switches brightness with the skin',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(450, 950);
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'skin_id': nightStarSkin.id});
    final state = await AppState.create();

    await tester.pumpWidget(FlipclockApp(state: state));
    await tester.pump(const Duration(milliseconds: 300));

    ThemeData theme() => Theme.of(tester.element(find.byType(HomeScreen)));
    expect(theme().brightness, Brightness.dark);
    expect(SystemChrome.latestStyle!.statusBarIconBrightness, Brightness.light);
    expect(SystemChrome.latestStyle!.systemNavigationBarIconBrightness,
        Brightness.light);

    await state.setSkin(beigeRoseSkin);
    // Past the theme's own cross-fade between the two.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(theme().brightness, Brightness.light);
    expect(SystemChrome.latestStyle!.statusBarIconBrightness, Brightness.dark);
    expect(SystemChrome.latestStyle!.systemNavigationBarIconBrightness,
        Brightness.dark);

    await tester.pumpWidget(const SizedBox());
  });
}
