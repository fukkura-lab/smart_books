import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chat_message.dart';

// AIの応答モデル
class AIResponse {
  final String message;
  final String type;
  final String? filePath;
  
  AIResponse({
    required this.message,
    required this.type,
    this.filePath,
  });
}

// 画像解析結果モデル
class ImageAnalysisResult {
  final bool isReceipt;
  final String summary;
  final String detailedInfo;
  final Map<String, dynamic>? structuredData;
  
  ImageAnalysisResult({
    required this.isReceipt,
    required this.summary,
    required this.detailedInfo,
    this.structuredData,
  });
}

// AI サービスクラス
class AIService {
  static const String _defaultAIMessage = 'これについては詳しい情報がありません。別の質問をお試しください。';
  
  final Dio _dio = Dio();
  String? _apiKey;
  String _model = 'gpt-4-turbo';
  
  AIService() {
    _initService();
  }
  
  // 初期化処理
  Future<void> _initService() async {
    try {
      _apiKey = dotenv.env['OPENAI_API_KEY'];
      
      if (_apiKey == null || _apiKey!.isEmpty) {
        print('警告: OpenAI API キーが設定されていません。デモモードで動作します。');
        print('実際のAPIを使用するには、.envファイルにOPENAI_API_KEYを設定してください。');
      } else {
        print('OpenAI API の設定が完了しました。');
      }
      
      // モデル設定（環境変数から読み込み、ない場合はデフォルト）
      final configuredModel = dotenv.env['OPENAI_MODEL'];
      if (configuredModel != null && configuredModel.isNotEmpty) {
        _model = configuredModel;
      }
    } catch (e) {
      print('AI サービスの初期化エラー: $e');
    }
  }
  
  // モデルを設定
  void setModel(String model) {
    _model = model;
  }
  
