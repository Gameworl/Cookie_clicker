import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookie_clicker/main.dart';

void main() {
  group('Semaine 1 - Clic de base', () {
    testWidgets(
      'Le compteur demarre a 0 cookies',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());
        expect(find.text('0 cookies'), findsOneWidget);
      },
    );

    testWidgets(
      'Un clic incremente a 1 cookie (singulier)',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());

        await tester.tap(find.text('🍪'));
        await tester.pumpAndSettle();

        expect(find.text('1 cookie'), findsOneWidget);
      },
    );

    testWidgets(
      'Deux clics affichent 2 cookies (pluriel)',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());

        await tester.tap(find.text('🍪'));
        await tester.pump();
        await tester.tap(find.text('🍪'));
        await tester.pumpAndSettle();

        expect(find.text('2 cookies'), findsOneWidget);
      },
    );

    testWidgets(
      '5 clics affichent 5 cookies',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());

        for (var i = 0; i < 5; i++) {
          await tester.tap(find.text('🍪'));
          await tester.pump();
        }
        await tester.pumpAndSettle();

        expect(find.text('5 cookies'), findsOneWidget);
      },
    );

    testWidgets(
      'Le bouton reset remet le compteur a 0',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());

        // Cliquer 3 fois
        for (var i = 0; i < 3; i++) {
          await tester.tap(find.text('🍪'));
          await tester.pump();
        }

        // Appuyer sur le bouton reset
        await tester.tap(find.byIcon(Icons.restart_alt));
        await tester.pumpAndSettle();

        // Confirmer dans le dialog
        await tester.tap(find.text('Confirmer'));
        await tester.pumpAndSettle();

        expect(find.text('0 cookies'), findsOneWidget);
      },
    );

    testWidgets(
      'Annuler le reset conserve les cookies',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());

        for (var i = 0; i < 3; i++) {
          await tester.tap(find.text('🍪'));
          await tester.pump();
        }

        await tester.tap(find.byIcon(Icons.restart_alt));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Annuler'));
        await tester.pumpAndSettle();

        expect(find.text('3 cookies'), findsOneWidget);
      },
    );

    testWidgets(
      'Le bouton theme est present',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());
        expect(
          find.byIcon(Icons.brightness_6),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'AnimatedSwitcher est present dans l arbre',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());
        expect(
          find.byType(AnimatedSwitcher),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Le message de bienvenue est affiche',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());
        expect(
          find.text('Bienvenue dans Clicky Cookie !'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Le Tooltip du cookie est present',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());
        expect(
          find.byTooltip('Clique pour gagner un cookie'),
          findsOneWidget,
        );
      },
    );
  });
}
