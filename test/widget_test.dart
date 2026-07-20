import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_clicker/main.dart';
import 'package:cookie_clicker/cubit/cookie_cubit.dart';
import 'package:cookie_clicker/cubit/cookie_state.dart';
import 'package:cookie_clicker/cubit/achievement_cubit.dart';
import 'package:cookie_clicker/cubit/achievement_state.dart';
import 'package:cookie_clicker/cubit/theme_cubit.dart';
import 'package:cookie_clicker/cubit/leaderboard_cubit.dart';
import 'package:cookie_clicker/cubit/leaderboard_state.dart';
import 'package:cookie_clicker/models/score.dart';
import 'package:cookie_clicker/models/upgrade.dart';
import 'package:cookie_clicker/services/fake_score_repository.dart';
import 'package:cookie_clicker/services/score_repository.dart';
import 'package:cookie_clicker/screens/leaderboard_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Semaine 8 - flutter_bloc', () {
    // --- CookieCubit ---

    blocTest<CookieCubit, CookieState>(
      'clickCookie incremente cookies',
      build: CookieCubit.new,
      act: (cubit) => cubit.clickCookie(),
      verify: (cubit) {
        expect(cubit.state.cookies, 1);
        expect(cubit.state.totalClicks, 1);
      },
    );

    blocTest<CookieCubit, CookieState>(
      'addCookies ajoute le bon montant',
      build: CookieCubit.new,
      act: (cubit) => cubit.addCookies(100),
      verify: (cubit) {
        expect(cubit.state.cookies, 100);
      },
    );

    blocTest<CookieCubit, CookieState>(
      'buyUpgrade deduit le cout',
      build: CookieCubit.new,
      act: (cubit) {
        cubit.addCookies(100);
        cubit.buyUpgrade(cubit.state.upgrades.first);
      },
      verify: (cubit) {
        expect(cubit.state.upgrades.first.quantity, 1);
        expect(cubit.state.cookies, lessThan(100));
      },
    );

    blocTest<CookieCubit, CookieState>(
      'prestige remet a zero avec multiplicateur',
      build: CookieCubit.new,
      act: (cubit) {
        cubit.addCookies(10000);
        cubit.prestige();
      },
      verify: (cubit) {
        expect(cubit.state.cookies, 0);
        expect(cubit.state.prestiges, 1);
        expect(cubit.state.prestigeMultiplier, 1.1);
      },
    );

    blocTest<CookieCubit, CookieState>(
      'reset remet tout a zero',
      build: CookieCubit.new,
      act: (cubit) {
        cubit.addCookies(500);
        cubit.clickCookie();
        cubit.reset();
      },
      verify: (cubit) {
        expect(cubit.state.cookies, 0);
        expect(cubit.state.totalClicks, 0);
      },
    );

    blocTest<CookieCubit, CookieState>(
      'activateFrenzy active le frenzy',
      build: CookieCubit.new,
      act: (cubit) => cubit.activateFrenzy(),
      verify: (cubit) {
        expect(cubit.state.frenzyActive, true);
      },
    );

    // --- AchievementCubit ---

    blocTest<AchievementCubit, AchievementState>(
      'check debloque first_click',
      build: AchievementCubit.new,
      act: (cubit) {
        cubit.check(CookieState(
          totalClicks: 1,
          upgrades: defaultUpgrades(),
        ));
      },
      verify: (cubit) {
        final a = cubit.state.achievements.firstWhere(
          (x) => x.id == 'first_click',
        );
        expect(a.unlocked, true);
      },
    );

    blocTest<AchievementCubit, AchievementState>(
      'check ne debloque pas si condition non remplie',
      build: AchievementCubit.new,
      act: (cubit) {
        cubit.check(CookieState(
          totalClicks: 0,
          upgrades: defaultUpgrades(),
        ));
      },
      verify: (cubit) {
        final a = cubit.state.achievements.firstWhere(
          (x) => x.id == 'first_click',
        );
        expect(a.unlocked, false);
      },
    );

    blocTest<AchievementCubit, AchievementState>(
      'check debloque first_prestige apres prestige',
      build: AchievementCubit.new,
      act: (cubit) {
        cubit.check(CookieState(
          prestiges: 1,
          upgrades: defaultUpgrades(),
        ));
      },
      verify: (cubit) {
        final a = cubit.state.achievements.firstWhere(
          (x) => x.id == 'first_prestige',
        );
        expect(a.unlocked, true);
      },
    );

    // --- ThemeCubit ---

    blocTest<ThemeCubit, ThemeMode>(
      'toggleTheme bascule en dark puis light',
      build: ThemeCubit.new,
      act: (cubit) {
        cubit.toggleTheme();
        cubit.toggleTheme();
      },
      expect: () => [ThemeMode.dark, ThemeMode.light],
    );

    // --- LeaderboardCubit ---

    blocTest<LeaderboardCubit, LeaderboardState>(
      'fetchScores charge les scores',
      build: () => LeaderboardCubit(FakeScoreRepository()),
      wait: const Duration(milliseconds: 300),
      verify: (cubit) {
        expect(
          cubit.state.loadingState,
          LoadingState.loaded,
        );
        expect(cubit.state.scores.length, 5);
      },
    );

    // --- Tests unitaires modeles ---

    test('Score.fromJson et toJson', () {
      const score = Score(name: 'Alice', cookies: 42);
      final restored = Score.fromJson(score.toJson());
      expect(restored.name, 'Alice');
      expect(restored.cookies, 42);
    });

    test('Upgrade cost scaling', () {
      final u = Upgrade(
        id: 'test',
        name: 'Test',
        description: '',
        baseCost: 100,
        icon: Icons.star,
        category: UpgradeCategory.production,
      );
      expect(u.cost, 100);
      u.quantity = 5;
      expect(u.cost, greaterThan(100));
    });

    // --- Tests widget ---

    testWidgets(
      'Splash screen affiche le bouton Jouer',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());
        await tester.pumpAndSettle();
        expect(find.text('Jouer'), findsOneWidget);
      },
    );

    testWidgets(
      'Apres Jouer, l ecran principal s affiche',
      (tester) async {
        await tester.pumpWidget(const CookieClickerApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Jouer'));
        await tester.pumpAndSettle();

        expect(find.text('Boutique'), findsOneWidget);
        expect(find.text('Stats'), findsOneWidget);
      },
    );
  });
}
