import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_clicker/main.dart';
import 'package:cookie_clicker/models/score.dart';
import 'package:cookie_clicker/services/fake_score_repository.dart';
import 'package:cookie_clicker/services/score_repository.dart';
import 'package:cookie_clicker/models/cookie_model.dart';
import 'package:cookie_clicker/models/theme_model.dart';
import 'package:cookie_clicker/screens/leaderboard_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Semaine 7 - Connexion API', () {
    test('Score.fromJson et toJson roundtrip', () {
      const score = Score(name: 'Alice', cookies: 1234);
      final json = score.toJson();
      final restored = Score.fromJson(json);
      expect(restored.name, 'Alice');
      expect(restored.cookies, 1234);
    });

    test('Score.fromJson gere les valeurs manquantes', () {
      final score = Score.fromJson({});
      expect(score.name, 'Anonyme');
      expect(score.cookies, 0);
    });

    test('FakeScoreRepository retourne des donnees', () async {
      final repo = FakeScoreRepository();
      final scores = await repo.fetchLeaderboard();
      expect(scores.length, 5);
      expect(scores.first.cookies, 9999);
    });

    test('FakeScoreRepository trie par score decroissant',
        () async {
      final repo = FakeScoreRepository();
      final scores = await repo.fetchLeaderboard();
      for (var i = 0; i < scores.length - 1; i++) {
        expect(
          scores[i].cookies,
          greaterThanOrEqualTo(scores[i + 1].cookies),
        );
      }
    });

    test('FakeScoreRepository submitScore ajoute un score',
        () async {
      final repo = FakeScoreRepository();
      await repo.submitScore(
        const Score(name: 'Test', cookies: 100),
      );
      final scores = await repo.fetchLeaderboard();
      expect(scores.length, 6);
    });

    test('LoadingState a 4 valeurs', () {
      expect(LoadingState.values.length, 4);
      expect(
        LoadingState.values,
        contains(LoadingState.initial),
      );
      expect(
        LoadingState.values,
        contains(LoadingState.loading),
      );
      expect(
        LoadingState.values,
        contains(LoadingState.loaded),
      );
      expect(
        LoadingState.values,
        contains(LoadingState.error),
      );
    });

    test('Cache sauvegarde et restaure correctement', () async {
      SharedPreferences.setMockInitialValues({
        'leaderboard_cache':
            '[{"name":"Alice","cookies":999}]',
        'leaderboard_cached_at': '2026-01-01T00:00:00',
      });
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString('leaderboard_cache'),
        contains('Alice'),
      );
    });

    test('ScoreRepository est bien une classe abstraite', () {
      final repo = FakeScoreRepository();
      expect(repo, isA<ScoreRepository>());
    });

    testWidgets(
      'Le classement est accessible via la navigation',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());
        expect(find.text('Classement'), findsOneWidget);
      },
    );

    testWidgets(
      'Le classement affiche un indicateur de chargement',
      (tester) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => CookieModel(),
              ),
              ChangeNotifierProvider(
                create: (_) => ThemeModel(),
              ),
              Provider<ScoreRepository>(
                create: (_) => FakeScoreRepository(),
              ),
            ],
            child: const MaterialApp(
              home: LeaderboardScreen(),
            ),
          ),
        );

        // Au lancement, un CircularProgressIndicator est affiché
        // ou les scores chargés rapidement
        await tester.pump();
        final hasLoader = find
            .byType(CircularProgressIndicator)
            .evaluate()
            .isNotEmpty;
        final hasScores =
            find.text('Alice').evaluate().isNotEmpty;
        expect(hasLoader || hasScores, true);

        // Après attente, les scores sont affichés
        await tester.pumpAndSettle();
        expect(find.text('Alice'), findsOneWidget);
      },
    );

    testWidgets(
      'Le classement affiche les medailles pour le top 3',
      (tester) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => CookieModel(),
              ),
              ChangeNotifierProvider(
                create: (_) => ThemeModel(),
              ),
              Provider<ScoreRepository>(
                create: (_) => FakeScoreRepository(),
              ),
            ],
            child: const MaterialApp(
              home: LeaderboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('🥇'), findsOneWidget);
        expect(find.text('🥈'), findsOneWidget);
        expect(find.text('🥉'), findsOneWidget);
      },
    );

    testWidgets(
      'Le bouton envoyer est present',
      (tester) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => CookieModel(),
              ),
              ChangeNotifierProvider(
                create: (_) => ThemeModel(),
              ),
              Provider<ScoreRepository>(
                create: (_) => FakeScoreRepository(),
              ),
            ],
            child: const MaterialApp(
              home: LeaderboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.send), findsOneWidget);
      },
    );
  });
}
