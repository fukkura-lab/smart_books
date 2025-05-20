import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ModerationService {
  final String _apiKey;
  
  ModerationService() : _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  
  // OpenAIのModeration APIを使用してコンテンツをチェック
  Future<bool> checkContent(String content) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/moderations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'input': content,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final flagged = data['results'][0]['flagged'];
        
        // フラグが立っている場合は不適切コンテンツと判断
        return flagged;
      }
      
      // エラーの場合は安全側に倒して不適切と判断
      return true;
    } catch (e) {
      print('モデレーションチェックでエラー: $e');
      // エラーの場合は安全側に倒して不適切とみなさない
      return false;
    }
  }
  
  // ローカルでのキーワードベースの簡易チェック
  bool quickCheck(String content) {
    final lowercaseContent = content.toLowerCase();
    
    // 会計アプリで不適切とみなすキーワード
    final inappropriateKeywords = [
      '脱税', '税金逃れ', '裏金', '闇金',
      '資金洗浄', 'マネーロンダリング', '脱法',
      '違法', '粉飾', '粉飾決算', '経理操作',
      'インサイダー', '株価操作'
    ];
    
    for (var keyword in inappropriateKeywords) {
      if (lowercaseContent.contains(keyword)) {
        return true; // 不適切なコンテンツと判断
      }
    }
    
    return false; // 特に問題なし
  }
}
