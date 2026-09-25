import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Tests must never reach out to the network for a typeface. Without this a
  // font lookup that misses falls through to an HTTP fetch and stalls the
  // whole suite for ~30 seconds per variant.
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}
