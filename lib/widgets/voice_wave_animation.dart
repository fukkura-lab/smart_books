import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 音声波アニメーションウィジェット
///
/// 音声入力中の音声波を表示するアニメーションウィジェット
class VoiceWaveAnimation extends StatefulWidget {
  final double level;           // 音量レベル（0.0 ~ 1.0）
  final Color color;            // アニメーション色
  final double size;            // ウィジェット全体のサイズ
  final int waveCount;          // 波の数
  final Duration duration;      // アニメーション時間
  final bool isListening;       // 音声認識中かどうか
  
  const VoiceWaveAnimation({
    Key? key,
    required this.level,
    this.color = Colors.blue,
    this.size = 80.0,
    this.waveCount = 5,
    this.duration = const Duration(milliseconds: 1500),
    this.isListening = false,
  }) : super(key: key);

  @override
  State<VoiceWaveAnimation> createState() => _VoiceWaveAnimationState();
}

class _VoiceWaveAnimationState extends State<VoiceWaveAnimation> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  @override
  void didUpdateWidget(VoiceWaveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 音声認識状態が変わった場合
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
    
    // 波の数が変わった場合
    if (widget.waveCount != oldWidget.waveCount) {
      _disposeAnimations();
      _initializeAnimations();
    }
  }
  
  // アニメーションの初期化
  void _initializeAnimations() {
    _controllers = List.generate(
      widget.waveCount,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: widget.duration.inMilliseconds - (index * 100),
        ),
      ),
    );
    
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutQuart,
        ),
      );
    }).toList();
    
    if (widget.isListening) {
      _startAnimations();
    }
  }
  
  // アニメーション開始
  void _startAnimations() {
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted && widget.isListening) {
          _controllers[i].repeat();
        }
      });
    }
  }
  
  // アニメーション停止
  void _stopAnimations() {
    for (var controller in _controllers) {
      controller.stop();
    }
  }
  
  // アニメーションの破棄
  void _disposeAnimations() {
    for (var controller in _controllers) {
      controller.dispose();
    }
  }
  
  @override
  void dispose() {
    _disposeAnimations();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // レベルに応じたサイズ計算（最小0.2、最大1.0）
    final levelFactor = 0.2 + (widget.level * 0.8);
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 中央の円（マイクアイコン）
            Container(
              width: widget.size * 0.4,
              height: widget.size * 0.4,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
              ),
            ),
            
            // 波アニメーション（複数の波を表示）
            ...List.generate(widget.waveCount, (index) {
              // 各波のサイズと不透明度を計算
              final waveIndex = widget.waveCount - index - 1;
              
              return AnimatedBuilder(
                animation: _animations[index],
                builder: (context, child) {
                  // アニメーション値に応じてサイズと不透明度を計算
                  final animValue = _animations[index].value;
                  final size = widget.size * 0.5 + (animValue * widget.size * 0.5 * levelFactor);
                  final opacity = (1.0 - animValue) * 0.7;
                  
                  return Opacity(
                    opacity: opacity,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.color,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
            
            // 音量に応じたエフェクト（波紋）
            if (widget.isListening)
              ...List.generate(3, (index) {
                final angle = index * (math.pi * 2 / 3);
                final offset = Offset(
                  math.cos(angle) * (widget.size * 0.2 * levelFactor),
                  math.sin(angle) * (widget.size * 0.2 * levelFactor),
                );
                
                return Positioned(
                  left: (widget.size / 2) + offset.dx - 4,
                  top: (widget.size / 2) + offset.dy - 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

/// 音声認識フローティングボタン
///
/// 音声認識の開始・停止が行えるカスタムフローティングボタン
class VoiceRecognitionButton extends StatelessWidget {
  final bool isListening;
  final double soundLevel;
  final VoidCallback onPressed;
  final Color color;
  final double size;
  
  const VoiceRecognitionButton({
    Key? key,
    required this.isListening,
    required this.onPressed,
    this.soundLevel = 0.0,
    this.color = Colors.blue,
    this.size = 60.0,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 3,
            ),
          ],
        ),
        child: isListening
            ? VoiceWaveAnimation(
                level: soundLevel,
                color: color,
                size: size,
                isListening: isListening,
              )
            : Icon(
                Icons.mic,
                color: color,
                size: size * 0.5,
              ),
      ),
    );
  }
}

/// 音声認識中のオーバーレイウィジェット
///
/// 音声認識中に表示されるフルスクリーンオーバーレイ
class VoiceRecognitionOverlay extends StatelessWidget {
  final bool isListening;
  final String recognizedText;
  final double soundLevel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final Color primaryColor;
  
  const VoiceRecognitionOverlay({
    Key? key,
    required this.isListening,
    required this.recognizedText,
    required this.soundLevel,
    required this.onCancel,
    required this.onConfirm,
    this.primaryColor = Colors.blue,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isListening ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: isListening
          ? Container(
              color: Colors.black.withOpacity(0.7),
              child: SafeArea(
                child: Column(
                  children: [
                    // ヘッダー
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: onCancel,
                          ),
                          const Expanded(
                            child: Text(
                              '音声入力',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 48), // バランスを取るためのスペース
                        ],
                      ),
                    ),
                    
                    // アニメーション
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 波アニメーション
                            VoiceWaveAnimation(
                              level: soundLevel,
                              color: primaryColor,
                              size: 150,
                              isListening: isListening,
                              waveCount: 7,
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // 認識テキスト表示
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                recognizedText.isEmpty
                                    ? 'お話しください...'
                                    : recognizedText,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: recognizedText.isEmpty ? 16 : 20,
                                  fontWeight: recognizedText.isEmpty
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // 確定ボタン
                    if (recognizedText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: onConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            '確定',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
