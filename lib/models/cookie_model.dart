import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'upgrade.dart';

/// Critère de tri pour les améliorations.
enum SortCriteria { price, cps, quantity }

/// Entrée dans le journal d'activité.
class LogEntry {
  final String message;
  final DateTime time;
  const LogEntry(this.message, this.time);
}

/// Modèle central du jeu.
///
/// Gère les cookies, les upgrades, la production automatique
/// via [Timer], le frenzy x2 et le journal d'activité.
class CookieModel extends ChangeNotifier {
  int _cookies = 0;
  int _totalClicks = 0;
  int _totalFromClicks = 0;
  int _totalFromAuto = 0;
  DateTime? _firstClickAt;
  final List<Upgrade> _upgrades = defaultUpgrades();
  SortCriteria _sortCriteria = SortCriteria.price;
  bool _showOnlyAffordable = false;
  Timer? _timer;
  final List<LogEntry> _log = [];

  // Frenzy
  bool _frenzyActive = false;
  int _frenzyRemaining = 0;
  Timer? _frenzyTimer;
  static const frenzyDuration = 30;
  static const frenzyCooldown = 300; // 5 minutes
  int _frenzyCooldownRemaining = 0;
  Timer? _frenzyCooldownTimer;

  // Cycle de vie
  DateTime? _pausedAt;

  final _numberFormat = NumberFormat('#,###', 'fr_FR');
  static const milestones = [100, 500, 1000, 5000, 10000];

  CookieModel() {
    _startTimer();
  }

  // --- Getters ---

  int get cookies => _cookies;
  int get totalClicks => _totalClicks;
  int get totalFromClicks => _totalFromClicks;
  int get totalFromAuto => _totalFromAuto;
  DateTime? get firstClickAt => _firstClickAt;
  List<Upgrade> get upgrades => _upgrades;
  SortCriteria get sortCriteria => _sortCriteria;
  bool get showOnlyAffordable => _showOnlyAffordable;
  List<LogEntry> get log => List.unmodifiable(_log);
  bool get frenzyActive => _frenzyActive;
  int get frenzyRemaining => _frenzyRemaining;
  int get frenzyCooldownRemaining => _frenzyCooldownRemaining;

  int get cookiesPerClick {
    var cpc = 1;
    for (final u in _upgrades) {
      cpc += u.cookiesPerClickBonus * u.quantity;
    }
    return _frenzyActive ? cpc * 2 : cpc;
  }

  /// CPS de base (sans frenzy).
  int get baseCookiesPerSecond {
    var cps = 0;
    for (final u in _upgrades) {
      cps += u.cookiesPerSecond * u.quantity;
    }
    return cps;
  }

  /// CPS effectif (avec frenzy si actif).
  int get cookiesPerSecond {
    final base = baseCookiesPerSecond;
    return _frenzyActive ? base * 2 : base;
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

  List<Upgrade> get productionUpgrades =>
      _sortAndFilter(UpgradeCategory.production);

  List<Upgrade> get bonusUpgrades =>
      _sortAndFilter(UpgradeCategory.bonus);

  // --- Actions ---

  int? clickCookie() {
    _firstClickAt ??= DateTime.now();
    final cpc = cookiesPerClick;
    final before = _cookies;
    _cookies += cpc;
    _totalClicks++;
    _totalFromClicks += cpc;
    _addLog('+$cpc (clic)');
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
    _totalFromClicks = 0;
    _totalFromAuto = 0;
    _firstClickAt = null;
    _frenzyActive = false;
    _frenzyRemaining = 0;
    _frenzyCooldownRemaining = 0;
    _frenzyTimer?.cancel();
    _frenzyCooldownTimer?.cancel();
    _log.clear();
    for (final u in _upgrades) {
      u.quantity = 0;
    }
    notifyListeners();
  }

  bool buyUpgrade(Upgrade upgrade) {
    if (_cookies >= upgrade.cost) {
      _cookies -= upgrade.cost;
      upgrade.quantity++;
      _addLog('Achat : ${upgrade.name}');
      notifyListeners();
      return true;
    }
    return false;
  }

  void setSortCriteria(SortCriteria criteria) {
    _sortCriteria = criteria;
    notifyListeners();
  }

  void toggleAffordableFilter() {
    _showOnlyAffordable = !_showOnlyAffordable;
    notifyListeners();
  }

  // --- Timer production automatique ---

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tick(),
    );
  }

  void _tick() {
    final cps = cookiesPerSecond;
    if (cps > 0) {
      _cookies += cps;
      _totalFromAuto += cps;
      _addLog('+$cps (auto)');
      notifyListeners();
    }
  }

  // --- Frenzy ---

  /// Active le frenzy x2 pendant [frenzyDuration] secondes.
  void activateFrenzy() {
    if (_frenzyActive || _frenzyCooldownRemaining > 0) return;

    _frenzyActive = true;
    _frenzyRemaining = frenzyDuration;
    _addLog('⚡ Frenzy x2 activé !');
    notifyListeners();

    _frenzyTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        _frenzyRemaining--;
        if (_frenzyRemaining <= 0) {
          _frenzyActive = false;
          _frenzyTimer?.cancel();
          _addLog('Frenzy terminé');
          _startFrenzyCooldown();
        }
        notifyListeners();
      },
    );
  }

  void _startFrenzyCooldown() {
    _frenzyCooldownRemaining = frenzyCooldown;
    _frenzyCooldownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        _frenzyCooldownRemaining--;
        if (_frenzyCooldownRemaining <= 0) {
          _frenzyCooldownTimer?.cancel();
        }
        notifyListeners();
      },
    );
  }

  // --- Cycle de vie ---

  /// Appelé quand l'app passe en arrière-plan.
  void onPause() {
    _pausedAt = DateTime.now();
  }

  /// Appelé quand l'app revient au premier plan.
  ///
  /// Retourne le nombre de cookies gagnés pendant l'absence,
  /// ou null si aucun gain.
  int? onResume() {
    if (_pausedAt == null) return null;
    final elapsed =
        DateTime.now().difference(_pausedAt!).inSeconds;
    _pausedAt = null;
    if (elapsed > 0 && baseCookiesPerSecond > 0) {
      final gained = baseCookiesPerSecond * elapsed;
      _cookies += gained;
      _totalFromAuto += gained;
      _addLog('+$gained (absence ${elapsed}s)');
      notifyListeners();
      return gained;
    }
    return null;
  }

  // --- Journal ---

  void _addLog(String message) {
    _log.insert(0, LogEntry(message, DateTime.now()));
    if (_log.length > 20) _log.removeLast();
  }

  // --- Privé ---

  List<Upgrade> _sortAndFilter(UpgradeCategory category) {
    var list =
        _upgrades.where((u) => u.category == category).toList();
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

  @override
  void dispose() {
    _timer?.cancel();
    _frenzyTimer?.cancel();
    _frenzyCooldownTimer?.cancel();
    super.dispose();
  }
}
