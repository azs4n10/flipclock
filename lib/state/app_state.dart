import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/bgm.dart';
import '../theme/fonts.dart';
import '../theme/skin.dart';
import '../theme/skins.dart';

class AppState extends ChangeNotifier {
  AppState._(this._prefs)
      : _skinId = _prefs.getString(_kSkinId) ?? beigeRoseSkin.id,
        _customBg = _prefs.getInt(_kCustomBg) ?? 0xFFFCE7F3,
        _customCard = _prefs.getInt(_kCustomCard) ?? 0xFFFFFFFF,
        _customDigit = _prefs.getInt(_kCustomDigit) ?? 0xFFBE5A8F,
        _customAccent = _prefs.getInt(_kCustomAccent) ?? 0xFFC4A8E1,
        _font = fontById(_prefs.getString(_kFontId) ?? allFonts.first.id),
        _focusMinutes = _prefs.getInt(_kFocusMinutes) ?? 25,
        _shortBreakMinutes = _prefs.getInt(_kShortBreakMinutes) ?? 5,
        _longBreakMinutes = _prefs.getInt(_kLongBreakMinutes) ?? 15,
        _longBreakInterval = _prefs.getInt(_kLongBreakInterval) ?? 4,
        _remindSoundEnabled = _prefs.getBool(_kRemindSound) ?? true,
        _vibrationEnabled = _prefs.getBool(_kVibration) ?? true,
        _use24Hour = _prefs.getBool(_kUse24Hour) ?? true,
        _showSeconds = _prefs.getBool(_kShowSeconds) ?? true,
        _showDate = _prefs.getBool(_kShowDate) ?? true,
        _signature = _prefs.getString(_kSignature) ?? 'less is more',
        _bgmId = _prefs.getString(_kBgmId) ?? 'none',
        _fontScale = _prefs.getDouble(_kFontScale) ?? 1.0,
        _seasonalEffect = _prefs.getBool(_kSeasonalEffect) ?? true;

  static const String _kSkinId = 'skin_id';
  static const String _kCustomBg = 'custom_bg';
  static const String _kCustomCard = 'custom_card';
  static const String _kCustomDigit = 'custom_digit';
  static const String _kCustomAccent = 'custom_accent';
  static const String _kFontId = 'font_id';
  static const String _kFocusMinutes = 'focus_minutes';
  static const String _kShortBreakMinutes = 'short_break_minutes';
  static const String _kLongBreakMinutes = 'long_break_minutes';
  static const String _kLongBreakInterval = 'long_break_interval';
  static const String _kRemindSound = 'remind_sound';
  static const String _kVibration = 'vibration';
  static const String _kUse24Hour = 'use_24_hour';
  static const String _kShowSeconds = 'show_seconds';
  static const String _kShowDate = 'show_date';
  static const String _kSignature = 'signature';
  static const String _kBgmId = 'bgm_id';
  static const String _kFontScale = 'font_scale';
  static const String _kSeasonalEffect = 'seasonal_effect';

