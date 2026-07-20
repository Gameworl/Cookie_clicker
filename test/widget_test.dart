import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_clicker/main.dart';
import 'package:cookie_clicker/models/cookie_model.dart';
import 'package:cookie_clicker/models/upgrade.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Semaine 6 - Equilibrage et progression', () {
    test('Le prix augmente exponentiellement', () {
      final upgrade = Upgrade(
        id: 'test',
        name: 'Test',
        description: 'Test',
        baseCost: 100,
        icon: Icons.star,
        category: UpgradeCategory.production,
      );
      expect(upgrade.cost, 100);
      upgrade.quantity = 1;
      expect(upgrade.cost, greaterThan(100));
      upgrade.quantity = 10;
      expect(upgrade.cost, greaterThan(200));
    });

    test('Prestige remet a zero mais garde le multiplicateur', () {
      final model = CookieModel();
      model.addCookies(10000);
      model.prestige();
      expect(model.cookies, 0);
      expect(model.prestiges, 1);
      expect(model.prestigeMultiplier, 1.1);
      model.dispose();
    });

    test('Multiplicateur correct apres N prestiges', () {
      final model = CookieModel();
      model.addCookies(10000);
      model.prestige();
      model.addCookies(10000);
      model.prestige();
      expect(model.prestiges, 2);
      expect(model.prestigeMultiplier, 1.2);
      model.dispose();
    });

    test('canPrestige est false sous le seuil', () {
      final model = CookieModel();
      model.addCookies(9999);
      expect(model.canPrestige, false);
      model.dispose();
    });

    test('canPrestige est true au seuil', () {
      final model = CookieModel();
      model.addCookies(10000);
      expect(model.canPrestige, true);
      model.dispose();
    });

    test('Achievement se debloque quand condition remplie', () {
      final model = CookieModel();
      model.clickCookie();
      final firstClick = model.achievements.firstWhere(
        (a) => a.id == 'first_click',
      );
      expect(firstClick.unlocked, true);
      model.dispose();
    });

    test('Achievement ne se debloque pas si condition non remplie',
        () {
      final model = CookieModel();
      final millionaire = model.achievements.firstWhere(
        (a) => a.id == 'cookies_1000',
      );
      expect(millionaire.unlocked, false);
      model.dispose();
    });

    test('Achievement first_buy se debloque a l achat', () {
      final model = CookieModel();
      model.addCookies(100);
      model.buyUpgrade(model.upgrades.first);
      final firstBuy = model.achievements.firstWhere(
        (a) => a.id == 'first_buy',
      );
      expect(firstBuy.unlocked, true);
      model.dispose();
    });

    test('Upgrades visibles selon les paliers', () {
      final model = CookieModel();
      // Au debut, seuls les upgrades sans seuil sont visibles
      final visible = model.productionUpgrades;
      expect(
        visible.any((u) => u.id == 'cursor'),
        true,
      );
      expect(
        visible.any((u) => u.id == 'mine'),
        false,
      );
      model.dispose();
    });

    test('Mine visible apres 500 cookies', () {
      final model = CookieModel();
      model.addCookies(500);
      final visible = model.productionUpgrades;
      expect(visible.any((u) => u.id == 'mine'), true);
      model.dispose();
    });

    test('3 nouveaux upgrades sont presents', () {
      final upgrades = defaultUpgrades();
      expect(upgrades.any((u) => u.id == 'lab'), true);
      expect(upgrades.any((u) => u.id == 'portal'), true);
      expect(upgrades.any((u) => u.id == 'time_machine'), true);
    });

    test('Le prestige sauvegarde le nombre', () {
      final model = CookieModel();
      model.addCookies(10000);
      model.prestige();
      final save = model.exportSave();
      expect(save, contains('"prestiges": 1'));
      model.dispose();
    });

    testWidgets(
      'Ecran succes accessible depuis l AppBar',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());

        await tester.tap(find.byIcon(Icons.emoji_events));
        await tester.pumpAndSettle();

        expect(find.textContaining('Succès'), findsOneWidget);
      },
    );
  });
}
