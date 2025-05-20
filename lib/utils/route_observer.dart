import 'package:flutter/material.dart';
import 'keyboard_util.dart';

/// アプリのルート変更を監視するオブザーバー
class AppRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  static final AppRouteObserver _instance = AppRouteObserver._internal();
  
  factory AppRouteObserver() {
    return _instance;
  }
  
  AppRouteObserver._internal();
  
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // 新しいルートへ遷移する前にキーボードを隠す
    if (route.navigator?.context != null) {
      KeyboardUtil.hideKeyboard(route.navigator!.context);
    }
  }
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // 戻る時にキーボードを隠す
    if (previousRoute?.navigator?.context != null) {
      KeyboardUtil.hideKeyboard(previousRoute!.navigator!.context);
    }
  }
  
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    // ルート置換時にキーボードを隠す
    if (newRoute?.navigator?.context != null) {
      KeyboardUtil.hideKeyboard(newRoute!.navigator!.context);
    }
  }
  
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    // ルート削除時にキーボードを隠す
    if (previousRoute?.navigator?.context != null) {
      KeyboardUtil.hideKeyboard(previousRoute!.navigator!.context);
    }
  }
}
