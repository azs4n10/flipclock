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
    // ignore: prefer_initializing_formals
  }) : _builder = builder;

  final String id;
  final String name;
  final TextStyle Function(double fontSize, Color color) _builder;

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
