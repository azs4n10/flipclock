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
    required this.build,
  });

  final String id;
  final String name;
  final TextStyle Function(double fontSize, Color color) build;
}

final List<DigitFont> allFonts = [
  DigitFont(
    id: 'bold',
    name: 'Bold',
    build: (s, c) => GoogleFonts.inter(
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
    build: (s, c) => GoogleFonts.inter(
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
    build: (s, c) => GoogleFonts.nunito(
      fontSize: s,
      color: c,
      fontWeight: FontWeight.w800,
      height: 1.0,
    ),
  ),
  DigitFont(
    id: 'serif',
    name: 'Serif',
    build: (s, c) => GoogleFonts.playfairDisplay(
      fontSize: s,
      color: c,
      fontWeight: FontWeight.w700,
      height: 1.0,
    ),
  ),
  DigitFont(
    id: 'serif_heavy',
    name: 'Serif Heavy',
    build: (s, c) => GoogleFonts.dmSerifDisplay(
      fontSize: s,
      color: c,
      height: 1.0,
    ),
  ),
  DigitFont(
    id: 'slab',
    name: 'Slab',
    build: (s, c) => GoogleFonts.robotoSlab(
      fontSize: s,
      color: c,
      fontWeight: FontWeight.w800,
      height: 1.0,
    ),
  ),
  DigitFont(
    id: 'stencil',
    name: 'Stencil',
    build: (s, c) => GoogleFonts.sairaStencilOne(
      fontSize: s,
      color: c,
      height: 1.0,
    ),
  ),
  DigitFont(
    id: 'rails',
    name: 'Rails',
    build: (s, c) => GoogleFonts.monoton(
      fontSize: s,
      color: c,
      height: 1.0,
    ),
  ),
];

DigitFont fontById(String id) =>
    allFonts.firstWhere((f) => f.id == id, orElse: () => allFonts.first);
