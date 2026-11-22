import 'package:flutter/material.dart';

@immutable
class Skin {
  const Skin({
    required this.id,
    required this.name,
    required this.background,
    required this.cardBackground,
    required this.digitColor,
    required this.accentColor,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.primaryTextColor,
    required this.subTextColor,
    required this.dividerColor,
  });

  final String id;
  final String name;
  final Color background;
  final Color cardBackground;
  final Color digitColor;
  final Color accentColor;
  final Color buttonColor;
  final Color buttonTextColor;
  final Color primaryTextColor;
  final Color subTextColor;
  final Color dividerColor;

  /// Whether this skin is a dark or a light one, judged from its background
  /// so that a custom skin is covered too. Drives the Material theme and the
  /// colour of the system status and navigation bar icons.
  Brightness get brightness =>
      ThemeData.estimateBrightnessForColor(background);
}
