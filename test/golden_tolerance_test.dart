import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'support/tolerant_golden_comparator.dart';

/// A 200x200 white PNG with the first [changed] pixels painted black.
Uint8List _png(int changed, {int size = 200}) {
  final image = img.Image(width: size, height: size);
  img.fill(image, color: img.ColorRgb8(255, 255, 255));
  for (var i = 0; i < changed; i++) {
    image.setPixelRgb(i % size, i ~/ size, 0, 0, 0);
  }
  return img.encodePng(image);
}

void main() {
  late Directory dir;
  late TolerantGoldenFileComparator comparator;
  final golden = Uri.parse('golden.png');

  setUp(() {
    dir = Directory.systemTemp.createTempSync('flipclock_golden');
    File('${dir.path}/golden.png').writeAsBytesSync(_png(0));
    comparator = TolerantGoldenFileComparator(
      Uri.file('${dir.path}/some_test.dart'),
    );
  });

  tearDown(() => dir.deleteSync(recursive: true));

  test('the suite runs with the tolerant comparator installed', () {
    expect(goldenFileComparator, isA<TolerantGoldenFileComparator>());
    expect(
      (goldenFileComparator as TolerantGoldenFileComparator).tolerance,
      lessThanOrEqualTo(0.005),
    );
  });

  test('an identical image passes', () async {
    expect(await comparator.compare(_png(0), golden), isTrue);
  });

  test('a cross-platform sized difference (0.25%) passes', () async {
    // 100 of 40,000 pixels: what the Linux runner reports for these goldens.
    expect(await comparator.compare(_png(100), golden), isTrue);
  });

  test('a difference just over the limit (0.6%) fails', () async {
    await expectLater(
      comparator.compare(_png(240), golden),
      throwsA(isA<FlutterError>()),
    );
  });

  test('a large difference (10%) fails', () async {
    await expectLater(
      comparator.compare(_png(4000), golden),
      throwsA(isA<FlutterError>()),
    );
  });

  test('a different image size fails', () async {
    await expectLater(
      comparator.compare(_png(0, size: 100), golden),
      throwsA(isA<FlutterError>()),
    );
  });
}
