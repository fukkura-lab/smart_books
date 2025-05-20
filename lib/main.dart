import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_books/blocs/chat/chat_bloc.dart';
import 'package:smart_books/blocs/chat/chat_event.dart';
import 'package:smart_books/blocs/theme/theme_bloc.dart';
import 'package:smart_books/blocs/theme/theme_event.dart';
import 'package:smart_books/blocs/theme/theme_state.dart';
import 'package:smart_books/blocs/transaction/transaction_bloc.dart';
import 'package:smart_books/config/routes.dart';
import 'package:smart_books/config/theme_enhanced.dart';
import 'package:smart_books/di/service_locator.dart';
import 'package:smart_books/screens/auth/login_screen.dart';
import 'package:smart_books/screens/home_screen.dart';
import 'package:smart_books/utils/auth_helper.dart';
import 'package:smart_books/utils/keyboard_util.dart';
import 'package:smart_books/utils/route_observer.dart';
import 'package:smart_books/widgets/keyboard_dismissible.dart';
import 'package:smart_books/services/sound_effect_service.dart';

// デバッグモード設定
// true の場合、認証をスキップしてホーム画面に直接遷移します
const bool debugSkipLogin = true;

// RouteObserverインスタンスを作成
final AppRouteObserver appRouteObserver = AppRouteObserver();

Future<void> main() async {
  // Flutterバインディングの初期化を確認
  WidgetsFlutterBinding.ensureInitialized();

  // システムUIのオーバーレイスタイルを設定
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // 画面の向きを縦向きに固定
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    // 環境変数の読み込み
    await dotenv.load(fileName: ".env");
    print('環境変数の読み込みが完了しました');
  } catch (e) {
    // .envファイルがない場合のフォールバック
    print('警告: .envファイルが見つかりません。デフォルト設定を使用します。');
  }

  // 依存関係の初期化
  await setupDependencies();
  print('依存関係の初期化が完了しました');
  
  // 効果音サービスの初期化
  await serviceLocator<SoundEffectService>().initialize();
  print('効果音サービスの初期化が完了しました');

  // 認証状態のチェック
  bool isLoggedIn;
  if (debugSkipLogin) {
    // デバッグモードの場合は常にログイン済みとする
    isLoggedIn = true;
    print('デバッグモード: 認証をスキップしています');
  } else {
    // 通常モードの場合は認証状態をチェック
    final authHelper = AuthHelper();
    isLoggedIn = await authHelper.checkAuth();
  }

  // アプリケーションの起動
  runApp(ZaiTechApp(isLoggedIn: isLoggedIn));
}

class ZaiTechApp extends StatelessWidget {
  final bool isLoggedIn;

  const ZaiTechApp({
    Key? key,
    required this.isLoggedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatBloc>(
          create: (context) => serviceLocator<ChatBloc>()..add(LoadChatHistoryEvent()),
        ),
        BlocProvider<TransactionBloc>(
          create: (context) => serviceLocator<TransactionBloc>(),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => serviceLocator<ThemeBloc>()..add(ThemeInitEvent()),
        ),
        // 他のBlocを必要に応じて追加
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final themeMode = state is ThemeLoaded ? state.themeMode : ThemeMode.light;
          
          return MaterialApp(
            title: '財Tech',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,

            // 日本語対応の追加
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ja', 'JP'), // 日本語がデフォルト
            ],
            locale: const Locale('ja', 'JP'),

            // 初期画面の設定
            initialRoute: '/',

            // AppRouter クラスからルートを生成
            onGenerateRoute: AppRouter.generateRoute,

            // ホーム画面設定
            home: KeyboardDismissible(
              child: isLoggedIn ? const HomeScreen() : const LoginScreen(),
            ),
            
            // RouteObserverを設定
            navigatorObservers: [
              appRouteObserver,
            ],

            // キーボードを隠すコールバックを設定
            builder: (context, child) {
              return GestureDetector(
                onTap: () => KeyboardUtil.hideKeyboard(context),
                behavior: HitTestBehavior.opaque,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
