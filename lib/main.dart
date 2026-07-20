import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cookie_model.dart';
import 'models/theme_model.dart';
import 'screens/about_screen.dart';
import 'screens/home_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/stats_screen.dart';

void main() {
  runApp(const CookieClickerApp());
}

/// Point d'entrée de l'application Clicky Cookie.
///
/// Utilise [MultiProvider] pour fournir les modèles
/// et un [BottomNavigationBar] pour la navigation.
class CookieClickerApp extends StatelessWidget {
  const CookieClickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CookieModel()),
        ChangeNotifierProvider(create: (_) => ThemeModel()),
      ],
      child: Consumer<ThemeModel>(
        builder: (context, themeModel, _) {
          return MaterialApp(
            title: 'Clicky Cookie',
            debugShowCheckedModeBanner: false,
            themeMode: themeModel.themeMode,
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
            home: const MainShell(),
          );
        },
      ),
    );
  }
}

/// Shell principal avec [BottomNavigationBar] et [IndexedStack].
///
/// Gère la navigation entre les 3 onglets (Jeu, Boutique,
/// Stats) en conservant l'état de chaque page.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _pages = [
    HomeScreen(),
    ShopScreen(),
    StatsScreen(),
  ];

  void _showResetDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Recommencer ?'),
        content: const Text(
          'Tu vas perdre tous tes cookies et '
          'tes améliorations.',
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
            icon: const Icon(Icons.info_outline),
            tooltip: 'À propos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AboutScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Recommencer',
            onPressed: _showResetDialog,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.cookie),
            label: 'Jeu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Boutique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
