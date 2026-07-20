import 'package:flutter/material.dart';

/// Modèle pour la gestion du thème (clair/sombre).
///
/// Étend [ChangeNotifier] pour notifier l'arbre de widgets
/// quand le mode de thème change.
class ThemeModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  /// Mode de thème actuel.
  ThemeMode get themeMode => _themeMode;

  /// Bascule entre thème clair et sombre.
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }
}
