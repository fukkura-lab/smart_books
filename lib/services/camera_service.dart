import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:smart_books/services/audio_service.dart';
import 'package:get_it/get_it.dart';

class CameraService {
  // カメラコントローラー
  CameraController? _cameraController;
  
  // 利用可能なカメラ
  List<CameraDescription> _cameras = [];
  
  // カメラの初期化完了フラグ
  bool _isCameraInitialized = false;
  
  // 画像選択用
  final ImagePicker _imagePicker = ImagePicker();
  
  // オーディオサービス（シャッター音などの効果音用）
  late AudioService _audioService;
  
  CameraService() {
    _audioService = GetIt.instance<AudioService>();
    _initCameras();
  }
  
  // カメラの初期化
  Future<void> _initCameras() async {
    try {
      // 利用可能なカメラを取得
      _cameras = await availableCameras();
    } on CameraException catch (e) {
      print('カメラの初期化エラー: $e');
    }
  }
  
  // カメラコントローラーの初期化
  Future<bool> initCameraController() async {
    if (_cameras.isEmpty) {
      return false;
    }
    
    try {
      // 後面カメラを使用
      final rearCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );
      
      // カメラコントローラーの作成
      _cameraController = CameraController(
        rearCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      
      // カメラコントローラーの初期化
      await _cameraController!.initialize();
      
      // 自動フォーカスを有効化（利用可能な場合）
      if (_cameraController!.value.isInitialized) {
        await _cameraController!.setFocusMode(FocusMode.auto);
        await _cameraController!.setFlashMode(FlashMode.auto);
        _isCameraInitialized = true;
      }
      
      return _isCameraInitialized;
    } on CameraException catch (e) {
      print('カメラコントローラーの初期化エラー: $e');
      return false;
    }
  }
  
  // カメラプレビューウィジェットの取得
  CameraPreview? getCameraPreview() {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      return CameraPreview(_cameraController!);
    }
    return null;
  }
  
  // 写真撮影
  Future<File?> takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return null;
    }
    
    try {
      // シャッター音を再生
      await _audioService.playCameraShutterSound();
      
      // 写真を撮影
      final XFile image = await _cameraController!.takePicture();
      
      // 一時ファイルとして保存
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${tempDir.path}/image_$timestamp.jpg';
      
      // XFileをFileに変換
      final file = File(path);
      await file.writeAsBytes(await image.readAsBytes());
      
      return file;
    } on CameraException catch (e) {
      print('写真撮影エラー: $e');
      return null;
    }
  }
  
  // ギャラリーから画像を選択
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image == null) {
        return null;
      }
      
      return File(image.path);
    } on PlatformException catch (e) {
      print('ギャラリーからの画像選択エラー: $e');
      return null;
    }
  }
  
  // カメラからの画像キャプチャ（カメラ画面表示なし）
  Future<File?> captureImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image == null) {
        return null;
      }
      
      return File(image.path);
    } on PlatformException catch (e) {
      print('カメラからの画像キャプチャエラー: $e');
      return null;
    }
  }
  
  // フラッシュモードの切り替え
  Future<void> toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    try {
      final FlashMode currentFlashMode = _cameraController!.value.flashMode;
      FlashMode newFlashMode;
      
      switch (currentFlashMode) {
        case FlashMode.off:
          newFlashMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          newFlashMode = FlashMode.always;
          break;
        default:
          newFlashMode = FlashMode.off;
          break;
      }
      
      await _cameraController!.setFlashMode(newFlashMode);
    } on CameraException catch (e) {
      print('フラッシュモード切り替えエラー: $e');
    }
  }
  
  // 現在のフラッシュモードを取得
  FlashMode? getCurrentFlashMode() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return null;
    }
    
    return _cameraController!.value.flashMode;
  }
  
  // カメラの一時停止
  Future<void> pauseCamera() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    try {
      await _cameraController!.pausePreview();
    } on CameraException catch (e) {
      print('カメラ一時停止エラー: $e');
    }
  }
  
  // カメラの再開
  Future<void> resumeCamera() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    try {
      await _cameraController!.resumePreview();
    } on CameraException catch (e) {
      print('カメラ再開エラー: $e');
    }
  }
  
  // カメラの破棄
  Future<void> disposeCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
      _isCameraInitialized = false;
    }
  }
  
  // カメラの初期化状態を取得
  bool get isCameraInitialized => _isCameraInitialized;
  
  // 利用可能なカメラがあるかを確認
  bool get hasCamera => _cameras.isNotEmpty;
}