  // メッセージの応答を生成
  Future<AIResponse> generateResponse({
    required List<ChatMessage> messages,
    required String conversationId,
  }) async {
    // API キーがない場合はモックレスポンスを返す
    if (_apiKey == null || _apiKey!.isEmpty) {
      return _mockResponse(messages);
    }
    
    try {
      // API リクエストを構築
      final requestBody = {
        'model': _model,
        'messages': _formatMessagesForAPI(messages),
        'max_tokens': 1000,
        'temperature': 0.7,
        'user': conversationId,
      };
      
      print('OpenAI APIリクエスト送信中... モデル: $_model');
      
      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
        ),
        data: requestBody,
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['choices'][0]['message']['content'] as String;
        
        print('OpenAI API レスポンス受信完了: ${content.length}文字');
        
        // 特殊なレスポンスタイプの検出（フォーマットされた応答の解析）
        final responseType = _detectResponseType(content);
        
        return AIResponse(
          message: content,
          type: responseType,
        );
      } else {
        print('API リクエストエラー: ${response.statusCode}');
        return AIResponse(
          message: '応答の生成中にエラーが発生しました。もう一度お試しください。\n\nステータスコード: ${response.statusCode}',
          type: 'text',
        );
      }
    } catch (e) {
      print('AI 応答生成エラー: $e');
      return AIResponse(
        message: '応答の生成中にエラーが発生しました。ネットワーク接続を確認してください。\n\nエラー: ${e.toString()}',
        type: 'text',
      );
    }
  }
  
  // 画像解析
  Future<ImageAnalysisResult> analyzeImage(String imagePath) async {
    // API キーがない場合はモック解析結果を返す
    if (_apiKey == null || _apiKey!.isEmpty) {
      return _mockImageAnalysis(imagePath);
    }
    
    try {
      // 画像データを読み込み
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);
      
      print('画像ファイル読み込み完了: ${bytes.length} bytes');
      
      // API リクエストを構築
      final requestBody = {
        'model': 'gpt-4-vision-preview',  // ビジョン機能を使用するモデル
        'messages': [
          {
            'role': 'system',
            'content': '''あなたは財務書類の解析アシスタントです。画像をスキャンして以下の情報を抽出してください:
1. 書類の種類（領収書/請求書/その他）
2. 日付
3. 店舗/企業名
4. 合計金額
5. 税額（表示されている場合）
6. 支払方法（表示されている場合）
7. 品目/サービス内容のリスト

可能な限り構造化された形式で回答してください。見つからない情報は「不明」と記載してください。
JSON形式で出力してください。形式: 
{
  "documentType": "領収書",
  "date": "2023-04-15",
  "vendor": "株式会社サンプル",
  "totalAmount": 3240,
  "taxAmount": 200,
  "paymentMethod": "クレジットカード",
  "items": [
    {"name": "商品A", "price": 1000},
    {"name": "商品B", "price": 2000}
  ]
}'''
          },
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': 'この画像を解析して、領収書/請求書の情報を抽出してください。構造化JSON形式で回答してください。'
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$base64Image',
                }
              }
            ]
          }
        ],
        'max_tokens': 1000,
      };
      
      print('Vision API リクエスト送信中...');
      
      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
        ),
        data: requestBody,
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['choices'][0]['message']['content'] as String;
        
        print('Vision API レスポンス受信完了: ${content.length}文字');
        
        // JSONデータの抽出を試みる
        try {
          // JSON部分を抽出
          final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
          Map<String, dynamic>? jsonData;
          
          if (jsonMatch != null) {
            final jsonStr = jsonMatch.group(0);
            jsonData = json.decode(jsonStr!) as Map<String, dynamic>;
            
            // レシートかどうかを判定
            final docType = jsonData['documentType']?.toString().toLowerCase() ?? '';
            final isReceipt = docType.contains('receipt') || 
                              docType.contains('invoice') ||
                              docType.contains('領収書') ||
                              docType.contains('請求書');
            
            // 構造化データからフォーマットされた詳細情報を生成
            final detailedInfo = _formatReceiptInfo(jsonData);
            
            return ImageAnalysisResult(
              isReceipt: isReceipt,
              summary: '${jsonData['documentType'] ?? '書類'}を解析しました',
              detailedInfo: detailedInfo,
              structuredData: jsonData,
            );
          } else {
            // JSONが見つからない場合は、テキスト全体を詳細として使用
            return ImageAnalysisResult(
              isReceipt: content.toLowerCase().contains('領収書') || content.toLowerCase().contains('請求書'),
              summary: '書類を解析しました',
              detailedInfo: content,
              structuredData: null,
            );
          }
        } catch (e) {
          print('解析結果のパースエラー: $e');
          return ImageAnalysisResult(
            isReceipt: false,
            summary: '書類を解析しましたが、データの構造化に失敗しました',
            detailedInfo: content,
            structuredData: null,
          );
        }
      } else {
        print('API リクエストエラー: ${response.statusCode}');
        return ImageAnalysisResult(
          isReceipt: false,
          summary: '画像の解析に失敗しました',
          detailedInfo: '画像の解析中にエラーが発生しました。もう一度お試しください。\n\nステータスコード: ${response.statusCode}',
          structuredData: null,
        );
      }
    } catch (e) {
      print('画像解析エラー: $e');
      return ImageAnalysisResult(
        isReceipt: false,
        summary: '画像の解析に失敗しました',
        detailedInfo: '画像の解析中にエラーが発生しました。もう一度お試しください。\n\nエラー: ${e.toString()}',
        structuredData: null,
      );
    }
  }
  
  // JSONデータから読みやすいレシート情報を生成
  String _formatReceiptInfo(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    
    // 書類タイプ
    buffer.writeln('【${data['documentType'] ?? '書類'}】');
    buffer.writeln('');
    
    // 日付
    buffer.writeln('📅 日付: ${data['date'] ?? '不明'}');
    
    // 店舗/企業名
    buffer.writeln('🏢 発行元: ${data['vendor'] ?? '不明'}');
    
    // 合計金額
    if (data['totalAmount'] != null) {
      buffer.writeln('💰 合計金額: ¥${_formatNumber(data['totalAmount'])}');
    } else {
      buffer.writeln('💰 合計金額: 不明');
    }
    
    // 税額
    if (data['taxAmount'] != null) {
      buffer.writeln('🧾 税額: ¥${_formatNumber(data['taxAmount'])}');
    }
    
    // 支払方法
    if (data['paymentMethod'] != null) {
      buffer.writeln('💳 支払方法: ${data['paymentMethod']}');
    }
    
    // 品目リスト
    if (data['items'] != null && data['items'] is List && (data['items'] as List).isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('【品目】');
      
      for (var item in data['items']) {
        if (item is Map && item['name'] != null) {
          final name = item['name'];
          final price = item['price'];
          
          if (price != null) {
            buffer.writeln('• $name: ¥${_formatNumber(price)}');
          } else {
            buffer.writeln('• $name');
          }
        }
      }
    }
    
    return buffer.toString();
  }
  
  // 数値を3桁区切りでフォーマット
  String _formatNumber(dynamic number) {
    if (number is int || number is double) {
      return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (match) => '${match.group(1)},',
      );
    }
    
    if (number is String) {
      try {
        final n = double.parse(number);
        return n.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)},',
        );
      } catch (e) {
        return number;
      }
    }
    
    return number.toString();
  }
  
  // メッセージの特殊タイプを検出
  String _detectResponseType(String content) {
    // 特殊フォーマットの検出
    if (content.contains('【選択してください】') || 
        content.contains('以下から選択') ||
        (content.contains('[') && content.contains(']') && content.contains('選択'))) {
      return 'buttons';
    }
    
    if (content.contains('【領収書】') || 
        content.contains('【請求書】') ||
        content.contains('領収書解析結果')) {
      return 'receipt';
    }
    
    // デフォルトはテキスト
    return 'text';
  }
  
  // APIに送信するためのメッセージ形式に変換
  List<Map<String, dynamic>> _formatMessagesForAPI(List<ChatMessage> messages) {
    // システムメッセージを追加
    final formattedMessages = [
      {
        'role': 'system',
        'content': '''あなたは「財Tech」という会計アプリのAIアシスタントです。日本の会計、税務、確定申告、経費管理などの専門的な質問に簡潔かつ正確に回答してください。
ユーザーはITに詳しくない、個人経営者や小規模ビジネスの経営者です。専門用語を使いすぎず、初心者にも分かりやすい表現を心がけてください。

あなたの主な役割:
1. 会計・税務の質問に答える
2. 確定申告の手続きを案内する
3. 経費計上の判断を助ける
4. 節税対策のアドバイスをする
5. 簿記の基本を教える

重要な機能について:
- ユーザーが領収書やレシートの写真をアップロードすると、自動解析して仕分けします
- ふるさと納税のシミュレーションと提案ができます
- 確定申告に必要な資料の準備を手伝います

回答の際は次のガイドラインに従ってください:
- 簡潔かつわかりやすく説明する
- 長すぎる応答は避ける
- 必要に応じて箇条書きやステップで説明する
- 金額は「¥1,000」のように3桁区切りで表示する
- ユーザーが選択肢から選べるようにボタン形式の回答を提案する場合は「【選択してください】」という見出しをつける

専門用語を使う場合は必ず簡単な説明を付け加えてください。会話は日本語で行います。'''
      }
    ];
    
    // ユーザーとAIのメッセージを追加（最新12件まで）
    for (final message in messages.take(12).toList()) {
      if (message.type == 'text') {
        formattedMessages.add({
          'role': message.isUser ? 'user' : 'assistant',
          'content': message.content,
        });
      } else if (message.type == 'buttons' && !message.isUser) {
        // ボタン表示はAIからのメッセージのみ
        formattedMessages.add({
          'role': 'assistant',
          'content': message.content,
        });
      }
    }
    
    return formattedMessages;
  }
  
  // モックレスポンス（デモ用）
  Future<AIResponse> _mockResponse(List<ChatMessage> messages) async {
    // 最後のユーザーメッセージを取得
    String userMessage = '';
    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].isUser && messages[i].type == 'text') {
        userMessage = messages[i].content;
        break;
      }
    }
    
    // 少し遅延を入れてAPI呼び出しをシミュレート
    await Future.delayed(const Duration(seconds: 1));
    
    // ユーザーメッセージに基づいて応答を分岐
    String response;
    String type = 'text';
    
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('領収書') || lowerMessage.contains('レシート')) {
      response = '領収書の写真を撮影するか、アップロードしていただければ、自動で解析して仕訳します。スマートフォンのカメラアイコンをタップして撮影してみてください。';
    } else if (lowerMessage.contains('ふるさと納税') || lowerMessage.contains('寄付')) {
      response = 'ふるさと納税についてですね。年収や家族構成によって控除上限額が変わります。シミュレーションを行うには、年収の情報をお聞かせいただけますか？';
    } else if (lowerMessage.contains('確定申告') || lowerMessage.contains('税金')) {
      response = '確定申告の準備に関するご質問ですね。個人事業主の方は、収入と経費を整理することが大切です。具体的にどのような点でお悩みですか？\n\n【選択してください】\n1. 書類の準備方法について\n2. 必要経費の計算について\n3. 申告書の書き方について\n4. その他の質問';
      type = 'buttons';
    } else if (lowerMessage.contains('経費') || lowerMessage.contains('仕訳')) {
      response = '経費の計上についてのご質問ですね。事業に関係する支出が経費になります。例えば、交通費、通信費、消耗品費などです。具体的な経費があれば、教えてください。';
    } else if (lowerMessage.contains('青色申告') || lowerMessage.contains('白色申告')) {
      response = '青色申告は、白色申告に比べて控除額が大きいメリットがあります（最大65万円の控除）。ただし、複式簿記での記帳が必要です。財Techでは青色申告に必要な仕訳や帳簿作成をサポートします。';
    } else if (lowerMessage.contains('消費税') || lowerMessage.contains('インボイス')) {
      response = '消費税の課税事業者になると、売上に対して消費税を預かり、仕入れにかかった消費税を控除できます。インボイス制度により、2023年10月以降は適格請求書発行事業者からの請求書等が必要です。詳しく知りたい点はありますか？';
    } else if (lowerMessage.contains('節税') || lowerMessage.contains('控除')) {
      response = '節税対策としては、経費の適切な計上、小規模企業共済（掛金全額所得控除）、iDeCo（年間最大40万円の所得控除）、保険の活用などがあります。あなたの状況に合わせたアドバイスをするには、もう少し詳しい情報をお聞かせください。';
    } else {
      // 一般的な応答
      final responses = [
        'ご質問ありがとうございます。もう少し具体的に教えていただけますか？',
        '会計や税務に関することでしたら、お気軽にご相談ください。',
        'その点については、状況によって異なる場合があります。詳しい状況を教えていただけますか？',
        '財務管理のお手伝いをします。何かお困りのことはありますか？',
        'ご質問の内容を整理して、もう少し詳しく教えていただけますか？',
      ];
      
      final random = (DateTime.now().millisecondsSinceEpoch % responses.length).toInt();
      response = responses[random];
    }
    
    return AIResponse(
      message: response,
      type: type,
    );
  }
  
  // モック画像解析（デモ用）
  Future<ImageAnalysisResult> _mockImageAnalysis(String imagePath) async {
    // 少し遅延を入れてAPI呼び出しをシミュレート
    await Future.delayed(const Duration(seconds: 2));
    
    // 画像パスを解析して領収書かどうかを推測
    final isReceipt = imagePath.toLowerCase().contains('receipt') || 
                    imagePath.toLowerCase().contains('invoice') ||
                    imagePath.contains('領収書') ||
                    imagePath.contains('請求書');
    
    if (isReceipt) {
      // サンプルの構造化データ
      final structuredData = {
        'documentType': '領収書',
        'date': '2023-04-15',
        'vendor': '株式会社サンプルストア',
        'totalAmount': 3240,
        'taxAmount': 200,
        'paymentMethod': 'クレジットカード',
        'items': [
          {'name': '文房具', 'price': 2000},
          {'name': '消費税', 'price': 200},
          {'name': '送料', 'price': 1040},
        ],
      };
      
      // フォーマットされた詳細情報を生成
      final detailedInfo = _formatReceiptInfo(structuredData);
      
      return ImageAnalysisResult(
        isReceipt: true,
        summary: '領収書を検出しました',
        detailedInfo: detailedInfo,
        structuredData: structuredData,
      );
    } else {
      return ImageAnalysisResult(
        isReceipt: false,
        summary: '画像を解析しました',
        detailedInfo: 'この画像は領収書や請求書ではないようです。会計関連の書類をアップロードしてください。',
        structuredData: null,
      );
    }
  }
}