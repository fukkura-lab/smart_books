import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_books/blocs/chat/chat_event.dart';
import 'package:smart_books/blocs/chat/chat_state.dart';
import 'package:smart_books/models/chat_message.dart';
import 'package:smart_books/services/chat_service.dart';
import 'package:smart_books/services/chat_storage_service.dart';
import 'package:smart_books/services/content_classifier.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService;
  final ChatStorageService _storageService;
  List<ChatMessage> _messages = [];
  
  ChatBloc(this._chatService, this._storageService) : super(ChatInitial()) {
    on<LoadChatHistoryEvent>(_onLoadChatHistory);
    on<SendMessageEvent>(_onSendMessage);
    on<ClearChatHistoryEvent>(_onClearChatHistory);
  }
  
  void _onLoadChatHistory(LoadChatHistoryEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      // 会話履歴の読み込み
      _messages = await _storageService.loadChatHistory();
      emit(ChatLoaded(_messages));
    } catch (e) {
      print('履歴読み込みエラー: $e');
      emit(ChatError('会話履歴の読み込みに失敗しました', []));
    }
  }
  
  void _onClearChatHistory(ClearChatHistoryEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      // 会話履歴のクリア
      await _storageService.clearChatHistory();
      _messages = [];
      emit(ChatLoaded(_messages));
    } catch (e) {
      print('履歴クリアエラー: $e');
      emit(ChatError('会話履歴のクリアに失敗しました', _messages));
    }
  }
  
  void _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    // 現在の状態を保存
    final currentMessages = [..._messages];
    
    // 入力内容のカテゴリを分類
    final category = ContentClassifier.classifyContent(event.message);
    
    // 不適切なコンテンツの場合は即時にブロック
    if (category == ContentCategory.inappropriate) {
      final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: event.message,
      timestamp: DateTime.now(),
      isUser: true,
        type: 'text',
    );
      
      final rejectionMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '申し訳ありませんが、違法行為や不適切な内容に関するご質問にはお答えできません。会計や財務に関する適切なご質問をお願いいたします。',
        timestamp: DateTime.now(),
        isUser: false,
        type: 'text',
      );
      
      _messages.add(userMessage);
      _messages.add(rejectionMessage);
      
      await _storageService.saveChatHistory(_messages);
      emit(ChatLoaded([..._messages]));
      return;
    }
    
    // サポート対象外のコンテンツの場合は警告表示
    if (category == ContentCategory.unsupported) {
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: event.message,
        timestamp: DateTime.now(),
        isUser: true,
        type: 'text',
      );
      
      final warningMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'ご質問の内容は、当アプリの主要なサポート範囲外となります。一般的な情報のみ提供可能です。投資アドバイスなど専門的な内容については、該当する専門家にご相談ください。',
        timestamp: DateTime.now(),
        isUser: false,
        type: 'text',
      );
      
      _messages.add(userMessage);
      _messages.add(warningMessage);
      
      await _storageService.saveChatHistory(_messages);
      emit(ChatLoaded([..._messages]));
      return;
    }
    
    // ユーザーメッセージをリストに追加
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: event.message,
      timestamp: DateTime.now(),
      isUser: true,
    );
    
    _messages.add(userMessage);
    emit(ChatProcessing([..._messages]));
    
    try {
      // APIに送信するための会話履歴を整形
      final history = _messages
          .where((msg) => msg != userMessage)
          .map((msg) => {
                'role': msg.isUser ? 'user' : 'assistant',
                'content': msg.content,
              })
          .toList();
      
      // カテゴリに応じた補足プロンプトを取得
      final supplementaryPrompt = ContentClassifier.getSupplementaryPrompt(category);
      
      // メッセージに補足プロンプトを追加
      final enhancedMessage = '$supplementaryPrompt\n\n${event.message}';
      
      // メッセージ送信と応答取得
      final response = await _chatService.sendMessage(enhancedMessage, history);
      
      // 応答をリストに追加
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        timestamp: DateTime.now(),
        isUser: false,
        type: 'text',
      );
      
      _messages.add(aiMessage);
      
      // 会話履歴の保存
      await _storageService.saveChatHistory(_messages);
      
      emit(ChatLoaded([..._messages]));
    } catch (e) {
      print('メッセージ送信エラー: $e');
      // エラー発生時は元の状態に戻す
      _messages = currentMessages;
      emit(ChatError('メッセージの送信に失敗しました', _messages));
    }
  }
}
