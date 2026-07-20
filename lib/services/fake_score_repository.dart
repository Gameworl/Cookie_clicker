import '../models/score.dart';
import 'score_repository.dart';

/// Implémentation en mémoire pour les tests.
class FakeScoreRepository implements ScoreRepository {
  final List<Score> _scores = [
    const Score(name: 'Alice', cookies: 9999),
    const Score(name: 'Bob', cookies: 5432),
    const Score(name: 'Charlie', cookies: 2100),
    const Score(name: 'Diana', cookies: 1500),
    const Score(name: 'Eve', cookies: 800),
  ];

  @override
  Future<List<Score>> fetchLeaderboard() async {
    await Future<void>.delayed(
      const Duration(milliseconds: 200),
    );
    return List.of(_scores)
      ..sort((a, b) => b.cookies.compareTo(a.cookies));
  }

  @override
  Future<void> submitScore(Score score) async {
    await Future<void>.delayed(
      const Duration(milliseconds: 200),
    );
    _scores.add(score);
  }
}
