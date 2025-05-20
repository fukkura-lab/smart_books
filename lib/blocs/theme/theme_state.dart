import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();
  
  @override
  List<Object> get props => [];
}

/// テーマ初期化中の状態
class ThemeInitial extends ThemeState {}

/// テーマ読み込み中の状態
class ThemeLoading extends ThemeState {}

/// テーマ読み込み完了の状態
class ThemeLoaded extends ThemeState {
  final ThemeMode themeMode;
  
  const ThemeLoaded(this.themeMode);
  
  @override
  List<Object> get props => [themeMode];
}

/// テーマ読み込みエラーの状態
class ThemeError extends ThemeState {
  final String message;
  
  const ThemeError(this.message);
  
  @override
  List<Object> get props => [message];
}
