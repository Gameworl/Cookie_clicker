import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cookie_model.dart';

/// Écran des statistiques enrichi.
///
/// Affiche les stats détaillées : total clic vs auto,
/// ratio, CPS, cookies par clic, etc.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CookieModel>();
    final total = model.totalFromClicks + model.totalFromAuto;
    final clickRatio =
        total > 0
            ? (model.totalFromClicks / total * 100)
                .toStringAsFixed(1)
            : '0.0';
    final autoRatio =
        total > 0
            ? (model.totalFromAuto / total * 100)
                .toStringAsFixed(1)
            : '0.0';

    return ListView(
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
          icon: Icons.ads_click,
          title: 'Cookies par clic',
          value: '${model.cookiesPerClick}',
        ),
        _StatCard(
          icon: Icons.speed,
          title: 'Cookies par seconde',
          value: '${model.cookiesPerSecond}',
        ),
        const Divider(),
        _StatCard(
          icon: Icons.mouse,
          title: 'Total produit par clic',
          value: '${model.totalFromClicks} ($clickRatio%)',
        ),
        _StatCard(
          icon: Icons.autorenew,
          title: 'Total produit auto',
          value: '${model.totalFromAuto} ($autoRatio%)',
        ),
        const Divider(),
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
        _StatCard(
          icon: Icons.shopping_cart,
          title: 'Upgrades possédés',
          value: '${model.upgrades.fold<int>(0, (s, u) => s + u.quantity)}',
        ),
        if (model.frenzyActive)
          _StatCard(
            icon: Icons.bolt,
            title: 'Frenzy actif',
            value: '${model.frenzyRemaining}s restantes',
          ),
      ],
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
