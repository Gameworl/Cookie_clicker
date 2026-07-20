import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const CookieClickerApp());
}

/// Point d'entrée de l'application Clicky Cookie.
///
/// Gère le thème (clair/sombre) via un [StatefulWidget]
/// qui maintient le [ThemeMode] courant.
class CookieClickerApp extends StatefulWidget {
  const CookieClickerApp({super.key});

  @override
  State<CookieClickerApp> createState() => _CookieClickerAppState();
}

class _CookieClickerAppState extends State<CookieClickerApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clicky Cookie',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
      home: HomeScreen(onToggleTheme: _toggleTheme),
    );
  }
}

/// Écran principal du jeu.
///
/// Affiche le compteur de cookies avec formatage intelligent
/// (singulier/pluriel, séparateurs de milliers), un bouton
/// cookie avec effet ripple, des paliers avec feedback
/// et un bouton reset avec confirmation.
class HomeScreen extends StatefulWidget {
  /// Callback pour basculer entre thème clair et sombre.
  final VoidCallback onToggleTheme;

  const HomeScreen({super.key, required this.onToggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _cookies = 0;

  /// Paliers qui déclenchent un feedback visuel.
  static const _milestones = [100, 500, 1000, 5000, 10000];

  /// Formatte le nombre de cookies avec séparateurs de milliers.
  final _numberFormat = NumberFormat('#,###', 'fr_FR');

  /// Texte du compteur avec gestion singulier/pluriel.
  String get _cookieText {
    final formatted = _cookies == 0
        ? '0'
        : _numberFormat.format(_cookies);
    return _cookies == 1
        ? '$formatted cookie'
        : '$formatted cookies';
  }

  /// Couleur du compteur selon le palier atteint.
  Color _counterColor(BuildContext context) {
    if (_cookies >= 10000) return Colors.purple;
    if (_cookies >= 5000) return Colors.red;
    if (_cookies >= 1000) return Colors.orange;
    if (_cookies >= 500) return Colors.blue;
    if (_cookies >= 100) return Colors.green;
    return Theme.of(context).colorScheme.onSurface;
  }

  void _clickCookie() {
    final before = _cookies;
    setState(() {
      _cookies++;
    });
    _checkMilestone(before, _cookies);
  }

  /// Vérifie si un palier a été franchi et affiche un [SnackBar].
  void _checkMilestone(int before, int after) {
    for (final milestone in _milestones) {
      if (before < milestone && after >= milestone) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🎉 Bravo ! $milestone cookies atteints !',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        break;
      }
    }
  }

  /// Affiche un dialog de confirmation avant de reset.
  void _showResetDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recommencer ?'),
        content: const Text(
          'Tu vas perdre tous tes cookies. '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _cookies = 0;
              });
              Navigator.pop(context);
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clicky Cookie 🍪'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Changer le thème',
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Recommencer',
            onPressed: _showResetDialog,
          ),
        ],
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
              // Compteur animé
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _cookieText,
                  key: ValueKey<int>(_cookies),
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(color: _counterColor(context)),
                ),
              ),
              const SizedBox(height: 32),
              // Cookie cliquable avec taille responsive
              LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.maxWidth < 400
                      ? 100.0
                      : 140.0;
                  return Tooltip(
                    message: 'Clique pour gagner un cookie',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _clickCookie,
                        borderRadius: BorderRadius.circular(
                          size,
                        ),
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.brown.withAlpha(
                                  60,
                                ),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '🍪',
                              style: TextStyle(fontSize: size * 0.8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Clique sur le cookie !',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
