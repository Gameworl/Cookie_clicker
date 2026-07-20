import '../models/upgrade.dart';

/// État immutable du jeu de cookies.
class CookieState {
  final int cookies;
  final int totalClicks;
  final int totalFromClicks;
  final int totalFromAuto;
  final int totalCookiesEarned;
  final List<Upgrade> upgrades;
  final int cookiesPerClick;
  final int cookiesPerSecond;
  final int prestiges;
  final double prestigeMultiplier;
  final bool frenzyActive;
  final int frenzyRemaining;
  final int frenzyCooldownRemaining;
  final String playerName;
  final bool isSaving;

  const CookieState({
    this.cookies = 0,
    this.totalClicks = 0,
    this.totalFromClicks = 0,
    this.totalFromAuto = 0,
    this.totalCookiesEarned = 0,
    this.upgrades = const [],
    this.cookiesPerClick = 1,
    this.cookiesPerSecond = 0,
    this.prestiges = 0,
    this.prestigeMultiplier = 1.0,
    this.frenzyActive = false,
    this.frenzyRemaining = 0,
    this.frenzyCooldownRemaining = 0,
    this.playerName = 'Joueur',
    this.isSaving = false,
  });

  bool get canPrestige => cookies >= 10000;

  CookieState copyWith({
    int? cookies,
    int? totalClicks,
    int? totalFromClicks,
    int? totalFromAuto,
    int? totalCookiesEarned,
    List<Upgrade>? upgrades,
    int? cookiesPerClick,
    int? cookiesPerSecond,
    int? prestiges,
    double? prestigeMultiplier,
    bool? frenzyActive,
    int? frenzyRemaining,
    int? frenzyCooldownRemaining,
    String? playerName,
    bool? isSaving,
  }) {
    return CookieState(
      cookies: cookies ?? this.cookies,
      totalClicks: totalClicks ?? this.totalClicks,
      totalFromClicks:
          totalFromClicks ?? this.totalFromClicks,
      totalFromAuto: totalFromAuto ?? this.totalFromAuto,
      totalCookiesEarned:
          totalCookiesEarned ?? this.totalCookiesEarned,
      upgrades: upgrades ?? this.upgrades,
      cookiesPerClick:
          cookiesPerClick ?? this.cookiesPerClick,
      cookiesPerSecond:
          cookiesPerSecond ?? this.cookiesPerSecond,
      prestiges: prestiges ?? this.prestiges,
      prestigeMultiplier:
          prestigeMultiplier ?? this.prestigeMultiplier,
      frenzyActive: frenzyActive ?? this.frenzyActive,
      frenzyRemaining:
          frenzyRemaining ?? this.frenzyRemaining,
      frenzyCooldownRemaining: frenzyCooldownRemaining ??
          this.frenzyCooldownRemaining,
      playerName: playerName ?? this.playerName,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
