import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cookie_model.dart';
import 'models/theme_model.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CookieClickerApp());
}

/// Point d'entrée de l'application Clicky Cookie.
///
/// Utilise [MultiProvider] pour fournir le [CookieModel]
/// et le [ThemeModel] à tout l'arbre de widgets.
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
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
