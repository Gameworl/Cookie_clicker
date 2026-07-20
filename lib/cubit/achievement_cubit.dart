import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/achievement.dart';
import '../models/upgrade.dart';
import 'achievement_state.dart';
import 'cookie_state.dart';

/// Cubit des achievements.
///
/// Vérifie les conditions à chaque changement
/// de [CookieState] et débloque les succès.
class AchievementCubit extends Cubit<AchievementState> {
  AchievementCubit()
      : super(AchievementState(
          achievements: defaultAchievements(),
        ));

  /// Vérifie et débloque les achievements.
  void check(CookieState cookieState) {
    var changed = false;

    void unlock(String id) {
      final a = state.achievements.firstWhere(
        (x) => x.id == id,
      );
      if (!a.unlocked) {
        a.unlocked = true;
        changed = true;
        emit(state.copyWith(
          achievements: List.of(state.achievements),
          lastUnlocked: a,
        ));
      }
    }

    if (cookieState.totalClicks >= 1) unlock('first_click');
    if (cookieState.cookies >= 100) unlock('cookies_100');
    if (cookieState.cookies >= 1000) unlock('cookies_1000');
    if (cookieState.cookies >= 10000) unlock('cookies_10000');
    if (cookieState.totalClicks >= 100) unlock('clicks_100');
    if (cookieState.totalClicks >= 1000) {
      unlock('clicks_1000');
    }
    if (cookieState.upgrades.any((u) => u.quantity > 0)) {
      unlock('first_buy');
    }
    final prodUpgrades = cookieState.upgrades
        .where((u) => u.category == UpgradeCategory.production);
    if (prodUpgrades.isNotEmpty &&
        prodUpgrades.every((u) => u.quantity > 0)) {
      unlock('collector');
    }
    if (cookieState.cookiesPerSecond >= 10) unlock('cps_10');
    if (cookieState.cookiesPerSecond >= 100) unlock('cps_100');
    if (cookieState.prestiges >= 1) unlock('first_prestige');
    if (cookieState.prestiges >= 3) unlock('prestige_3');
    if (cookieState.frenzyActive) unlock('frenzy_used');
    if (cookieState.playerName != 'Joueur') unlock('name_set');

    if (!changed) return;
  }
}
