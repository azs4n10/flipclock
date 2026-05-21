import 'package:flutter/material.dart';
import 'skin.dart';

const Skin yumekawaSkin = Skin(
  id: 'yumekawa',
  name: 'Yumekawa',
  background: Color(0xFFFCE7F3),
  cardBackground: Color(0xFFFFFFFF),
  digitColor: Color(0xFFBE5A8F),
  accentColor: Color(0xFFC4A8E1),
  buttonColor: Color(0xFFF8A5C2),
  buttonTextColor: Color(0xFFFFFFFF),
  primaryTextColor: Color(0xFF6B4858),
  subTextColor: Color(0xFFB89AA8),
  dividerColor: Color(0xFFF5D2E1),
);

const Skin lavenderSkin = Skin(
  id: 'lavender',
  name: 'Lavender Dream',
  background: Color(0xFFF1E8FF),
  cardBackground: Color(0xFFFFFFFF),
  digitColor: Color(0xFF8C6BB5),
  accentColor: Color(0xFFFFB6D9),
  buttonColor: Color(0xFFB69CE8),
  buttonTextColor: Color(0xFFFFFFFF),
  primaryTextColor: Color(0xFF5E4A7A),
  subTextColor: Color(0xFFA897C2),
  dividerColor: Color(0xFFE3D6F5),
);

const Skin mintPeachSkin = Skin(
  id: 'mint_peach',
  name: 'Mint Peach',
  background: Color(0xFFF5F9F4),
  cardBackground: Color(0xFFFFF5EE),
  digitColor: Color(0xFF5C8D89),
  accentColor: Color(0xFFFFB088),
  buttonColor: Color(0xFF88C9BF),
  buttonTextColor: Color(0xFFFFFFFF),
  primaryTextColor: Color(0xFF4A6B68),
  subTextColor: Color(0xFF9CB6B0),
  dividerColor: Color(0xFFDDE8E0),
);

const Skin beigeRoseSkin = Skin(
  id: 'beige_rose',
  name: 'Beige Rose',
  background: Color(0xFFF5EBE0),
  cardBackground: Color(0xFFE8D5C4),
  digitColor: Color(0xFF8B5A6B),
  accentColor: Color(0xFFD4A5A5),
  buttonColor: Color(0xFFC9A88D),
  buttonTextColor: Color(0xFFFFFFFF),
  primaryTextColor: Color(0xFF6B4858),
  subTextColor: Color(0xFFB8A398),
  dividerColor: Color(0xFFD6BFAE),
);

const Skin sugarPinkSkin = Skin(
  id: 'sugar_pink',
  name: 'Sugar Pink',
  background: Color(0xFFFFFFFF),
  cardBackground: Color(0xFFFFE4EC),
  digitColor: Color(0xFFF472B6),
  accentColor: Color(0xFFFBCFE8),
  buttonColor: Color(0xFFEC4899),
  buttonTextColor: Color(0xFFFFFFFF),
  primaryTextColor: Color(0xFF8B2A6B),
  subTextColor: Color(0xFFD4A5BF),
  dividerColor: Color(0xFFFBCFE8),
);

const Skin nightStarSkin = Skin(
  id: 'night_star',
  name: 'Night Star',
  background: Color(0xFF2A2342),
  cardBackground: Color(0xFF3D3460),
  digitColor: Color(0xFFFFC0E2),
  accentColor: Color(0xFFB69CE8),
  buttonColor: Color(0xFFEC4899),
  buttonTextColor: Color(0xFFFFFFFF),
  primaryTextColor: Color(0xFFF5EBE0),
  subTextColor: Color(0xFFB8A8D0),
  dividerColor: Color(0xFF2A2342),
);

const List<Skin> allSkins = [
  yumekawaSkin,
  lavenderSkin,
  mintPeachSkin,
  beigeRoseSkin,
  sugarPinkSkin,
  nightStarSkin,
];

Skin skinById(String id) =>
    allSkins.firstWhere((s) => s.id == id, orElse: () => yumekawaSkin);
