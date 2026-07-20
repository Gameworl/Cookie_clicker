import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cookie_model.dart';
import '../models/upgrade.dart';

/// Carte d'une amélioration dans la boutique.
///
/// Affiche l'icône, le nom, le prix, la progression vers
/// l'achat et un bouton d'achat. Change de couleur selon
/// si le joueur peut acheter ou non.
class UpgradeCard extends StatelessWidget {
  final Upgrade upgrade;

  const UpgradeCard({super.key, required this.upgrade});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CookieModel>();
    final canBuy = model.cookies >= upgrade.cost;
    final progress = (model.cookies / upgrade.cost.toDouble()).clamp(
      0.0,
      1.0,
    );

    final totalCps =
        upgrade.cookiesPerSecond * upgrade.quantity;
    final totalCpc =
        upgrade.cookiesPerClickBonus * upgrade.quantity;
    final cost = upgrade.cost;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      color: canBuy
          ? Theme.of(context)
              .colorScheme
              .primaryContainer
              .withAlpha(80)
          : null,
      child: Column(
        children: [
          ListTile(
            leading: Icon(upgrade.icon, size: 32),
            title: Text(upgrade.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coût : $cost 🍪',
                ),
                if (upgrade.cookiesPerSecond > 0)
                  Text(
                    '+${upgrade.cookiesPerSecond}/s par unité'
                    ' (total : +$totalCps/s)',
                  ),
                if (upgrade.cookiesPerClickBonus > 0)
                  Text(
                    '+${upgrade.cookiesPerClickBonus}/clic par unité'
                    ' (total : +$totalCpc/clic)',
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'x${upgrade.quantity}',
                  style:
                      Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: canBuy
                      ? () => _buy(context, model)
                      : null,
                  child: const Text('Acheter'),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Détails',
                  onPressed: () => _showDetails(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: LinearProgressIndicator(value: progress),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _buy(BuildContext context, CookieModel model) {
    final success = model.buyUpgrade(upgrade);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '✅ ${upgrade.name} acheté !'
              : '❌ Il te manque '
                  '${upgrade.cost - model.cookies} cookies.',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(upgrade.icon, size: 40),
                const SizedBox(width: 12),
                Text(
                  upgrade.name,
                  style:
                      Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(upgrade.description),
            const Divider(height: 24),
            Text('Coût : ${upgrade.cost} cookies (base : ${upgrade.baseCost})'),
            if (upgrade.cookiesPerSecond > 0)
              Text(
                'Production : +${upgrade.cookiesPerSecond} '
                'cookies/seconde par unité',
              ),
            if (upgrade.cookiesPerClickBonus > 0)
              Text(
                'Bonus clic : +${upgrade.cookiesPerClickBonus} '
                'cookies/clic par unité',
              ),
            Text('Possédés : ${upgrade.quantity}'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
