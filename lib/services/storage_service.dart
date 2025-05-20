import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_books/data/models/user.dart';

class StorageService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;
  
  // キー定義
  static const String _tokenKey = 'auth_tokens';
  static const String _userKey = 'current_user';
  static const String _themeKey = 'app_theme';
  static const String _localeKey = 'app_locale';
  static const String _onboardingKey = 'onboarding_completed';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _soundsKey = 'sounds_enabled';
  
  StorageService(this._prefs, this._secureStorage);
  
  // トークンの保存
  Future<void> saveTokens(AuthTokens tokens) async {
    await _secureStorage.write(
      key: _tokenKey,
      value: jsonEncode(tokens.toJson()),
    );
  }
  
  // トークンの取得
  Future<AuthTokens?> getTokens() async {
    final tokensJson = await _secureStorage.read(key: _tokenKey);
    
    if (tokensJson == null) {
      return null;
    }
    
    try {
      return AuthTokens.fromJson(jsonDecode(tokensJson));
    } catch (e) {
      print('Error parsing tokens: $e');
      return null;
    }
  }
  
  // トークンのクリア
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _tokenKey);
  }
  
  // ユーザー情報の保存
  Future<void> saveUser(User user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
  
  // ユーザー情報の取得
  User? getUser() {
    final userJson = _prefs.getString(_userKey);
    
    if (userJson == null) {
      return null;
    }
    
    try {
      return User.fromJson(jsonDecode(userJson));
    } catch (e) {
      print('Error parsing user: $e');
      return null;
    }
  }
  
  // ユーザー情報のクリア
  Future<void> clearUser() async {
    await _prefs.remove(_userKey);
  }
  
  // テーマの保存
  Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(_themeKey, themeMode);
  }
  
  // テーマの取得
  String getThemeMode() {
    return _prefs.getString(_themeKey) ?? 'light';
  }
  
  // ロケールの保存
  Future<void> saveLocale(String locale) async {
    await _prefs.setString(_localeKey, locale);
  }
  
  // ロケールの取得
  String getLocale() {
    return _prefs.getString(_localeKey) ?? 'ja';
  }
  
  // オンボーディング完了状態の保存
  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_onboardingKey, completed);
  }
  
  // オンボーディング完了状態の取得
  bool isOnboardingCompleted() {
    return _prefs.getBool(_onboardingKey) ?? false;
  }
  
  // 通知設定の保存
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_notificationsKey, enabled);
  }
  
  // 通知設定の取得
  bool areNotificationsEnabled() {
    return _prefs.getBool(_notificationsKey) ?? true;
  }
  
  // 効果音設定の保存
  Future<void> setSoundsEnabled(bool enabled) async {
    await _prefs.setBool(_soundsKey, enabled);
  }
  
  // 効果音設定の取得
  bool areSoundsEnabled() {
    return _prefs.getBool(_soundsKey) ?? true;
  }
  
  // すべての設定をクリア（ログアウト時など）
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    
    // テーマやロケールなどのアプリ設定は保持する
    final themeMode = getThemeMode();
    final locale = getLocale();
    final notificationsEnabled = areNotificationsEnabled();
    final soundsEnabled = areSoundsEnabled();
    
    await _prefs.clear();
    
    // アプリ設定を復元
    await _prefs.setString(_themeKey, themeMode);
    await _prefs.setString(_localeKey, locale);
    await _prefs.setBool(_notificationsKey, notificationsEnabled);
    await _prefs.setBool(_soundsKey, soundsEnabled);
  }
}
