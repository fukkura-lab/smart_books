import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_books/blocs/chat/chat_bloc.dart';
import 'package:smart_books/blocs/chat/chat_event.dart';
import 'package:smart_books/blocs/chat/chat_state.dart';
import 'package:smart_books/models/chat_message.dart';
import 'package:smart_books/di/service_locator.dart';
import 'package:smart_books/services/sound_effect_service.dart';
import 'package:smart_books/screens/document_scan_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);
  
  // フォーカス状態を管理する通知
  static final ValueNotifier<bool> focusNotifier = ValueNotifier<bool>(false);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  bool _isComposing = false;
  
  // 効果音サービス
  late SoundEffectService _soundEffectService;
  
  @override
  void initState() {
    super.initState();
    // メッセージ履歴の読み込み
    context.read<ChatBloc>().add(LoadChatHistoryEvent());
    
    // 効果音サービスの取得
    _soundEffectService = serviceLocator<SoundEffectService>();
    
    // フォーカス状態の監視
    _inputFocusNode.addListener(_handleFocusChange);
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocusNode.removeListener(_handleFocusChange);
    _inputFocusNode.dispose();
    super.dispose();
  }
  
  // フォーカス状態の変更を通知
  void _handleFocusChange() {
    if (mounted) {
      ChatScreen.focusNotifier.value = _inputFocusNode.hasFocus;
      // フォーカスが外れたときの処理を追加
      if (!_inputFocusNode.hasFocus) {
        // キーボードを閉じる
        FocusScope.of(context).unfocus();
      }
    }
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    // テキストフィールドをクリア
    _messageController.clear();
    setState(() => _isComposing = false);
    
    // メッセージ送信
    context.read<ChatBloc>().add(SendMessageEvent(text));
    
    // 効果音再生
    _soundEffectService.playClickSound();
    
    // 少し遅延してスクロール（UIが更新されるのを待つ）
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    
    // ハプティックフィードバック
    HapticFeedback.lightImpact();
    
    // フォーカスを外す
    if (mounted) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    // キーボードの高さを取得
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return GestureDetector(
      // 画面タップでフォーカスを外す
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 16,
                child: Icon(Icons.assistant, color: Theme.of(context).primaryColor, size: 20),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('財Tech AIアシスタント', style: TextStyle(fontSize: 16)),
                  Text('会計・税務のエキスパート', style: TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                _showClearHistoryDialog();
              },
              tooltip: '履歴をクリア',
            ),
          ],
        ),
        body: Padding(
          // キーボードが表示されたときにパディングを調整
          padding: EdgeInsets.only(bottom: bottomPadding > 0 ? 0 : 0),
          child: Column(
            children: [
              // チャット履歴表示エリア
              Expanded(
                child: BlocConsumer<ChatBloc, ChatState>(
                  listener: (context, state) {
                    if (state is ChatLoaded || state is ChatProcessing) {
                      // 状態が更新されたらスクロール
                      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
                    }
                  },
                  builder: (context, state) {
                    if (state is ChatLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ChatLoaded || state is ChatProcessing) {
                      final messages = state is ChatLoaded 
                          ? state.messages 
                          : (state as ChatProcessing).messages;
                      
                      if (messages.isEmpty) {
                        return _buildEmptyState();
                      }
                      
                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return _buildMessageItem(message);
                        },
                      );
                    } else if (state is ChatError) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[300], size: 48),
                          const SizedBox(height: 16),
                          Text('エラー: ${state.message}', style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ChatBloc>().add(LoadChatHistoryEvent());
                            },
                            child: const Text('再試行'),
                          ),
                        ],
                      );
                    } else {
                      return _buildEmptyState();
                    }
                  },
                ),
              ),
              
              // アシスタント応答中の表示
              BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatProcessing) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[900] 
                          : Colors.grey[100],
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '返答を作成中...',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.grey[400] 
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              
                // チャット入力コンテナ
                Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: EdgeInsets.only(bottom: bottomPadding > 0 ? bottomPadding - 28 : 0), // キーボードの高さに応じて調整
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Theme.of(context).scaffoldBackgroundColor 
                        : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        spreadRadius: 1,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                child: Row(
                  children: [
                    // 画像アップロードボタン
                    IconButton(
                      icon: const Icon(Icons.image),
                      color: Colors.grey[600],
                      onPressed: () {
                        _showImageUploadDialog();
                      },
                    ),
                    
                    // メッセージ入力
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _inputFocusNode,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: '質問を入力...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.grey[800] 
                              : Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.send,
                        onChanged: (text) {
                          setState(() {
                            _isComposing = text.trim().isNotEmpty;
                          });
                        },
                        onSubmitted: _isComposing ? (text) {
                          _handleSubmitted(text);
                          // 送信後にフォーカスを外す
                          FocusScope.of(context).unfocus();
                        } : null,
                      ),
                    ),
                    
                    // 送信ボタン
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: _isComposing ? Theme.of(context).primaryColor : Colors.grey[400],
                      onPressed: _isComposing
                          ? () {
                              _handleSubmitted(_messageController.text);
                              // 送信後にフォーカスを外す
                              FocusScope.of(context).unfocus();
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '財Tech AIアシスタント',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              '会計・税務に関するご質問に答えます。何でもお気軽にお尋ねください。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildSuggestionButton('消費税の計算方法を教えてください'),
          const SizedBox(height: 8),
          _buildSuggestionButton('確定申告の期限はいつですか？'),
          const SizedBox(height: 8),
          _buildSuggestionButton('経費として計上できるものを教えてください'),
        ],
      ),
    );
  }
  
  Widget _buildSuggestionButton(String text) {
    return OutlinedButton(
      onPressed: () {
        _messageController.text = text;
        _handleSubmitted(text);
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: BorderSide(color: Theme.of(context).primaryColor),
      ),
      child: Text(text),
    );
  }
  
  Widget _buildMessageItem(ChatMessage message) {
    final isUserMessage = message.isUser;
    
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUserMessage 
              ? Theme.of(context).primaryColor 
              : Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey[800] 
                  : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // メッセージ内容
            SelectableText(
              message.content,
              style: TextStyle(
                color: isUserMessage 
                    ? Colors.white 
                    : Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            
            // タイムスタンプ
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isUserMessage)
                  Icon(
                    Icons.assistant,
                    size: 12,
                    color: isUserMessage 
                        ? Colors.white70 
                        : Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white70 
                            : Colors.black45,
                  ),
                if (!isUserMessage)
                  const SizedBox(width: 4),
                Text(
                  '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isUserMessage 
                        ? Colors.white70 
                        : Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white70 
                            : Colors.black45,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('会話履歴のクリア'),
        content: const Text('会話履歴をすべて削除しますか？この操作は元に戻せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ChatBloc>().add(ClearChatHistoryEvent());
            },
            child: const Text('削除'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showImageUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('画像をアップロード'),
        content: Container(
          height: 180,
          width: 280,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('領収書や請求書の画像を選択してください。'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // カメラボタン
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.camera_alt, size: 36),
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          Navigator.pop(context);
                          _takePhoto();
                        },
                      ),
                      const Text('写真を撮影')
                    ],
                  ),
                  // ギャラリーボタン
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.photo_library, size: 36),
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          Navigator.pop(context);
                          _pickImage();
                        },
                      ),
                      const Text('ギャラリーから選択')
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
  
  // 写真を撮影
  void _takePhoto() {
    // 撮影画面への遷移実装
    Navigator.pushNamed(context, '/document-scan');
  }
  
  // ギャラリーから画像を選択
  void _pickImage() {
    // ギャラリーから画像選択実装
    Navigator.pushNamed(context, '/document-scan', arguments: {'source': 'gallery'});
  }
}
