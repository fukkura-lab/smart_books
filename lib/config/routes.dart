import 'package:flutter/material.dart';
import 'package:smart_books/screens/account_management/account_categories_screen.dart';
import 'package:smart_books/screens/auth/login_screen.dart';
import 'package:smart_books/screens/auth/register_screen.dart';
import 'package:smart_books/screens/chat_screen.dart';
import 'package:smart_books/screens/dashboard_screen.dart';
import 'package:smart_books/screens/document_detail_screen.dart';
import 'package:smart_books/screens/document_library_screen.dart';
import 'package:smart_books/screens/document_scan_screen.dart';
import 'package:smart_books/screens/home_screen.dart';
import 'package:smart_books/screens/profile_screen.dart';
import 'package:smart_books/screens/settings_screen.dart';
import 'package:smart_books/screens/reports/monthly_report_page.dart';
import 'package:smart_books/screens/transaction/transaction_list_screen.dart';
import 'package:smart_books/utils/custom_route_transition.dart';
import 'package:smart_books/utils/keyboard_util.dart';
import 'package:smart_books/widgets/swipe_back_navigator.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String dashboard = '/dashboard';
  static const String documentLibrary = '/document-library';
  static const String documentDetail = '/document-detail';
  static const String documentScan = '/document-scan';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String accountCategories = '/account-categories';
  static const String monthlyReport = '/monthly-report';
  static const String transactionList = '/transaction-list';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return CustomRouteTransition.fadeTransition(
          page: const LoginScreen(),
          settings: settings,
        );

      case AppRoutes.register:
        return CustomRouteTransition.slideTransition(
          page: SwipeBackScreen(child: const RegisterScreen()),
          settings: settings,
        );

      case AppRoutes.home:
        return CustomRouteTransition.fadeTransition(
          page: const HomeScreen(),
          settings: settings,
        );

      case AppRoutes.chat:
        return CustomRouteTransition.fadeTransition(
          page: const ChatScreen(),
          settings: settings,
        );

      case AppRoutes.dashboard:
        return CustomRouteTransition.fadeTransition(
          page: const DashboardScreen(),
          settings: settings,
        );

      case AppRoutes.documentLibrary:
        return CustomRouteTransition.fadeTransition(
          page: const DocumentLibraryScreen(),
          settings: settings,
        );

      case AppRoutes.documentDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return CustomRouteTransition.scaleTransition(
          page: SwipeBackScreen(
            child: DocumentDetailScreen(
              documentId: args?['documentId'] ?? '',
            ),
          ),
          settings: settings,
        );

      case AppRoutes.documentScan:
        return CustomRouteTransition.modalTransition(
          page: SwipeBackScreen(child: const DocumentScanScreen()),
          settings: settings,
        );

      case AppRoutes.settings:
        return CustomRouteTransition.fadeTransition(
          page: const SettingsScreen(),
          settings: settings,
        );

      case AppRoutes.profile:
        return CustomRouteTransition.slideTransition(
          page: SwipeBackScreen(child: const ProfileScreen()),
          settings: settings,
        );
        
      case AppRoutes.accountCategories:
        return CustomRouteTransition.slideTransition(
          page: const AccountCategoriesScreen(),
          settings: settings,
        );

      case AppRoutes.monthlyReport:
        return CustomRouteTransition.fadeTransition(
          page: const MonthlyReportPage(),
          settings: settings,
        );
        
      case AppRoutes.transactionList:
        return CustomRouteTransition.fadeTransition(
          page: SwipeBackScreen(child: const TransactionListScreen()),
          settings: settings,
        );

      // ルートが登録されていない場合はデフォルトとしてホーム画面に遷移
      default:
        return CustomRouteTransition.fadeTransition(
          page: const HomeScreen(),
          settings: settings,
        );
    }
  }

  // アプリ全体のナビゲーション履歴をクリアして特定の画面に遷移するヘルパーメソッド
  static void navigateAndRemoveUntil(BuildContext context, String routeName) {
    // キーボードを隠す
    KeyboardUtil.hideKeyboard(context);
    
    Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false, // すべてのルートを削除
    );
  }

  // 現在の画面を置き換えて新しい画面に遷移するヘルパーメソッド
  static void navigateAndReplace(BuildContext context, String routeName,
      {Object? arguments}) {
    // キーボードを隠す
    KeyboardUtil.hideKeyboard(context);
    
    Navigator.of(context).pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  // アニメーション付きの遷移を行うヘルパーメソッド
  static void navigateWithAnimation(BuildContext context, String routeName,
      {Object? arguments}) {
    // キーボードを隠す
    KeyboardUtil.hideKeyboard(context);
    
    Navigator.of(context).pushNamed(
      routeName,
      arguments: arguments,
    );
  }
}
