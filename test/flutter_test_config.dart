import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'support/tolerant_golden_comparator.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Tests must never reach out to the network for a typeface. Without this a
  // font lookup that misses falls through to an HTTP fetch and stalls the
  // whole suite for ~30 seconds per variant.
  GoogleFonts.config.allowRuntimeFetching = false;

  // The goldens come from Windows; Linux CI renders them ~0.2% differently.
  // Allow up to 0.5% so the same files serve every host. The comparator's own
  // limits are pinned by test/golden_tolerance_test.dart.
  final current = goldenFileComparator;
  if (current is LocalFileComparator) {
    goldenFileComparator = TolerantGoldenFileComparator(
      current.basedir.resolve('flutter_test_config.dart'),
    );
  }
  await testMain();
}
