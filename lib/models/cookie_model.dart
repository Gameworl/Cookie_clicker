import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'upgrade.dart';

/// Critère de tri pour les améliorations.
enum SortCriteria { price, cps, quantity }

/// Modèle central du jeu.
///
/// Gère les cookies, les améliorations et toute la logique
/// métier. Étend [ChangeNotifier] pour notifier l'UI.
class CookieModel extends ChangeNotifier {
  int _cookies = 0;
  int _totalClicks = 0;
  DateTime? _firstClickAt;
  final List<Upgrade> _upgrades = defaultUpgrades();
  SortCriteria _sortCriteria = SortCriteria.price;
  bool _showOnlyAffordable = false;

  final _numberFormat = NumberFormat('#,###', 'fr_FR');

  static const milestones = [100, 500, 1000, 5000, 10000];

  // --- Getters ---

  int get cookies => _cookies;
  int get totalClicks => _totalClicks;
  DateTime? get firstClickAt => _firstClickAt;
  List<Upgrade> get upgrades => _upgrades;
  SortCriteria get sortCriteria => _sortCriteria;
  bool get showOnlyAffordable => _showOnlyAffordable;

  /// Cookies gagnés par clic (1 de base + bonus des upgrades).
  int get cookiesPerClick {
    var cpc = 1;
    for (final u in _upgrades) {
      cpc += u.cookiesPerClickBonus * u.quantity;
    }
    return cpc;
  }

  /// Cookies produits par seconde.
  int get cookiesPerSecond {
    var cps = 0;
    for (final u in _upgrades) {
      cps += u.cookiesPerSecond * u.quantity;
    }
    return cps;
  }

  String get formattedCookies {
    final formatted =
        _cookies == 0 ? '0' : _numberFormat.format(_cookies);
    return _cookies == 1
        ? '$formatted cookie'
        : '$formatted cookies';
  }

  int? get nextMilestone {
    for (final m in milestones) {
      if (_cookies < m) return m;
    }
    return null;
  }

  /// Upgrades de production triés et filtrés.
  List<Upgrade> get productionUpgrades =>
      _sortAndFilter(UpgradeCategory.production);

  /// Upgrades bonus triés et filtrés.
  List<Upgrade> get bonusUpgrades =>
      _sortAndFilter(UpgradeCategory.bonus);

  // --- Actions ---

  /// Ajoute des cookies selon [cookiesPerClick].
  int? clickCookie() {
    _firstClickAt ??= DateTime.now();
    final before = _cookies;
    _cookies += cookiesPerClick;
    _totalClicks++;
    notifyListeners();
    return _getMilestoneReached(before, _cookies);
  }

  void addCookies(int amount) {
    _cookies += amount;
    notifyListeners();
  }

  void reset() {
    _cookies = 0;
    _totalClicks = 0;
    _firstClickAt = null;
    for (final u in _upgrades) {
      u.quantity = 0;
    }
    notifyListeners();
  }

  /// Achète un upgrade. Retourne `true` si réussi.
  bool buyUpgrade(Upgrade upgrade) {
    if (_cookies >= upgrade.cost) {
      _cookies -= upgrade.cost;
      upgrade.quantity++;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Change le critère de tri.
  void setSortCriteria(SortCriteria criteria) {
    _sortCriteria = criteria;
    notifyListeners();
  }

  /// Active/désactive le filtre "achetable uniquement".
  void toggleAffordableFilter() {
    _showOnlyAffordable = !_showOnlyAffordable;
    notifyListeners();
  }

  // --- Privé ---

  List<Upgrade> _sortAndFilter(UpgradeCategory category) {
    var list = _upgrades
        .where((u) => u.category == category)
        .toList();
    if (_showOnlyAffordable) {
      list = list.where((u) => _cookies >= u.cost).toList();
    }
    switch (_sortCriteria) {
      case SortCriteria.price:
        list.sort((a, b) => a.cost.compareTo(b.cost));
      case SortCriteria.cps:
        list.sort(
          (a, b) =>
              b.cookiesPerSecond.compareTo(a.cookiesPerSecond),
        );
      case SortCriteria.quantity:
        list.sort(
          (a, b) => b.quantity.compareTo(a.quantity),
        );
    }
    return list;
  }

  int? _getMilestoneReached(int before, int after) {
    for (final m in milestones) {
      if (before < m && after >= m) return m;
    }
    return null;
  }
}
