import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'skin.dart';

/// The Material theme for [skin]. Its brightness follows the skin, so the
/// pickers, dialogs and switches of a dark skin are drawn for a dark surface
/// instead of a light one.
ThemeData themeForSkin(Skin skin) {
  final brightness = skin.brightness;
  return ThemeData(
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: skin.buttonColor,
      brightness: brightness,
      primary: skin.buttonColor,
      surface: skin.background,
    ),
    scaffoldBackgroundColor: skin.background,
    // App-wide UI font: a soft rounded sans (tabs, buttons, labels,
    // settings). Headings (date / Focus / signature) override this
    // with Playfair Display.
    textTheme: GoogleFonts.quicksandTextTheme().apply(
      bodyColor: skin.primaryTextColor,
      displayColor: skin.primaryTextColor,
    ),
    useMaterial3: true,
  );
}

/// System bar styling for [skin]: dark icons over a light skin, light icons
/// over a dark one. The app already draws behind the status bar, so that one
/// is left clear; the navigation bar takes the skin's background where the
/// system still paints it (before Android 15), so its icons always have the
/// contrast they were chosen for.
SystemUiOverlayStyle overlayStyleForSkin(Skin skin) {
  final icons = skin.brightness == Brightness.dark
      ? Brightness.light
      : Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: icons, // Android
    statusBarBrightness: skin.brightness, // iOS: describes the bar itself
    systemNavigationBarColor: skin.background,
    systemNavigationBarIconBrightness: icons,
  );
}
