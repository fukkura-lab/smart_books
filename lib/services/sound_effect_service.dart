import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// アプリ全体で使用する効果音を管理するサービス
/// OSデフォルトのシステムサウンドを利用するバージョン
class SoundEffectService {
  // シングルトンパターン用のプライベートコンストラクタ
  SoundEffectService._();
  static final SoundEffectService _instance = SoundEffectService._();
  
  /// シングルトンインスタンスを取得
  factory SoundEffectService() => _instance;

  /// システムサウンド用のMethodChannel
  static const MethodChannel _channel = MethodChannel('com.smartbooks.system_sound');

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
      // OSのサウンド設定を確認
      _isSoundEnabled = await _channel.invokeMethod<bool>('checkSystemSoundEnabled') ?? true;
      _isInitialized = true;
      debugPrint('🔊 SoundEffectService initialized successfully');
    } catch (e) {
      debugPrint('🔊 Failed to initialize SoundEffectService: $e');
      // エラーの場合もデフォルトで有効に
      _isInitialized = true;
    }
  }
  
  /// 効果音を再生
  Future<void> playSound(SoundEffect effect) async {
    if (!_isSoundEnabled || !_isInitialized) return;
    
    try {
      // OSのシステムサウンドを再生
      if (effect._systemSoundType != null) {
        // SystemSoundType APIを使用
        await SystemSound.play(effect._systemSoundType!);
      } else if (effect._osSpecificId != null) {
        // プラットフォーム固有のサウンドIDを使用
        await _channel.invokeMethod<void>(
          'playSystemSound', 
          {'soundId': effect._osSpecificId}
        );
      }
    } catch (e) {
      debugPrint('🔊 Error playing system sound: $e');
    }
  }

  /// すべての効果音を停止 (OSのシステムサウンドは短いので実際には不要)
  Future<void> stopAllSounds() async {
    // システムサウンドは短いので特に何もしない
  }
  
  /// リソースを解放
  Future<void> dispose() async {
    _isInitialized = false;
  }
  
  /// クリック効果音を再生
  Future<void> playClickSound() async {
    await playSound(SoundEffect.click);
    // 触覚フィードバックも追加
    HapticFeedback.selectionClick();
  }
  
  /// 成功効果音を再生
  Future<void> playSuccessSound() async {
    await playSound(SoundEffect.success);
    // 触覚フィードバックも追加
    HapticFeedback.lightImpact();
  }
  
  /// エラー効果音を再生
  Future<void> playErrorSound() async {
    await playSound(SoundEffect.error);
    // 触覚フィードバックも追加
    HapticFeedback.vibrate();
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
  final SystemSoundType? _systemSoundType;
  final int? _osSpecificId; // プラットフォーム固有のサウンドID
  
  const SoundEffect._({SystemSoundType? systemSoundType, int? osSpecificId})
      : _systemSoundType = systemSoundType,
        _osSpecificId = osSpecificId;
  
  /// クリック音
  static const SoundEffect click = SoundEffect._(systemSoundType: SystemSoundType.click);
  
  /// 成功音
  static const SoundEffect success = SoundEffect._(osSpecificId: 1054); // iOS: 完了音, Android: 同等の音
  
  /// エラー音
  static const SoundEffect error = SoundEffect._(osSpecificId: 1073); // iOS: アラート音, Android: 同等の音
  
  /// スワイプ音
  static const SoundEffect swipe = SoundEffect._(osSpecificId: 1057); // iOS: スワイプ音, Android: 同等の音
  
  /// 通知音
  static const SoundEffect notification = SoundEffect._(osSpecificId: 1007); // iOS: 通知音, Android: 同等の音
}
