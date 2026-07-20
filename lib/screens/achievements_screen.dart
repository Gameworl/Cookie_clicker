import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/achievement_cubit.dart';
import '../cubit/achievement_state.dart';

/// Écran des succès (Bloc version).
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AchievementCubit, AchievementState>(
      builder: (context, state) {
        final achievements = state.achievements;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Succès (${state.unlockedCount}'
              '/${achievements.length})',
            ),
            centerTitle: true,
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final a = achievements[index];
              return Card(
                color: a.unlocked
                    ? Theme.of(context)
                        .colorScheme
                        .primaryContainer
                    : Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                child: InkWell(
                  onTap: () => _showDetail(
                    context,
                    a.name,
                    a.description,
                    a.unlocked,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          a.unlocked ? a.icon : Icons.lock,
                          size: 32,
                          color: a.unlocked
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                              : Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          a.unlocked ? a.name : '???',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                fontWeight: a.unlocked
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showDetail(
    BuildContext context,
    String name,
    String description,
    bool unlocked,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(unlocked ? name : '???'),
        content: Text(
          unlocked ? description : 'Succès verrouillé.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
