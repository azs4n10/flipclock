import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flipclock/screens/home_screen.dart';
import 'package:flipclock/services/timer_notifier.dart';
import 'package:flipclock/state/app_state.dart';
import 'package:flipclock/state/timer_snapshot.dart';
import 'package:flipclock/widgets/flip_card.dart';

import 'support/fakes.dart';

const int _countUp = 0;
const int _countDown = 1;
const int _target = 2;

Map<String, Object> _prefs(TimerSnapshot t) => {
      'timer_mode': t.mode,
      'timer_running': t.running,
      'timer_started_millis': t.startedAtMillis,
      'timer_accumulated_millis': t.accumulatedMillis,
      'timer_countdown_millis': t.countDownMillis,
      'timer_target_millis': t.targetMillis,
    };

int _ago(Duration d) => DateTime.now().subtract(d).millisecondsSinceEpoch;
int _ahead(Duration d) => DateTime.now().add(d).millisecondsSinceEpoch;

Widget _wrap(AppState state) => ChangeNotifierProvider<AppState>.value(
      value: state,
      child: const MaterialApp(home: HomeScreen()),
    );

Future<void> _pumpFor(WidgetTester tester, int ms) async {
  for (var i = 0; i < ms ~/ 100; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Launches the app on [prefs] and opens the Timer page.
Future<(AppState, FakeTimerNotifier)> _launch(
  WidgetTester tester,
  Map<String, Object>? prefs,
) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(600, 1000);
  addTearDown(tester.view.reset);
  // Null relaunches on whatever the previous session left in storage.
  if (prefs != null) SharedPreferences.setMockInitialValues(prefs);
  final notifier = FakeTimerNotifier();
  final state = await AppState.create(notifier: notifier);
  await tester.pumpWidget(_wrap(state));
  await _pumpFor(tester, 300);
  await tester.tap(find.text('Timer'));
  await _pumpFor(tester, 500);
  return (state, notifier);
}

/// The HH:MM:SS on the flip cards, in seconds.
int _shownSeconds(WidgetTester tester) {
  final parts = tester
      .widgetList<FlipGroup>(find.byType(FlipGroup))
      .map((g) => int.parse(g.value))
      .toList();
  expect(parts, hasLength(3));
  return parts[0] * 3600 + parts[1] * 60 + parts[2];
}

void main() {
  group('stored snapshot', () {
    final cases = <String, TimerSnapshot>{
      'Count Up running': TimerSnapshot(
        mode: _countUp,
        running: true,
        startedAtMillis: _ago(const Duration(seconds: 90)),
        accumulatedMillis: 4200,
        countDownMillis: 600000,
        targetMillis: _ahead(const Duration(hours: 1)),
      ),
      'Count Up paused': TimerSnapshot(
        mode: _countUp,
        running: false,
        startedAtMillis: 0,
        accumulatedMillis: 75000,
        countDownMillis: 600000,
        targetMillis: _ahead(const Duration(hours: 1)),
      ),
      'Count Down running': TimerSnapshot(
        mode: _countDown,
        running: true,
        startedAtMillis: _ago(const Duration(seconds: 60)),
        accumulatedMillis: 0,
        countDownMillis: 330000,
        targetMillis: _ahead(const Duration(hours: 1)),
      ),
      'Count Down paused': TimerSnapshot(
        mode: _countDown,
        running: false,
        startedAtMillis: 0,
        accumulatedMillis: 12345,
        countDownMillis: 330000,
        targetMillis: _ahead(const Duration(hours: 1)),
      ),
      'Target running': TimerSnapshot(
        mode: _target,
        running: true,
        startedAtMillis: _ago(const Duration(minutes: 3)),
        accumulatedMillis: 0,
        countDownMillis: 600000,
        targetMillis: _ahead(const Duration(hours: 2)),
      ),
      'Target paused': TimerSnapshot(
        mode: _target,
        running: false,
        startedAtMillis: 0,
        accumulatedMillis: 0,
        countDownMillis: 600000,
        targetMillis: _ahead(const Duration(days: 3)),
      ),
    };

    test('nothing is reported before a timer has ever been saved', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      expect((await AppState.create()).timerSnapshot, isNull);
    });

    for (final entry in cases.entries) {
      test('${entry.key} survives a new AppState', () async {
        TestWidgetsFlutterBinding.ensureInitialized();
        SharedPreferences.setMockInitialValues({});
        final first = await AppState.create(notifier: FakeTimerNotifier());
        await first.saveTimer(entry.value);

        // A fresh state stands for the next launch: it has only the store.
        final second = await AppState.create(notifier: FakeTimerNotifier());
        expect(second.timerSnapshot, entry.value);
      });
    }
  });

  group('the Timer page on relaunch', () {
    testWidgets('a running stopwatch has kept counting', (tester) async {
      final (_, notifier) = await _launch(
        tester,
        _prefs(TimerSnapshot(
          mode: _countUp,
          running: true,
          startedAtMillis: _ago(const Duration(seconds: 90)),
          accumulatedMillis: 30000,
          countDownMillis: 600000,
          targetMillis: 0,
        )),
      );
      expect(find.text('Pause'), findsOneWidget);
      expect(_shownSeconds(tester), closeTo(120, 3)); // 30s before + 90s away
      expect(notifier.log, isEmpty); // a stopwatch has nothing to announce

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('a paused stopwatch shows where it stopped', (tester) async {
      await _launch(
        tester,
        _prefs(const TimerSnapshot(
          mode: _countUp,
          running: false,
          startedAtMillis: 0,
          accumulatedMillis: 75000,
          countDownMillis: 600000,
          targetMillis: 0,
        )),
      );
      expect(find.text('Start'), findsOneWidget);
      expect(_shownSeconds(tester), 75);

      // And carries on from there.
      await tester.tap(find.text('Start'));
      await _pumpFor(tester, 300);
      expect(find.text('Pause'), findsOneWidget);
      expect(_shownSeconds(tester), closeTo(75, 2));

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('a running countdown has kept counting', (tester) async {
      final started = _ago(const Duration(seconds: 60));
      final (_, notifier) = await _launch(
        tester,
        _prefs(TimerSnapshot(
          mode: _countDown,
          running: true,
          startedAtMillis: started,
          accumulatedMillis: 0,
          countDownMillis: 330000, // 5:30
          targetMillis: 0,
        )),
      );
      expect(find.text('Pause'), findsOneWidget);
      expect(_shownSeconds(tester), closeTo(270, 3)); // 5:30 less the minute
      // Booked again for the same end, without a permission prompt at launch.
      expect(notifier.log, ['schedule:${NoticeId.timer}']);
      expect(
        notifier.pending[NoticeId.timer]!.at.millisecondsSinceEpoch,
        started + 330000,
      );

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('a paused countdown keeps the length set on the wheels',
        (tester) async {
      final (state, _) = await _launch(
        tester,
        _prefs(const TimerSnapshot(
          mode: _countDown,
          running: false,
          startedAtMillis: 0,
          accumulatedMillis: 0,
          countDownMillis: 3930000, // 1:05:30
          targetMillis: 0,
        )),
      );
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Scroll to set the length'), findsOneWidget);

      await tester.tap(find.text('Start'));
      await _pumpFor(tester, 300);
      expect(_shownSeconds(tester), closeTo(3930, 2));
      expect(state.timerSnapshot!.running, isTrue);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('a countdown that ended while away is stopped, not restarted',
        (tester) async {
      final (state, notifier) = await _launch(
        tester,
        _prefs(TimerSnapshot(
          mode: _countDown,
          running: true,
          startedAtMillis: _ago(const Duration(minutes: 20)),
          accumulatedMillis: 0,
          countDownMillis: 600000,
          targetMillis: 0,
        )),
      );
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Pause'), findsNothing);
      expect(state.timerSnapshot!.running, isFalse);
      expect(notifier.log, ['cancel:${NoticeId.timer}']);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('a running target is still being counted down to',
        (tester) async {
      final target = _ahead(const Duration(hours: 2));
      final (_, notifier) = await _launch(
        tester,
        _prefs(TimerSnapshot(
          mode: _target,
          running: true,
          startedAtMillis: _ago(const Duration(minutes: 3)),
          accumulatedMillis: 0,
          countDownMillis: 600000,
          targetMillis: target,
        )),
      );
      expect(find.text('Pause'), findsOneWidget);
      expect(_shownSeconds(tester), closeTo(7200, 3));
      expect(
        notifier.pending[NoticeId.timer]!.at.millisecondsSinceEpoch,
        target,
      );

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('a target that was set but not started is kept',
        (tester) async {
      final target = DateTime.now().add(const Duration(days: 3));
      await _launch(
        tester,
        _prefs(TimerSnapshot(
          mode: _target,
          running: false,
          startedAtMillis: 0,
          accumulatedMillis: 0,
          countDownMillis: 600000,
          targetMillis: target.millisecondsSinceEpoch,
        )),
      );
      expect(find.text('Start'), findsOneWidget);
      expect(
        find.text(DateFormat('MMM d, yyyy  HH:mm').format(target)),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('a target reached while away is stopped', (tester) async {
      final (state, notifier) = await _launch(
        tester,
        _prefs(TimerSnapshot(
          mode: _target,
          running: true,
          startedAtMillis: _ago(const Duration(hours: 2)),
          accumulatedMillis: 0,
          countDownMillis: 600000,
          targetMillis: _ago(const Duration(hours: 1)),
        )),
      );
      expect(find.text('Start'), findsOneWidget);
      expect(_shownSeconds(tester), 0);
      expect(state.timerSnapshot!.running, isFalse);
      expect(notifier.log, ['cancel:${NoticeId.timer}']);

      await tester.pumpWidget(const SizedBox());
    });
  });

  group('what the Timer page saves comes back on the next launch', () {
    Future<void> relaunchAndExpect(
      WidgetTester tester, {
      required String button,
      required int mode,
    }) async {
      // Tear the first session down, then start again on the same storage.
      await tester.pumpWidget(const SizedBox());
      await _launch(tester, null);
      expect(find.text(button), findsOneWidget);
      // Each mode has a line of its own under the tabs.
      expect(find.text('Tap Start to begin'),
          mode == _countUp ? findsOneWidget : findsNothing);
      expect(find.text('Target: '),
          mode == _target ? findsOneWidget : findsNothing);
    }

    testWidgets('Count Up, running then paused', (tester) async {
      await _launch(tester, {});
      await tester.tap(find.text('Start'));
      await _pumpFor(tester, 300);

      await relaunchAndExpect(tester, button: 'Pause', mode: _countUp);

      await tester.tap(find.text('Pause'));
      await _pumpFor(tester, 300);
      final stoppedAt = _shownSeconds(tester);
      await relaunchAndExpect(tester, button: 'Start', mode: _countUp);
      expect(_shownSeconds(tester), stoppedAt);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('Count Down, running then paused', (tester) async {
      await _launch(tester, {});
      await tester.tap(find.text('Count Down'));
      await _pumpFor(tester, 400);
      await tester.tap(find.text('Start'));
      await _pumpFor(tester, 300);

      await relaunchAndExpect(tester, button: 'Pause', mode: _countDown);
      expect(_shownSeconds(tester), closeTo(600, 3)); // the 10-minute default
      expect(find.text('Scroll to set the length'), findsNothing);

      await tester.tap(find.text('Pause'));
      await _pumpFor(tester, 300);
      await relaunchAndExpect(tester, button: 'Start', mode: _countDown);
      expect(find.text('Scroll to set the length'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('Target, running then paused', (tester) async {
      await _launch(tester, {});
      await tester.tap(find.text('Target'));
      await _pumpFor(tester, 400);
      final shownTarget = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .firstWhere((s) => RegExp(r'^\w{3} \d+, \d{4}  \d\d:\d\d$').hasMatch(s));
      await tester.tap(find.text('Start'));
      await _pumpFor(tester, 300);

      await relaunchAndExpect(tester, button: 'Pause', mode: _target);
      expect(find.text(shownTarget), findsOneWidget);
      expect(_shownSeconds(tester), closeTo(3600, 3));

      await tester.tap(find.text('Pause'));
      await _pumpFor(tester, 300);
      await relaunchAndExpect(tester, button: 'Start', mode: _target);
      expect(find.text(shownTarget), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
