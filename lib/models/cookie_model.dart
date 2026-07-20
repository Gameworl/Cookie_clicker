import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Modèle central du jeu, contenant l'état des cookies.
///
/// Étend [ChangeNotifier] pour notifier les widgets
/// quand l'état change. Contient toute la logique métier
/// liée aux cookies.
class CookieModel extends ChangeNotifier {
  int _cookies = 0;
  int _totalClicks = 0;
  DateTime? _firstClickAt;

  /// Formatte les nombres avec séparateurs de milliers.
  final _numberFormat = NumberFormat('#,###', 'fr_FR');

  /// Paliers qui déclenchent un feedback visuel.
  static const milestones = [100, 500, 1000, 5000, 10000];

  /// Nombre actuel de cookies.
  int get cookies => _cookies;

  /// Nombre total de clics effectués.
  int get totalClicks => _totalClicks;

  /// Date/heure du premier clic (null si aucun clic).
  DateTime? get firstClickAt => _firstClickAt;

  /// Texte formaté avec séparateurs et singulier/pluriel.
  String get formattedCookies {
    final formatted =
        _cookies == 0 ? '0' : _numberFormat.format(_cookies);
    return _cookies == 1
        ? '$formatted cookie'
        : '$formatted cookies';
  }

  /// Prochain palier à atteindre (null si tous atteints).
  int? get nextMilestone {
    for (final m in milestones) {
      if (_cookies < m) return m;
    }
    return null;
  }

  /// Ajoute un cookie (clic du joueur).
  ///
  /// Retourne le palier atteint, ou null si aucun.
  int? clickCookie() {
    _firstClickAt ??= DateTime.now();
    final before = _cookies;
    _cookies++;
    _totalClicks++;
    notifyListeners();
    return _getMilestoneReached(before, _cookies);
  }

  /// Ajoute plusieurs cookies d'un coup.
  void addCookies(int amount) {
    _cookies += amount;
    notifyListeners();
  }

  /// Remet tout à zéro.
  void reset() {
    _cookies = 0;
    _totalClicks = 0;
    _firstClickAt = null;
    notifyListeners();
  }

  int? _getMilestoneReached(int before, int after) {
    for (final m in milestones) {
      if (before < m && after >= m) return m;
    }
    return null;
  }
}
