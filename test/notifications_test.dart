import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flipclock/screens/home_screen.dart';
import 'package:flipclock/services/timer_notifier.dart';
import 'package:flipclock/state/app_state.dart';

import 'support/fakes.dart';

Future<Widget> _app(Map<String, Object> prefs, FakeTimerNotifier notifier) async {
  SharedPreferences.setMockInitialValues(prefs);
  final state = await AppState.create(notifier: notifier);
  return ChangeNotifierProvider<AppState>.value(
    value: state,
    child: const MaterialApp(home: HomeScreen()),
  );
}

Future<void> _pumpFor(WidgetTester tester, int ms) async {
  for (var i = 0; i < ms ~/ 100; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

// Wide enough for the Target row in the test font, whose glyphs are square.
void _size(WidgetTester tester) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(600, 1000);
  addTearDown(tester.view.reset);
}

/// Lets the wall clock, which the countdowns read, really move on.
Future<void> _realWait(WidgetTester tester, int ms) =>
    tester.runAsync(() => Future<void>.delayed(Duration(milliseconds: ms)));

Matcher _about(DateTime expected) => predicate<DateTime>(
      (at) => at.difference(expected).abs() < const Duration(seconds: 5),
      'within 5s of $expected',
    );

void main() {
  testWidgets('a pomodoro books its notice on start and withdraws it on pause '
      'and reset', (tester) async {
    _size(tester);
    final notifier = FakeTimerNotifier();
    await tester.pumpWidget(await _app({}, notifier));
    await _pumpFor(tester, 500);

    // Nothing is asked of the user just for opening the app.
    expect(notifier.log, isEmpty);

    await tester.tap(find.text('Pomodoro'));
    await _pumpFor(tester, 500);
    expect(notifier.log, isEmpty);

    await tester.tap(find.textContaining('Start'));
    await _pumpFor(tester, 300);
    // Permission is asked the first time a countdown starts, then the notice
    // is booked for the moment the focus block ends.
    expect(notifier.log, ['ask', 'schedule:${NoticeId.pomodoro}']);
    final first = notifier.pending[NoticeId.pomodoro]!;
    expect(first.title, 'Focus complete');
    expect(first.at, _about(DateTime.now().add(const Duration(minutes: 25))));
    expect(first.sound, isTrue);

    await tester.tap(find.text('Pause'));
    await _pumpFor(tester, 300);
    expect(notifier.log.last, 'cancel:${NoticeId.pomodoro}');
    expect(notifier.pending, isEmpty);

    // Starting again books again, without asking a second time.
    await tester.tap(find.textContaining('Start'));
    await _pumpFor(tester, 300);
    expect(notifier.asks, 1);
    expect(notifier.pending[NoticeId.pomodoro]!.title, 'Focus complete');

    await tester.tap(find.text('Reset'));
    await _pumpFor(tester, 300);
    expect(notifier.log.last, 'cancel:${NoticeId.pomodoro}');
    expect(notifier.pending, isEmpty);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('each pomodoro phase books a notice of its own', (tester) async {
    _size(tester);
    final notifier = FakeTimerNotifier();
    final end = DateTime.now().add(const Duration(milliseconds: 1500));
    await tester.pumpWidget(await _app({
      'pomo_running': true,
      'pomo_phase': 0, // focus
      'pomo_completed': 0,
      'pomo_end_millis': end.millisecondsSinceEpoch,
    }, notifier));
    await _pumpFor(tester, 300);
    await tester.tap(find.text('Pomodoro'));
    await _pumpFor(tester, 300);

    // A countdown restored at launch is booked again (a browser tab loses
    // its bookings), but launch is not the moment to ask for permission.
    expect(notifier.log, ['schedule:${NoticeId.pomodoro}']);
    expect(notifier.pending[NoticeId.pomodoro]!.title, 'Focus complete');
    expect(
      notifier.pending[NoticeId.pomodoro]!.at.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
    );

    // The focus block ends with the app in front: the chime and the flash
    // announce it, so the notice is withdrawn rather than repeated.
    await _realWait(tester, 1800);
    await _pumpFor(tester, 700);
    expect(find.textContaining('Start Short Break'), findsOneWidget);
    expect(notifier.log.last, 'cancel:${NoticeId.pomodoro}');
    expect(notifier.pending, isEmpty);

    // The flash stays until it is tapped away.
    expect(find.text('Focus complete'), findsOneWidget);
    await tester.tap(find.text('Focus complete'));
    await _pumpFor(tester, 300);

    // The break is a new countdown with a new notice.
    await tester.tap(find.textContaining('Start Short Break'));
    await _pumpFor(tester, 300);
    final next = notifier.pending[NoticeId.pomodoro]!;
    expect(next.title, 'Break over');
    expect(next.at, _about(DateTime.now().add(const Duration(minutes: 5))));

    await tester.tap(find.text('Reset'));
    await _pumpFor(tester, 300);
    await tester.pumpWidget(const SizedBox());
    await _pumpFor(tester, 3000); // let the completion flash timers run out
  });

  testWidgets('a phase that ends in the background keeps its notice',
      (tester) async {
    _size(tester);
    final notifier = FakeTimerNotifier();
    final end = DateTime.now().add(const Duration(milliseconds: 1500));
    await tester.pumpWidget(await _app({
      'pomo_running': true,
      'pomo_phase': 0,
      'pomo_end_millis': end.millisecondsSinceEpoch,
    }, notifier));
    await _pumpFor(tester, 300);
    await tester.tap(find.text('Pomodoro'));
    await _pumpFor(tester, 300);
    expect(notifier.pending, contains(NoticeId.pomodoro));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    addTearDown(() => tester.binding
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed));

    // The ticker may still fire while the app is behind another one. It must
    // not withdraw the one thing that can reach the user there.
    await _realWait(tester, 1800);
    await _pumpFor(tester, 700);
    expect(notifier.log.where((e) => e.startsWith('cancel')), isEmpty);
    expect(notifier.pending, contains(NoticeId.pomodoro));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await _pumpFor(tester, 300);
    await tester.pumpWidget(const SizedBox());
    await _pumpFor(tester, 3000);
  });

  testWidgets('a pomodoro that ended while the app was closed clears its '
      'notice and asks for nothing', (tester) async {
    _size(tester);
    final notifier = FakeTimerNotifier();
    await tester.pumpWidget(await _app({
      'pomo_running': true,
      'pomo_phase': 0,
      'pomo_end_millis': DateTime.now()
          .subtract(const Duration(minutes: 5))
          .millisecondsSinceEpoch,
    }, notifier));
    await _pumpFor(tester, 300);
    await tester.tap(find.text('Pomodoro'));
    await _pumpFor(tester, 300);

    // The catch-up to the next phase still happens.
    expect(find.textContaining('Start Short Break'), findsOneWidget);
    expect(notifier.log, ['cancel:${NoticeId.pomodoro}']);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a countdown books its notice on start and withdraws it on '
      'pause, reset and a change of mode', (tester) async {
    _size(tester);
    final notifier = FakeTimerNotifier();
    await tester.pumpWidget(await _app({}, notifier));
    await _pumpFor(tester, 500);
    await tester.tap(find.text('Timer'));
    await _pumpFor(tester, 500);

    // A stopwatch has no end to announce.
    await tester.tap(find.text('Start'));
    await _pumpFor(tester, 300);
    expect(notifier.log.where((e) => e.startsWith('schedule')), isEmpty);
    expect(notifier.asks, 0);

    await tester.tap(find.text('Count Down'));
    await _pumpFor(tester, 400);
    notifier.log.clear();

    await tester.tap(find.text('Start'));
    await _pumpFor(tester, 300);
    expect(notifier.log, ['ask', 'schedule:${NoticeId.timer}']);
    final booked = notifier.pending[NoticeId.timer]!;
    expect(booked.title, "Time's up");
    expect(booked.at, _about(DateTime.now().add(const Duration(minutes: 10))));

    await tester.tap(find.text('Pause'));
    await _pumpFor(tester, 300);
    expect(notifier.log.last, 'cancel:${NoticeId.timer}');
    expect(notifier.pending, isEmpty);

    await tester.tap(find.text('Start'));
    await _pumpFor(tester, 300);
    expect(notifier.asks, 1);
    expect(notifier.pending, contains(NoticeId.timer));

    await tester.tap(find.text('Reset'));
    await _pumpFor(tester, 300);
    expect(notifier.pending, isEmpty);

    await tester.tap(find.text('Start'));
    await _pumpFor(tester, 300);
    expect(notifier.pending, contains(NoticeId.timer));

    await tester.tap(find.text('Target'));
    await _pumpFor(tester, 400);
    expect(notifier.pending, isEmpty);

    // Target mode books for the target itself (an hour ahead by default).
    await tester.tap(find.text('Start'));
    await _pumpFor(tester, 300);
    expect(
      notifier.pending[NoticeId.timer]!.at,
      _about(DateTime.now().add(const Duration(hours: 1))),
    );

    await tester.tap(find.text('Reset'));
    await _pumpFor(tester, 300);
    expect(notifier.pending, isEmpty);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the timer and the pomodoro keep separate notices',
      (tester) async {
    _size(tester);
    final notifier = FakeTimerNotifier();
    await tester.pumpWidget(await _app({'remind_sound': false}, notifier));
    await _pumpFor(tester, 500);

    await tester.tap(find.text('Pomodoro'));
    await _pumpFor(tester, 500);
    await tester.tap(find.textContaining('Start'));
    await _pumpFor(tester, 300);

    await tester.tap(find.text('Timer'));
    await _pumpFor(tester, 600);
    await tester.tap(find.text('Count Down'));
    await _pumpFor(tester, 400);
    await tester.tap(find.text('Start'));
    await _pumpFor(tester, 300);

    expect(notifier.pending.keys,
        unorderedEquals([NoticeId.pomodoro, NoticeId.timer]));
    expect(notifier.asks, 1); // asked once, whichever countdown came first
    // With the remind sound switched off, the notices are silent too.
    expect(notifier.pending.values.every((n) => !n.sound), isTrue);

    await tester.tap(find.text('Pause'));
    await _pumpFor(tester, 300);
    expect(notifier.pending.keys, [NoticeId.pomodoro]);

    await tester.pumpWidget(const SizedBox());
  });

  test('a notifier that throws does not break a countdown', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final state = await AppState.create(notifier: _ThrowingNotifier());
    await state.scheduleCompletionNotice(
      id: NoticeId.timer,
      at: DateTime.now().add(const Duration(minutes: 1)),
      title: 't',
      body: 'b',
    );
    await state.cancelCompletionNotice(NoticeId.timer);
  });
}

class _ThrowingNotifier implements TimerNotifier {
  @override
  Future<bool> requestPermission() => throw StateError('no permission api');

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    bool sound = true,
  }) =>
      throw StateError('cannot schedule');

  @override
  Future<void> cancel(int id) => throw StateError('cannot cancel');
}
