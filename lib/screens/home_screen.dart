import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cookie_model.dart';
import '../widgets/cookie_button.dart';
import '../widgets/cookie_counter.dart';

/// Page de jeu principale avec production automatique,
/// frenzy x2 et gestion du cycle de vie.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  static const _bonusAmount = 10;
  static const _bonusCooldownSeconds = 30;
  int _cooldownRemaining = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final model = context.read<CookieModel>();
    if (state == AppLifecycleState.paused) {
      model.onPause();
    } else if (state == AppLifecycleState.resumed) {
      final gained = model.onResume();
      if (gained != null && gained > 0 && mounted) {
        showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Bon retour !'),
            content: Text(
              'Pendant ton absence, tu as gagné '
              '$gained cookies !',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Super !'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _onCookieClick() {
    final milestone =
        context.read<CookieModel>().clickCookie();
    if (milestone != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 Bravo ! $milestone cookies atteints !',
          ),
        ),
      );
    }
  }

  void _onBonusClick() {
    if (_cooldownRemaining > 0) return;
    context.read<CookieModel>().addCookies(_bonusAmount);
    setState(() {
      _cooldownRemaining = _bonusCooldownSeconds;
    });
    _cooldownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        setState(() {
          _cooldownRemaining--;
        });
        if (_cooldownRemaining <= 0) {
          _cooldownTimer?.cancel();
        }
      },
    );
  }

  void _showPrestigeDialog(CookieModel model) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🌟 Prestige'),
        content: Text(
          'Tu vas remettre tes cookies et upgrades à zéro.\n\n'
          'En échange, ton multiplicateur passera de '
          'x${model.prestigeMultiplier.toStringAsFixed(1)} '
          'à x${(model.prestigeMultiplier + 0.1).toStringAsFixed(1)}.\n\n'
          'Ce bonus s\'applique à tous tes gains.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              model.prestige();
              Navigator.pop(context);
            },
            child: const Text('Prestige !'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CookieModel>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              const CookieCounter(),
              const SizedBox(height: 4),
              // CPS avec AnimatedSwitcher
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  '${model.cookiesPerSecond} cookies/s '
                  '· ${model.cookiesPerClick} cookies/clic',
                  key: ValueKey(
                    '${model.cookiesPerSecond}_${model.cookiesPerClick}',
                  ),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        color: model.frenzyActive
                            ? Colors.orange
                            : Colors.grey,
                      ),
                ),
              ),
              if (model.frenzyActive) ...[
                const SizedBox(height: 4),
                Text(
                  '⚡ FRENZY x2 (${model.frenzyRemaining}s)',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 64,
                  ),
                  child: LinearProgressIndicator(
                    value: model.frenzyRemaining /
                        CookieModel.frenzyDuration,
                    color: Colors.orange,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              CookieButton(onTap: _onCookieClick),
              const SizedBox(height: 20),
              // Boutons d'action
              Wrap(
                spacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: _cooldownRemaining > 0
                        ? null
                        : _onBonusClick,
                    icon: const Icon(Icons.card_giftcard),
                    label: Text(
                      _cooldownRemaining > 0
                          ? 'Bonus (${_cooldownRemaining}s)'
                          : 'Bonus +$_bonusAmount',
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: model.frenzyActive ||
                            model.frenzyCooldownRemaining > 0
                        ? null
                        : () => model.activateFrenzy(),
                    icon: const Icon(Icons.bolt),
                    label: Text(
                      model.frenzyCooldownRemaining > 0
                          ? 'Frenzy (${model.frenzyCooldownRemaining}s)'
                          : 'Frenzy x2',
                    ),
                  ),
                ],
              ),
              // Prestige
              if (model.canPrestige) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _showPrestigeDialog(model),
                  icon: const Icon(Icons.star),
                  label: Text(
                    'Prestige (x${model.prestigeMultiplier.toStringAsFixed(1)}'
                    ' → x${(model.prestigeMultiplier + 0.1).toStringAsFixed(1)})',
                  ),
                ),
              ],
              if (model.prestiges > 0) ...[
                const SizedBox(height: 4),
                Text(
                  'Multiplicateur : x${model.prestigeMultiplier.toStringAsFixed(1)}'
                  ' (${model.prestiges} prestiges)',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.purple),
                ),
              ],
              const SizedBox(height: 16),
              // Journal des dernières actions
              if (model.log.isNotEmpty)
                ExpansionTile(
                  title: const Text('📋 Journal'),
                  children: model.log
                      .take(10)
                      .map(
                        (e) => ListTile(
                          dense: true,
                          title: Text(e.message),
                          trailing: Text(
                            '${e.time.hour}:'
                            '${e.time.minute.toString().padLeft(2, '0')}:'
                            '${e.time.second.toString().padLeft(2, '0')}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall,
                          ),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
