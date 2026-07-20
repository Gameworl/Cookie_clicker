import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cookie_model.dart';
import '../widgets/upgrade_card.dart';

/// Écran de la boutique d'améliorations.
///
/// Affiche les upgrades en deux catégories (Production et
/// Bonus) avec tri et filtre. Utilise des [ExpansionTile]
/// pour les catégories.
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CookieModel>();

    return Column(
      children: [
        // En-tête avec cookies et CPS
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                model.formattedCookies,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '${model.cookiesPerSecond} cookies/s '
                '· ${model.cookiesPerClick} cookies/clic',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
        // Barre de tri et filtre
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text('Trier par : '),
              const SizedBox(width: 8),
              DropdownButton<SortCriteria>(
                value: model.sortCriteria,
                onChanged: (v) {
                  if (v != null) model.setSortCriteria(v);
                },
                items: const [
                  DropdownMenuItem(
                    value: SortCriteria.price,
                    child: Text('Prix'),
                  ),
                  DropdownMenuItem(
                    value: SortCriteria.cps,
                    child: Text('CPS'),
                  ),
                  DropdownMenuItem(
                    value: SortCriteria.quantity,
                    child: Text('Quantité'),
                  ),
                ],
              ),
              const Spacer(),
              FilterChip(
                label: const Text('Achetable'),
                selected: model.showOnlyAffordable,
                onSelected: (_) =>
                    model.toggleAffordableFilter(),
              ),
            ],
          ),
        ),
        // Liste des upgrades par catégorie
        Expanded(
          child: ListView(
            children: [
              ExpansionTile(
                title: const Text('🏭 Production'),
                initiallyExpanded: true,
                children: model.productionUpgrades
                    .map((u) => UpgradeCard(upgrade: u))
                    .toList(),
              ),
              ExpansionTile(
                title: const Text('⚡ Bonus clic'),
                initiallyExpanded: true,
                children: model.bonusUpgrades
                    .map((u) => UpgradeCard(upgrade: u))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
