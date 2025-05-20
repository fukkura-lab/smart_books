import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smart_books/blocs/auth/auth_bloc.dart';
import 'package:smart_books/blocs/theme/theme_bloc.dart';
import 'package:smart_books/blocs/theme/theme_event.dart';
import 'package:smart_books/blocs/theme/theme_state.dart';
import 'package:smart_books/config/routes.dart';
import 'package:smart_books/config/theme_enhanced.dart';
import 'package:smart_books/di/service_locator.dart';
import 'package:smart_books/screens/auth/login_screen.dart';
import 'package:smart_books/screens/chat/chat_screen.dart';
import 'package:smart_books/services/notification_service.dart';

class SmartBooksApp extends StatefulWidget {
  const SmartBooksApp({Key? key}) : super(key: key);

  @override
  State<SmartBooksApp> createState() => _SmartBooksAppState();
}

class _SmartBooksAppState extends State<SmartBooksApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // 通知サービスの初期化
    getIt<NotificationService>().init();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>()..add(AuthCheckStatusEvent()),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => getIt<ThemeBloc>()..add(ThemeInitEvent()),
        ),
        // 他のBlocプロバイダーをここに追加
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final themeMode = state is ThemeLoaded ? state.themeMode : ThemeMode.light;

          return MaterialApp(
            title: 'SmartBooks AI',
            navigatorKey: _navigatorKey,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ja', 'JP'),
              Locale('en', 'US'),
            ],
            // 言語設定（日本語をデフォルトにする）
            locale: const Locale('ja', 'JP'),
            // ルート設定
            onGenerateRoute: AppRouter.generateRoute,
            // 初期画面（認証状態によって変化）
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return const ChatScreen(); // 認証済みならチャット画面へ
                } else {
                  return const LoginScreen(); // 未認証ならログイン画面へ
                }
              },
            ),
          );
        },
      ),
    );
  }
}
