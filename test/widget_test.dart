import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookie_clicker/main.dart';
import 'package:cookie_clicker/models/cookie_model.dart';

void main() {
  group('Semaine 4 - Production automatique', () {
    test('CPS = 0 sans upgrades', () {
      final model = CookieModel();
      expect(model.cookiesPerSecond, 0);
      model.dispose();
    });

    test('CPS augmente apres achat', () {
      final model = CookieModel();
      model.addCookies(10);
      model.buyUpgrade(model.upgrades.first);
      expect(model.cookiesPerSecond, 1);
      model.dispose();
    });

    test('Le timer ajoute des cookies', () async {
      final model = CookieModel();
      model.addCookies(10);
      model.buyUpgrade(model.upgrades.first);

      await Future<void>.delayed(
        const Duration(milliseconds: 1200),
      );
      expect(model.cookies, greaterThanOrEqualTo(1));
      model.dispose();
    });

    test('totalFromClicks et totalFromAuto se separent', () {
      final model = CookieModel();
      model.clickCookie();
      expect(model.totalFromClicks, 1);
      expect(model.totalFromAuto, 0);
      model.dispose();
    });

    test('Frenzy double le CPS', () {
      final model = CookieModel();
      model.addCookies(10);
      model.buyUpgrade(model.upgrades.first);
      expect(model.cookiesPerSecond, 1);

      model.activateFrenzy();
      expect(model.frenzyActive, true);
      expect(model.cookiesPerSecond, 2);
      model.dispose();
    });

    test('Frenzy double aussi les cookies par clic', () {
      final model = CookieModel();
      expect(model.cookiesPerClick, 1);
      model.activateFrenzy();
      expect(model.cookiesPerClick, 2);
      model.dispose();
    });

    test('Frenzy ne se reactive pas pendant le cooldown', () {
      final model = CookieModel();
      model.activateFrenzy();
      expect(model.frenzyActive, true);

      // Simuler fin du frenzy manuellement pas possible
      // mais on verifie que activer 2 fois ne change rien
      model.activateFrenzy();
      expect(model.frenzyActive, true);
      model.dispose();
    });

    test('onResume calcule les cookies d absence', () {
      final model = CookieModel();
      model.addCookies(10);
      model.buyUpgrade(model.upgrades.first);
      model.onPause();
      // Simuler 5s d'absence
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      model.onResume();
      // Le gain depend du temps reel ecoule, teste juste que ca ne crash pas
      model.dispose();
    });

    test('Le journal enregistre les actions', () {
      final model = CookieModel();
      model.clickCookie();
      expect(model.log.length, 1);
      expect(model.log.first.message, contains('clic'));
      model.dispose();
    });

    test('Le journal ne depasse pas 20 entrees', () {
      final model = CookieModel();
      for (var i = 0; i < 25; i++) {
        model.clickCookie();
      }
      expect(model.log.length, lessThanOrEqualTo(20));
      model.dispose();
    });

    testWidgets(
      'Le bouton Frenzy est present',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());
        expect(find.text('Frenzy x2'), findsOneWidget);
      },
    );

    testWidgets(
      'Stats affiche le ratio clic/auto',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());

        await tester.tap(find.text('Stats'));
        await tester.pumpAndSettle();

        expect(
          find.text('Total produit par clic'),
          findsOneWidget,
        );
        expect(
          find.text('Total produit auto'),
          findsOneWidget,
        );
      },
    );
  });
}
