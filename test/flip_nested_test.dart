import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flipclock/theme/fonts.dart' show DigitFont;
import 'package:flipclock/theme/skins.dart';
import 'package:flipclock/widgets/flip_card_row.dart';

final DigitFont _plain = DigitFont(
  id: 'plain',
  name: 'Plain',
  build: (s, c) => TextStyle(fontSize: s, color: c, height: 1.0),
);

class _Host extends StatefulWidget {
  const _Host();
  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  String v = '00';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            const Spacer(),
            FlipCardRow(values: [v], skin: yumekawaSkin, font: _plain),
            const Spacer(),
            ElevatedButton(
              onPressed: () => setState(() => v = '01'),
              child: const Text('go'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets('nested FlipCardRow animates on setState-driven change',
      (tester) async {
    await tester.pumpWidget(const _Host());
    await tester.pump();

    // Trigger a value change exactly like the clock's per-second setState.
    await tester.tap(find.text('go'));
    await tester.pump(); // process setState + didUpdateWidget

    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.binding.hasScheduledFrame, isTrue,
        reason: 'flip animation should be running after a nested change');

    await tester.pumpAndSettle();
  });
}
