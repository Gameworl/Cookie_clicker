/// Modèle de sauvegarde sérialisable en JSON.
///
/// Centralise toutes les données à persister,
/// y compris les prestiges et achievements.
class GameSave {
  final int cookies;
  final int totalClicks;
  final int totalFromClicks;
  final int totalFromAuto;
  final Map<String, int> upgradeQuantities;
  final String playerName;
  final String? lastSavedAt;
  final int prestiges;
  final List<String> unlockedAchievements;

  const GameSave({
    this.cookies = 0,
    this.totalClicks = 0,
    this.totalFromClicks = 0,
    this.totalFromAuto = 0,
    this.upgradeQuantities = const {},
    this.playerName = 'Joueur',
    this.lastSavedAt,
    this.prestiges = 0,
    this.unlockedAchievements = const [],
  });

  factory GameSave.fromJson(Map<String, dynamic> json) {
    return GameSave(
      cookies: (json['cookies'] as int?) ?? 0,
      totalClicks: (json['totalClicks'] as int?) ?? 0,
      totalFromClicks:
          (json['totalFromClicks'] as int?) ?? 0,
      totalFromAuto: (json['totalFromAuto'] as int?) ?? 0,
      upgradeQuantities:
          (json['upgrades'] as Map<String, dynamic>?)
                  ?.map((k, v) => MapEntry(k, v as int)) ??
              {},
      playerName:
          (json['playerName'] as String?) ?? 'Joueur',
      lastSavedAt: json['lastSavedAt'] as String?,
      prestiges: (json['prestiges'] as int?) ?? 0,
      unlockedAchievements:
          (json['unlockedAchievements'] as List<dynamic>?)
                  ?.cast<String>() ??
              [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cookies': cookies,
      'totalClicks': totalClicks,
      'totalFromClicks': totalFromClicks,
      'totalFromAuto': totalFromAuto,
      'upgrades': upgradeQuantities,
      'playerName': playerName,
      'lastSavedAt': lastSavedAt,
      'prestiges': prestiges,
      'unlockedAchievements': unlockedAchievements,
    };
  }
}
