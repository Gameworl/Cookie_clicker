# 🍪 Clicky Cookie — Projet Fil Rouge Flutter

Jeu incrémental (cookie clicker) développé en Flutter sur 8 semaines.
Chaque semaine introduit de nouvelles notions Flutter/Dart, de la gestion
d'état au réseau en passant par les animations et les tests.

## Lancement

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```

## Architecture (semaine 8)

```
lib/
├── cubit/          # Cubits et états immutables
│   ├── cookie_cubit.dart
│   ├── cookie_state.dart
│   ├── achievement_cubit.dart
│   ├── achievement_state.dart
│   ├── theme_cubit.dart
│   ├── leaderboard_cubit.dart
│   └── leaderboard_state.dart
├── models/         # Modèles de données
│   ├── achievement.dart
│   ├── game_save.dart
│   ├── score.dart
│   └── upgrade.dart
├── screens/        # Écrans de l'application
│   ├── achievements_screen.dart
│   ├── home_screen.dart
│   ├── leaderboard_screen.dart
│   ├── settings_screen.dart
│   ├── shop_screen.dart
│   ├── splash_screen.dart
│   └── stats_screen.dart
├── services/       # Couche d'accès aux données
│   ├── score_repository.dart
│   ├── api_score_repository.dart
│   └── fake_score_repository.dart
├── widgets/        # Widgets réutilisables
│   ├── cookie_button.dart
│   └── cookie_counter.dart
└── main.dart       # Point d'entrée, MultiBlocProvider
```

## Roadmap détaillé (8 semaines × ~3h45 = 30h)

### Semaine 1 — Le clic de base
- `StatefulWidget`, `setState`
- `ThemeData`, `ColorScheme.fromSeed`, dark mode
- `InkWell` avec `BoxDecoration` circulaire et ombre
- `NumberFormat` (intl) pour séparateurs de milliers, singulier/pluriel
- `AnimatedSwitcher` sur le compteur
- Paliers avec `SnackBar` (100, 500, 1 000, 5 000, 10 000)
- Bouton reset avec `AlertDialog` de confirmation
- Taille responsive du cookie avec `LayoutBuilder`

### Semaine 2 — Passage à Provider
- `ChangeNotifier`, `Provider`, `MultiProvider`
- `CookieModel` enrichi (totalClicks, firstClickAt, formattedCookies)
- `ThemeModel` pour le dark mode
- Écran Statistiques et écran À propos
- `Drawer` avec navigation et switch thème
- Widgets extraits : `CookieButton`, `CookieCounter`
- Bouton Bonus +10 cookies avec cooldown 30s

### Semaine 3 — La boutique d'améliorations
- `BottomNavigationBar` + `IndexedStack` (Jeu, Boutique, Stats)
- Modèle `Upgrade` avec catégories (Production, Bonus)
- Upgrades bonus qui augmentent cookies/clic
- Widget `UpgradeCard` avec icône, couleur, barre de progression
- Tri par prix/CPS/quantité (`DropdownButton`)
- Filtre achetable (`FilterChip`)
- `showModalBottomSheet` pour les détails
- `ExpansionTile` pour les catégories

### Semaine 4 — Production automatique
- `Timer.periodic` pour production auto
- Frenzy x2 pendant 30s avec cooldown 5 min
- `WidgetsBindingObserver` pour cookies pendant l'absence
- Journal des 20 dernières actions avec timestamps
- Stats enrichies : total clic vs auto, ratio, CPS
- `AnimatedSwitcher` sur le CPS

### Semaine 5 — Sauvegarde locale
- `shared_preferences` pour persistance
- Modèle `GameSave` avec `toJson`/`fromJson`
- Sauvegarde avec debounce de 2 secondes
- Profil joueur avec pseudo
- 3 slots de sauvegarde
- Import/Export JSON avec gestion d'erreur
- Double confirmation pour nouvelle partie
- Indicateur de sauvegarde

### Semaine 6 — Équilibrage et progression
- Formule de prix exponentielle (`baseCost × 1.15^qty`)
- Système de prestige avec multiplicateur permanent
- 15 achievements avec écran `GridView`
- Déblocage progressif des upgrades (`unlockThreshold`)
- 8 upgrades : Curseur, Grand-mère, Ferme, Mine, Usine, Labo, Portail, Machine temporelle
- 2 upgrades bonus : Meilleur clic, Super clic

### Semaine 7 — Connexion API
- Classe abstraite `ScoreRepository` (injection de dépendances)
- `ApiScoreRepository` (HTTP) et `FakeScoreRepository` (tests)
- Classement avec médailles top 3, `RefreshIndicator`
- `enum LoadingState` pour gestion d'état
- Formulaire `Form` + `TextFormField` avec validation
- Cache local du classement
- Retry avec backoff exponentiel
- `Stream.periodic` pour auto-refresh
- Mode offline

### Semaine 8 — flutter_bloc + finitions
- 5 Cubits : Cookie, Achievement, Theme, Leaderboard + Profile dans Cookie
- États immutables avec `copyWith`
- `MultiBlocProvider` + `MultiBlocListener`
- `BlocListener` pour vérifier et notifier les achievements
- `blocTest` pour tester les séquences d'états
- Splash screen animé (scale + fade)
- `AnimatedContainer` pour les cartes d'upgrade
- Documentation `///` sur toutes les classes publiques

## Choix techniques

- **État** : `flutter_bloc` (Cubit) pour séparation UI/logique
- **Sauvegarde** : `shared_preferences` avec debounce
- **Réseau** : package `http` avec abstraction Repository
- **Tests** : `flutter_test`, `bloc_test`, `FakeScoreRepository`
- **Thème** : `ColorScheme.fromSeed` avec support dark mode
