import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'cubit/achievement_cubit.dart';
import 'cubit/achievement_state.dart';
import 'cubit/cookie_cubit.dart';
import 'cubit/cookie_state.dart';
import 'cubit/leaderboard_cubit.dart';
import 'cubit/theme_cubit.dart';
import 'screens/achievements_screen.dart';
import 'screens/home_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/stats_screen.dart';
import 'services/api_score_repository.dart';
import 'services/score_repository.dart';

void main() {
  runApp(const CookieClickerApp());
}

/// Point d'entrée de l'application Clicky Cookie.
///
/// Utilise [MultiBlocProvider] pour fournir les 5 Cubits
/// (Cookie, Achievement, Theme, Leaderboard) et le
/// [ScoreRepository] à tout l'arbre de widgets.
class CookieClickerApp extends StatelessWidget {
  const CookieClickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CookieCubit()),
        BlocProvider(create: (_) => AchievementCubit()),
        BlocProvider(create: (_) => ThemeCubit()),
        Provider<ScoreRepository>(
          create: (_) => ApiScoreRepository(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (ctx) => LeaderboardCubit(
                  ctx.read<ScoreRepository>(),
                ),
              ),
            ],
            child: MaterialApp(
              title: 'Clicky Cookie',
              debugShowCheckedModeBanner: false,
              themeMode: themeMode,
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
                  bodyLarge: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
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
                  bodyLarge: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              home: const _AppRoot(),
            ),
          );
        },
      ),
    );
  }
}

/// Racine de l'app : gère splash → jeu.
class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(
        onStart: () => setState(() => _showSplash = false),
      );
    }
    return const _MainShell();
  }
}

/// Shell principal avec navigation, BlocListeners.
class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _currentIndex = 0;

  static const _pages = <Widget>[
    HomeScreen(),
    ShopScreen(),
    StatsScreen(),
    LeaderboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Vérifie les achievements à chaque changement
        BlocListener<CookieCubit, CookieState>(
          listener: (context, state) {
            context.read<AchievementCubit>().check(state);
          },
        ),
        // SnackBar quand un achievement est débloqué
        BlocListener<AchievementCubit, AchievementState>(
          listenWhen: (prev, curr) =>
              curr.lastUnlocked != null &&
              curr.lastUnlocked != prev.lastUnlocked,
          listener: (context, state) {
            if (state.lastUnlocked != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '🏆 Succès débloqué : '
                    '${state.lastUnlocked!.name}',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<CookieCubit, CookieState>(
        builder: (context, cookieState) {
          return Scaffold(
            appBar: AppBar(
              title: Text('${cookieState.playerName} 🍪'),
              centerTitle: true,
              actions: [
                if (cookieState.isSaving)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.emoji_events),
                  tooltip: 'Succès',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AchievementsScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.brightness_6),
                  tooltip: 'Changer le thème',
                  onPressed: () =>
                      context.read<ThemeCubit>().toggleTheme(),
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Paramètres',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) =>
                  setState(() => _currentIndex = i),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.cookie),
                  label: 'Jeu',
                ),
                NavigationDestination(
                  icon: Icon(Icons.store),
                  label: 'Boutique',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart),
                  label: 'Stats',
                ),
                NavigationDestination(
                  icon: Icon(Icons.leaderboard),
                  label: 'Classement',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
