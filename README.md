# 🍪 Clicky Cookie

Un jeu incrémental (façon *Cookie Clicker*) développé en Flutter.

## 📖 Description

Le joueur clique sur un cookie pour gagner des points, achète des améliorations
pour produire des cookies automatiquement, sauvegarde sa progression et consulte
un classement mondial.

## 🗺️ Branches du projet

Chaque branche correspond à une semaine de développement :

| Branche | Contenu | Notions |
|---|---|---|
| `semaine-1` | Clic de base avec `setState` | StatefulWidget, GestureDetector |
| `semaine-2` | Gestion d'état avec Provider | ChangeNotifier, Provider |
| `semaine-3` | Boutique d'améliorations | ListView, Navigation, Modèles |
| `semaine-4` | Production automatique | Timer, dispose() |
| `semaine-5` | Sauvegarde locale | shared_preferences, JSON |
| `semaine-6` | Équilibrage et progression | Formules exponentielles |
| `semaine-7` | Connexion API | http, FutureBuilder, JSON |
| `semaine-8` | Refactoring flutter_bloc | Cubit, BlocProvider, BlocBuilder |

## 🚀 Lancer le projet

```bash
flutter pub get
flutter run
```

## 📦 Packages utilisés

| Package | Utilité | Semaine |
|---|---|---|
| provider | Gestion d'état simple | 2 |
| shared_preferences | Sauvegarde locale | 5 |
| http | Appels réseau REST | 7 |
| flutter_bloc | Architecture Cubit/Bloc | 8 |
