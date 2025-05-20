import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// キーボード操作のユーティリティクラス
class KeyboardUtil {
  /// 現在のフォーカスを解除し、キーボードを隠す
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
    // デバッグモードの場合はログを表示
    if (kDebugMode) {
      print('KeyboardUtil: キーボードを隠しました');
    }
  }
  
  /// 指定したFocusNodeにフォーカスを移動する
  static void focusField(BuildContext context, FocusNode node) {
    FocusScope.of(context).requestFocus(node);
    // デバッグモードの場合はログを表示
    if (kDebugMode) {
      print('KeyboardUtil: フォーカスを移動しました');
    }
  }
  
  /// 次の入力フィールドにフォーカスを移動
  static void nextFocus(BuildContext context) {
    FocusScope.of(context).nextFocus();
    // デバッグモードの場合はログを表示
    if (kDebugMode) {
      print('KeyboardUtil: 次のフィールドに移動しました');
    }
  }
  
  /// キーボードが表示されているかチェック
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }
}