  static Future<AppState> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AppState._(prefs);
  }

  final SharedPreferences _prefs;

  String _skinId;
  int _customBg;
  int _customCard;
  int _customDigit;
  int _customAccent;
  DigitFont _font;
  int _focusMinutes;
  int _shortBreakMinutes;
  int _longBreakMinutes;
  int _longBreakInterval;
  bool _remindSoundEnabled;
  bool _vibrationEnabled;
  bool _use24Hour;
  bool _showSeconds;
  bool _showDate;
  String _signature;
  String _bgmId;
  double _fontScale;
  bool _seasonalEffect;

  Skin get skin => _skinId == 'custom' ? _customSkin() : skinById(_skinId);
  bool get isCustomSkin => _skinId == 'custom';
  Color get customBg => Color(_customBg);
  Color get customCard => Color(_customCard);
  Color get customDigit => Color(_customDigit);
  Color get customAccent => Color(_customAccent);
  DigitFont get font => _font;

  Skin _customSkin() {
    final bg = Color(_customBg);
    final card = Color(_customCard);
    final digit = Color(_customDigit);
    final accent = Color(_customAccent);
    return Skin(
      id: 'custom',
      name: 'Custom',
      background: bg,
      cardBackground: card,
      digitColor: digit,
      accentColor: accent,
      buttonColor: accent,
      buttonTextColor:
          accent.computeLuminance() > 0.5 ? const Color(0xFF3A2A33) : Colors.white,
      primaryTextColor: digit,
      subTextColor: Color.lerp(digit, bg, 0.45)!,
      dividerColor: Color.lerp(card, bg, 0.5)!,
    );
  }
  int get focusMinutes => _focusMinutes;
  int get shortBreakMinutes => _shortBreakMinutes;
  int get longBreakMinutes => _longBreakMinutes;
  int get longBreakInterval => _longBreakInterval;
  bool get remindSoundEnabled => _remindSoundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get use24Hour => _use24Hour;
  bool get showSeconds => _showSeconds;
  bool get showDate => _showDate;
  String get signature => _signature;
  String get bgmId => _bgmId;
  double get fontScale => _fontScale;
  bool get seasonalEffect => _seasonalEffect;

  Future<void> setSkin(Skin next) async => setSkinId(next.id);

  Future<void> setSkinId(String id) async {
    if (_skinId == id) return;
    _skinId = id;
    await _prefs.setString(_kSkinId, id);
    notifyListeners();
  }

  Future<void> setCustomColors({
    Color? bg,
    Color? card,
    Color? digit,
    Color? accent,
  }) async {
    if (bg != null) _customBg = bg.toARGB32();
    if (card != null) _customCard = card.toARGB32();
    if (digit != null) _customDigit = digit.toARGB32();
    if (accent != null) _customAccent = accent.toARGB32();
    await _prefs.setInt(_kCustomBg, _customBg);
    await _prefs.setInt(_kCustomCard, _customCard);
    await _prefs.setInt(_kCustomDigit, _customDigit);
    await _prefs.setInt(_kCustomAccent, _customAccent);
    notifyListeners();
  }

  Future<void> setFont(DigitFont next) async {
    if (_font.id == next.id) return;
    _font = next;
    await _prefs.setString(_kFontId, next.id);
    notifyListeners();
  }

  Future<void> setFocusMinutes(int v) async {
    _focusMinutes = v;
    await _prefs.setInt(_kFocusMinutes, v);
    notifyListeners();
  }

  Future<void> setShortBreakMinutes(int v) async {
    _shortBreakMinutes = v;
    await _prefs.setInt(_kShortBreakMinutes, v);
    notifyListeners();
  }

  Future<void> setLongBreakMinutes(int v) async {
    _longBreakMinutes = v;
    await _prefs.setInt(_kLongBreakMinutes, v);
    notifyListeners();
  }

  Future<void> setLongBreakInterval(int v) async {
    _longBreakInterval = v;
    await _prefs.setInt(_kLongBreakInterval, v);
    notifyListeners();
  }

  Future<void> setRemindSoundEnabled(bool v) async {
    _remindSoundEnabled = v;
    await _prefs.setBool(_kRemindSound, v);
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool v) async {
    _vibrationEnabled = v;
    await _prefs.setBool(_kVibration, v);
    notifyListeners();
  }

  Future<void> setUse24Hour(bool v) async {
    _use24Hour = v;
    await _prefs.setBool(_kUse24Hour, v);
    notifyListeners();
  }

  Future<void> setShowSeconds(bool v) async {
    _showSeconds = v;
    await _prefs.setBool(_kShowSeconds, v);
    notifyListeners();
  }

  Future<void> setShowDate(bool v) async {
    _showDate = v;
    await _prefs.setBool(_kShowDate, v);
    notifyListeners();
  }

  Future<void> setSignature(String v) async {
    _signature = v;
    await _prefs.setString(_kSignature, v);
    notifyListeners();
  }

  Future<void> setBgm(String id) async {
    _bgmId = id;
    await _prefs.setString(_kBgmId, id);
    await BgmController.instance.play(id);
    notifyListeners();
  }

  Future<void> setFontScale(double v) async {
    _fontScale = v;
    await _prefs.setDouble(_kFontScale, v);
    notifyListeners();
  }

  Future<void> setSeasonalEffect(bool v) async {
    _seasonalEffect = v;
    await _prefs.setBool(_kSeasonalEffect, v);
    notifyListeners();
  }
}
