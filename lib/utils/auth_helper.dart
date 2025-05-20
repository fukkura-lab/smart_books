import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 認証状態を管理するシンプルなヘルパークラス
/// BlocやRepositoryの代わりに単純な認証処理を提供します
class AuthHelper {
  // シングルトンパターン
  static final AuthHelper _instance = AuthHelper._internal();
  factory AuthHelper() => _instance;
  
  AuthHelper._internal();

  // ユーザー情報
  String? _username;
  String? _email;
  bool _isLoggedIn = false;

  // ゲッター
  String? get username => _username;
  String? get email => _email;
  bool get isLoggedIn => _isLoggedIn;

  // ログイン処理
  Future<bool> login(String email, String password) async {
    try {
      // 実際のAPI接続は行わず、ローカルでの処理のみを実施
      await Future.delayed(const Duration(seconds: 1)); // API呼び出しのシミュレーション
      
      // ダミー確認（本番環境では実際の認証を行う）
      if (password.length >= 6) {
        _username = email.split('@').first;
        _email = email;
        _isLoggedIn = true;
        
        // ログイン状態を保存
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('email', email);
        
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('ログインエラー: $e');
      return false;
    }
  }

  // 登録処理
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? businessType,
  }) async {
    try {
      // 実際のAPI接続は行わず、ローカルでの処理のみを実施
      await Future.delayed(const Duration(seconds: 2)); // API呼び出しのシミュレーション
      
      _username = username;
      _email = email;
      _isLoggedIn = true;
      
      // ログイン状態を保存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('email', email);
      await prefs.setString('username', username);
      
      return true;
    } catch (e) {
      debugPrint('登録エラー: $e');
      return false;
    }
  }

  // ログアウト処理
  Future<bool> logout() async {
    try {
      _username = null;
      _email = null;
      _isLoggedIn = false;
      
      // ログイン状態を削除
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);
      
      return true;
    } catch (e) {
      debugPrint('ログアウトエラー: $e');
      return false;
    }
  }

  // 認証状態のチェック
  Future<bool> checkAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      
      if (_isLoggedIn) {
        _email = prefs.getString('email');
        _username = prefs.getString('username') ?? _email?.split('@').first;
      }
      
      return _isLoggedIn;
    } catch (e) {
      debugPrint('認証チェックエラー: $e');
      return false;
    }
  }
}
