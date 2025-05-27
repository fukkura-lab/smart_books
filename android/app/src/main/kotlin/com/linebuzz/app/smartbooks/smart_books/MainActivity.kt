package com.linebuzz.app.smartbooks.smart_books

import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.view.HapticFeedbackConstants
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val SYSTEM_SOUND_CHANNEL = "com.smartbooks.system_sound"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // システムサウンド用のチャンネルを設定
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SYSTEM_SOUND_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkSystemSoundEnabled" -> {
                    // システム効果音設定の確認
                    val audioManager = getSystemService(AUDIO_SERVICE) as AudioManager
                    val soundEnabled = audioManager.ringerMode != AudioManager.RINGER_MODE_SILENT
                    result.success(soundEnabled)
                }
                "playSystemSound" -> {
                    val soundId = call.argument<Int>("soundId") ?: 0
                    playSystemSound(soundId)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun playSystemSound(soundId: Int) {
        try {
            // 効果音を再生
            when (soundId) {
                1054 -> { // 成功音
                    val toneGenerator = ToneGenerator(AudioManager.STREAM_SYSTEM, ToneGenerator.MAX_VOLUME)
                    toneGenerator.startTone(ToneGenerator.TONE_CDMA_CONFIRM, 150)
                    toneGenerator.release()
                    // 触覚フィードバックも追加
                    window.decorView.performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY)
                }
                1073 -> { // エラー音
                    val toneGenerator = ToneGenerator(AudioManager.STREAM_SYSTEM, ToneGenerator.MAX_VOLUME)
                    toneGenerator.startTone(ToneGenerator.TONE_CDMA_ABBR_ALERT, 500)
                    toneGenerator.release()
                    // 振動も追加
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val vibratorManager = getSystemService(VIBRATOR_MANAGER_SERVICE) as VibratorManager
                        val vibrator = vibratorManager.defaultVibrator
                        vibrator.vibrate(VibrationEffect.createOneShot(500, VibrationEffect.DEFAULT_AMPLITUDE))
                    } else {
                        @Suppress("DEPRECATION")
                        val vibrator = getSystemService(VIBRATOR_SERVICE) as Vibrator
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            vibrator.vibrate(VibrationEffect.createOneShot(500, VibrationEffect.DEFAULT_AMPLITUDE))
                        } else {
                            @Suppress("DEPRECATION")
                            vibrator.vibrate(500)
                        }
                    }
                }
                1057 -> { // スワイプ音
                    val toneGenerator = ToneGenerator(AudioManager.STREAM_SYSTEM, ToneGenerator.MAX_VOLUME)
                    toneGenerator.startTone(ToneGenerator.TONE_CDMA_SOFT_ERROR_LITE, 100)
                    toneGenerator.release()
                }
                1007 -> { // 通知音
                    val toneGenerator = ToneGenerator(AudioManager.STREAM_NOTIFICATION, ToneGenerator.MAX_VOLUME)
                    toneGenerator.startTone(ToneGenerator.TONE_CDMA_ALERT_CALL_GUARD, 500)
                    toneGenerator.release()
                }
                else -> {
                    // デフォルトはクリック音
                    val toneGenerator = ToneGenerator(AudioManager.STREAM_SYSTEM, ToneGenerator.MAX_VOLUME)
                    toneGenerator.startTone(ToneGenerator.TONE_PROP_BEEP, 100)
                    toneGenerator.release()
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
