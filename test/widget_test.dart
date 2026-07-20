import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookie_clicker/main.dart';

void main() {
  group('Semaine 1 - Clic de base', () {
    testWidgets(
      'Le compteur démarre à 0',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());
        expect(find.text('0 cookies'), findsOneWidget);
      },
    );

    testWidgets(
      'Le compteur augmente au clic sur le cookie',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());

        // Cliquer sur le cookie (emoji 🍪)
        await tester.tap(find.text('🍪'));
        await tester.pump();

        expect(find.text('1 cookies'), findsOneWidget);
      },
    );

    testWidgets(
      'Plusieurs clics incrémentent correctement',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());

        for (var i = 0; i < 5; i++) {
          await tester.tap(find.text('🍪'));
          await tester.pump();
        }

        expect(find.text('5 cookies'), findsOneWidget);
      },
    );
  });
}
