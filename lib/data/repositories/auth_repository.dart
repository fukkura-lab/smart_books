import 'dart:async';
import 'package:smart_books/api/auth_api.dart';
import 'package:smart_books/data/models/user.dart';
import 'package:smart_books/services/storage_service.dart';

class AuthRepository {
  final AuthApi _authApi;
  final StorageService _storageService;
  
  // 現在のユーザー情報
  User? _currentUser;
  AuthTokens? _tokens;
  
  // ユーザー情報の変更を通知するためのコントローラー
  final _userController = StreamController<User?>.broadcast();
  
  // ユーザー情報のストリーム
  Stream<User?> get user => _userController.stream;
  
  AuthRepository(this._authApi, this._storageService);
  
  // ログイン
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _authApi.login(
      email: email,
      password: password,
    );
    
    // トークンの保存
    final tokens = AuthTokens.fromJson(response);
    await _storageService.saveTokens(tokens);
    _tokens = tokens;
    
    // トークンをAPIクライアントにセット
    _authApi._apiClient.setToken(tokens.accessToken);
    
    // ユーザー情報の取得
    final user = await _authApi.getCurrentUser();
    _currentUser = user;
    _userController.add(user);
    
    return user;
  }
  
  // ユーザー登録
  Future<User> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? businessType,
  }) async {
    final response = await _authApi.register(
      username: username,
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      businessType: businessType,
    );
    
    // トークンの保存
    final tokens = AuthTokens.fromJson(response);
    await _storageService.saveTokens(tokens);
    _tokens = tokens;
    
    // トークンをAPIクライアントにセット
    _authApi._apiClient.setToken(tokens.accessToken);
    
    // ユーザー情報の取得
    final user = await _authApi.getCurrentUser();
    _currentUser = user;
    _userController.add(user);
    
    return user;
  }
  
  // ログアウト
  Future<void> logout() async {
    try {
      await _authApi.logout();
    } catch (e) {
      // エラーが発生してもトークンをクリアする
      print('Logout error: $e');
    } finally {
      await _storageService.clearTokens();
      _tokens = null;
      _currentUser = null;
      _userController.add(null);
      _authApi._apiClient.clearToken();
    }
  }
  
  // 認証状態のチェック
  Future<bool> isAuthenticated() async {
    // 保存されたトークンを取得
    _tokens = await _storageService.getTokens();
    
    if (_tokens == null) {
      return false;
    }
    
    // トークンが期限切れの場合は更新を試みる
    if (_tokens!.isExpired) {
      try {
        final response = await _authApi.refreshToken(_tokens!.refreshToken);
        final newTokens = AuthTokens.fromJson(response);
        await _storageService.saveTokens(newTokens);
        _tokens = newTokens;
        _authApi._apiClient.setToken(newTokens.accessToken);
      } catch (e) {
        // トークンの更新に失敗した場合はログアウト
        await logout();
        return false;
      }
    } else {
      // 有効なトークンが存在する場合はAPIクライアントにセット
      _authApi._apiClient.setToken(_tokens!.accessToken);
    }
    
    try {
      // ユーザー情報の取得
      _currentUser = await _authApi.getCurrentUser();
      _userController.add(_currentUser);
      return true;
    } catch (e) {
      // ユーザー情報の取得に失敗した場合はログアウト
      await logout();
      return false;
    }
  }
  
  // 現在のユーザー情報を取得
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }
    
    // 認証状態をチェック
    final isAuth = await isAuthenticated();
    if (isAuth) {
      return _currentUser;
    }
    
    return null;
  }
  
  // パスワードリセット
  Future<void> resetPassword({
    required String email,
  }) async {
    await _authApi.resetPassword(email: email);
  }
  
  // パスワードの変更
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _authApi.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
  
  // プロフィールの更新
  Future<User> updateProfile({
    String? fullName,
    String? phone,
    String? businessType,
  }) async {
    final user = await _authApi.updateProfile(
      fullName: fullName,
      phone: phone,
      businessType: businessType,
    );
    
    _currentUser = user;
    _userController.add(user);
    
    return user;
  }
  
  // リソースの解放
  void dispose() {
    _userController.close();
  }
}
