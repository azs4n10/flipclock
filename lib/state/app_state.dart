import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/fonts.dart';
import '../theme/skin.dart';
import '../theme/skins.dart';

class AppState extends ChangeNotifier {
  AppState._(this._prefs)
      : _skin = skinById(_prefs.getString(_kSkinId) ?? beigeRoseSkin.id),
        _font = fontById(_prefs.getString(_kFontId) ?? allFonts.first.id),
        _focusMinutes = _prefs.getInt(_kFocusMinutes) ?? 25,
        _shortBreakMinutes = _prefs.getInt(_kShortBreakMinutes) ?? 5,
        _longBreakMinutes = _prefs.getInt(_kLongBreakMinutes) ?? 15,
        _longBreakInterval = _prefs.getInt(_kLongBreakInterval) ?? 4,
        _remindSoundEnabled = _prefs.getBool(_kRemindSound) ?? true,
        _vibrationEnabled = _prefs.getBool(_kVibration) ?? true;

  static const String _kSkinId = 'skin_id';
  static const String _kFontId = 'font_id';
  static const String _kFocusMinutes = 'focus_minutes';
  static const String _kShortBreakMinutes = 'short_break_minutes';
  static const String _kLongBreakMinutes = 'long_break_minutes';
  static const String _kLongBreakInterval = 'long_break_interval';
  static const String _kRemindSound = 'remind_sound';
  static const String _kVibration = 'vibration';

  static Future<AppState> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AppState._(prefs);
  }

  final SharedPreferences _prefs;

  Skin _skin;
  DigitFont _font;
  int _focusMinutes;
  int _shortBreakMinutes;
  int _longBreakMinutes;
  int _longBreakInterval;
  bool _remindSoundEnabled;
  bool _vibrationEnabled;

  Skin get skin => _skin;
  DigitFont get font => _font;
  int get focusMinutes => _focusMinutes;
  int get shortBreakMinutes => _shortBreakMinutes;
  int get longBreakMinutes => _longBreakMinutes;
  int get longBreakInterval => _longBreakInterval;
  bool get remindSoundEnabled => _remindSoundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  Future<void> setSkin(Skin next) async {
    if (_skin.id == next.id) return;
    _skin = next;
    await _prefs.setString(_kSkinId, next.id);
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
}
