import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden comparison that forgives the handful of pixels that differ between
/// operating systems.
///
/// The goldens are generated on Windows and checked on Linux in CI, where text
/// and curve antialiasing come out about 0.2% different. Anything larger than
/// [tolerance] still fails, with the usual diff images written to
/// `test/failures`.
class TolerantGoldenFileComparator extends LocalFileComparator {
  TolerantGoldenFileComparator(super.testFile, {this.tolerance = 0.005})
      : assert(tolerance >= 0 && tolerance < 1);

  /// Largest accepted share of differing pixels, 0.005 meaning 0.5%.
  final double tolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= tolerance) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
