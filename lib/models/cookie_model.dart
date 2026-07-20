import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'achievement.dart';
import 'game_save.dart';
import 'upgrade.dart';

/// Critère de tri pour les améliorations.
enum SortCriteria { price, cps, quantity }

/// Entrée dans le journal d'activité.
class LogEntry {
  final String message;
  final DateTime time;
  const LogEntry(this.message, this.time);
}

/// Point de données pour le graphique de progression.
class ProgressPoint {
  final DateTime time;
  final int cookies;
  const ProgressPoint(this.time, this.cookies);
}

/// Modèle central du jeu.
///
/// Gère cookies, upgrades, production auto, frenzy,
/// prestige, achievements, journal et sauvegarde.
class CookieModel extends ChangeNotifier {
  int _cookies = 0;
  int _totalClicks = 0;
  int _totalFromClicks = 0;
  int _totalFromAuto = 0;
  int _totalCookiesEarned = 0;
  DateTime? _firstClickAt;
  final List<Upgrade> _upgrades = defaultUpgrades();
  final List<Achievement> _achievements = defaultAchievements();
  SortCriteria _sortCriteria = SortCriteria.price;
  bool _showOnlyAffordable = false;
  Timer? _timer;
  Timer? _progressTimer;
  final List<LogEntry> _log = [];
  String _playerName = 'Joueur';
  DateTime? _lastSavedAt;
  bool _bonusUsed = false;

  // Prestige
  int _prestiges = 0;
  double get prestigeMultiplier => 1.0 + 0.1 * _prestiges;
  static const _prestigeThreshold = 10000;

  // Frenzy
  bool _frenzyActive = false;
  int _frenzyRemaining = 0;
  Timer? _frenzyTimer;
  static const frenzyDuration = 30;
  static const frenzyCooldown = 300;
  int _frenzyCooldownRemaining = 0;
  Timer? _frenzyCooldownTimer;
  bool _frenzyUsed = false;

  // Cycle de vie
  DateTime? _pausedAt;

  // Sauvegarde
  Timer? _debounceTimer;
  final ValueNotifier<bool> savingNotifier =
      ValueNotifier(false);
  int _currentSlot = 0;
  bool _disposed = false;

  // Progression graphique
  final List<ProgressPoint> _progressHistory = [];
  static const _maxProgressPoints = 60;

  final _numberFormat = NumberFormat('#,###', 'fr_FR');
  static const milestones = [100, 500, 1000, 5000, 10000];

  /// Dernier achievement débloqué (pour notification).
  Achievement? lastUnlockedAchievement;

  CookieModel() {
    _startTimer();
    _startProgressTimer();
    loadGame();
  }

  // --- Getters ---

  int get cookies => _cookies;
  int get totalClicks => _totalClicks;
  int get totalFromClicks => _totalFromClicks;
  int get totalFromAuto => _totalFromAuto;
  int get totalCookiesEarned => _totalCookiesEarned;
  DateTime? get firstClickAt => _firstClickAt;
  List<Upgrade> get upgrades => _upgrades;
  List<Achievement> get achievements => _achievements;
  SortCriteria get sortCriteria => _sortCriteria;
  bool get showOnlyAffordable => _showOnlyAffordable;
  List<LogEntry> get log => List.unmodifiable(_log);
  bool get frenzyActive => _frenzyActive;
  int get frenzyRemaining => _frenzyRemaining;
  int get frenzyCooldownRemaining => _frenzyCooldownRemaining;
  String get playerName => _playerName;
  DateTime? get lastSavedAt => _lastSavedAt;
  int get currentSlot => _currentSlot;
  int get prestiges => _prestiges;
  bool get canPrestige => _cookies >= _prestigeThreshold;
  List<ProgressPoint> get progressHistory => _progressHistory;

  int get cookiesPerClick {
    var cpc = 1;
    for (final u in _upgrades) {
      cpc += u.cookiesPerClickBonus * u.quantity;
    }
    final base = (cpc * prestigeMultiplier).ceil();
    return _frenzyActive ? base * 2 : base;
  }

  int get baseCookiesPerSecond {
    var cps = 0;
    for (final u in _upgrades) {
      cps += u.cookiesPerSecond * u.quantity;
    }
    return (cps * prestigeMultiplier).ceil();
  }

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

  /// Upgrades de production visibles (débloqués).
  List<Upgrade> get productionUpgrades => _sortAndFilter(
        UpgradeCategory.production,
      );

  /// Upgrades bonus visibles (débloqués).
  List<Upgrade> get bonusUpgrades => _sortAndFilter(
        UpgradeCategory.bonus,
      );

