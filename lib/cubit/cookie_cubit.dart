import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_save.dart';
import '../models/upgrade.dart';
import 'cookie_state.dart';

/// Cubit principal du jeu.
///
/// Remplace [CookieModel] avec des états immutables.
/// Gère cookies, upgrades, production auto, frenzy,
/// prestige et sauvegarde.
class CookieCubit extends Cubit<CookieState> {
  Timer? _timer;
  Timer? _frenzyTimer;
  Timer? _frenzyCooldownTimer;
  Timer? _debounceTimer;
  int _currentSlot = 0;

  static const _frenzyDuration = 30;
  static const _frenzyCooldown = 300;

  CookieCubit() : super(CookieState(upgrades: defaultUpgrades())) {
    _startTimer();
    loadGame();
  }

  void clickCookie() {
    final cpc = state.cookiesPerClick;
    emit(state.copyWith(
      cookies: state.cookies + cpc,
      totalClicks: state.totalClicks + 1,
      totalFromClicks: state.totalFromClicks + cpc,
      totalCookiesEarned: state.totalCookiesEarned + cpc,
    ));
    _debounceSave();
  }

  void addCookies(int amount) {
    emit(state.copyWith(
      cookies: state.cookies + amount,
      totalCookiesEarned: state.totalCookiesEarned + amount,
    ));
    _debounceSave();
  }

  void buyUpgrade(Upgrade upgrade) {
    if (state.cookies < upgrade.cost) return;
    final newCookies = state.cookies - upgrade.cost;
    upgrade.quantity++;
    emit(state.copyWith(
      cookies: newCookies,
      upgrades: List.of(state.upgrades),
    ));
    _recalculate();
    _debounceSave();
  }

  void prestige() {
    if (!state.canPrestige) return;
    final newPrestiges = state.prestiges + 1;
    final newMultiplier = 1.0 + 0.1 * newPrestiges;
    for (final u in state.upgrades) {
      u.quantity = 0;
    }
    emit(CookieState(
      upgrades: List.of(state.upgrades),
      prestiges: newPrestiges,
      prestigeMultiplier: newMultiplier,
      playerName: state.playerName,
      cookiesPerClick: newMultiplier.ceil(),
    ));
    _saveGameNow();
  }

  void setPlayerName(String name) {
    emit(state.copyWith(playerName: name));
    _debounceSave();
  }

