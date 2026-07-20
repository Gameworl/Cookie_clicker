import 'package:flutter/material.dart';

/// Catégorie d'une amélioration.
enum UpgradeCategory {
  /// Produit des cookies automatiquement (cookies/seconde).
  production,

  /// Augmente les cookies gagnés par clic.
  bonus,
}

/// Représente une amélioration achetable dans la boutique.
class Upgrade {
  /// Identifiant unique.
  final String id;

  /// Nom affiché dans la boutique.
  final String name;

  /// Description de l'amélioration.
  final String description;

  /// Coût en cookies pour acheter une unité.
  final int cost;

  /// Cookies produits par seconde par unité (production).
  final int cookiesPerSecond;

  /// Cookies ajoutés par clic par unité (bonus).
  final int cookiesPerClickBonus;

  /// Icône Material associée.
  final IconData icon;

  /// Catégorie de l'amélioration.
  final UpgradeCategory category;

  /// Nombre d'unités possédées.
  int quantity;

  Upgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    this.cookiesPerSecond = 0,
    this.cookiesPerClickBonus = 0,
    required this.icon,
    required this.category,
    this.quantity = 0,
  });
}

/// Liste des améliorations de production.
List<Upgrade> defaultProductionUpgrades() {
  return [
    Upgrade(
      id: 'cursor',
      name: 'Curseur',
      description: 'Un petit curseur qui clique tout seul.',
      cost: 10,
      cookiesPerSecond: 1,
      icon: Icons.mouse,
      category: UpgradeCategory.production,
    ),
    Upgrade(
      id: 'grandma',
      name: 'Grand-mère',
      description: 'Une gentille mamie qui fait des cookies.',
      cost: 50,
      cookiesPerSecond: 5,
      icon: Icons.elderly,
      category: UpgradeCategory.production,
    ),
    Upgrade(
      id: 'farm',
      name: 'Ferme',
      description: 'Cultive des cookies dans les champs.',
      cost: 200,
      cookiesPerSecond: 20,
      icon: Icons.agriculture,
      category: UpgradeCategory.production,
    ),
  ];
}

/// Liste des améliorations bonus (cookies par clic).
List<Upgrade> defaultBonusUpgrades() {
  return [
    Upgrade(
      id: 'better_click',
      name: 'Meilleur clic',
      description: 'Chaque clic rapporte 1 cookie de plus.',
      cost: 25,
      cookiesPerClickBonus: 1,
      icon: Icons.ads_click,
      category: UpgradeCategory.bonus,
    ),
    Upgrade(
      id: 'super_click',
      name: 'Super clic',
      description: 'Chaque clic rapporte 5 cookies de plus.',
      cost: 150,
      cookiesPerClickBonus: 5,
      icon: Icons.bolt,
      category: UpgradeCategory.bonus,
    ),
  ];
}

/// Toutes les améliorations par défaut.
List<Upgrade> defaultUpgrades() {
  return [
    ...defaultProductionUpgrades(),
    ...defaultBonusUpgrades(),
  ];
}
