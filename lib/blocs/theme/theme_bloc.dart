import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_books/blocs/theme/theme_event.dart';
import 'package:smart_books/blocs/theme/theme_state.dart';
import 'package:smart_books/services/theme/theme_service.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeService _themeService;
  
  ThemeBloc({required ThemeService themeService}) 
      : _themeService = themeService,
        super(ThemeInitial()) {
    on<ThemeInitEvent>(_onThemeInitEvent);
    on<ThemeChangedEvent>(_onThemeChangedEvent);
    on<ThemeToggleEvent>(_onThemeToggleEvent);
  }
  
  /// テーマの初期化処理
  Future<void> _onThemeInitEvent(
      ThemeInitEvent event, Emitter<ThemeState> emit) async {
    emit(ThemeLoading());
    try {
      final themeMode = await _themeService.getThemeMode();
      emit(ThemeLoaded(themeMode));
    } catch (e) {
      emit(ThemeError('テーマの初期化中にエラーが発生しました: $e'));
    }
  }
  
  /// テーマモード変更処理
  Future<void> _onThemeChangedEvent(
      ThemeChangedEvent event, Emitter<ThemeState> emit) async {
    emit(ThemeLoading());
    try {
      await _themeService.setThemeMode(event.themeMode);
      emit(ThemeLoaded(event.themeMode));
    } catch (e) {
      emit(ThemeError('テーマの変更中にエラーが発生しました: $e'));
    }
  }
  
  /// テーマモード切替処理
  Future<void> _onThemeToggleEvent(
      ThemeToggleEvent event, Emitter<ThemeState> emit) async {
    emit(ThemeLoading());
    try {
      final newThemeMode = await _themeService.toggleThemeMode();
      emit(ThemeLoaded(newThemeMode));
    } catch (e) {
      emit(ThemeError('テーマの切替中にエラーが発生しました: $e'));
    }
  }
}
