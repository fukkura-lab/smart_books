import 'package:equatable/equatable.dart';

enum MessageType {
  text,
  image,
  audio,
  document,
  system,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

enum MessageSender {
  user,
  ai,
  system,
}

class ChatMessage extends Equatable {
  final String id;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;
  final MessageSender sender;
  final Map<String, dynamic>? metadata;
  final String? imageUrl;
  final String? documentUrl;
  final String? audioUrl;
  
  const ChatMessage({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.type,
    required this.status,
    required this.sender,
    this.metadata,
    this.imageUrl,
    this.documentUrl,
    this.audioUrl,
  });

  // JSONからChatMessageモデルを作成
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${json['status']}',
        orElse: () => MessageStatus.sent,
      ),
      sender: MessageSender.values.firstWhere(
        (e) => e.toString() == 'MessageSender.${json['sender']}',
        orElse: () => MessageSender.user,
      ),
      metadata: json['metadata'],
      imageUrl: json['image_url'],
      documentUrl: json['document_url'],
      audioUrl: json['audio_url'],
    );
  }

  // ChatMessageモデルをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'sender': sender.toString().split('.').last,
      'metadata': metadata,
      'image_url': imageUrl,
      'document_url': documentUrl,
      'audio_url': audioUrl,
    };
  }

  // コピーコンストラクタ
  ChatMessage copyWith({
    String? id,
    String? content,
    DateTime? timestamp,
    MessageType? type,
    MessageStatus? status,
    MessageSender? sender,
    Map<String, dynamic>? metadata,
    String? imageUrl,
    String? documentUrl,
    String? audioUrl,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
      sender: sender ?? this.sender,
      metadata: metadata ?? this.metadata,
      imageUrl: imageUrl ?? this.imageUrl,
      documentUrl: documentUrl ?? this.documentUrl,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }

  // ユーザーメッセージを作成するファクトリメソッド
  factory ChatMessage.user({
    required String id,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
    String? imageUrl,
    String? documentUrl,
    String? audioUrl,
  }) {
    return ChatMessage(
      id: id,
      content: content,
      timestamp: DateTime.now(),
      type: type,
      status: MessageStatus.sending,
      sender: MessageSender.user,
      metadata: metadata,
      imageUrl: imageUrl,
      documentUrl: documentUrl,
      audioUrl: audioUrl,
    );
  }

  // AIメッセージを作成するファクトリメソッド
  factory ChatMessage.ai({
    required String id,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
    String? imageUrl,
    String? documentUrl,
    String? audioUrl,
  }) {
    return ChatMessage(
      id: id,
      content: content,
      timestamp: DateTime.now(),
      type: type,
      status: MessageStatus.delivered,
      sender: MessageSender.ai,
      metadata: metadata,
      imageUrl: imageUrl,
      documentUrl: documentUrl,
      audioUrl: audioUrl,
    );
  }

  // システムメッセージを作成するファクトリメソッド
  factory ChatMessage.system({
    required String id,
    required String content,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id,
      content: content,
      timestamp: DateTime.now(),
      type: MessageType.system,
      status: MessageStatus.delivered,
      sender: MessageSender.system,
      metadata: metadata,
    );
  }

  @override
  List<Object?> get props => [
    id,
    content,
    timestamp,
    type,
    status,
    sender,
    metadata,
    imageUrl,
    documentUrl,
    audioUrl,
  ];
}

// チャット会話モデル
class ChatConversation extends Equatable {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage> messages;
  final Map<String, dynamic>? metadata;

  const ChatConversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
    this.metadata,
  });

  // JSONからChatConversationモデルを作成
  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      messages: (json['messages'] as List)
          .map((messageJson) => ChatMessage.fromJson(messageJson))
          .toList(),
      metadata: json['metadata'],
    );
  }

  // ChatConversationモデルをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'messages': messages.map((message) => message.toJson()).toList(),
      'metadata': metadata,
    };
  }

  // コピーコンストラクタ
  ChatConversation copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ChatMessage>? messages,
    Map<String, dynamic>? metadata,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      metadata: metadata ?? this.metadata,
    );
  }

  // 新しいメッセージを追加したConversationを返す
  ChatConversation addMessage(ChatMessage message) {
    return copyWith(
      messages: [...messages, message],
      updatedAt: DateTime.now(),
    );
  }

  // 最後のメッセージを取得
  ChatMessage? get lastMessage {
    if (messages.isEmpty) {
      return null;
    }
    return messages.last;
  }

  @override
  List<Object?> get props => [
    id,
    title,
    createdAt,
    updatedAt,
    messages,
    metadata,
  ];
}
