import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// チャットメッセージモデル
class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final String type; // テキスト、画像、音声など
  final String? filePath; // 画像や音声ファイルのパス（ある場合）

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.type,
    this.filePath,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // JSONからオブジェクト生成
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['message'] as String,
      isUser: json['isUser'] as bool,
      type: json['type'] as String,
      filePath: json['filePath'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  // オブジェクトからJSON生成
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'isUser': isUser,
      'type': type,
      'filePath': filePath,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // 等価性の比較を実装
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatMessage &&
        other.message == message &&
        other.isUser == isUser &&
        other.type == type &&
        other.filePath == filePath &&
        other.timestamp.isAtSameMomentAs(timestamp);
  }

  // hashCode も一緒に実装
  @override
  int get hashCode {
    return message.hashCode ^
        isUser.hashCode ^
        type.hashCode ^
        filePath.hashCode ^
        timestamp.hashCode;
  }
}

// チャット会話モデル（複数のメッセージをグルーピング）
class ChatConversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final List<ChatMessage> messages;

  ChatConversation({
    required this.id,
    required this.title,
    required this.messages,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastUpdatedAt = lastUpdatedAt ?? DateTime.now();

  // JSONからオブジェクト生成
  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
      messages: (json['messages'] as List)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // オブジェクトからJSON生成
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  // 会話に新しいメッセージを追加し、更新時間を最新にする
  ChatConversation addMessage(ChatMessage message) {
    // 重複チェック - 既に同じメッセージが存在する場合は追加しない
    if (messages.contains(message)) {
      return this;
    }

    return ChatConversation(
      id: id,
      title: title,
      createdAt: createdAt,
      lastUpdatedAt: DateTime.now(),
      messages: [...messages, message],
    );
  }

  // タイトルを更新する
  ChatConversation updateTitle(String newTitle) {
    return ChatConversation(
      id: id,
      title: newTitle,
      createdAt: createdAt,
      lastUpdatedAt: DateTime.now(),
      messages: messages,
    );
  }

  // 等価性の比較
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! ChatConversation) return false;

    final ChatConversation otherConversation = other;
    if (otherConversation.id != id ||
        otherConversation.title != title ||
        !otherConversation.createdAt.isAtSameMomentAs(createdAt) ||
        !otherConversation.lastUpdatedAt.isAtSameMomentAs(lastUpdatedAt) ||
        otherConversation.messages.length != messages.length) {
      return false;
    }

    // メッセージの比較
    for (int i = 0; i < messages.length; i++) {
      if (messages[i] != otherConversation.messages[i]) {
        return false;
      }
    }

    return true;
  }

  // hashCode も一緒に実装
  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        createdAt.hashCode ^
        lastUpdatedAt.hashCode ^
        messages.hashCode;
  }
}

// チャットストレージサービス
class ChatStorageService {
  static const String _conversationsKey = 'chat_conversations';
  static const String _activeConversationIdKey = 'active_conversation_id';

  // すべての会話を取得
  Future<List<ChatConversation>> getAllConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final conversationsJson = prefs.getStringList(_conversationsKey) ?? [];

    return conversationsJson
        .map((json) => ChatConversation.fromJson(jsonDecode(json)))
        .toList()
      // 最後に更新したものが最初に来るようにソート
      ..sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
  }

  // 特定の会話を取得
  Future<ChatConversation?> getConversationById(String id) async {
    final conversations = await getAllConversations();
    try {
      return conversations.firstWhere((conv) => conv.id == id);
    } catch (e) {
      return null; // 見つからない場合はnull
    }
  }

  // 会話を保存（新規または更新）
  Future<void> saveConversation(ChatConversation conversation) async {
    final prefs = await SharedPreferences.getInstance();
    final conversations = await getAllConversations();

    // 既存の会話を更新または新しい会話を追加
    final index = conversations.indexWhere((c) => c.id == conversation.id);
    if (index >= 0) {
      conversations[index] = conversation;
    } else {
      conversations.add(conversation);
    }

    // JSONに変換して保存
    final conversationsJson =
        conversations.map((conv) => jsonEncode(conv.toJson())).toList();

    await prefs.setStringList(_conversationsKey, conversationsJson);
  }

  // 会話を削除
  Future<void> deleteConversation(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final conversations = await getAllConversations();

    // 指定されたIDの会話を削除
    conversations.removeWhere((conv) => conv.id == id);

    // JSONに変換して保存
    final conversationsJson =
        conversations.map((conv) => jsonEncode(conv.toJson())).toList();

    await prefs.setStringList(_conversationsKey, conversationsJson);

    // アクティブな会話IDを確認し、削除された会話が選択されていた場合はリセット
    final activeId = prefs.getString(_activeConversationIdKey);
    if (activeId == id) {
      await prefs.remove(_activeConversationIdKey);
    }
  }

  // すべての会話を削除
  Future<void> deleteAllConversations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_conversationsKey);
    await prefs.remove(_activeConversationIdKey);
  }

  // アクティブな会話IDを保存
  Future<void> setActiveConversationId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeConversationIdKey, id);
  }

  // アクティブな会話IDを取得
  Future<String?> getActiveConversationId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeConversationIdKey);
  }

  // 新しい会話を作成
  Future<ChatConversation> createNewConversation({String? title}) async {
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch.toString();

    // 初期メッセージを作成（AIのウェルカムメッセージ）
    final initialMessage = ChatMessage(
      message:
          'こんにちは！財Techへようこそ。会計や税務のご質問、写真や書類のアップロードなど、なんでもお気軽にどうぞ。お手伝いさせていただきます。',
      isUser: false,
      type: 'text',
    );

    final conversation = ChatConversation(
      id: id,
      title: title ?? '新しい会話',
      messages: [initialMessage],
      createdAt: now,
      lastUpdatedAt: now,
    );

    await saveConversation(conversation);
    await setActiveConversationId(id);

    return conversation;
  }
}