  void activateFrenzy() {
    if (state.frenzyActive ||
        state.frenzyCooldownRemaining > 0) return;
    emit(state.copyWith(
      frenzyActive: true,
      frenzyRemaining: _frenzyDuration,
    ));
    _recalculate();

    _frenzyTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        final remaining = state.frenzyRemaining - 1;
        if (remaining <= 0) {
          _frenzyTimer?.cancel();
          emit(state.copyWith(
            frenzyActive: false,
            frenzyRemaining: 0,
          ));
          _recalculate();
          _startFrenzyCooldown();
        } else {
          emit(state.copyWith(frenzyRemaining: remaining));
        }
      },
    );
  }

  void _startFrenzyCooldown() {
    emit(state.copyWith(
      frenzyCooldownRemaining: _frenzyCooldown,
    ));
    _frenzyCooldownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        final remaining = state.frenzyCooldownRemaining - 1;
        emit(state.copyWith(
          frenzyCooldownRemaining: remaining,
        ));
        if (remaining <= 0) _frenzyCooldownTimer?.cancel();
      },
    );
  }

  void reset() {
    for (final u in state.upgrades) {
      u.quantity = 0;
    }
    emit(CookieState(upgrades: List.of(state.upgrades)));
    _frenzyTimer?.cancel();
    _frenzyCooldownTimer?.cancel();
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
    final cps = state.cookiesPerSecond;
    if (cps > 0) {
      emit(state.copyWith(
        cookies: state.cookies + cps,
        totalFromAuto: state.totalFromAuto + cps,
        totalCookiesEarned: state.totalCookiesEarned + cps,
      ));
      _debounceSave();
    }
  }

  void _recalculate() {
    var cpc = 1;
    var cps = 0;
    for (final u in state.upgrades) {
      cpc += u.cookiesPerClickBonus * u.quantity;
      cps += u.cookiesPerSecond * u.quantity;
    }
    final mult = state.prestigeMultiplier;
    final effectiveCpc = (cpc * mult).ceil();
    final effectiveCps = (cps * mult).ceil();
    emit(state.copyWith(
      cookiesPerClick: state.frenzyActive
          ? effectiveCpc * 2
          : effectiveCpc,
      cookiesPerSecond: state.frenzyActive
          ? effectiveCps * 2
          : effectiveCps,
    ));
  }

  // --- Sauvegarde ---

  void _debounceSave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(seconds: 2),
      _saveGameNow,
    );
  }

  Future<void> _saveGameNow() async {
    if (isClosed) return;
    emit(state.copyWith(isSaving: true));
    final prefs = await SharedPreferences.getInstance();
    final upgradesMap = <String, int>{};
    for (final u in state.upgrades) {
      upgradesMap[u.id] = u.quantity;
    }
    final save = GameSave(
      cookies: state.cookies,
      totalClicks: state.totalClicks,
      totalFromClicks: state.totalFromClicks,
      totalFromAuto: state.totalFromAuto,
      upgradeQuantities: upgradesMap,
      playerName: state.playerName,
      lastSavedAt: DateTime.now().toIso8601String(),
      prestiges: state.prestiges,
    );
    await prefs.setString(
      'slot_$_currentSlot',
      jsonEncode(save.toJson()),
    );
    if (!isClosed) emit(state.copyWith(isSaving: false));
  }

  Future<void> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    if (isClosed) return;
    final json = prefs.getString('slot_$_currentSlot');
    if (json == null) return;
    final save = GameSave.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
    for (final u in state.upgrades) {
      u.quantity = save.upgradeQuantities[u.id] ?? 0;
    }
    emit(state.copyWith(
      cookies: save.cookies,
      totalClicks: save.totalClicks,
      totalFromClicks: save.totalFromClicks,
      totalFromAuto: save.totalFromAuto,
      upgrades: List.of(state.upgrades),
      playerName: save.playerName,
      prestiges: save.prestiges,
      prestigeMultiplier: 1.0 + 0.1 * save.prestiges,
    ));
    _recalculate();
  }

  String exportSave() {
    final upgradesMap = <String, int>{};
    for (final u in state.upgrades) {
      upgradesMap[u.id] = u.quantity;
    }
    final save = GameSave(
      cookies: state.cookies,
      totalClicks: state.totalClicks,
      totalFromClicks: state.totalFromClicks,
      totalFromAuto: state.totalFromAuto,
      upgradeQuantities: upgradesMap,
      playerName: state.playerName,
      prestiges: state.prestiges,
    );
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(save.toJson());
  }

  void importSave(String jsonString) {
    final data =
        jsonDecode(jsonString) as Map<String, dynamic>;
    final save = GameSave.fromJson(data);
    for (final u in state.upgrades) {
      u.quantity = save.upgradeQuantities[u.id] ?? 0;
    }
    emit(state.copyWith(
      cookies: save.cookies,
      totalClicks: save.totalClicks,
      totalFromClicks: save.totalFromClicks,
      totalFromAuto: save.totalFromAuto,
      upgrades: List.of(state.upgrades),
      playerName: save.playerName,
      prestiges: save.prestiges,
      prestigeMultiplier: 1.0 + 0.1 * save.prestiges,
    ));
    _recalculate();
    _saveGameNow();
  }

  /// Upgrades de production visibles.
  List<Upgrade> get visibleProductionUpgrades => state.upgrades
      .where((u) =>
          u.category == UpgradeCategory.production &&
          (u.unlockThreshold == 0 ||
              state.totalCookiesEarned >= u.unlockThreshold))
      .toList()
    ..sort((a, b) => a.cost.compareTo(b.cost));

  /// Upgrades bonus visibles.
  List<Upgrade> get visibleBonusUpgrades => state.upgrades
      .where((u) =>
          u.category == UpgradeCategory.bonus &&
          (u.unlockThreshold == 0 ||
              state.totalCookiesEarned >= u.unlockThreshold))
      .toList()
    ..sort((a, b) => a.cost.compareTo(b.cost));

  @override
  Future<void> close() {
    _timer?.cancel();
    _frenzyTimer?.cancel();
    _frenzyCooldownTimer?.cancel();
    _debounceTimer?.cancel();
    return super.close();
  }
}
