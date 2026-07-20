import 'package:flutter/material.dart';

/// Écran "À propos" avec les règles du jeu.
///
/// Présente le fonctionnement du jeu dans des [Card]
/// avec des sections claires.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _RuleCard(
            icon: Icons.cookie,
            title: 'Le but du jeu',
            description:
                'Clique sur le cookie pour gagner des cookies ! '
                'Plus tu en as, plus tu peux acheter '
                "d'améliorations.",
          ),
          _RuleCard(
            icon: Icons.touch_app,
            title: 'Comment jouer',
            description:
                'Appuie sur le gros cookie au centre de '
                "l'écran. Chaque clic te donne un cookie.",
          ),
          _RuleCard(
            icon: Icons.card_giftcard,
            title: 'Bonus',
            description:
                'Utilise le bouton Bonus pour gagner 10 '
                'cookies d\'un coup ! Attention, il a un '
                'temps de recharge de 30 secondes.',
          ),
          _RuleCard(
            icon: Icons.emoji_events,
            title: 'Paliers',
            description:
                'Des paliers existent à 100, 500, 1 000, '
                '5 000 et 10 000 cookies. Un message '
                "s'affiche quand tu les atteins !",
          ),
          _RuleCard(
            icon: Icons.restart_alt,
            title: 'Recommencer',
            description:
                'Tu peux recommencer une partie à tout '
                "moment via le bouton dans l'AppBar.",
          ),
        ],
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _RuleCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
