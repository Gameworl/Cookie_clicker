import '../models/score.dart';

/// Interface abstraite pour le stockage des scores.
///
/// Permet de découpler le classement de l'implémentation
/// concrète (API HTTP, local, mock...).
abstract class ScoreRepository {
  /// Récupère la liste des scores.
  Future<List<Score>> fetchLeaderboard();

  /// Envoie un score au serveur.
  Future<void> submitScore(Score score);
}
