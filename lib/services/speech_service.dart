import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// 音声入力の状態を表す列挙型
enum SpeechState {
  /// 待機中
  notListening,
  
  /// 準備中
  initializing,
  
  /// リスニング中
  listening,
  
  /// 処理中
  processing,
  
  /// 完了
  done,
  
  /// エラー
  error
}

/// 音声認識サービス
class SpeechService {
  /// Speech to Textインスタンス
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  /// レコーダーインスタンス
  final _recorder = Record();
  
  /// 音声認識状態
  SpeechState _speechState = SpeechState.notListening;
  
  /// 認識結果
  String _recognizedText = '';
  
  /// 録音中のパス
  String? _recordingPath;
  
  /// 認識可能フラグ
  bool _isAvailable = false;
  
  /// ストリームコントローラー
  final _stateController = StreamController<SpeechState>.broadcast();
  final _textController = StreamController<String>.broadcast();
  
  /// 音声状態ストリーム
  Stream<SpeechState> get speechStateStream => _stateController.stream;
  
  /// 認識テキストストリーム
  Stream<String> get recognizedTextStream => _textController.stream;
  
  /// 音声認識状態
  SpeechState get speechState => _speechState;
  
  /// 認識結果
  String get recognizedText => _recognizedText;
  
  /// 録音ファイルパス
  String? get recordingPath => _recordingPath;
  
  /// 初期化処理
  Future<bool> initialize() async {
    _updateSpeechState(SpeechState.initializing);
    
    try {
      _isAvailable = await _speech.initialize(
        onStatus: (status) {
          if (kDebugMode) {
            print('Speech recognition status: $status');
          }
          
          if (status == 'done') {
            _updateSpeechState(SpeechState.done);
          } else if (status == 'notListening') {
            _updateSpeechState(SpeechState.notListening);
          }
        },
        onError: (error) {
          if (kDebugMode) {
            print('Speech recognition error: $error');
          }
          _updateSpeechState(SpeechState.error);
        },
        debugLogging: kDebugMode,
      );
      
      if (_isAvailable) {
        _updateSpeechState(SpeechState.notListening);
        return true;
      } else {
        _updateSpeechState(SpeechState.error);
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Speech initialization error: $e');
      }
      _updateSpeechState(SpeechState.error);
      return false;
    }
  }
  
  /// マイク権限の確認
  Future<bool> checkPermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      return true;
    }
    
    // 権限がない場合はリクエスト
    final result = await Permission.microphone.request();
    return result.isGranted;
  }
  
  /// 音声認識の開始
  Future<bool> startListening() async {
    if (!_isAvailable) {
      await initialize();
    }
    
    // マイク権限の確認
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      _updateSpeechState(SpeechState.error);
      return false;
    }
    
    // 録音用の一時ファイルパス生成
    final tempDir = await getTemporaryDirectory();
    _recordingPath = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    
    // レコーダー開始
    await _recorder.start(path: _recordingPath);
    
    try {
      _updateSpeechState(SpeechState.listening);
      
      // 日本語で音声認識を開始
      return await _speech.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          _textController.add(_recognizedText);
          
          if (kDebugMode) {
            print('認識テキスト: $_recognizedText');
          }
        },
        localeId: 'ja_JP', // 日本語に設定
        listenMode: stt.ListenMode.confirmation, // 確認モード
        pauseFor: const Duration(seconds: 3), // 3秒間の沈黙で自動停止
        cancelOnError: true,
        partialResults: true, // 途中結果を返す
      );
    } catch (e) {
      if (kDebugMode) {
        print('音声認識エラー: $e');
      }
      _updateSpeechState(SpeechState.error);
      return false;
    }
  }
  
  /// 音声認識の停止
  Future<String> stopListening() async {
    _updateSpeechState(SpeechState.processing);
    
    // SpeechToTextの停止
    _speech.stop();
    
    // レコーダーの停止
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    
    // 認識結果の取得
    final result = _recognizedText.trim();
    
    _updateSpeechState(SpeechState.done);
    return result;
  }
  
  /// 音声認識のキャンセル
  Future<void> cancelListening() async {
    _speech.cancel();
    
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    
    // 作成したファイルがあれば削除
    if (_recordingPath != null && File(_recordingPath!).existsSync()) {
      try {
        await File(_recordingPath!).delete();
        _recordingPath = null;
      } catch (e) {
        if (kDebugMode) {
          print('ファイル削除エラー: $e');
        }
      }
    }
    
    _recognizedText = '';
    _updateSpeechState(SpeechState.notListening);
  }
  
  /// 状態の更新
  void _updateSpeechState(SpeechState state) {
    _speechState = state;
    _stateController.add(state);
  }
  
  /// リソースの解放
  void dispose() {
    _stateController.close();
    _textController.close();
    _speech.cancel();
    _recorder.dispose();
  }
}