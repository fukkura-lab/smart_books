import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// スワイプによる「戻る」ジェスチャーを実装するウィジェット
/// iOSスタイルの戻るジェスチャーをAndroidでも使用できるようにします
class SwipeBackNavigator extends StatefulWidget {
  final Widget child;
  final bool enableSwipeBack;
  final Function? onSwipeBack;

  const SwipeBackNavigator({
    Key? key,
    required this.child,
    this.enableSwipeBack = true,
    this.onSwipeBack,
  }) : super(key: key);

  @override
  State<SwipeBackNavigator> createState() => _SwipeBackNavigatorState();
}

class _SwipeBackNavigatorState extends State<SwipeBackNavigator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late Animation<double> _scaleAnimation;

  double _dragStartX = 0.0;
  bool _isDragging = false;
  bool _canPop = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfCanPop();
    });
  }

  // 現在のルートがポップ可能かどうかをチェック
  void _checkIfCanPop() {
    _canPop = Navigator.of(context).canPop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ドラッグ開始時の処理
  void _onDragStart(DragStartDetails details) {
    if (!widget.enableSwipeBack || !_canPop) return;

    // 画面の左端20%以内からのスワイプのみを検知
    final screenWidth = MediaQuery.of(context).size.width;
    if (details.localPosition.dx > screenWidth * 0.2) return;

    setState(() {
      _isDragging = true;
      _dragStartX = details.localPosition.dx;
    });
  }

  // ドラッグ更新時の処理
  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final screenWidth = MediaQuery.of(context).size.width;
    double dragDistancePercent =
        (details.localPosition.dx - _dragStartX) / screenWidth;

    // 0から1の範囲に制限
    dragDistancePercent = dragDistancePercent.clamp(0.0, 1.0);

    _controller.value = dragDistancePercent;
  }

  // ドラッグ終了時の処理
  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging) return;

    // 速度または位置に基づいて、ジェスチャーを完了するか元に戻すかを決定
    final velocity = details.velocity.pixelsPerSecond.dx;
    final screenWidth = MediaQuery.of(context).size.width;
    final positionThreshold = screenWidth * 0.3; // 30%以上ドラッグされたら遷移
    final velocityThreshold = 800.0; // 一定以上の速度でスワイプされたら遷移

    if (_controller.value > 0.3 || velocity > velocityThreshold) {
      // ジェスチャーを完了して前の画面に戻る
      _controller.forward().then((_) {
        if (widget.onSwipeBack != null) {
          widget.onSwipeBack!();
        } else {
          Navigator.of(context).pop();
        }
      });
    } else {
      // 元の位置に戻す
      _controller.reverse();
    }

    setState(() {
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // スワイプジェスチャー検出用のGestureDetector
    return GestureDetector(
      onHorizontalDragStart: widget.enableSwipeBack ? _onDragStart : null,
      onHorizontalDragUpdate: widget.enableSwipeBack ? _onDragUpdate : null,
      onHorizontalDragEnd: widget.enableSwipeBack ? _onDragEnd : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // スワイプ中は現在の画面を右にスライドさせ、少し縮小する
          return Transform.translate(
            offset: Offset(
                _animation.value.dx * MediaQuery.of(context).size.width * 0.3,
                0),
            child: Transform.scale(
              scale: 1.0 - (_controller.value * 0.05), // わずかに縮小
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// スワイプバック機能付きの画面を作成するためのベースクラス
/// このクラスを継承することで、簡単にスワイプバック機能を追加できます
abstract class SwipeBackPage extends StatelessWidget {
  final bool enableSwipeBack;

  const SwipeBackPage({Key? key, this.enableSwipeBack = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwipeBackNavigator(
      enableSwipeBack: enableSwipeBack,
      child: buildContent(context),
    );
  }

  /// 継承クラスで実装する画面コンテンツビルドメソッド
  Widget buildContent(BuildContext context);
}

/// スワイプバック機能付きのスクリーンラッパー
/// 既存のウィジェットをラップして、スワイプバック機能を追加します
class SwipeBackScreen extends StatelessWidget {
  final Widget child;
  final bool enableSwipeBack;

  const SwipeBackScreen({
    Key? key,
    required this.child,
    this.enableSwipeBack = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwipeBackNavigator(
      enableSwipeBack: enableSwipeBack,
      child: child,
    );
  }
}
