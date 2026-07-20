import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../cubit/cookie_cubit.dart';
import '../cubit/cookie_state.dart';
import '../models/upgrade.dart';

/// Écran de la boutique (Bloc version).
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  static final _fmt = NumberFormat('#,###', 'fr_FR');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CookieCubit, CookieState>(
      builder: (context, state) {
        final cubit = context.read<CookieCubit>();
        final prod = cubit.visibleProductionUpgrades;
        final bonus = cubit.visibleBonusUpgrades;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '${_fmt.format(state.cookies)} 🍪',
                    style:
                        Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${state.cookiesPerSecond} cookies/s '
                    '· ${state.cookiesPerClick} cookies/clic',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ExpansionTile(
                    title: const Text('🏭 Production'),
                    initiallyExpanded: true,
                    children: prod
                        .map((u) => _UpgradeCard(
                              upgrade: u,
                              canBuy: state.cookies >= u.cost,
                            ))
                        .toList(),
                  ),
                  ExpansionTile(
                    title: const Text('⚡ Bonus clic'),
                    initiallyExpanded: true,
                    children: bonus
                        .map((u) => _UpgradeCard(
                              upgrade: u,
                              canBuy: state.cookies >= u.cost,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  final Upgrade upgrade;
  final bool canBuy;

  const _UpgradeCard({
    required this.upgrade,
    required this.canBuy,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Card(
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
        child: ListTile(
          leading: Icon(upgrade.icon, size: 32),
          title: Text(upgrade.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Coût : ${upgrade.cost} 🍪'),
              if (upgrade.cookiesPerSecond > 0)
                Text(
                  '+${upgrade.cookiesPerSecond}/s par unité',
                ),
              if (upgrade.cookiesPerClickBonus > 0)
                Text(
                  '+${upgrade.cookiesPerClickBonus}/clic par unité',
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'x${upgrade.quantity}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: canBuy
                    ? () => context
                        .read<CookieCubit>()
                        .buyUpgrade(upgrade)
                    : null,
                child: const Text('Acheter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
