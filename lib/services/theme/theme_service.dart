import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// テーマ設定を管理するサービス
class ThemeService {
  // SharedPreferencesのキー
  static const String _themeKey = 'theme_mode';

  // テーマモードの種類
  static const String _lightMode = 'light';
  static const String _darkMode = 'dark';
  static const String _systemMode = 'system';

  /// 現在のテーマモードを取得する
  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey) ?? _lightMode;

    switch (themeString) {
      case _darkMode:
        return ThemeMode.dark;
      case _systemMode:
        return ThemeMode.system;
      case _lightMode:
      default:
        return ThemeMode.light;
    }
  }

  /// テーマモードを設定する
  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    
    String themeString;
    switch (mode) {
      case ThemeMode.dark:
        themeString = _darkMode;
        break;
      case ThemeMode.system:
        themeString = _systemMode;
        break;
      case ThemeMode.light:
      default:
        themeString = _lightMode;
        break;
    }

    await prefs.setString(_themeKey, themeString);
  }

  /// ダークモードかどうかを判定する
  Future<bool> isDarkMode() async {
    final mode = await getThemeMode();
    return mode == ThemeMode.dark;
  }

  /// テーマモードを切り替える
  Future<ThemeMode> toggleThemeMode() async {
    final currentMode = await getThemeMode();
    late ThemeMode newMode;

    switch (currentMode) {
      case ThemeMode.dark:
        newMode = ThemeMode.light;
        break;
      case ThemeMode.light:
      default:
        newMode = ThemeMode.dark;
        break;
    }

    await setThemeMode(newMode);
    return newMode;
  }
}
