import Flutter
import UIKit
import AudioToolbox

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // システムサウンド用のMethodChannelを設定
    let controller = window?.rootViewController as! FlutterViewController
    let systemSoundChannel = FlutterMethodChannel(name: "com.smartbooks.system_sound", binaryMessenger: controller.binaryMessenger)
    
    systemSoundChannel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "checkSystemSoundEnabled":
        // サウンド設定を確認
        let soundEnabled = !UserDefaults.standard.bool(forKey: "silent_mode_enabled")
        result(soundEnabled)
        
      case "playSystemSound":
        guard let args = call.arguments as? [String: Any],
              let soundId = args["soundId"] as? Int else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing or invalid soundId", details: nil))
          return
        }
        
        // システムサウンドを再生
        AudioServicesPlaySystemSound(UInt32(soundId))
        
        // 成功音とエラー音には触覚フィードバックも追加
        if soundId == 1054 {  // 成功音
          AudioServicesPlaySystemSound(1520)  // 軽い触覚フィードバック
        } else if soundId == 1073 {  // エラー音
          AudioServicesPlaySystemSound(1521)  // 強い触覚フィードバック
        }
        
        result(nil)
        
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
