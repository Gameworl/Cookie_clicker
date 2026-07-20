import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cookie_model.dart';
import '../models/theme_model.dart';
import '../widgets/cookie_button.dart';
import '../widgets/cookie_counter.dart';
import 'about_screen.dart';
import 'stats_screen.dart';

/// Écran principal du jeu.
///
/// Affiche le compteur, le cookie cliquable, le bouton bonus
/// avec cooldown, et un [Drawer] pour la navigation.
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

  void _showResetDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Recommencer ?'),
        content: const Text(
          'Tu vas perdre tous tes cookies. '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              context.read<CookieModel>().reset();
              Navigator.pop(ctx);
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CookieModel>();
    final nextMilestone = model.nextMilestone;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clicky Cookie 🍪'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Changer le thème',
            onPressed: () =>
                context.read<ThemeModel>().toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Recommencer',
            onPressed: _showResetDialog,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    '🍪',
                    style: TextStyle(fontSize: 48),
                  ),
                  Text(
                    'Clicky Cookie',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Statistiques'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StatsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('À propos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AboutScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: const Text('Mode sombre'),
              value: context.watch<ThemeModel>().themeMode ==
                  ThemeMode.dark,
              onChanged: (_) =>
                  context.read<ThemeModel>().toggleTheme(),
            ),
          ],
        ),
      ),
      body: Container(
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
              Text(
                'Bienvenue dans Clicky Cookie !',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              const CookieCounter(),
              if (nextMilestone != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Prochain palier : $nextMilestone',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ],
              const SizedBox(height: 32),
              CookieButton(onTap: _onCookieClick),
              const SizedBox(height: 16),
              Text(
                'Clique sur le cookie !',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed:
                    _cooldownRemaining > 0
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
      ),
    );
  }
}
