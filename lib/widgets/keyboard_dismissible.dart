import 'package:flutter/material.dart';
import '../utils/keyboard_util.dart';

/// タップ時にキーボードを閉じるウィジェット
/// 子ウィジェットをラップして使用する
class KeyboardDismissible extends StatelessWidget {
  final Widget child;
  final bool opaque;

  const KeyboardDismissible({
    Key? key,
    required this.child,
    this.opaque = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => KeyboardUtil.hideKeyboard(context),
      behavior: opaque ? HitTestBehavior.opaque : HitTestBehavior.translucent,
      child: child,
    );
  }
}
