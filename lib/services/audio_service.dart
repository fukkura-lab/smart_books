import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:smart_books/services/storage_service.dart';
import 'package:get_it/get_it.dart';

class AudioService {
  // オーディオプレーヤー
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // レコーダー
  final Record _audioRecorder = Record();
  
  // 録音中かどうか
  bool _isRecording = false;
  
  // 現在の録音ファイルのパス
  String? _currentRecordingPath;
  
  // 効果音のパスマップ
  final Map<String, String> _soundEffects = {};
  
  // ストレージサービス（設定の保存に使用）
  late StorageService _storageService;
  
  // 効果音が有効かどうか
  bool _soundsEnabled = true;
  
  AudioService() {
    _storageService = GetIt.instance<StorageService>();
    _initAudioService();
  }
  
  // オーディオサービスの初期化
  Future<void> _initAudioService() async {
    // 設定から効果音の有効/無効を読み込む
    _soundsEnabled = _storageService.areSoundsEnabled();
    
    // アセットの効果音をローカルにコピー
    await _loadSoundEffects();
  }
  
  // 効果音をアセットからローカルにコピー
  Future<void> _loadSoundEffects() async {
    try {
      final tempDir = await getTemporaryDirectory();
      
      // 効果音の定義
      final sounds = {
        'message_sent': 'assets/audio/message_sent.mp3',
        'message_received': 'assets/audio/message_received.mp3',
        'button_press': 'assets/audio/button_press.mp3',
        'error': 'assets/audio/error.mp3',
        'success': 'assets/audio/success.mp3',
        'camera_shutter': 'assets/audio/camera_shutter.mp3',
      };
      
      // 各効果音をアセットからローカルにコピー
      for (final entry in sounds.entries) {
        final soundName = entry.key;
        final assetPath = entry.value;
        
        final localPath = '${tempDir.path}/$soundName.mp3';
        final file = File(localPath);
        
        if (!await file.exists()) {
          final data = await rootBundle.load(assetPath);
          final bytes = data.buffer.asUint8List();
          await file.writeAsBytes(bytes);
        }
        
        _soundEffects[soundName] = localPath;
      }
    } catch (e) {
      print('効果音の読み込みエラー: $e');
    }
  }
  
  // 効果音の有効/無効を切り替え
  Future<void> toggleSounds(bool enabled) async {
    _soundsEnabled = enabled;
    await _storageService.setSoundsEnabled(enabled);
  }
  
  // 効果音の有効状態を取得
  bool get isSoundsEnabled => _soundsEnabled;
  
  // 効果音を再生
  Future<void> _playSound(String soundName) async {
    if (!_soundsEnabled) return;
    
    try {
      final soundPath = _soundEffects[soundName];
      if (soundPath != null) {
        await _audioPlayer.play(DeviceFileSource(soundPath));
      }
    } catch (e) {
      print('効果音再生エラー: $e');
    }
  }
  
  // メッセージ送信時の効果音
  Future<void> playMessageSentSound() async {
    await _playSound('message_sent');
  }
  
  // メッセージ受信時の効果音
  Future<void> playMessageReceivedSound() async {
    await _playSound('message_received');
  }
  
  // ボタン押下時の効果音
  Future<void> playButtonPressSound() async {
    await _playSound('button_press');
  }
  
  // エラー時の効果音
  Future<void> playErrorSound() async {
    await _playSound('error');
  }
  
  // 成功時の効果音
  Future<void> playSuccessSound() async {
    await _playSound('success');
  }
  
  // カメラシャッター音
  Future<void> playCameraShutterSound() async {
    await _playSound('camera_shutter');
  }
  
  // 録音を開始
  Future<bool> startRecording() async {
    if (_isRecording) {
      return false;
    }
    
    try {
      // マイク権限を確認
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        return false;
      }
      
      // 録音ファイルのパスを生成
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${tempDir.path}/recording_$timestamp.m4a';
      
      // 録音開始
      await _audioRecorder.start(
        path: _currentRecordingPath,
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        samplingRate: 44100,
      );
      
      _isRecording = true;
      return true;
    } catch (e) {
      print('録音開始エラー: $e');
      return false;
    }
  }
  
  // 録音を停止
  Future<String?> stopRecording() async {
    if (!_isRecording) {
      return null;
    }
    
    try {
      // 録音停止
      await _audioRecorder.stop();
      _isRecording = false;
      
      // 録音ファイルのパスを返す
      return _currentRecordingPath;
    } catch (e) {
      print('録音停止エラー: $e');
      return null;
    }
  }
  
  // 録音をキャンセル
  Future<void> cancelRecording() async {
    if (!_isRecording) {
      return;
    }
    
    try {
      // 録音停止
      await _audioRecorder.stop();
      _isRecording = false;
      
      // 録音ファイルを削除
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      _currentRecordingPath = null;
    } catch (e) {
      print('録音キャンセルエラー: $e');
    }
  }
  
  // 録音中かどうか
  bool get isRecording => _isRecording;
  
  // 録音の再生
  Future<void> playRecording(String path) async {
    try {
      await _audioPlayer.play(DeviceFileSource(path));
    } catch (e) {
      print('録音再生エラー: $e');
    }
  }
  
  // 再生を停止
  Future<void> stopPlaying() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('再生停止エラー: $e');
    }
  }
  
  // リソースの解放
  Future<void> dispose() async {
    await _audioPlayer.dispose();
    await _audioRecorder.dispose();
  }
}
