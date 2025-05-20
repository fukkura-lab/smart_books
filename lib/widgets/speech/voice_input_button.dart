import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../../services/speech_service.dart';

class VoiceInputButton extends StatefulWidget {
  /// 音声入力サービス
  final SpeechService speechService;
  
  /// 録音開始コールバック
  final VoidCallback? onRecordingStarted;
  
  /// 録音終了コールバック
  final Function(String, String?)? onRecordingFinished;
  
  /// 録音キャンセルコールバック
  final VoidCallback? onRecordingCancelled;
  
  /// ボタンサイズ
  final double size;
  
  /// アクティブカラー
  final Color activeColor;
  
  /// 非アクティブカラー
  final Color inactiveColor;
  
  /// エラーカラー
  final Color errorColor;
  
  const VoiceInputButton({
    Key? key,
    required this.speechService,
    this.onRecordingStarted,
    this.onRecordingFinished,
    this.onRecordingCancelled,
    this.size = 48.0,
    this.activeColor = Colors.red,
    this.inactiveColor = Colors.blue,
    this.errorColor = Colors.orange,
  }) : super(key: key);

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> with SingleTickerProviderStateMixin {
  /// 現在の状態
  SpeechState _currentState = SpeechState.notListening;
  
  /// 認識テキスト
  String _currentText = '';
  
  /// アニメーションコントローラ
  late AnimationController _animationController;
  
  /// 拡大アニメーション
  late Animation<double> _scaleAnimation;
  
  /// ドラッグ中フラグ
  bool _isDragging = false;
  
  /// ドラッグキャンセル位置の閾値（上方向へのドラッグ距離）
  final double _cancelThreshold = -80.0;
  
  /// ドラッグオフセット
  Offset _dragOffset = Offset.zero;
  
  @override
  void initState() {
    super.initState();
    
    // アニメーションコントローラの初期化
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    // スケールアニメーションの設定
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    // ストリーム購読
    widget.speechService.speechStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _currentState = state;
        });
      }
    });
    
    widget.speechService.recognizedTextStream.listen((text) {
      if (mounted) {
        setState(() {
          _currentText = text;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  // 録音の開始
  Future<void> _startRecording() async {
    if (_currentState == SpeechState.notListening || 
        _currentState == SpeechState.done || 
        _currentState == SpeechState.error) {
      
      widget.onRecordingStarted?.call();
      
      final success = await widget.speechService.startListening();
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('音声入力を開始できませんでした。マイクへのアクセス許可を確認してください。')),
        );
      }
    }
  }
  
  // 録音の停止
  Future<void> _stopRecording({bool cancel = false}) async {
    if (_currentState == SpeechState.listening) {
      if (cancel) {
        await widget.speechService.cancelListening();
        widget.onRecordingCancelled?.call();
      } else {
        final text = await widget.speechService.stopListening();
        widget.onRecordingFinished?.call(text, widget.speechService.recordingPath);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // ボタンの色を状態に応じて設定
    Color buttonColor;
    Icon buttonIcon;
    bool showGlow = false;
    
    switch (_currentState) {
      case SpeechState.listening:
        buttonColor = widget.activeColor;
        buttonIcon = const Icon(Icons.mic, color: Colors.white);
        showGlow = true;
        break;
      case SpeechState.initializing:
      case SpeechState.processing:
        buttonColor = widget.activeColor.withOpacity(0.7);
        buttonIcon = const Icon(Icons.hourglass_empty, color: Colors.white);
        showGlow = false;
        break;
      case SpeechState.error:
        buttonColor = widget.errorColor;
        buttonIcon = const Icon(Icons.error_outline, color: Colors.white);
        showGlow = false;
        break;
      case SpeechState.notListening:
      case SpeechState.done:
      default:
        buttonColor = widget.inactiveColor;
        buttonIcon = const Icon(Icons.mic_none, color: Colors.white);
        showGlow = false;
    }
    
    // ドラッグによるキャンセル表示の可否
    final showCancelHint = _isDragging && _dragOffset.dy < 0;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // キャンセルヒント
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: showCancelHint ? 40 : 0,
          child: showCancelHint
              ? Center(
                  child: Text(
                    'スワイプアップでキャンセル',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                )
              : null,
        ),
        
        // 認識テキスト表示（リスニング中のみ）
        if (_currentState == SpeechState.listening && _currentText.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _currentText,
              style: TextStyle(color: Colors.grey[800]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        
        // マイクボタン
        GestureDetector(
          onLongPressStart: (_) {
            _isDragging = true;
            _dragOffset = Offset.zero;
            _animationController.forward();
            _startRecording();
          },
          onLongPressEnd: (_) {
            _isDragging = false;
            _animationController.reverse();
            
            // キャンセル閾値を超えていればキャンセル
            final shouldCancel = _dragOffset.dy < _cancelThreshold;
            _stopRecording(cancel: shouldCancel);
            
            setState(() {
              _dragOffset = Offset.zero;
            });
          },
          onLongPressMoveUpdate: (details) {
            setState(() {
              _dragOffset += details.offsetFromOrigin - _dragOffset;
            });
          },
          child: AvatarGlow(
            endRadius: widget.size * 1.5,
            glowColor: buttonColor,
            animate: showGlow,
            duration: const Duration(milliseconds: 1500),
            repeat: true,
            showTwoGlows: true,
            repeatPauseDuration: const Duration(milliseconds: 100),
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: buttonColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: buttonColor.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: buttonIcon,
                  ),
                );
              },
            ),
          ),
        ),
        
        // ヘルプテキスト
        const SizedBox(height: 4),
        Text(
          _currentState == SpeechState.listening
              ? '話し終わったら指を離してください'
              : '長押しして話す',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
