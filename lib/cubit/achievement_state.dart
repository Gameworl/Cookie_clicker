import '../models/achievement.dart';

/// État immutable des achievements.
class AchievementState {
  final List<Achievement> achievements;
  final Achievement? lastUnlocked;

  const AchievementState({
    this.achievements = const [],
    this.lastUnlocked,
  });

  int get unlockedCount =>
      achievements.where((a) => a.unlocked).length;

  AchievementState copyWith({
    List<Achievement>? achievements,
    Achievement? lastUnlocked,
  }) {
    return AchievementState(
      achievements: achievements ?? this.achievements,
      lastUnlocked: lastUnlocked ?? this.lastUnlocked,
    );
  }
}
