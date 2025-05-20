import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_books/screens/chat_screen.dart';
import 'package:smart_books/screens/dashboard_screen.dart';
import 'package:smart_books/screens/document_library_screen.dart';
import 'package:smart_books/di/service_locator.dart';
import 'package:smart_books/services/sound_effect_service.dart';
import 'package:smart_books/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isInputFocused = false; // チャット入力欄のフォーカス状態を追跡

  // 画面のリスト - 各画面を一度だけ初期化する
  final List<Widget> _screens = [
    const ChatScreen(),
    const DocumentLibraryScreen(),
    const DashboardScreen(),
    const SettingsScreen(),
  ];

  // タブ情報のリスト
  final List<Map<String, dynamic>> _tabs = [
    {
      'icon': Icons.chat_bubble_outline,
      'activeIcon': Icons.chat_bubble,
      'label': 'チャット',
      'badge': 0, // バッジカウント（0の場合は非表示）
    },
    {
      'icon': Icons.receipt_long_outlined,
      'activeIcon': Icons.receipt_long,
      'label': '書類',
      'badge': 2, // 例：2件の新しい書類がある
    },
    {
      'icon': Icons.dashboard_outlined,
      'activeIcon': Icons.dashboard,
      'label': '収支',
      'badge': 0,
    },
    {
      'icon': Icons.settings_outlined,
      'activeIcon': Icons.settings,
      'label': '設定',
      'badge': 0,
    },
  ];

  // 各タブのアニメーションコントローラー
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;
  
  // 効果音サービス
  late SoundEffectService _soundEffectService;

  @override
  void initState() {
    super.initState();

    // 効果音サービスの取得
    _soundEffectService = serviceLocator<SoundEffectService>();
    
    // 各タブのアニメーションコントローラーを初期化
    _animationControllers = List.generate(
      _tabs.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );

    // 各タブのアニメーションを初期化
    _animations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutBack,
        ),
      );
    }).toList();

    // 現在のタブのアニメーションを開始
    _animationControllers[_currentIndex].forward();
    
    // ChatScreenからのフォーカス状態をリッスンする
    ChatScreen.focusNotifier.addListener(_updateInputFocusState);
  }

  @override
  void dispose() {
    // アニメーションコントローラーをすべて破棄
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    
    // リスナーを削除
    ChatScreen.focusNotifier.removeListener(_updateInputFocusState);
    
    super.dispose();
  }

  // タブの変更処理
  void _onTabChanged(int index) {
    if (_currentIndex == index) return;

    // ハプティックフィードバック
    HapticFeedback.lightImpact();
    
    // 効果音再生
    _soundEffectService.playSwipeSound();

    // 現在のタブのアニメーションをリセット
    _animationControllers[_currentIndex].reverse();

    setState(() {
      _currentIndex = index;
    });

    // 新しいタブのアニメーションを開始
    _animationControllers[_currentIndex].forward();
  }
  
  // チャット入力欄のフォーカス状態が変化したときの処理
  void _updateInputFocusState() {
    setState(() {
      _isInputFocused = ChatScreen.focusNotifier.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      // IndexedStackを使うことで、タブの状態を保持する
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        // 高さを修正し、オーバーフローを防止
        height: bottomInset > 0 || _isInputFocused ? 0 : kBottomNavigationBarHeight + 16,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Theme.of(context).cardColor 
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 1,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: SafeArea(
          // bottom: falseを追加して下部のパディングを削除（SafeAreaの下部パディングと
          // AnimatedContainerの高さ調整でダブルパディングになることを防ぐ）
          bottom: false,
          child: Padding(
            // 垂直方向のパディングを調整して空間効率を向上
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // チャットタブ
                _buildTabItem(0),
                // 書類タブ
                _buildTabItem(1),
                // 中央のスペース (フローティングボタン用)
                const SizedBox(width: 64),
                // 収支タブ
                _buildTabItem(2),
                // 設定タブ
                _buildTabItem(3),
              ],
            ),
          ),
        ),
      ),
      // 書類スキャンボタン（フローティングアクションボタン）
      // チャット入力欄にフォーカスがあるときは表示しない
      floatingActionButton: _isInputFocused 
          ? null 
          : _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // タブアイテムを构築
  Widget _buildTabItem(int index) {
    final primaryColor = Theme.of(context).primaryColor;
    final tab = _tabs[index];
    final isSelected = index == _currentIndex;

    // アニメーション値（選択時のみ有効）
    final animation = isSelected
        ? _animations[index]
        : const AlwaysStoppedAnimation(0.0);

    return GestureDetector(
      onTap: () => _onTabChanged(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Container(
            // パディングを微調整して最適化
            padding: const EdgeInsets.symmetric(
                vertical: 3, horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // アイコンとバッジ
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // アニメーション付きアイコン
                    Transform.scale(
                      scale: isSelected
                          ? 1.0 + animation.value * 0.2
                          : 1.0,
                      child: Icon(
                        isSelected
                            ? tab['activeIcon']
                            : tab['icon'],
                        color:
                            isSelected ? primaryColor : Colors.grey,
                        // サイズを少し小さくして高さ調整に貢献
                        size: isSelected ? 24 : 22,
                      ),
                    ),
                    // バッジの表示（バッジカウントが0より大きい場合）
                    if (tab['badge'] > 0)
                      Positioned(
                        right: -5,
                        top: -5,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${tab['badge']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 4),

                // タブラベル
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isSelected ? primaryColor : Colors.grey,
                    // フォントサイズを小さく統一して余分なスペースを削減
                    fontSize: 10,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  child: Text(tab['label']),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // フローティングアクションボタン
  Widget _buildFloatingActionButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          // 新規書類スキャン画面へ遷移
          Navigator.pushNamed(context, '/document-scan');

          // 触覚フィードバック
          HapticFeedback.mediumImpact();
        },
        heroTag: 'scanButton',
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(
          Icons.document_scanner,
          size: 28,
        ),
      ),
    );
  }
}

// 画面遷移アニメーション
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

// スライド画面遷移アニメーション
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlidePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}
