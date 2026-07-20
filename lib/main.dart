import 'package:flutter/material.dart';

void main() {
  runApp(const CookieClickerApp());
}

/// Point d'entrée de l'application Clicky Cookie.
class CookieClickerApp extends StatelessWidget {
  const CookieClickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clicky Cookie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
          brightness: Brightness.light,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

/// Écran principal du jeu.
///
/// Affiche le compteur de cookies et un bouton cliquable
/// pour en gagner. Utilise [setState] pour mettre à jour
/// l'interface à chaque clic.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _cookies = 0;

  void _clickCookie() {
    setState(() {
      _cookies++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clicky Cookie 🍪'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_cookies cookies',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _clickCookie,
              child: const Text(
                '🍪',
                style: TextStyle(fontSize: 120),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Clique sur le cookie !',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
