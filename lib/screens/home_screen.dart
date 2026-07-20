import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cookie_cubit.dart';
import '../cubit/cookie_state.dart';
import '../widgets/cookie_button.dart';
import '../widgets/cookie_counter.dart';

/// Page de jeu principale (Bloc version).
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

  void _onCookieClick() {
    context.read<CookieCubit>().clickCookie();
  }

  void _onBonusClick() {
    if (_cooldownRemaining > 0) return;
    context.read<CookieCubit>().addCookies(_bonusAmount);
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

  void _showPrestigeDialog(CookieState state) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🌟 Prestige'),
        content: Text(
          'Tu vas remettre tes cookies et upgrades à zéro.\n\n'
          'En échange, ton multiplicateur passera de '
          'x${state.prestigeMultiplier.toStringAsFixed(1)} '
          'à x${(state.prestigeMultiplier + 0.1).toStringAsFixed(1)}.\n\n'
          'Ce bonus s\'applique à tous tes gains.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              context.read<CookieCubit>().prestige();
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
    return BlocBuilder<CookieCubit, CookieState>(
      builder: (context, state) {
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
                  AnimatedSwitcher(
                    duration: const Duration(
                      milliseconds: 300,
                    ),
                    child: Text(
                      '${state.cookiesPerSecond} cookies/s '
                      '· ${state.cookiesPerClick} cookies/clic',
                      key: ValueKey(
                        '${state.cookiesPerSecond}_${state.cookiesPerClick}',
                      ),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: state.frenzyActive
                                ? Colors.orange
                                : Colors.grey,
                          ),
                    ),
                  ),
                  if (state.frenzyActive) ...[
                    const SizedBox(height: 4),
                    Text(
                      '⚡ FRENZY x2 (${state.frenzyRemaining}s)',
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
                        value: state.frenzyRemaining / 30,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  CookieButton(onTap: _onCookieClick),
                  const SizedBox(height: 20),
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
                        onPressed: state.frenzyActive ||
                                state.frenzyCooldownRemaining >
                                    0
                            ? null
                            : () => context
                                .read<CookieCubit>()
                                .activateFrenzy(),
                        icon: const Icon(Icons.bolt),
                        label: Text(
                          state.frenzyCooldownRemaining > 0
                              ? 'Frenzy (${state.frenzyCooldownRemaining}s)'
                              : 'Frenzy x2',
                        ),
                      ),
                    ],
                  ),
                  if (state.canPrestige) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () =>
                          _showPrestigeDialog(state),
                      icon: const Icon(Icons.star),
                      label: Text(
                        'Prestige (x${state.prestigeMultiplier.toStringAsFixed(1)}'
                        ' → x${(state.prestigeMultiplier + 0.1).toStringAsFixed(1)})',
                      ),
                    ),
                  ],
                  if (state.prestiges > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'x${state.prestigeMultiplier.toStringAsFixed(1)}'
                      ' (${state.prestiges} prestiges)',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.purple),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
