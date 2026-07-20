import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookie_clicker/main.dart';
import 'package:cookie_clicker/models/cookie_model.dart';
import 'package:cookie_clicker/models/upgrade.dart';

void main() {
  group('Semaine 3 - Boutique', () {
    // --- Tests unitaires ---

    test('cookiesPerClick vaut 1 par defaut', () {
      final model = CookieModel();
      expect(model.cookiesPerClick, 1);
    });

    test('cookiesPerClick augmente avec bonus', () {
      final model = CookieModel();
      model.addCookies(25);
      final bonus = model.upgrades.firstWhere(
        (u) => u.id == 'better_click',
      );
      model.buyUpgrade(bonus);
      expect(model.cookiesPerClick, 2);
    });

    test('clickCookie ajoute cookiesPerClick cookies', () {
      final model = CookieModel();
      model.addCookies(25);
      final bonus = model.upgrades.firstWhere(
        (u) => u.id == 'better_click',
      );
      model.buyUpgrade(bonus);
      final before = model.cookies;
      model.clickCookie();
      expect(model.cookies, before + 2);
    });

    test('buyUpgrade echoue si pas assez de cookies', () {
      final model = CookieModel();
      final result = model.buyUpgrade(model.upgrades.first);
      expect(result, false);
      expect(model.upgrades.first.quantity, 0);
    });

    test('buyUpgrade reussit si assez de cookies', () {
      final model = CookieModel();
      model.addCookies(10);
      final cursor = model.upgrades.first;
      expect(model.buyUpgrade(cursor), true);
      expect(cursor.quantity, 1);
      expect(model.cookies, 0);
    });

    test('defaultUpgrades contient production et bonus', () {
      final upgrades = defaultUpgrades();
      final production = upgrades
          .where((u) => u.category == UpgradeCategory.production);
      final bonus = upgrades
          .where((u) => u.category == UpgradeCategory.bonus);
      expect(production.length, 3);
      expect(bonus.length, 2);
    });

    test('tri par prix fonctionne', () {
      final model = CookieModel();
      model.setSortCriteria(SortCriteria.price);
      final prod = model.productionUpgrades;
      for (var i = 0; i < prod.length - 1; i++) {
        expect(prod[i].cost, lessThanOrEqualTo(prod[i + 1].cost));
      }
    });

    test('filtre achetable fonctionne', () {
      final model = CookieModel();
      model.addCookies(15);
      model.toggleAffordableFilter();
      final prod = model.productionUpgrades;
      expect(prod.length, 1); // Curseur (10)
    });

    test('reset remet les upgrades a zero', () {
      final model = CookieModel();
      model.addCookies(100);
      model.buyUpgrade(model.upgrades.first);
      model.reset();
      expect(model.upgrades.first.quantity, 0);
      expect(model.cookies, 0);
    });

    // --- Tests widget ---

    testWidgets(
      'BottomNavigationBar a 3 onglets',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());
        expect(find.text('Jeu'), findsOneWidget);
        expect(find.text('Boutique'), findsOneWidget);
        expect(find.text('Stats'), findsOneWidget);
      },
    );

    testWidgets(
      'Navigation vers Boutique affiche les categories',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());

        await tester.tap(find.text('Boutique'));
        await tester.pumpAndSettle();

        expect(find.text('🏭 Production'), findsOneWidget);
        expect(find.text('Trier par : '), findsOneWidget);
      },
    );

    testWidgets(
      'Navigation vers Stats affiche les statistiques',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());

        await tester.tap(find.text('Stats'));
        await tester.pumpAndSettle();

        expect(find.text('Clics total'), findsOneWidget);
        expect(find.text('Cookies par clic'), findsOneWidget);
      },
    );
  });
}
