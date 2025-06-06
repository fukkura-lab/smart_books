abstract class ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String message;
  
  SendMessageEvent(this.message);
}

class LoadChatHistoryEvent extends ChatEvent {}

class ClearChatHistoryEvent extends ChatEvent {}
