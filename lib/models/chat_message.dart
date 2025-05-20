class ChatMessage {
  final String id;
  final String content;
  final DateTime timestamp;
  final bool isUser;
  final String type;
  
  ChatMessage({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isUser,
    this.type = 'text',
  });
  
  // JSONからの変換
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      isUser: json['isUser'],
      type: json['type'] ?? 'text',
    );
  }
  
  // JSONへの変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isUser': isUser,
      'type': type,
    };
  }
}