  /// Nombre d'achievements débloqués.
  int get unlockedAchievementCount =>
      _achievements.where((a) => a.unlocked).length;

  // --- Actions ---

  int? clickCookie() {
    _firstClickAt ??= DateTime.now();
    final cpc = cookiesPerClick;
    final before = _cookies;
    _cookies += cpc;
    _totalClicks++;
    _totalFromClicks += cpc;
    _totalCookiesEarned += cpc;
    _addLog('+$cpc (clic)');
    notifyListeners();
    _checkAchievements();
    _debounceSave();
    return _getMilestoneReached(before, _cookies);
  }

  void addCookies(int amount) {
    _cookies += amount;
    _totalCookiesEarned += amount;
    _bonusUsed = true;
    notifyListeners();
    _checkAchievements();
    _debounceSave();
  }

  void reset() {
    _cookies = 0;
    _totalClicks = 0;
    _totalFromClicks = 0;
    _totalFromAuto = 0;
    _totalCookiesEarned = 0;
    _firstClickAt = null;
    _frenzyActive = false;
    _frenzyRemaining = 0;
    _frenzyCooldownRemaining = 0;
    _frenzyTimer?.cancel();
    _frenzyCooldownTimer?.cancel();
    _log.clear();
    _progressHistory.clear();
    for (final u in _upgrades) {
      u.quantity = 0;
    }
    for (final a in _achievements) {
      a.unlocked = false;
    }
    _prestiges = 0;
    notifyListeners();
    _saveGameNow();
  }

  bool buyUpgrade(Upgrade upgrade) {
    if (_cookies >= upgrade.cost) {
      _cookies -= upgrade.cost;
      upgrade.quantity++;
      _addLog('Achat : ${upgrade.name}');
      notifyListeners();
      _checkAchievements();
      _debounceSave();
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

  void setPlayerName(String name) {
    _playerName = name;
    notifyListeners();
    _checkAchievements();
    _debounceSave();
  }

  // --- Prestige ---

  /// Effectue un prestige : reset + multiplicateur.
  void prestige() {
    if (!canPrestige) return;
    _prestiges++;
    _cookies = 0;
    _totalClicks = 0;
    _totalFromClicks = 0;
    _totalFromAuto = 0;
    _frenzyActive = false;
    _frenzyRemaining = 0;
    _frenzyCooldownRemaining = 0;
    _frenzyTimer?.cancel();
    _frenzyCooldownTimer?.cancel();
    _log.clear();
    _progressHistory.clear();
    for (final u in _upgrades) {
      u.quantity = 0;
    }
    _addLog('🌟 Prestige #$_prestiges !');
    notifyListeners();
    _checkAchievements();
    _saveGameNow();
  }

  // --- Timer ---

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
      _totalCookiesEarned += cps;
      _addLog('+$cps (auto)');
      notifyListeners();
      _debounceSave();
    }
  }

