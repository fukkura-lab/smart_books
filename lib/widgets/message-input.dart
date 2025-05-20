import 'package:flutter/material.dart';
import 'package:smart_books/services/audio_service.dart';
import 'package:get_it/get_it.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback onAttachmentPressed;
  final VoidCallback onMicPressed;
  final bool isLoading;
  
  const MessageInput({
    Key? key,
    required this.onSendMessage,
    required this.onAttachmentPressed,
    required this.onMicPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;
  late AudioService _audioService;
  
  @override
  void initState() {
    super.initState();
    _audioService = GetIt.instance<AudioService>();
    _controller.addListener(_onTextChanged);
  }
  
  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _onTextChanged() {
    setState(() {
      _isComposing = _controller.text.isNotEmpty;
    });
  }
  
  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
    
    // 効果音を再生
    _audioService.playMessageSentSound();
    
    // メッセージを送信
    widget.onSendMessage(text);
    
    // キーボードがフォーカスを維持
    _focusNode.requestFocus();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 6,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          // 添付ファイルボタン
          IconButton(
            icon: Icon(
              Icons.attach_file,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: widget.onAttachmentPressed,
          ),
          
          // テキスト入力
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: widget.isLoading ? '回答を生成中...' : 'メッセージを入力...',
                hintStyle: TextStyle(
                  color: widget.isLoading
                      ? Theme.of(context).disabledColor
                      : Colors.grey[500],
                ),
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              enabled: !widget.isLoading,
              onSubmitted: _isComposing ? _handleSubmitted : null,
            ),
          ),
          
          // マイクボタン（テキストが入力されていない場合のみ表示）
          if (!_isComposing)
            IconButton(
              icon: Icon(
                Icons.mic,
                color: widget.isLoading
                    ? Theme.of(context).disabledColor
                    : Theme.of(context).primaryColor,
              ),
              onPressed: widget.isLoading ? null : widget.onMicPressed,
            ),
          
          // 送信ボタン（テキストが入力されている場合のみ表示）
          if (_isComposing)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: widget.isLoading
                    ? null
                    : () => _handleSubmitted(_controller.text),
                child: const Icon(Icons.send),
              ),
            ),
        ],
      ),
    );
  }
}
