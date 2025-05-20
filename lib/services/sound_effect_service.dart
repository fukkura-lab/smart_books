import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// アプリ全体で使用する効果音を管理するサービス
class SoundEffectService {
  // シングルトンパターン用のプライベートコンストラクタ
  SoundEffectService._();
  static final SoundEffectService _instance = SoundEffectService._();
  
  /// シングルトンインスタンスを取得
  factory SoundEffectService() => _instance;

  /// オーディオプレイヤーのインスタンス (複数の効果音を同時再生できるよう複数のプレイヤーを用意)
  final List<AudioPlayer> _players = [
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
  ];

  /// 効果音が有効かどうか
  bool _isSoundEnabled = true;
  
  /// 初期化済みかどうか
  bool _isInitialized = false;
  
  /// 効果音が有効かどうかを取得
  bool get isSoundEnabled => _isSoundEnabled;
  
  /// 効果音をオン/オフに切り替える
  void toggleSound(bool enabled) {
    _isSoundEnabled = enabled;
  }
  
  /// 効果音サービスを初期化
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // プレーヤーの設定
      for (final player in _players) {
        await player.setReleaseMode(ReleaseMode.stop); // リソースを解放するモード
        await player.setPlayerMode(PlayerMode.lowLatency); // 低遅延モード
        // 無音ファイルの読み込みを試みるが、失敗しても続行する
        try {
          await player.setSourceAsset('audio/silence.mp3'); // 無音を読み込み（初期化用）
        } catch (e) {
          debugPrint('🔊 Warning: Could not load silence.mp3, but continuing: $e');
        }
      }
      
      // 効果音ファイルの事前読み込みを試みるが、失敗しても続行する
      try {
        await AudioCache.instance.loadAll([
          'audio/click.mp3',
          'audio/success.mp3',
          'audio/error.mp3',
          'audio/swipe.mp3',
          'audio/notification.mp3',
        ]);
      } catch (e) {
        debugPrint('🔊 Warning: Could not preload sound files, but continuing: $e');
      }
      
      _isInitialized = true;
      debugPrint('🔊 SoundEffectService initialized successfully');
    } catch (e) {
      debugPrint('🔊 Failed to initialize SoundEffectService: $e');
    }
  }
  
  /// 使用可能なプレイヤーを取得
  AudioPlayer _getAvailablePlayer() {
    // 再生中でないプレイヤーを探す
    for (final player in _players) {
      if (player.state != PlayerState.playing) {
        return player;
      }
    }
    // 全てのプレイヤーが使用中の場合は最初のプレイヤーを返す
    return _players.first;
  }
  
  /// 効果音を再生
  Future<void> playSound(SoundEffect effect) async {
    if (!_isSoundEnabled || !_isInitialized) return;
    
    try {
      final player = _getAvailablePlayer();
      
      // ボリュームを設定
      await player.setVolume(effect.volume);
      
      // アセットから効果音を再生するが、失敗してもエラーが表示されるだけ
      try {
        await player.play(
          AssetSource(effect.assetPath),
          volume: effect.volume,
          mode: PlayerMode.lowLatency,
        );
      } catch (e) {
        debugPrint('🔊 Error playing sound effect: $e');
      }
    } catch (e) {
      debugPrint('🔊 Error setting up sound player: $e');
    }
  }

  /// すべての効果音を停止
  Future<void> stopAllSounds() async {
    if (!_isInitialized) return;
    
    for (final player in _players) {
      await player.stop();
    }
  }
  
  /// リソースを解放
  Future<void> dispose() async {
    if (!_isInitialized) return;
    
    for (final player in _players) {
      await player.dispose();
    }
    
    _isInitialized = false;
  }
  
  /// クリック効果音を再生
  Future<void> playClickSound() async {
    await playSound(SoundEffect.click);
  }
  
  /// 成功効果音を再生
  Future<void> playSuccessSound() async {
    await playSound(SoundEffect.success);
  }
  
  /// エラー効果音を再生
  Future<void> playErrorSound() async {
    await playSound(SoundEffect.error);
  }
  
  /// スワイプ効果音を再生
  Future<void> playSwipeSound() async {
    await playSound(SoundEffect.swipe);
  }
  
  /// 通知効果音を再生
  Future<void> playNotificationSound() async {
    await playSound(SoundEffect.notification);
  }
}

/// 効果音の種類
class SoundEffect {
  final String assetPath;
  final double volume;
  
  const SoundEffect(this.assetPath, {this.volume = 1.0});
  
  /// クリック音
  static const SoundEffect click = SoundEffect('audio/click.mp3', volume: 0.5);
  
  /// 成功音
  static const SoundEffect success = SoundEffect('audio/success.mp3', volume: 0.7);
  
  /// エラー音
  static const SoundEffect error = SoundEffect('audio/error.mp3', volume: 0.6);
  
  /// スワイプ音
  static const SoundEffect swipe = SoundEffect('audio/swipe.mp3', volume: 0.4);
  
  /// 通知音
  static const SoundEffect notification = SoundEffect('audio/notification.mp3', volume: 0.8);
}
