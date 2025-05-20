import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';
import '../services/theme/theme_service.dart';
import '../services/sound_effect_service.dart';
import '../services/chat_service.dart';
import '../services/chat_storage_service.dart';
import '../services/speech_service.dart';
import '../services/voice_recognition_service.dart';
import '../services/content_classifier.dart';
import '../services/transaction/transaction_service.dart';
import '../blocs/chat/chat_bloc.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/theme/theme_bloc.dart';

/// GetIt インスタンス
final GetIt serviceLocator = GetIt.instance;

/// 依存関係の初期化
Future<void> setupDependencies() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerSingleton<SharedPreferences>(sharedPreferences);

  // サービス
  serviceLocator.registerLazySingleton<ChatStorageService>(() => ChatStorageService());
  serviceLocator.registerLazySingleton<AIService>(() => AIService());
  serviceLocator.registerLazySingleton<ChatService>(() => ChatService());
  serviceLocator.registerLazySingleton<SpeechService>(() => SpeechService());
  serviceLocator.registerLazySingleton<VoiceRecognitionService>(() => VoiceRecognitionService());
  serviceLocator.registerLazySingleton<TransactionService>(() => TransactionService());
  serviceLocator.registerLazySingleton<ThemeService>(() => ThemeService());
  serviceLocator.registerLazySingleton<SoundEffectService>(() => SoundEffectService());

  // Bloc
  serviceLocator.registerFactory<ChatBloc>(() => ChatBloc(
        serviceLocator<ChatService>(),
        serviceLocator<ChatStorageService>(),
      ));
      
  serviceLocator.registerFactory<TransactionBloc>(() => TransactionBloc(
        serviceLocator<TransactionService>(),
      ));

  serviceLocator.registerFactory<ThemeBloc>(() => ThemeBloc(
        themeService: serviceLocator<ThemeService>(),
      ));
}
