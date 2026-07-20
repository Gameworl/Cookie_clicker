import 'package:flutter/material.dart';

/// Représente un succès/achievement débloquable.
class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  bool unlocked;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.unlocked = false,
  });
}

/// Crée la liste des achievements par défaut.
///
/// Les conditions sont vérifiées dans le modèle,
/// pas dans l'achievement lui-même.
List<Achievement> defaultAchievements() {
  return [
    Achievement(
      id: 'first_click',
      name: 'Premier pas',
      description: 'Clique pour la première fois.',
      icon: Icons.touch_app,
    ),
    Achievement(
      id: 'cookies_100',
      name: 'Centenaire',
      description: 'Atteins 100 cookies.',
      icon: Icons.looks_one,
    ),
    Achievement(
      id: 'cookies_1000',
      name: 'Millionnaire',
      description: 'Atteins 1 000 cookies.',
      icon: Icons.star,
    ),
    Achievement(
      id: 'cookies_10000',
      name: 'Magnat',
      description: 'Atteins 10 000 cookies.',
      icon: Icons.emoji_events,
    ),
    Achievement(
      id: 'clicks_100',
      name: 'Cliqueur fou',
      description: 'Effectue 100 clics.',
      icon: Icons.speed,
    ),
    Achievement(
      id: 'clicks_1000',
      name: 'Cliqueur légendaire',
      description: 'Effectue 1 000 clics.',
      icon: Icons.flash_on,
    ),
    Achievement(
      id: 'first_buy',
      name: 'Premier achat',
      description: 'Achète ta première amélioration.',
      icon: Icons.shopping_cart,
    ),
    Achievement(
      id: 'collector',
      name: 'Collectionneur',
      description: 'Possède 1 de chaque upgrade production.',
      icon: Icons.collections,
    ),
    Achievement(
      id: 'cps_10',
      name: 'Automatisé',
      description: 'Atteins 10 cookies/seconde.',
      icon: Icons.autorenew,
    ),
    Achievement(
      id: 'cps_100',
      name: 'Industriel',
      description: 'Atteins 100 cookies/seconde.',
      icon: Icons.factory,
    ),
    Achievement(
      id: 'first_prestige',
      name: 'Première renaissance',
      description: 'Effectue ton premier prestige.',
      icon: Icons.refresh,
    ),
    Achievement(
      id: 'prestige_3',
      name: 'Vétéran',
      description: 'Effectue 3 prestiges.',
      icon: Icons.military_tech,
    ),
    Achievement(
      id: 'frenzy_used',
      name: 'Frénétique',
      description: 'Utilise le Frenzy x2.',
      icon: Icons.bolt,
    ),
    Achievement(
      id: 'bonus_used',
      name: 'Chanceux',
      description: 'Utilise le bonus gratuit.',
      icon: Icons.card_giftcard,
    ),
    Achievement(
      id: 'name_set',
      name: 'Identifié',
      description: 'Change ton pseudo.',
      icon: Icons.person,
    ),
  ];
}
