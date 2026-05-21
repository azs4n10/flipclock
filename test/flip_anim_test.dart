import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flipclock/theme/fonts.dart' show DigitFont;
import 'package:flipclock/theme/skins.dart';
import 'package:flipclock/widgets/flip_card.dart';

late DigitFont _font;

Widget _host(String c) => MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFFCE7F3),
        body: Center(
          child: FlipDigit(
            char: c,
            skin: yumekawaSkin,
            font: _font,
            width: 200,
            height: 280,
          ),
        ),
      ),
    );

void main() {
  setUpAll(() async {
    final bytes = File(r'C:\Windows\Fonts\arialbd.ttf').readAsBytesSync();
    final loader = FontLoader('TestArial')
      ..addFont(Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)));
    await loader.load();
    _font = DigitFont(
      id: 'test',
      name: 'Test',
      build: (s, c) => TextStyle(
        fontFamily: 'TestArial',
        fontSize: s,
        color: c,
        fontWeight: FontWeight.w800,
        height: 1.0,
      ),
    );
  });

  testWidgets('FlipDigit folds across the animation', (tester) async {
    await tester.pumpWidget(_host('1'));
    await tester.pump();

    await tester.pumpWidget(_host('2'));
    await tester.pump();

    // Phase 1: the old digit's top flap is folding down.
    await tester.pump(const Duration(milliseconds: 170));
    expect(tester.binding.hasScheduledFrame, isTrue,
        reason: 'should still be animating in phase 1');
    await expectLater(
      find.byType(FlipDigit),
      matchesGoldenFile('goldens/flip_phase1.png'),
    );

    // Phase 2: the new digit's bottom flap is dropping into place.
    await tester.pump(const Duration(milliseconds: 480));
    await expectLater(
      find.byType(FlipDigit),
      matchesGoldenFile('goldens/flip_phase2.png'),
    );

    await tester.pumpAndSettle();
  });
}
