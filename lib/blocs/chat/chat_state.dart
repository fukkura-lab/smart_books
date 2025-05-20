import 'package:smart_books/models/chat_message.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatProcessing extends ChatState {
  final List<ChatMessage> messages;
  
  ChatProcessing(this.messages);
}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  
  ChatLoaded(this.messages);
}

class ChatError extends ChatState {
  final String message;
  final List<ChatMessage> messages;
  
  ChatError(this.message, this.messages);
}
