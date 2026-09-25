import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flipclock/theme/fonts.dart';

// google_fonts loads a font from the assets when an asset path, minus its
// extension, ends with "<Family>-<Variant>". These are the variants the app
// actually asks for (see theme/fonts.dart); if one is missing the app silently
// falls back to fetching it over the network, or to a different typeface when
// offline.
const List<String> _required = [
  'Inter-ExtraBold',
  'Inter-Light',
  'Monoton-Regular',
  'Nunito-ExtraBold',
  'Nunito-SemiBold',
  'Nunito-Bold',
  'Nunito-MediumItalic',
  'PlayfairDisplay-Bold',
  'PlayfairDisplay-SemiBold',
  'PlayfairDisplay-MediumItalic',
  'DMSerifDisplay-Regular',
  'RobotoSlab-ExtraBold',
  'SairaStencilOne-Regular',
  'CormorantGaramond-SemiBold',
  'CormorantGaramond-Bold',
  'CormorantGaramond-MediumItalic',
  'Quicksand-Regular',
  'Quicksand-Medium',
  'Quicksand-SemiBold',
  'Quicksand-Bold',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every font the app uses is bundled as an asset', () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets();
    for (final name in _required) {
      final found = assets.any((a) =>
          (a.endsWith('.ttf') || a.endsWith('.otf')) &&
          a.substring(0, a.length - 4).endsWith(name));
      expect(found, isTrue, reason: '$name.ttf is not in the bundled assets');
    }
  });

  test('the font licenses ship with them', () async {
    final text = await rootBundle.loadString('assets/google_fonts/OFL.txt');
    expect(text, contains('SIL OPEN FONT LICENSE'));
    expect(text, contains('Apache License')); // Roboto Slab
  });

  test('every offered typeface is one that ships with the app', () {
    // The Rounded text font (M PLUS Rounded 1c) was dropped: its Japanese
    // glyphs weigh ~6.9 MB, and keeping it would mean downloading a font at
    // runtime. Nothing may reintroduce a family that is not bundled.
    expect(textFonts.map((f) => f.id), isNot(contains('rounded')));
    expect(textFonts, hasLength(4));
    expect(allFonts, hasLength(8));
  });

  test('a text font id saved by an older version still resolves', () {
    expect(normalizeTextFontId('rounded'), textFonts.first.id);
    expect(normalizeTextFontId(null), textFonts.first.id);
    expect(normalizeTextFontId('nunito'), 'nunito');
  });
}
