import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_books/models/chat_message.dart';
import 'dart:convert' show utf8;

class ChatService {
  final String _apiKey;
  final String _apiUrl;
  final String _model;
  
  ChatService() 
    : _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '',
      _apiUrl = dotenv.env['OPENAI_API_URL'] ?? 'https://api.openai.com/v1/chat/completions',
      _model = dotenv.env['OPENAI_MODEL'] ?? 'gpt-3.5-turbo';
  
  // システムプロンプトの定義（詳細な制約を含む）
  String get _baseSystemPrompt {
    const String prompt = '''
  あなたは財務と会計に特化したAIアシスタント「財Tech AI」です。以下の制約に従って応答してください：

  【応答可能なトピック】
  - 日本の会計基準と税法に関する一般的な質問
  - 基本的な財務分析と財務説明書の解釈
  - 業種別の会計処理のアドバイス
  - 確定申告や税金対策の一般的なヒント
  - 請求書や領収書の基本的な管理方法
  - 起業や個人事業主向けの会計アドバイス

  【応答禁止事項】
  - 特定の個人や企業に対する具体的な投資アドバイス
  - 脱税や違法な税金対策の方法
  - 複雑な法的アドバイス（「税理士や弁護士に相談してください」と案内する）
  - 特定の会計ソフトウェアの具体的な操作方法
  - プライバシーに関わる具体的な財務情報の要求
  - 政治的な意見や論争的な税制改革に関する主観的コメント
  - このアプリの競合製品に関する具体的な推奨

  【応答スタイル】
  - 簡潔かつ明確に説明する
  - 専門用語は使用後に簡単な説明を加える
  - 質問の背景にある意図を理解し、実用的な回答を心がける
  - 確信がない情報は提供せず、「専門家に相談することをお勧めします」と伝える
  - 日本の会計や税務に関する最新の一般的な知識に基づいて回答する
  ''';
    // UTF-8でエンコードしてからデコードすることで文字化けを防止
    return utf8.decode(utf8.encode(prompt));
  }
      
  Future<String> sendMessage(String message, List<Map<String, String>> history) async {
    try {
      // メッセージの内容を事前チェック
      final filteredMessage = _filterInputMessage(message);
      
      // 会話履歴から不適切な応答を検出
      final sanitizedHistory = _sanitizeHistory(history);
      
      // 会計に関する基本的なプロンプト設定
      final List<Map<String, String>> messages = [
        {"role": "system", "content": _baseSystemPrompt},
        ...sanitizedHistory,
        {"role": "user", "content": filteredMessage}
      ];
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 800,
          // 以下はOpenAIのモデレーション設定
          'user': 'smart_books_user', // ユーザー識別子（アナリティクス用）
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final responseContent = data['choices'][0]['message']['content'];
        
        print('受信したレスポンス: $responseContent');
        
        // 応答内容を後処理（フィルタリング）
        return _postProcessResponse(responseContent);
      } else {
        print('APIエラー: ${response.statusCode}');
        print('レスポンス: ${utf8.decode(response.bodyBytes)}');
        return 'すみません、回答の生成中にエラーが発生しました。';
      }
    } catch (e) {
      print('例外が発生しました: $e');
      String errorMessage = e.toString();
      // エラーメッセージが文字化けしていないか確認
      try {
        errorMessage = utf8.decode(utf8.encode(errorMessage));
      } catch (encodeError) {
        print('エンコードエラー: $encodeError');
      }
      return 'すみません、回答の生成中に問題が発生しました。';
    }
  }
  
  // 入力メッセージのフィルタリング
  String _filterInputMessage(String message) {
    // センシティブな情報（クレジットカード番号など）をマスク
    final maskedMessage = message.replaceAllMapped(
      RegExp(r'\b(?:\d{4}[-\s]?){3}\d{4}\b'), 
      (match) => '[カード番号は削除されました]'
    );
    
    // 過度に詳細な個人情報要求を検出
    if (RegExp(r'\b(?:マイナンバー|個人番号|パスワード|暗証番号)\b').hasMatch(maskedMessage)) {
      return '$maskedMessage\n※注意: 個人情報やパスワードは共有しないでください。一般的なアドバイスのみ提供します。';
    }
    
    return maskedMessage;
  }
  
  // 会話履歴の内容をサニタイズ
  List<Map<String, String>> _sanitizeHistory(List<Map<String, String>> history) {
    return history.map((msg) {
      // センシティブ情報をマスク
      final content = msg['content'] ?? '';
      final sanitizedContent = content
        .replaceAllMapped(
          RegExp(r'\b(?:\d{4}[-\s]?){3}\d{4}\b'), 
          (match) => '[カード番号は削除されました]'
        )
        .replaceAllMapped(
          RegExp(r'\b\d{3}-\d{4}-\d{4}\b'), 
          (match) => '[電話番号は削除されました]'
        );
      
      return {
        'role': msg['role'] ?? 'user',
        'content': sanitizedContent,
      };
    }).toList();
  }
  
  // APIからの応答を後処理
  String _postProcessResponse(String response) {
    // 禁止されたトピックに関する応答をチェック
    final forbiddenPatterns = [
      RegExp(r'脱税|税金逃れ|税金を払わない方法', caseSensitive: false),
      RegExp(r'法律を回避|規制を迂回', caseSensitive: false),
      // 他の禁止パターン
    ];
    
    for (var pattern in forbiddenPatterns) {
      if (pattern.hasMatch(response)) {
        return '申し訳ありませんが、そのような情報は提供できません。法令を遵守した形での節税対策についてのみアドバイスが可能です。';
      }
    }
    
    // 免責事項の追加（特定の条件の場合のみ）
    if (RegExp(r'税額|節税|控除|経費|申告', caseSensitive: false).hasMatch(response)) {
      return '$response\n\n※注意: このアドバイスは一般的な情報提供であり、個別の状況に応じた専門的なアドバイスではありません。具体的な税務判断は、税理士等の専門家にご相談ください。';
    }
    
    return response;
  }
}
