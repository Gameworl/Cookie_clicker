import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cookie_model.dart';

/// Écran des statistiques du joueur.
///
/// Affiche le total de cookies, le nombre de clics,
/// la date du premier clic et le prochain palier.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CookieModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatCard(
            icon: Icons.cookie,
            title: 'Cookies actuels',
            value: model.formattedCookies,
          ),
          _StatCard(
            icon: Icons.touch_app,
            title: 'Clics total',
            value: '${model.totalClicks}',
          ),
          _StatCard(
            icon: Icons.mouse,
            title: 'Cookies par clic',
            value: '1',
          ),
          _StatCard(
            icon: Icons.access_time,
            title: 'Premier clic',
            value: model.firstClickAt != null
                ? _formatDateTime(model.firstClickAt!)
                : 'Aucun clic',
          ),
          _StatCard(
            icon: Icons.flag,
            title: 'Prochain palier',
            value: model.nextMilestone != null
                ? '${model.nextMilestone} cookies'
                : 'Tous atteints !',
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
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