  void _startProgressTimer() {
    _progressTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        _progressHistory.add(
          ProgressPoint(DateTime.now(), _cookies),
        );
        if (_progressHistory.length > _maxProgressPoints) {
          _progressHistory.removeAt(0);
        }
      },
    );
  }

  // --- Frenzy ---

  void activateFrenzy() {
    if (_frenzyActive || _frenzyCooldownRemaining > 0) return;
    _frenzyActive = true;
    _frenzyRemaining = frenzyDuration;
    _frenzyUsed = true;
    _addLog('⚡ Frenzy x2 activé !');
    notifyListeners();
    _checkAchievements();
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

  void onPause() {
    _pausedAt = DateTime.now();
    _saveGameNow();
  }

  int? onResume() {
    if (_pausedAt == null) return null;
    final elapsed =
        DateTime.now().difference(_pausedAt!).inSeconds;
    _pausedAt = null;
    if (elapsed > 0 && baseCookiesPerSecond > 0) {
      final gained = baseCookiesPerSecond * elapsed;
      _cookies += gained;
      _totalFromAuto += gained;
      _totalCookiesEarned += gained;
      _addLog('+$gained (absence ${elapsed}s)');
      notifyListeners();
      return gained;
    }
    return null;
  }

  // --- Achievements ---

  void _checkAchievements() {
    void _unlock(String id) {
      final a = _achievements.firstWhere((x) => x.id == id);
      if (!a.unlocked) {
        a.unlocked = true;
        lastUnlockedAchievement = a;
        notifyListeners();
      }
    }

    if (_totalClicks >= 1) _unlock('first_click');
    if (_cookies >= 100) _unlock('cookies_100');
    if (_cookies >= 1000) _unlock('cookies_1000');
    if (_cookies >= 10000) _unlock('cookies_10000');
    if (_totalClicks >= 100) _unlock('clicks_100');
    if (_totalClicks >= 1000) _unlock('clicks_1000');
    if (_upgrades.any((u) => u.quantity > 0)) {
      _unlock('first_buy');
    }
    final prodUpgrades = _upgrades
        .where((u) => u.category == UpgradeCategory.production);
    if (prodUpgrades.every((u) => u.quantity > 0)) {
      _unlock('collector');
    }
    if (baseCookiesPerSecond >= 10) _unlock('cps_10');
    if (baseCookiesPerSecond >= 100) _unlock('cps_100');
    if (_prestiges >= 1) _unlock('first_prestige');
    if (_prestiges >= 3) _unlock('prestige_3');
    if (_frenzyUsed) _unlock('frenzy_used');
    if (_bonusUsed) _unlock('bonus_used');
    if (_playerName != 'Joueur') _unlock('name_set');
  }

  // --- Sauvegarde ---

  void _debounceSave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(seconds: 2),
      _saveGameNow,
    );
  }

  GameSave _createSave() {
    final upgradesMap = <String, int>{};
    for (final u in _upgrades) {
      upgradesMap[u.id] = u.quantity;
    }
    return GameSave(
      cookies: _cookies,
      totalClicks: _totalClicks,
      totalFromClicks: _totalFromClicks,
      totalFromAuto: _totalFromAuto,
      upgradeQuantities: upgradesMap,
      playerName: _playerName,
      lastSavedAt: DateTime.now().toIso8601String(),
      prestiges: _prestiges,
      unlockedAchievements: _achievements
          .where((a) => a.unlocked)
          .map((a) => a.id)
          .toList(),
    );
  }

  Future<void> _saveGameNow() async {
    if (_disposed) return;
    savingNotifier.value = true;
    final prefs = await SharedPreferences.getInstance();
    final save = _createSave();
    await prefs.setString(
      'slot_$_currentSlot',
      jsonEncode(save.toJson()),
    );
    _lastSavedAt = DateTime.now();
    if (!_disposed) savingNotifier.value = false;
  }

  Future<void> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    if (_disposed) return;
    final json = prefs.getString('slot_$_currentSlot');
    if (json != null) {
      _restoreFromSave(GameSave.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      ));
    }
  }

  Future<void> switchSlot(int slot) async {
    _currentSlot = slot;
    await loadGame();
  }

  Future<void> deleteSlot(int slot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('slot_$slot');
    if (slot == _currentSlot) reset();
  }

  Future<GameSave?> getSlotInfo(int slot) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('slot_$slot');
    if (json == null) return null;
    return GameSave.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }

  String exportSave() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(_createSave().toJson());
  }

  void importSave(String jsonString) {
    final Map<String, dynamic> data =
        jsonDecode(jsonString) as Map<String, dynamic>;
    final save = GameSave.fromJson(data);
    _restoreFromSave(save);
    _saveGameNow();
  }

  void _restoreFromSave(GameSave save) {
    _cookies = save.cookies;
    _totalClicks = save.totalClicks;
    _totalFromClicks = save.totalFromClicks;
    _totalFromAuto = save.totalFromAuto;
    _playerName = save.playerName;
    _prestiges = save.prestiges;
    if (save.lastSavedAt != null) {
      _lastSavedAt = DateTime.tryParse(save.lastSavedAt!);
    }
    for (final u in _upgrades) {
      u.quantity = save.upgradeQuantities[u.id] ?? 0;
    }
    for (final a in _achievements) {
      a.unlocked = save.unlockedAchievements.contains(a.id);
    }
    notifyListeners();
  }

  // --- Journal ---

  void _addLog(String message) {
    _log.insert(0, LogEntry(message, DateTime.now()));
    if (_log.length > 20) _log.removeLast();
  }

  // --- Privé ---

  List<Upgrade> _sortAndFilter(UpgradeCategory category) {
    var list = _upgrades
        .where((u) =>
            u.category == category &&
            (u.unlockThreshold == 0 ||
                _totalCookiesEarned >= u.unlockThreshold))
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

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _progressTimer?.cancel();
    _frenzyTimer?.cancel();
    _frenzyCooldownTimer?.cancel();
    _debounceTimer?.cancel();
    savingNotifier.dispose();
    super.dispose();
  }
}
