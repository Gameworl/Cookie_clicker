import '../models/score.dart';
import '../screens/leaderboard_screen.dart';

/// État immutable du classement.
class LeaderboardState {
  final LoadingState loadingState;
  final List<Score> scores;
  final String errorMessage;
  final bool isOffline;

  const LeaderboardState({
    this.loadingState = LoadingState.initial,
    this.scores = const [],
    this.errorMessage = '',
    this.isOffline = false,
  });

  LeaderboardState copyWith({
    LoadingState? loadingState,
    List<Score>? scores,
    String? errorMessage,
    bool? isOffline,
  }) {
    return LeaderboardState(
      loadingState: loadingState ?? this.loadingState,
      scores: scores ?? this.scores,
      errorMessage: errorMessage ?? this.errorMessage,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}
