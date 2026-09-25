import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flipclock/screens/home_screen.dart';
import 'package:flipclock/services/app_actions.dart';
import 'package:flipclock/screens/pomodoro_screen.dart';
import 'package:flipclock/screens/timer_screen.dart';
import 'package:flipclock/state/app_state.dart';
import 'package:flipclock/widgets/flip_card.dart';

Future<Widget> _app(Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  final state = await AppState.create();
  return ChangeNotifierProvider<AppState>.value(
    value: state,
    child: const MaterialApp(home: HomeScreen()),
  );
}

String _digits(WidgetTester tester) =>
    tester.widgetList<FlipGroup>(find.byType(FlipGroup)).map((g) => g.value).join(':');

Future<void> _pumpFor(WidgetTester tester, int ms) async {
  for (var i = 0; i < ms ~/ 100; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void _size(WidgetTester tester, Size logical) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = logical;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('a pomodoro that ended while the app was away moves to the break',
      (tester) async {
    _size(tester, const Size(450, 950));
    await tester.pumpWidget(await _app({
      'pomo_running': true,
      'pomo_phase': 0, // focus
      'pomo_completed': 2,
      'pomo_end_millis': DateTime.now()
          .subtract(const Duration(minutes: 5))
          .millisecondsSinceEpoch,
    }));
    await _pumpFor(tester, 500);
    await tester.tap(find.text('Pomodoro'));
    await _pumpFor(tester, 500);

    // Not stuck on 00:00, and the finished focus block is counted.
    expect(_digits(tester), '05:00'); // default short break
    expect(find.text('Completed: 3'), findsOneWidget);
    expect(find.textContaining('Start Short Break'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('start recovers even from a zero remaining time', (tester) async {
    _size(tester, const Size(450, 950));
    await tester.pumpWidget(await _app({
      'pomo_running': false,
      'pomo_phase': 0,
      'pomo_remaining_sec': 0,
    }));
    await _pumpFor(tester, 500);
    await tester.tap(find.text('Pomodoro'));
    await _pumpFor(tester, 500);

    await tester.tap(find.textContaining('Start'));
    await _pumpFor(tester, 300);
    expect(find.text('Pause'), findsOneWidget);
    expect(_digits(tester), isNot('00:00'));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a running pomodoro survives a tab switch', (tester) async {
    _size(tester, const Size(450, 950));
    await tester.pumpWidget(await _app({}));
    await _pumpFor(tester, 500);

    await tester.tap(find.text('Pomodoro'));
    await _pumpFor(tester, 500);
    await tester.tap(find.textContaining('Start'));
    await _pumpFor(tester, 500);
    expect(find.text('Pause'), findsOneWidget);
    final before = tester.state(find.byType(PomodoroScreen, skipOffstage: false));

    await tester.tap(find.text('Clock'));
    await _pumpFor(tester, 600);
    await tester.tap(find.text('Pomodoro'));
    await _pumpFor(tester, 600);

    // Same State object: the page was never torn down, so the ticker and the
    // phase it was counting are still the ones the user started.
    final after = tester.state(find.byType(PomodoroScreen, skipOffstage: false));
    expect(identical(before, after), isTrue);
    expect(find.text('Pause'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the timer keeps its mode and its run across a tab switch',
      (tester) async {
    _size(tester, const Size(450, 950));
    await tester.pumpWidget(await _app({}));
    await _pumpFor(tester, 500);

    await tester.tap(find.text('Timer'));
    await _pumpFor(tester, 500);
    await tester.tap(find.text('Count Down'));
    await _pumpFor(tester, 400);
    await tester.tap(find.text('Start'));
    await _pumpFor(tester, 500);
    expect(find.text('Pause'), findsOneWidget);
    final before = tester.state(find.byType(TimerScreen, skipOffstage: false));

    await tester.tap(find.text('Clock'));
    await _pumpFor(tester, 600);
    await tester.tap(find.text('Timer'));
    await _pumpFor(tester, 600);

    final after = tester.state(find.byType(TimerScreen, skipOffstage: false));
    expect(identical(before, after), isTrue);
    expect(find.text('Pause'), findsOneWidget); // still counting down
    expect(_digits(tester), isNot('00:00:00')); // still the 10-minute default

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the top bar fits a narrow screen', (tester) async {
    _size(tester, const Size(320, 640));
    await tester.pumpWidget(await _app({}));
    await _pumpFor(tester, 500);
    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.tune), findsOneWidget);
    expect(find.byIcon(Icons.palette_outlined), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the settings sheet offers the new entries', (tester) async {
    _size(tester, const Size(450, 950));
    await tester.pumpWidget(await _app({}));
    await _pumpFor(tester, 500);

    await tester.tap(find.byIcon(Icons.tune));
    await _pumpFor(tester, 800);

    expect(find.text('Keep screen on'), findsOneWidget);
    expect(find.text('Privacy policy'), findsOneWidget);
    // The feedback entry is hidden until the app has an address of its own,
    // so it can never open an empty mail draft.
    expect(find.text('Send feedback'),
        AppActions.contactEmail.isEmpty ? findsNothing : findsOneWidget);

    final row = find
        .ancestor(of: find.text('Keep screen on'), matching: find.byType(Row))
        .first;
    final toggle = find.descendant(of: row, matching: find.byType(Switch));
    expect(tester.widget<Switch>(toggle).value, isFalse);
    await tester.tap(toggle);
    await _pumpFor(tester, 400);
    expect(tester.widget<Switch>(toggle).value, isTrue);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('12-hour mode shows a meridiem', (tester) async {
    _size(tester, const Size(450, 950));
    await tester.pumpWidget(await _app({'use_24_hour': false}));
    await _pumpFor(tester, 500);
    final expected = DateTime.now().hour < 12 ? 'AM' : 'PM';
    expect(find.text(expected), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
