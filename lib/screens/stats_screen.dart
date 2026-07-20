import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/achievement_cubit.dart';
import '../cubit/cookie_cubit.dart';
import '../cubit/cookie_state.dart';

/// Écran des statistiques (Bloc version).
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CookieCubit, CookieState>(
      builder: (context, state) {
        final total = state.totalFromClicks + state.totalFromAuto;
        final clickRatio = total > 0
            ? (state.totalFromClicks / total * 100)
                .toStringAsFixed(1)
            : '0.0';
        final autoRatio = total > 0
            ? (state.totalFromAuto / total * 100)
                .toStringAsFixed(1)
            : '0.0';
        final achState =
            context.watch<AchievementCubit>().state;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StatCard(
              icon: Icons.cookie,
              title: 'Cookies actuels',
              value: '${state.cookies}',
            ),
            _StatCard(
              icon: Icons.touch_app,
              title: 'Clics total',
              value: '${state.totalClicks}',
            ),
            _StatCard(
              icon: Icons.ads_click,
              title: 'Cookies par clic',
              value: '${state.cookiesPerClick}',
            ),
            _StatCard(
              icon: Icons.speed,
              title: 'Cookies par seconde',
              value: '${state.cookiesPerSecond}',
            ),
            const Divider(),
            _StatCard(
              icon: Icons.mouse,
              title: 'Total produit par clic',
              value: '${state.totalFromClicks} ($clickRatio%)',
            ),
            _StatCard(
              icon: Icons.autorenew,
              title: 'Total produit auto',
              value: '${state.totalFromAuto} ($autoRatio%)',
            ),
            const Divider(),
            _StatCard(
              icon: Icons.star,
              title: 'Prestiges',
              value: '${state.prestiges}',
            ),
            _StatCard(
              icon: Icons.auto_awesome,
              title: 'Multiplicateur',
              value:
                  'x${state.prestigeMultiplier.toStringAsFixed(1)}',
            ),
            _StatCard(
              icon: Icons.emoji_events,
              title: 'Succès débloqués',
              value: '${achState.unlockedCount}'
                  '/${achState.achievements.length}',
            ),
            _StatCard(
              icon: Icons.shopping_cart,
              title: 'Upgrades possédés',
              value:
                  '${state.upgrades.fold<int>(0, (s, u) => s + u.quantity)}',
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
