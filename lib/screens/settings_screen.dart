import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_books/blocs/theme/theme_bloc.dart';
import 'package:smart_books/blocs/theme/theme_event.dart';
import 'package:smart_books/blocs/theme/theme_state.dart';
import 'package:smart_books/di/service_locator.dart';
import 'package:smart_books/services/sound_effect_service.dart';
import 'package:smart_books/widgets/profile_avatar_hero.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  // 設定の状態
  bool _isNotificationsEnabled = true;
  bool _isSoundEnabled = true;
  
  // 効果音サービス
  late SoundEffectService _soundEffectService;

  // アニメーション関連
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    // 効果音サービスの取得
    _soundEffectService = serviceLocator<SoundEffectService>();
    _isSoundEnabled = _soundEffectService.isSoundEnabled;

    // アニメーションコントローラの初期化
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // 画面表示時にアニメーションを開始
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: ListView(
          children: [
            // Heroアニメーション対応のプロフィールセクション
            _buildProfileSection(),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(height: 1, thickness: 1),
            ),

            // 一般設定セクション
            Container(
              margin: const EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: _buildSettingsSection('一般設定', [
                // ダークモード切替
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    final isDarkMode = state is ThemeLoaded && state.themeMode == ThemeMode.dark;
                    
                    return Padding(
                      padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                      child: SwitchListTile(
                        title: const Text('ダークモード'),
                        subtitle: const Text('ダークテーマを使用する'),
                        secondary: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isDarkMode ? Icons.dark_mode : Icons.light_mode,
                            color: Theme.of(context).primaryColor,
                            size: 22,
                          ),
                        ),
                        value: isDarkMode,
                        activeColor: Theme.of(context).primaryColor,
                        inactiveThumbColor: Colors.grey[400],
                        onChanged: (value) {
                          // ハプティックフィードバック
                          HapticFeedback.lightImpact();
                          
                          // テーマ切替
                          context.read<ThemeBloc>().add(
                            ThemeChangedEvent(value ? ThemeMode.dark : ThemeMode.light),
                          );
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                        dense: false,
                      ),
                    );
                  },
                ),

                // 通知設定
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                  child: SwitchListTile(
                    title: const Text('通知'),
                    subtitle: const Text('アプリからの通知を受け取る'),
                    secondary: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.notifications,
                        color: Theme.of(context).primaryColor,
                        size: 22,
                      ),
                    ),
                    value: _isNotificationsEnabled,
                    activeColor: Theme.of(context).primaryColor,
                    inactiveThumbColor: Colors.grey[400],
                    onChanged: (value) {
                      setState(() {
                        _isNotificationsEnabled = value;
                      });
                      // 通知設定の処理をここに実装
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                    dense: false,
                  ),
                ),

                // 効果音設定
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                  child: SwitchListTile(
                    title: const Text('効果音'),
                    subtitle: const Text('アプリ内の効果音を有効にする'),
                    secondary: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.volume_up,
                        color: Theme.of(context).primaryColor,
                        size: 22,
                      ),
                    ),
                    value: _isSoundEnabled,
                    activeColor: Theme.of(context).primaryColor,
                    inactiveThumbColor: Colors.grey[400],
                    onChanged: (value) {
                      setState(() {
                        _isSoundEnabled = value;
                      });
                      
                      // 効果音設定の反映
                      _soundEffectService.toggleSound(value);
                      
                      // 切替時にサンプル効果音を再生
                      if (value) {
                        _soundEffectService.playClickSound();
                      }
                      
                      // 触角フィードバック
                      HapticFeedback.selectionClick();
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                    dense: false,
                  ),
                ),
              ]),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(height: 1, thickness: 1),
            ),

            // 会計設定セクション
            Container(
              margin: const EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: _buildSettingsSection('会計設定', [
                // 勘定科目設定
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                  child: ListTile(
                    title: const Text('勘定科目設定'),
                    subtitle: const Text('勘定科目の追加・編集・削除'),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.category,
                        color: Theme.of(context).primaryColor,
                        size: 22,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // 勘定科目設定画面へのナビゲーション
                      Navigator.pushNamed(context, '/account-categories');
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                ),

                // データのエクスポート
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                  child: ListTile(
                    title: const Text('データのエクスポート'),
                    subtitle: const Text('会計データをCSVなどでエクスポート'),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.upload_file,
                        color: Theme.of(context).primaryColor,
                        size: 22,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // データエクスポート画面へのナビゲーション
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('この機能は準備中です'),
                        ),
                      );
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                ),
              ]),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(height: 1, thickness: 1),
            ),

            // その他セクション
            Container(
              margin: const EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: _buildSettingsSection('その他', [
                // ヘルプ＆サポート
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                  child: ListTile(
                    title: const Text('ヘルプ＆サポート'),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.help_outline,
                        color: Theme.of(context).primaryColor,
                        size: 22,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // ヘルプ＆サポート画面へのナビゲーション
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('この機能は準備中です'),
                        ),
                      );
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                ),

                // プライバシーポリシー
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                  child: ListTile(
                    title: const Text('プライバシーポリシー'),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.privacy_tip_outlined,
                        color: Theme.of(context).primaryColor,
                        size: 22,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // プライバシーポリシー画面へのナビゲーション
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('この機能は準備中です'),
                        ),
                      );
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                ),

                // 利用規約
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                  child: ListTile(
                    title: const Text('利用規約'),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        color: Theme.of(context).primaryColor,
                        size: 22,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // 利用規約画面へのナビゲーション
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('この機能は準備中です'),
                        ),
                      );
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                ),

                // アプリ情報
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                  child: ListTile(
                    title: const Text('アプリ情報'),
                    subtitle: const Text('バージョン 1.0.0'),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: Theme.of(context).primaryColor,
                        size: 22,
                      ),
                    ),
                    onTap: () {
                      // アプリ情報画面へのナビゲーション
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('この機能は準備中です'),
                        ),
                      );
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                ),

                // ログアウト
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                  child: ListTile(
                    title: const Text('ログアウト'),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.logout,
                        color: Colors.red[400],
                        size: 22,
                      ),
                    ),
                    onTap: _showLogoutConfirmation,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // プロフィールセクション（Heroアニメーション対応）
  Widget _buildProfileSection() {
    final primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/profile');
        },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primaryColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // プロフィール画像（Hero アニメーション付き）
                ProfileAvatarHero(
                  heroTag: 'profileAvatar',
                  size: 64,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  iconColor: primaryColor,
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                const SizedBox(width: 16),
                // ユーザー情報
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'テストユーザー',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'test@example.com',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'プロフィールを編集',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 設定セクション
  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  // ログアウト確認ダイアログ
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('ログアウトしてもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              // ログアウト処理をここに実装
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('ログアウト'),
          ),
        ],
      ),
    );
  }
}