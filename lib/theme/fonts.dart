import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A selectable digit font that mirrors one of the iOS lock-screen clock
/// styles. San Francisco itself cannot be redistributed off Apple platforms,
/// so each style maps to a close cross-platform Google Fonts equivalent.
@immutable
class DigitFont {
  const DigitFont({
    required this.id,
    required this.name,
    required TextStyle Function(double fontSize, Color color) builder,
    this.centerBias = 0.0,
    // ignore: prefer_initializing_formals
  }) : _builder = builder;

  final String id;
  final String name;
  final TextStyle Function(double fontSize, Color color) _builder;

  /// Vertical nudge as a fraction of the card height to visually centre the
  /// glyph on the flip seam. Fonts with extra ascent space (serifs) sit low,
  /// so they need a small negative (upward) bias.
  final double centerBias;

  /// Builds the style with tabular (fixed-width) figures so every digit —
  /// including the narrow "1" — occupies the same advance and renders at the
  /// same size when fitted into a flip card.
  TextStyle build(double fontSize, Color color) => _builder(fontSize, color)
      .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}

final List<DigitFont> allFonts = [
  DigitFont(
    id: 'bold',
    name: 'Bold',
    builder: (s, c) => GoogleFonts.inter(
      fontSize: s,
      color: c,
      fontWeight: FontWeight.w800,
      height: 1.0,
      letterSpacing: -2,
    ),
  ),
  DigitFont(
    id: 'light',
    name: 'Light',
    builder: (s, c) => GoogleFonts.inter(
      fontSize: s,
      color: c,
      fontWeight: FontWeight.w300,
      height: 1.0,
      letterSpacing: -1,
    ),
  ),
  DigitFont(
    id: 'rounded',
    name: 'Rounded',
    builder: (s, c) => GoogleFonts.nunito(
      fontSize: s,
      color: c,
      fontWeight: FontWeight.w800,
      height: 1.0,
    ),
  ),
  DigitFont(
    id: 'serif',
    name: 'Serif',
    centerBias: -0.13,
    builder: (s, c) => GoogleFonts.playfairDisplay(
      fontSize: s,
      color: c,
      fontWeight: FontWeight.w700,
      height: 1.0,
    ),
  ),
  DigitFont(
    id: 'serif_heavy',
    name: 'Serif Heavy',
    centerBias: -0.02,
    builder: (s, c) => GoogleFonts.dmSerifDisplay(
      fontSize: s,
      color: c,
      height: 1.0,
    ),
  ),
  DigitFont(
    id: 'slab',
    name: 'Slab',
    builder: (s, c) => GoogleFonts.robotoSlab(
      fontSize: s,
      color: c,
      fontWeight: FontWeight.w800,
      height: 1.0,
    ),
  ),
  DigitFont(
    id: 'stencil',
    name: 'Stencil',
    builder: (s, c) => GoogleFonts.sairaStencilOne(
      fontSize: s,
      color: c,
      height: 1.0,
    ),
  ),
  DigitFont(
    id: 'rails',
    name: 'Rails',
    builder: (s, c) => GoogleFonts.monoton(
      fontSize: s,
      color: c,
      height: 1.0,
    ),
  ),
];

DigitFont fontById(String id) =>
    allFonts.firstWhere((f) => f.id == id, orElse: () => allFonts.first);

/// Font for the display text (date / signature / phase label). Separate from
/// the digit font so the readable headings aren't forced into Stencil etc.
class TextFont {
  const TextFont(this.id, this.name, this._apply);
  final String id;
  final String name;
  final TextStyle Function(TextStyle base) _apply;

  TextStyle style({
    required double fontSize,
    Color? color,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
  }) =>
      _apply(TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
      ));
}

final List<TextFont> textFonts = [
  TextFont('playfair', 'Playfair',
      (b) => GoogleFonts.playfairDisplay(textStyle: b)),
  TextFont('cormorant', 'Cormorant',
      (b) => GoogleFonts.cormorantGaramond(textStyle: b)),
  TextFont('quicksand', 'Quicksand', (b) => GoogleFonts.quicksand(textStyle: b)),
  TextFont('nunito', 'Nunito', (b) => GoogleFonts.nunito(textStyle: b)),
  TextFont('rounded', 'Rounded', (b) => GoogleFonts.mPlusRounded1c(textStyle: b)),
];

TextFont textFontById(String id) =>
    textFonts.firstWhere((f) => f.id == id, orElse: () => textFonts.first);
