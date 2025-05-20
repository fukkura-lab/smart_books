import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'package:avatar_glow/avatar_glow.dart';

/// 高度な音声認識オーバーレイ
///
/// ロッティーアニメーションと美しいUIを使用した音声認識用のフルスクリーンオーバーレイ
class EnhancedVoiceRecognitionOverlay extends StatefulWidget {
  final bool isListening;               // 音声認識中かどうか
  final String recognizedText;          // 認識されたテキスト
  final double soundLevel;              // 音量レベル
  final VoidCallback onCancel;          // キャンセル時のコールバック
  final VoidCallback onConfirm;         // 確定時のコールバック
  final Color primaryColor;             // メインカラー
  final Color backgroundColor;          // 背景色
  
  const EnhancedVoiceRecognitionOverlay({
    Key? key,
    required this.isListening,
    required this.recognizedText,
    required this.soundLevel,
    required this.onCancel,
    required this.onConfirm,
    this.primaryColor = const Color(0xFF3BCFD4),
    this.backgroundColor = Colors.black,
  }) : super(key: key);

  @override
  State<EnhancedVoiceRecognitionOverlay> createState() => _EnhancedVoiceRecognitionOverlayState();
}

class _EnhancedVoiceRecognitionOverlayState extends State<EnhancedVoiceRecognitionOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final List<String> _hints = [
    'はっきりと喋るとより正確に認識します',
    '会計処理や税金に関する質問をしてみましょう',
    '「先月の売上は10万円です」など具体的な数字も認識します',
    '「領収書を登録して」と言うと、カメラが起動します',
    '「今月の経費を教えて」と聞いてみましょう',
    'ふるさと納税の相談もできます',
  ];
  int _currentHintIndex = 0;
  
  @override
  void initState() {
    super.initState();
    
    // アニメーションコントローラーの初期化
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    
    // ランダムなヒントを表示
    _currentHintIndex = DateTime.now().microsecond % _hints.length;
    
    // 表示時にアニメーションを開始
    if (widget.isListening) {
      _animationController.forward();
    }
    
    // 定期的にヒントを切り替える
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _rotateHint();
      }
    });
  }
  
  void _rotateHint() {
    setState(() {
      _currentHintIndex = (_currentHintIndex + 1) % _hints.length;
    });
    
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _rotateHint();
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(EnhancedVoiceRecognitionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // リスニング状態が変わった場合にアニメーションを制御
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isCompactHeight = screenHeight < 700;  // 小さい画面用のレイアウト調整
    
    return AnimatedOpacity(
      opacity: widget.isListening || widget.recognizedText.isNotEmpty ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Visibility(
        visible: widget.isListening || widget.recognizedText.isNotEmpty,
        child: Material(
          color: Colors.transparent,
          child: Container(
            color: widget.backgroundColor.withOpacity(0.9),
            child: SafeArea(
              child: Stack(
                children: [
                  // 閉じるボタン
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        widget.onCancel();
                      },
                      tooltip: 'キャンセル',
                    ),
                  ),
                  
                  // メインコンテンツ
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                        // ヘッダー
                        Container(
                          padding: const EdgeInsets.only(top: 20, bottom: 10),
                          alignment: Alignment.center,
                          child: Text(
                            widget.isListening ? '聞いています...' : '認識結果',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        // アニメーション部分
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 音声波アニメーション
                                if (widget.isListening)
                                  AvatarGlow(
                                    endRadius: 100.0,
                                    animate: true,
                                    duration: const Duration(milliseconds: 2000),
                                    glowColor: widget.primaryColor,
                                    repeat: true,
                                    repeatPauseDuration: const Duration(milliseconds: 100),
                                    showTwoGlows: true,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: widget.primaryColor.withOpacity(0.2),
                                      ),
                                      child: Icon(
                                        Icons.mic,
                                        color: widget.primaryColor,
                                        size: 40,
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: widget.primaryColor.withOpacity(0.2),
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      color: widget.primaryColor,
                                      size: 40,
                                    ),
                                  ),
                                
                                SizedBox(height: isCompactHeight ? 20 : 40),
                                
                                // 認識テキスト表示
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.all(20),
                                  margin: const EdgeInsets.symmetric(horizontal: 24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: widget.primaryColor.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        widget.recognizedText.isEmpty
                                            ? '何かお話しください...'
                                            : widget.recognizedText,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: widget.recognizedText.isEmpty ? 18 : 22,
                                          fontWeight: widget.recognizedText.isEmpty
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      
                                      if (widget.recognizedText.isEmpty && widget.isListening)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 16),
                                          child: Text(
                                            _hints[_currentHintIndex],
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                
                                // 音声レベルインジケーター
                                if (widget.isListening)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 32),
                                    child: _buildVoiceLevelIndicator(widget.soundLevel),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        
                        // 確定ボタン
                        if (widget.recognizedText.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 32,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                widget.onConfirm();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 4,
                                shadowColor: widget.primaryColor.withOpacity(0.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '確定',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.send, size: 18),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // 音声レベルインジケーター
  Widget _buildVoiceLevelIndicator(double level) {
    // 0〜1の範囲に正規化
    final normalizedLevel = level.clamp(0.0, 1.0);
    final barCount = 10;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(barCount, (index) {
        // 各バーがアクティブかどうか計算
        final threshold = index / barCount;
        final isActive = normalizedLevel >= threshold;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 6,
          height: 5 + (index * 3.0),
          decoration: BoxDecoration(
            color: isActive 
                ? widget.primaryColor.withOpacity(0.7 + (index / barCount) * 0.3)
                : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

/// 録音ボタン
///
/// アニメーション付きの録音ボタン
class AnimatedRecordButton extends StatefulWidget {
  final bool isRecording;
  final double soundLevel;
  final VoidCallback onPressed;
  final Color color;
  final double size;
  
  const AnimatedRecordButton({
    Key? key,
    required this.isRecording,
    required this.onPressed,
    this.soundLevel = 0.0,
    this.color = const Color(0xFF3BCFD4),
    this.size = 56.0,
  }) : super(key: key);
  
  @override
  State<AnimatedRecordButton> createState() => _AnimatedRecordButtonState();
}

class _AnimatedRecordButtonState extends State<AnimatedRecordButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    if (widget.isRecording) {
      _animationController.value = 1.0;
    }
  }
  
  @override
  void didUpdateWidget(AnimatedRecordButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // 音量レベルに基づくエフェクトを計算
    final glowOpacity = 0.3 + (widget.soundLevel * 0.7);
    final glowSpreadRadius = 2.0 + (widget.soundLevel * 8.0);
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onPressed();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(widget.isRecording ? glowOpacity : 0.3),
                    blurRadius: 10,
                    spreadRadius: widget.isRecording ? glowSpreadRadius : 2,
                  ),
                ],
              ),
              child: Center(
                child: widget.isRecording
                    ? _buildRecordingIndicator()
                    : Icon(
                        Icons.mic,
                        color: widget.color,
                        size: widget.size * 0.5,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  // 録音中のインジケーター
  Widget _buildRecordingIndicator() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 波紋エフェクト
        AvatarGlow(
          endRadius: widget.size * 0.4,
          animate: true,
          duration: const Duration(milliseconds: 1500),
          glowColor: widget.color,
          repeat: true,
          showTwoGlows: true,
          child: Container(),
        ),
        
        // マイクアイコン
        Icon(
          Icons.mic,
          color: widget.color,
          size: widget.size * 0.5,
        ),
      ],
    );
  }
}