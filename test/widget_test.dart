import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_clicker/main.dart';
import 'package:cookie_clicker/models/cookie_model.dart';
import 'package:cookie_clicker/models/game_save.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Semaine 5 - Sauvegarde locale', () {
    test('GameSave.toJson et fromJson roundtrip', () {
      const save = GameSave(
        cookies: 42,
        totalClicks: 10,
        playerName: 'Alice',
        upgradeQuantities: {'cursor': 3},
      );
      final json = save.toJson();
      final restored = GameSave.fromJson(json);
      expect(restored.cookies, 42);
      expect(restored.totalClicks, 10);
      expect(restored.playerName, 'Alice');
      expect(restored.upgradeQuantities['cursor'], 3);
    });

    test('GameSave.fromJson gere les valeurs manquantes', () {
      final save = GameSave.fromJson({});
      expect(save.cookies, 0);
      expect(save.playerName, 'Joueur');
    });

    test('setPlayerName met a jour le pseudo', () async {
      final model = CookieModel();
      await Future<void>.delayed(
        const Duration(milliseconds: 100),
      );
      model.setPlayerName('Bob');
      expect(model.playerName, 'Bob');
      model.dispose();
    });

    test('exportSave retourne du JSON valide', () async {
      final model = CookieModel();
      await Future<void>.delayed(
        const Duration(milliseconds: 100),
      );
      model.addCookies(100);
      final json = model.exportSave();
      expect(json, contains('"cookies": 100'));
      model.dispose();
    });

    test('importSave restaure les donnees', () async {
      final model = CookieModel();
      await Future<void>.delayed(
        const Duration(milliseconds: 100),
      );
      model.importSave(
        '{"cookies": 999, "playerName": "Test"}',
      );
      expect(model.cookies, 999);
      expect(model.playerName, 'Test');
      model.dispose();
    });

    test('importSave rejette le JSON invalide', () async {
      final model = CookieModel();
      await Future<void>.delayed(
        const Duration(milliseconds: 100),
      );
      expect(
        () => model.importSave('invalid json'),
        throwsA(isA<FormatException>()),
      );
      model.dispose();
    });

    test('reset remet tout a zero', () async {
      final model = CookieModel();
      await Future<void>.delayed(
        const Duration(milliseconds: 100),
      );
      model.addCookies(500);
      model.clickCookie();
      model.reset();
      expect(model.cookies, 0);
      expect(model.totalClicks, 0);
      model.dispose();
    });

    test('loadGame charge depuis SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'slot_0':
            '{"cookies":42,"totalClicks":5,"playerName":"Saved"}',
      });
      final model = CookieModel();
      await Future<void>.delayed(
        const Duration(milliseconds: 200),
      );
      expect(model.cookies, 42);
      expect(model.playerName, 'Saved');
      model.dispose();
    });

    testWidgets(
      'Le pseudo s affiche dans l AppBar',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());
        expect(find.text('Joueur 🍪'), findsOneWidget);
      },
    );

    testWidgets(
      'Le bouton parametres est present',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());
        expect(find.byIcon(Icons.settings), findsOneWidget);
      },
    );

    testWidgets(
      'Navigation vers Parametres fonctionne',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());

        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();

        expect(find.text('Profil'), findsOneWidget);
        expect(find.text('Sauvegardes'), findsOneWidget);
        expect(find.text('Import / Export'), findsOneWidget);
      },
    );
  });
}
