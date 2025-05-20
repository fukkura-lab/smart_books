import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_books/models/chat_message.dart';

class ChatStorageService {
  static const String _chatHistoryKey = 'chat_history';
  
  // 会話履歴の保存
  Future<void> saveChatHistory(List<ChatMessage> messages) async {
    try {
      // 最新の100メッセージのみ保存（メモリ節約）
      final messagesToSave = messages.length > 100 
          ? messages.sublist(messages.length - 100) 
          : messages;
      
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(
        messagesToSave.map((message) => message.toJson()).toList(),
      );
      
      await prefs.setString(_chatHistoryKey, jsonData);
    } catch (e) {
      print('会話履歴の保存に失敗しました: $e');
      throw Exception('会話履歴の保存に失敗しました');
    }
  }
  
  // 会話履歴の読み込み
  Future<List<ChatMessage>> loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(_chatHistoryKey);
      
      if (jsonData == null || jsonData.isEmpty) {
        return [];
      }
      
      final List<dynamic> decodedData = jsonDecode(jsonData);
      return decodedData
          .map((item) => ChatMessage.fromJson(item))
          .toList();
    } catch (e) {
      print('会話履歴の読み込みに失敗しました: $e');
      return [];
    }
  }
  
  // 会話履歴のクリア
  Future<void> clearChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chatHistoryKey);
    } catch (e) {
      print('会話履歴のクリアに失敗しました: $e');
      throw Exception('会話履歴のクリアに失敗しました');
    }
  }
}
