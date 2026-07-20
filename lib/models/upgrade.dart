import 'dart:math';

import 'package:flutter/material.dart';

/// Catégorie d'une amélioration.
enum UpgradeCategory {
  production,
  bonus,
}

/// Représente une amélioration achetable dans la boutique.
///
/// Le coût augmente de 15% à chaque achat via la propriété
/// calculée [cost] (formule : `baseCost * 1.15^quantity`).
class Upgrade {
  final String id;
  final String name;
  final String description;
  final int baseCost;
  final int cookiesPerSecond;
  final int cookiesPerClickBonus;
  final IconData icon;
  final UpgradeCategory category;

  /// Seuil de cookies totaux pour que l'upgrade apparaisse.
  /// Si 0, toujours visible.
  final int unlockThreshold;

  int quantity;

  Upgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.baseCost,
    this.cookiesPerSecond = 0,
    this.cookiesPerClickBonus = 0,
    required this.icon,
    required this.category,
    this.unlockThreshold = 0,
    this.quantity = 0,
  });

  /// Coût actuel avec la formule exponentielle.
  int get cost => (baseCost * pow(1.15, quantity)).ceil();
}

/// Améliorations de production par défaut.
List<Upgrade> defaultProductionUpgrades() {
  return [
    Upgrade(
      id: 'cursor',
      name: 'Curseur',
      description: 'Un petit curseur qui clique tout seul.',
      baseCost: 10,
      cookiesPerSecond: 1,
      icon: Icons.mouse,
      category: UpgradeCategory.production,
    ),
    Upgrade(
      id: 'grandma',
      name: 'Grand-mère',
      description: 'Une gentille mamie qui fait des cookies.',
      baseCost: 50,
      cookiesPerSecond: 5,
      icon: Icons.elderly,
      category: UpgradeCategory.production,
    ),
    Upgrade(
      id: 'farm',
      name: 'Ferme',
      description: 'Cultive des cookies dans les champs.',
      baseCost: 200,
      cookiesPerSecond: 20,
      icon: Icons.agriculture,
      category: UpgradeCategory.production,
      unlockThreshold: 100,
    ),
    Upgrade(
      id: 'mine',
      name: 'Mine',
      description: 'Extrait des cookies sous terre.',
      baseCost: 1000,
      cookiesPerSecond: 100,
      icon: Icons.hardware,
      category: UpgradeCategory.production,
      unlockThreshold: 500,
    ),
    Upgrade(
      id: 'factory',
      name: 'Usine',
      description: 'Produit des cookies en masse.',
      baseCost: 5000,
      cookiesPerSecond: 500,
      icon: Icons.factory,
      category: UpgradeCategory.production,
      unlockThreshold: 2500,
    ),
    Upgrade(
      id: 'lab',
      name: 'Labo',
      description: 'Recherche de nouveaux types de cookies.',
      baseCost: 25000,
      cookiesPerSecond: 2500,
      icon: Icons.science,
      category: UpgradeCategory.production,
      unlockThreshold: 10000,
    ),
    Upgrade(
      id: 'portal',
      name: 'Portail',
      description: 'Importe des cookies d\'autres dimensions.',
      baseCost: 100000,
      cookiesPerSecond: 10000,
      icon: Icons.door_front_door,
      category: UpgradeCategory.production,
      unlockThreshold: 50000,
    ),
    Upgrade(
      id: 'time_machine',
      name: 'Machine temporelle',
      description: 'Récupère les cookies du passé et du futur.',
      baseCost: 500000,
      cookiesPerSecond: 50000,
      icon: Icons.access_time_filled,
      category: UpgradeCategory.production,
      unlockThreshold: 200000,
    ),
  ];
}

/// Améliorations bonus par défaut.
List<Upgrade> defaultBonusUpgrades() {
  return [
    Upgrade(
      id: 'better_click',
      name: 'Meilleur clic',
      description: 'Chaque clic rapporte 1 cookie de plus.',
      baseCost: 25,
      cookiesPerClickBonus: 1,
      icon: Icons.ads_click,
      category: UpgradeCategory.bonus,
    ),
    Upgrade(
      id: 'super_click',
      name: 'Super clic',
      description: 'Chaque clic rapporte 5 cookies de plus.',
      baseCost: 150,
      cookiesPerClickBonus: 5,
      icon: Icons.bolt,
      category: UpgradeCategory.bonus,
      unlockThreshold: 50,
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
