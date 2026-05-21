import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flipclock/widgets/pill_button.dart';
import 'package:flipclock/theme/skins.dart';

void main() {
  testWidgets('PillButton renders its label', (tester) async {
    var pressed = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PillButton(
          label: 'Start',
          onPressed: () => pressed = true,
          skin: yumekawaSkin,
        ),
      ),
    ));

    expect(find.text('Start'), findsOneWidget);
    await tester.tap(find.text('Start'));
    expect(pressed, isTrue);
  });
}
