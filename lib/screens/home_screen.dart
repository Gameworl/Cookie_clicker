import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cookie_model.dart';
import '../widgets/cookie_button.dart';
import '../widgets/cookie_counter.dart';

/// Page de jeu principale (contenu sans Scaffold).
///
/// Affiche le compteur, le cookie cliquable, le CPS
/// et le bouton bonus avec cooldown.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _bonusAmount = 10;
  static const _bonusCooldownSeconds = 30;

  int _cooldownRemaining = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CookieCounter(),
            const SizedBox(height: 4),
            Text(
              '${model.cookiesPerSecond} cookies/s '
              '· ${model.cookiesPerClick} cookies/clic',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
            if (model.nextMilestone != null) ...[
              const SizedBox(height: 4),
              Text(
                'Prochain palier : ${model.nextMilestone}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
            ],
            const SizedBox(height: 32),
            CookieButton(onTap: _onCookieClick),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _cooldownRemaining > 0
                  ? null
                  : _onBonusClick,
              icon: const Icon(Icons.card_giftcard),
              label: Text(
                _cooldownRemaining > 0
                    ? 'Bonus (${_cooldownRemaining}s)'
                    : 'Bonus +$_bonusAmount 🍪',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
