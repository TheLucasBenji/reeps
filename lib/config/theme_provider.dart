import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemePrefKey = 'reeps_theme_mode';

/// Simple ChangeNotifier to control ThemeMode across the app.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;
  ThemeProvider() {
    // Load saved preference asynchronously
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getString(_kThemePrefKey) ?? 'system';
      switch (val) {
        case 'light':
          _mode = ThemeMode.light;
          break;
        case 'dark':
          _mode = ThemeMode.dark;
          break;
        default:
          _mode = ThemeMode.system;
      }
      notifyListeners();
    } catch (_) {
      // ignore errors and keep default
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = _mode == ThemeMode.light
          ? 'light'
          : _mode == ThemeMode.dark
          ? 'dark'
          : 'system';
      await prefs.setString(_kThemePrefKey, str);
    } catch (_) {
      // ignore
    }
  }

  void setLight() {
    _mode = ThemeMode.light;
    notifyListeners();
    _saveToPrefs();
  }

  void setDark() {
    _mode = ThemeMode.dark;
    notifyListeners();
    _saveToPrefs();
  }

  void setSystem() {
    _mode = ThemeMode.system;
    notifyListeners();
    _saveToPrefs();
  }

  void toggle() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    _saveToPrefs();
  }
}
