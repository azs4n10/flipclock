import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flipclock/screens/home_screen.dart';
import 'package:flipclock/state/app_state.dart';

import 'support/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a saved track starts playing at launch', () async {
    SharedPreferences.setMockInitialValues({'bgm_id': 'rain'});
    final bgm = FakeBgmPlayer();
    final state = await AppState.create(bgm: bgm, autoplayBlocked: false);
    await pumpEventQueue();

    expect(state.bgmId, 'rain');
    expect(bgm.played, ['rain']);
    expect(state.bgmAwaitingGesture, isFalse);
  });

  test('nothing is played when no track was saved', () async {
    SharedPreferences.setMockInitialValues({});
    final bgm = FakeBgmPlayer();
    final state = await AppState.create(bgm: bgm, autoplayBlocked: false);
    await pumpEventQueue();

    expect(state.bgmId, 'none');
    expect(bgm.played, isEmpty);
    expect(state.bgmAwaitingGesture, isFalse);

    SharedPreferences.setMockInitialValues({'bgm_id': 'none'});
    final blocked = await AppState.create(bgm: bgm, autoplayBlocked: true);
    expect(blocked.bgmAwaitingGesture, isFalse);
    expect(bgm.played, isEmpty);
  });

  test('a track id that no longer exists is treated as none', () async {
    SharedPreferences.setMockInitialValues({'bgm_id': 'gone'});
    final bgm = FakeBgmPlayer();
    await AppState.create(bgm: bgm, autoplayBlocked: false);
    await pumpEventQueue();
    expect(bgm.played, isEmpty);
  });

  test('where sound needs a gesture, the saved track waits for one', () async {
    SharedPreferences.setMockInitialValues({'bgm_id': 'ocean'});
    final bgm = FakeBgmPlayer();
    final state = await AppState.create(bgm: bgm, autoplayBlocked: true);
    addTearDown(state.dispose);
    await pumpEventQueue();

    // Not started, and the state says so instead of pretending.
    expect(bgm.played, isEmpty);
    expect(state.bgmAwaitingGesture, isTrue);

    var notified = 0;
    state.addListener(() => notified++);
    await state.handleUserGesture();
    expect(bgm.played, ['ocean']);
    expect(state.bgmAwaitingGesture, isFalse);
    expect(notified, 1);

    // Later gestures do not start it over.
    await state.handleUserGesture();
    expect(bgm.played, ['ocean']);
  });

  test('a gesture the browser still refuses leaves the track waiting',
      () async {
    SharedPreferences.setMockInitialValues({'bgm_id': 'ocean'});
    final bgm = FakeBgmPlayer()..succeed = false;
    final state = await AppState.create(bgm: bgm, autoplayBlocked: true);
    addTearDown(state.dispose);

    await state.handleUserGesture();
    expect(state.bgmAwaitingGesture, isTrue);

    bgm.succeed = true;
    await state.handleUserGesture();
    expect(bgm.played, ['ocean']);
    expect(state.bgmAwaitingGesture, isFalse);
  });

  test('picking a track ends the wait and plays only the new one', () async {
    SharedPreferences.setMockInitialValues({'bgm_id': 'ocean'});
    final bgm = FakeBgmPlayer();
    final state = await AppState.create(bgm: bgm, autoplayBlocked: true);
    addTearDown(state.dispose);

    await state.setBgm('rain');
    expect(state.bgmAwaitingGesture, isFalse);
    await state.handleUserGesture();
    expect(bgm.played, ['rain']);

    // And the choice is what the next launch restores.
    final next = FakeBgmPlayer();
    await AppState.create(bgm: next, autoplayBlocked: false);
    await pumpEventQueue();
    expect(next.played, ['rain']);
  });

  testWidgets('the first tap anywhere starts the waiting track, so it is '
      'playing by the time Settings shows it selected', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(450, 950);
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'bgm_id': 'dream_pad'});
    final bgm = FakeBgmPlayer();
    final state = await AppState.create(bgm: bgm, autoplayBlocked: true);
    addTearDown(state.dispose);

    await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
      value: state,
      child: const MaterialApp(home: HomeScreen()),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    expect(bgm.played, isEmpty);
    expect(state.bgmAwaitingGesture, isTrue);

    // Opening the settings sheet is itself a tap.
    await tester.tap(find.byIcon(Icons.tune));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(bgm.played, ['dream_pad']);
    expect(state.bgmAwaitingGesture, isFalse);
    expect(find.text('Dream Pad'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
