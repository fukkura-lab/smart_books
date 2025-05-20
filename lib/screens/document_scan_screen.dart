import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';

class DocumentScanScreen extends StatefulWidget {
  const DocumentScanScreen({Key? key}) : super(key: key);

  @override
  State<DocumentScanScreen> createState() => _DocumentScanScreenState();
}

class _DocumentScanScreenState extends State<DocumentScanScreen>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  List<File> _imageFiles = [];
  bool _isProcessing = false;
  bool _isDuplicateDetected = false;

  // 現在の選択モード
  String _selectedDocumentType = '領収書';
  final List<String> _documentTypes = ['領収書', '請求書', '通帳', 'その他'];

  // アニメーションコントローラー
  late AnimationController _scanAnimationController;
  late AnimationController _successAnimationController;

  // OCR解析のステップ表示用
  int _processingStep = 0;
  final List<String> _processingSteps = [
    '画像を準備中...',
    '文字を認識中...',
    '内容を分析中...',
    '仕訳を生成中...',
  ];

  @override
  void initState() {
    super.initState();

    // スキャンアニメーション
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 成功アニメーション
    _successAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _successAnimationController.dispose();
    super.dispose();
  }

  // カメラで写真を撮影
  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        setState(() {
          _imageFiles.add(File(photo.path));
          // 撮影時にハプティックフィードバック
          HapticFeedback.mediumImpact();
        });

        // 撮影が完了したら重複チェック
        _checkForDuplicates();
      }
    } catch (e) {
      _showErrorDialog('写真の撮影中にエラーが発生しました');
    }
  }

  // ギャラリーから複数画像を選択
  Future<void> _pickImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        setState(() {
          for (var image in images) {
            _imageFiles.add(File(image.path));
          }
          // ハプティックフィードバック
          HapticFeedback.lightImpact();
        });

        // 選択が完了したら重複チェック
        _checkForDuplicates();
      }
    } catch (e) {
      _showErrorDialog('画像の選択中にエラーが発生しました');
    }
  }

  // 重複チェック（デモのためランダムに重複を検出）
  void _checkForDuplicates() {
    // デモ用: 25%の確率で重複を検出
    final random = DateTime.now().millisecondsSinceEpoch % 4;
    setState(() {
      _isDuplicateDetected = (random == 0);
      _confirmDuplicate = false;
    });
  }

  // 書類を処理して保存
  Future<void> _processDocuments() async {
    if (_isDuplicateDetected && !_confirmDuplicate) {
      setState(() {
        _confirmDuplicate = true;
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _processingStep = 0;
    });

    try {
      // スキャンアニメーション開始
      _scanAnimationController.reset();
      _scanAnimationController.repeat();

      // 処理ステップのシミュレーション
      for (int i = 0; i < _processingSteps.length; i++) {
        // 各ステップを表示
        setState(() {
          _processingStep = i;
        });

        // 処理時間をシミュレート
        await Future.delayed(const Duration(milliseconds: 600));
      }

      // スキャンアニメーション終了
      _scanAnimationController.stop();

      // 成功アニメーション開始
      _successAnimationController.reset();
      _successAnimationController.forward();

      if (!mounted) return;

      // 処理成功
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('書類を正常に処理しました'),
          backgroundColor: Colors.green,
        ),
      );

      // ハプティックフィードバック
      HapticFeedback.mediumImpact();

      // 1秒後に結果画面に遷移
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      // 結果画面に遷移
      Navigator.pop(context, {
        'success': true,
        'documentCount': _imageFiles.length,
        'documentType': _selectedDocumentType,
        'imagePaths': _imageFiles.map((file) => file.path).toList(),
      });
    } catch (e) {
      _scanAnimationController.stop();
      _showErrorDialog('書類の処理中にエラーが発生しました');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // エラーダイアログを表示
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('エラー'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // 確認済みフラグ
  bool _confirmDuplicate = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('書類スキャン'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // メインコンテンツ
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 書類タイプ選択
                  _buildDocumentTypeSelector(),

                  const SizedBox(height: 20),

                  // 撮影またはアップロードエリア
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 画像プレビュー
                          if (_imageFiles.isNotEmpty)
                            Column(
                              children: [
                                SizedBox(
                                  height: 200,
                                  child: PageView.builder(
                                    itemCount: _imageFiles.length,
                                    itemBuilder: (context, index) {
                                      return Stack(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey
                                                      .withOpacity(0.3)),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.file(
                                                _imageFiles[index],
                                                height: 200,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _imageFiles.removeAt(index);
                                                  if (_imageFiles.isEmpty) {
                                                    _isDuplicateDetected =
                                                        false;
                                                  }
                                                });
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 2),
                                                    )
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // ページインジケーター
                                          if (_imageFiles.length > 1)
                                            Positioned(
                                              bottom: 16,
                                              left: 0,
                                              right: 0,
                                              child: Center(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.6),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    '${index + 1} / ${_imageFiles.length}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // 画像枚数表示
                                Text(
                                  '選択中: ${_imageFiles.length}枚',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            )
                          else
                            DottedBorder(
                              color: Colors.grey[300]!,
                              strokeWidth: 1,
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(12),
                              dashPattern: const [6, 3], // 破線のパターン [線の長さ, 間隔]
                              padding: const EdgeInsets.all(0), // 内側のパディング
                              child: Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _getDocumentTypeIcon(
                                          _selectedDocumentType),
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '${_selectedDocumentType}を撮影またはアップロード',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'AIが自動的に内容を認識します',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 20),

                          // 重複警告（必要な場合）
                          if (_isDuplicateDetected)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.amber),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber,
                                      color: Colors.amber),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          '類似の書類が見つかりました',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber,
                                          ),
                                        ),
                                        Text(
                                          '重複して登録する可能性があります。続行しますか？',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 20),

                          // ボタン行
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // カメラボタン
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                                  label: const Text('撮影', style: TextStyle(color: Colors.white)),
                                  onPressed:
                                      _isProcessing ? null : _takePicture,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // ギャラリーボタン
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('ギャラリー'),
                                  onPressed: _isProcessing ? null : _pickImages,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    foregroundColor: primaryColor,
                                    side: BorderSide(color: primaryColor),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 処理ボタン
                  if (_imageFiles.isNotEmpty)
                    ElevatedButton(
                      onPressed: _isProcessing ||
                              (_isDuplicateDetected && !_confirmDuplicate)
                          ? null
                          : _processDocuments,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor:
                            _isDuplicateDetected ? Colors.amber : primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isProcessing
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('処理中...', style: TextStyle(fontSize: 16)),
                              ],
                            )
                          : Text(
                              _isDuplicateDetected ? '重複を確認して続行' : 'AIで解析して保存',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),

                  if (_isDuplicateDetected && _imageFiles.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _imageFiles = [];
                          _isDuplicateDetected = false;
                        });
                      },
                      child: const Text('キャンセル'),
                    ),
                ],
              ),
            ),
          ),

          // 処理中のオーバーレイ
          if (_isProcessing) _buildProcessingOverlay(),
        ],
      ),
    );
  }

  // 書類タイプ選択ウィジェット
  Widget _buildDocumentTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            '書類タイプ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _documentTypes.map((type) {
                final isSelected = type == _selectedDocumentType;
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getDocumentTypeIcon(type),
                          size: 16,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(type),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedDocumentType = type;
                        });
                      }
                    },
                    backgroundColor: Colors.white,
                    selectedColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    elevation: isSelected ? 2 : 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // 処理中のオーバーレイ
  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // スキャンアニメーション
            AnimatedBuilder(
              animation: _scanAnimationController,
              builder: (context, child) {
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // スキャンライン
                      Positioned(
                        top: 60 * _scanAnimationController.value,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.8),
                        ),
                      ),

                      // ドキュメントアイコン
                      Icon(
                        _getDocumentTypeIcon(_selectedDocumentType),
                        size: 48,
                        color: Colors.white,
                      ),

                      // 周囲の円
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.5),
                            width: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // 処理ステップ表示
            Text(
              _processingSteps[_processingStep],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // 進捗表示
            SizedBox(
              width: 240,
              child: LinearProgressIndicator(
                value: (_processingStep + 1) / _processingSteps.length,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // 完了アニメーション
            AnimatedBuilder(
              animation: _successAnimationController,
              builder: (context, child) {
                return AnimatedOpacity(
                  opacity: _successAnimationController.value,
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '処理完了',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 書類タイプに応じたアイコンを取得
  IconData _getDocumentTypeIcon(String type) {
    switch (type) {
      case '領収書':
        return Icons.receipt_long;
      case '請求書':
        return Icons.description;
      case '通帳':
        return Icons.account_balance;
      default:
        return Icons.insert_drive_file;
    }
  }
}
