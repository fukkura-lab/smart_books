import 'package:flutter/material.dart';
import 'package:smart_books/utils/auth_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedBusinessType;
  bool _isLoading = false;

  // アニメーション関連
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // 業種リスト
  final List<Map<String, dynamic>> _businessTypes = [
    {'value': 'restaurant', 'label': '飲食店'},
    {'value': 'retail', 'label': '小売業'},
    {'value': 'service', 'label': 'サービス業'},
    {'value': 'nightlife', 'label': '水商売'},
    {'value': 'adult', 'label': '風俗業'},
    {'value': 'freelance', 'label': 'フリーランス'},
    {'value': 'other', 'label': 'その他'},
  ];

  // 初期化処理
  @override
  void initState() {
    super.initState();
    _loadUserProfile();

    // アニメーションコントローラの初期化
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuad,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // 画面表示時にアニメーションを開始
    _animationController.forward();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ユーザー情報を読み込む
  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 認証ヘルパーからユーザー情報を取得
      final authHelper = AuthHelper();

      // ログイン状態をチェック
      final isLoggedIn = await authHelper.checkAuth();

      if (isLoggedIn) {
        // ユーザー情報をコントローラに設定
        _fullNameController.text = "山田 太郎"; // サンプルデータ
        _emailController.text = authHelper.email ?? "sample@example.com";
        _phoneController.text = "090-1234-5678"; // サンプルデータ
        _selectedBusinessType = "freelance"; // サンプルデータ
      }
    } catch (e) {
      // エラー処理
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('プロフィール情報の取得に失敗しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // プロフィール更新
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // 実際のAPI呼び出しの代わりに遅延をシミュレート
        await Future.delayed(const Duration(seconds: 1));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('プロフィールを更新しました'),
            backgroundColor: Colors.green,
          ),
        );

        // 前の画面に戻る
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('プロフィールの更新に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
        backgroundColor: primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // プロフィール画像セクション（Hero対応）
                    _buildProfileImageSection(),

                    // フォーム内容はアニメーション付きで表示
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),

                          // プロフィール情報フォーム
                          _buildProfileForm(),

                          const SizedBox(height: 24),

                          // 保存ボタン
                          ElevatedButton(
                            onPressed: _isLoading ? null : _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              '保存',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // プロフィール画像セクション（Hero対応）
  Widget _buildProfileImageSection() {
    final primaryColor = Theme.of(context).primaryColor;

    return Center(
      child: Column(
        children: [
          // プロフィール画像（Heroタグ付き）
          Hero(
            tag: 'profileAvatar',
            child: Stack(
              children: [
                // 画像のプレースホルダー
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withOpacity(0.2),
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: 64,
                      color: primaryColor,
                    ),
                  ),
                ),

                // 編集ボタン
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        // プロフィール画像変更機能（実装予定）
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('この機能は準備中です'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ユーザー名
          Text(
            _emailController.text.split('@').first,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // メールアドレス
          Text(
            _emailController.text,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // プロフィール情報フォーム
  Widget _buildProfileForm() {
    final primaryColor = Theme.of(context).primaryColor;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // セクションタイトル
            Text(
              'プロフィール情報',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),

            const SizedBox(height: 16),

            // 氏名フィールド
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: '氏名',
                labelStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon:
                    Icon(Icons.person, color: primaryColor.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '氏名を入力してください';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // メールアドレス（読み取り専用）
            TextFormField(
              controller: _emailController,
              readOnly: true, // メールアドレスは変更不可
              decoration: InputDecoration(
                labelText: 'メールアドレス',
                labelStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon:
                    Icon(Icons.email, color: primaryColor.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),

            const SizedBox(height: 16),

            // 電話番号フィールド
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: '電話番号',
                labelStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon:
                    Icon(Icons.phone, color: primaryColor.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),

            const SizedBox(height: 16),

            // 業種選択ドロップダウン
            DropdownButtonFormField<String>(
              value: _selectedBusinessType,
              decoration: InputDecoration(
                labelText: '業種',
                labelStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon:
                    Icon(Icons.business, color: primaryColor.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              items: _businessTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type['value'],
                  child: Text(type['label']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBusinessType = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '業種を選択してください';
                }
                return null;
              },
            ),

            // パスワード変更リンク
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.lock_outline),
              label: const Text('パスワードを変更'),
              onPressed: () {
                // パスワード変更画面に遷移
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('この機能は準備中です'),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
