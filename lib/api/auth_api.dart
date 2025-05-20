import 'package:dio/dio.dart';
import 'package:smart_books/api/api_client.dart';
import 'package:smart_books/data/models/user.dart';

class AuthApi {
  final ApiClient _apiClient;
  
  AuthApi(this._apiClient);
  
  // ログイン
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('メールアドレスまたはパスワードが間違っています');
      }
      throw Exception('ログインに失敗しました: ${e.message}');
    } catch (e) {
      throw Exception('予期せぬエラーが発生しました: $e');
    }
  }
  
  // ユーザー登録
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? businessType,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone': phone,
          'business_type': businessType,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('このメールアドレスは既に登録されています');
      }
      throw Exception('ユーザー登録に失敗しました: ${e.message}');
    } catch (e) {
      throw Exception('予期せぬエラーが発生しました: $e');
    }
  }
  
  // パスワードリセット
  Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await _apiClient.post(
        '/auth/reset-password',
        data: {
          'email': email,
        },
      );
    } catch (e) {
      throw Exception('パスワードリセットに失敗しました: $e');
    }
  }
  
  // ログアウト
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
      _apiClient.clearToken();
    } catch (e) {
      throw Exception('ログアウトに失敗しました: $e');
    }
  }
  
  // ユーザー情報の取得
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/auth/me');
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('ユーザー情報の取得に失敗しました: $e');
    }
  }
  
  // トークンの更新
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post(
        '/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
      );
      
      return response.data;
    } catch (e) {
      throw Exception('トークンの更新に失敗しました: $e');
    }
  }
  
  // パスワードの変更
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiClient.post(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } catch (e) {
      throw Exception('パスワードの変更に失敗しました: $e');
    }
  }
  
  // プロフィールの更新
  Future<User> updateProfile({
    String? fullName,
    String? phone,
    String? businessType,
  }) async {
    try {
      final response = await _apiClient.put(
        '/auth/profile',
        data: {
          'full_name': fullName,
          'phone': phone,
          'business_type': businessType,
        },
      );
      
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('プロフィールの更新に失敗しました: $e');
    }
  }
}
