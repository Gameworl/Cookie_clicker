import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookie_clicker/main.dart';
import 'package:cookie_clicker/models/cookie_model.dart';
import 'package:cookie_clicker/models/theme_model.dart';

void main() {
  group('Semaine 2 - Provider', () {
    // --- Tests unitaires CookieModel ---

    test('CookieModel demarre a 0', () {
      final model = CookieModel();
      expect(model.cookies, 0);
      expect(model.totalClicks, 0);
      expect(model.firstClickAt, isNull);
    });

    test('clickCookie incremente cookies et totalClicks', () {
      final model = CookieModel();
      model.clickCookie();
      expect(model.cookies, 1);
      expect(model.totalClicks, 1);
      expect(model.firstClickAt, isNotNull);
    });

    test('addCookies ajoute le bon montant', () {
      final model = CookieModel();
      model.addCookies(10);
      expect(model.cookies, 10);
    });

    test('reset remet tout a zero', () {
      final model = CookieModel();
      model.clickCookie();
      model.clickCookie();
      model.reset();
      expect(model.cookies, 0);
      expect(model.totalClicks, 0);
      expect(model.firstClickAt, isNull);
    });

    test('formattedCookies gere le singulier', () {
      final model = CookieModel();
      model.clickCookie();
      expect(model.formattedCookies, '1 cookie');
    });

    test('formattedCookies gere le pluriel', () {
      final model = CookieModel();
      expect(model.formattedCookies, '0 cookies');
      model.addCookies(5);
      expect(model.formattedCookies, '5 cookies');
    });

    test('nextMilestone retourne le bon palier', () {
      final model = CookieModel();
      expect(model.nextMilestone, 100);
      model.addCookies(100);
      expect(model.nextMilestone, 500);
      model.addCookies(9900);
      expect(model.nextMilestone, isNull);
    });

    test('clickCookie retourne le palier atteint', () {
      final model = CookieModel();
      model.addCookies(99);
      final milestone = model.clickCookie();
      expect(milestone, 100);
    });

    // --- Tests unitaires ThemeModel ---

    test('ThemeModel demarre en light', () {
      final model = ThemeModel();
      expect(model.themeMode, ThemeMode.light);
    });

    test('toggleTheme bascule en dark puis light', () {
      final model = ThemeModel();
      model.toggleTheme();
      expect(model.themeMode, ThemeMode.dark);
      model.toggleTheme();
      expect(model.themeMode, ThemeMode.light);
    });

    // --- Tests widget ---

    testWidgets(
      'Le Drawer s ouvre et contient les liens',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());

        // Ouvrir le drawer
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();

        expect(find.text('Accueil'), findsOneWidget);
        expect(find.text('Statistiques'), findsOneWidget);
        expect(find.text('À propos'), findsOneWidget);
        expect(find.text('Mode sombre'), findsOneWidget);
      },
    );

    testWidgets(
      'Navigation vers Statistiques fonctionne',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Statistiques'));
        await tester.pumpAndSettle();

        expect(find.text('Clics total'), findsOneWidget);
      },
    );

    testWidgets(
      'Le bouton bonus est present',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());
        expect(find.text('Bonus +10 🍪'), findsOneWidget);
      },
    );
  });
}
