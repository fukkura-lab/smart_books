import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';

/// 音声認識サービス
///
/// アプリ内で音声認識を行うためのサービスクラス
class VoiceRecognitionService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _recognizedText = '';

  // 言語設定（日本語）
  final String _language = 'ja_JP';

  // ストリームコントローラー（音声認識中の経過をリアルタイムでUIに反映するため）
  final StreamController<String> _textStreamController =
      StreamController<String>.broadcast();
  final StreamController<bool> _statusStreamController =
      StreamController<bool>.broadcast();
  final StreamController<double> _confidenceStreamController =
      StreamController<double>.broadcast();
  final StreamController<double> _soundLevelStreamController =
      StreamController<double>.broadcast();

  // ゲッター
  Stream<String> get textStream => _textStreamController.stream;
  Stream<bool> get statusStream => _statusStreamController.stream;
  Stream<double> get confidenceStream => _confidenceStreamController.stream;
  Stream<double> get soundLevelStream => _soundLevelStreamController.stream;

  bool get isListening => _isListening;
  String get recognizedText => _recognizedText;

  /// 初期化メソッド
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          debugPrint('音声認識ステータス: $status');
          final isListening = status == 'listening';
          _isListening = isListening;
          _statusStreamController.add(isListening);

          // 音声認識が終了した場合
          if (status == 'done' && _recognizedText.isNotEmpty) {
            // 触覚フィードバック
            HapticFeedback.mediumImpact();
          }
        },
        onError: (error) {
          debugPrint('音声認識エラー: $error');
          _isListening = false;
          _statusStreamController.add(false);

          // エラー時のフィードバック
          HapticFeedback.vibrate();
        },
        debugLogging: true,
      );

      return _isInitialized;
    } catch (e) {
      debugPrint('音声認識の初期化エラー: $e');
      return false;
    }
  }

  /// 音声認識開始
  Future<bool> startListening({
    Function(String text)? onResult,
    Function()? onTimeout,
    int timeoutSeconds = 30,
  }) async {
    // 初期化確認
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    _recognizedText = '';

    try {
      // 触覚フィードバック
      HapticFeedback.lightImpact();

      // *** 重要な修正: listen関数の戻り値がbool型であることを保証 ***
      final started = await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          _recognizedText = result.recognizedWords;
          _textStreamController.add(_recognizedText);

          // 信頼度の送信
          _confidenceStreamController.add(result.confidence);

          // コールバック
          if (onResult != null) {
            onResult(_recognizedText);
          }
        },
        listenFor: Duration(seconds: timeoutSeconds),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: _language,
        onSoundLevelChange: (level) {
          // 音量レベルの送信（アニメーションに使用）
          _soundLevelStreamController.add(level);
        },
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );

      // listen()の結果に基づいて状態を更新
      _isListening = started;
      _statusStreamController.add(started);

      return started;
    } catch (e) {
      debugPrint('音声認識開始エラー: $e');
      _isListening = false;
      _statusStreamController.add(false);
      return false;
    }
  }

  /// 音声認識停止
  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
    _statusStreamController.add(false);

    // 触覚フィードバック
    HapticFeedback.lightImpact();
  }

  /// キャンセル
  Future<void> cancel() async {
    await _speech.cancel();
    _recognizedText = '';
    _isListening = false;
    _statusStreamController.add(false);
    _textStreamController.add('');
  }

  /// サービスの破棄
  void dispose() {
    _speech.cancel();
    _textStreamController.close();
    _statusStreamController.close();
    _confidenceStreamController.close();
    _soundLevelStreamController.close();
  }

  /// 音声認識が利用可能かどうか確認
  Future<bool> isAvailable() async {
    if (!_isInitialized) {
      return await initialize();
    }
    return _isInitialized;
  }
}
