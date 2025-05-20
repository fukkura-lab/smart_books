import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

/// テーマ設定の初期化イベント
class ThemeInitEvent extends ThemeEvent {}

/// テーマモード変更イベント
class ThemeChangedEvent extends ThemeEvent {
  final ThemeMode themeMode;

  const ThemeChangedEvent(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}

/// テーマモード切替イベント
class ThemeToggleEvent extends ThemeEvent {}
