import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit pour la gestion du thème clair/sombre.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  /// Bascule entre thème clair et sombre.
  void toggleTheme() {
    emit(state == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light);
  }
}
