/// Modèle de sauvegarde sérialisable en JSON.
///
/// Centralise toutes les données à persister.
class GameSave {
  final int cookies;
  final int totalClicks;
  final int totalFromClicks;
  final int totalFromAuto;
  final Map<String, int> upgradeQuantities;
  final String playerName;
  final String? lastSavedAt;

  const GameSave({
    this.cookies = 0,
    this.totalClicks = 0,
    this.totalFromClicks = 0,
    this.totalFromAuto = 0,
    this.upgradeQuantities = const {},
    this.playerName = 'Joueur',
    this.lastSavedAt,
  });

  /// Crée un [GameSave] depuis un objet JSON.
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
    );
  }

  /// Convertit en objet JSON.
  Map<String, dynamic> toJson() {
    return {
      'cookies': cookies,
      'totalClicks': totalClicks,
      'totalFromClicks': totalFromClicks,
      'totalFromAuto': totalFromAuto,
      'upgrades': upgradeQuantities,
      'playerName': playerName,
      'lastSavedAt': lastSavedAt,
    };
  }
}
