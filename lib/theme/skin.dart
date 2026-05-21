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
}
