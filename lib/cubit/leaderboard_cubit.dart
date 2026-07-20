import 'package:flutter_bloc/flutter_bloc.dart';

import '../screens/leaderboard_screen.dart';
import '../services/score_repository.dart';
import 'leaderboard_state.dart';

/// Cubit du classement.
///
/// Gère le chargement, le cache et les erreurs du
/// classement en utilisant un [ScoreRepository].
class LeaderboardCubit extends Cubit<LeaderboardState> {
  final ScoreRepository _repository;

  LeaderboardCubit(this._repository)
      : super(const LeaderboardState()) {
    fetchScores();
  }

  Future<void> fetchScores() async {
    emit(state.copyWith(
      loadingState: LoadingState.loading,
    ));
    try {
      final scores = await _repository.fetchLeaderboard();
      emit(state.copyWith(
        loadingState: LoadingState.loaded,
        scores: scores,
        isOffline: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        loadingState: state.scores.isEmpty
            ? LoadingState.error
            : LoadingState.loaded,
        errorMessage: e.toString(),
        isOffline: true,
      ));
    }
  }
}
