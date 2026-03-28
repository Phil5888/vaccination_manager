import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/user_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_dependency_providers.dart';
import 'package:vaccination_manager/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:vaccination_manager/presentation/viewmodels/settings_viewmodel.dart';

import '../../helpers/fakes/fake_active_user_notifier.dart';
import '../../helpers/fakes/fake_settings_repository.dart';
import '../../helpers/fakes/fake_vaccination_repository.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/screen_sizes.dart';

// ---------------------------------------------------------------------------
// Local helpers
// ---------------------------------------------------------------------------

Widget _localizedApp({
  required Widget child,
  ThemeMode themeMode = ThemeMode.light,
  double textScaleFactor = 1.0,
}) =>
    MaterialApp(
      themeMode: themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateRoute: (settings) =>
          MaterialPageRoute(builder: (_) => const SizedBox()),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScaleFactor),
        ),
        child: child!,
      ),
      home: Scaffold(body: child),
    );

Widget _buildScope({
  required Widget child,
  required FakeVaccinationRepository fakeVax,
  ThemeMode themeMode = ThemeMode.light,
  double textScaleFactor = 1.0,
}) =>
    ProviderScope(
      overrides: [
        activeUserProvider
            .overrideWith(() => FakeActiveUserNotifier(Fixtures.userAlice())),
        vaccinationRepositoryProvider.overrideWith((_) => fakeVax),
        settingsRepositoryProvider
            .overrideWith((_) => FakeSettingsRepository()),
      ],
      child: _localizedApp(
          child: child, themeMode: themeMode, textScaleFactor: textScaleFactor),
    );

void main() {
  group('DashboardScreen', () {
    group('no overflow — empty state', () {
      for (final size in allScreenSizes) {
        testWidgets(
          'at ${size.width}x${size.height}',
          (tester) async {
            final fakeVax = FakeVaccinationRepository();
            await pumpAtSize(
              tester,
              () => _buildScope(
                child: const DashboardScreen(),
                fakeVax: fakeVax,
              ),
              size,
            );
            expectNoOverflow(tester);
          },
        );
      }
    });

    group('no overflow — with data', () {
      for (final size in allScreenSizes) {
        testWidgets(
          'at ${size.width}x${size.height}',
          (tester) async {
            final fakeVax = FakeVaccinationRepository();
            fakeVax.seedAll([
              // Complete single-shot series
              Fixtures.singleShotPast(name: 'Flu', userId: 1),
              // In-progress 3-shot series (2 of 3 done)
              ...Fixtures.threeShots(
                name: 'COVID-19',
                userId: 1,
                d1: Fixtures.thirtyDaysAgo,
                d2: Fixtures.yesterday,
                d3: null,
              ),
            ]);
            await pumpAtSize(
              tester,
              () => _buildScope(
                child: const DashboardScreen(),
                fakeVax: fakeVax,
              ),
              size,
            );
            expectNoOverflow(tester);
          },
        );
      }
    });

    group('dark mode', () {
      testWidgets(
        'key text widgets are findable in dark mode',
        (tester) async {
          final fakeVax = FakeVaccinationRepository();
          fakeVax.seedAll([
            Fixtures.singleShotPast(name: 'Flu', userId: 1),
          ]);
          await pumpAtSize(
            tester,
            () => _buildScope(
              child: const DashboardScreen(),
              fakeVax: fakeVax,
              themeMode: ThemeMode.dark,
            ),
            phone,
          );
          expectNoOverflow(tester);
          expect(find.byType(DashboardScreen), findsOneWidget);
        },
      );
    });

    group('text scaling', () {
      for (final scale in [1.5, 2.0]) {
        testWidgets(
          'no overflow at phoneSmall × $scale',
          (tester) async {
            final fakeVax = FakeVaccinationRepository();
            fakeVax.seedAll([
              Fixtures.singleShotPast(name: 'Flu', userId: 1),
              ...Fixtures.threeShots(
                name: 'COVID-19',
                userId: 1,
                d1: Fixtures.thirtyDaysAgo,
                d2: Fixtures.yesterday,
                d3: null,
              ),
            ]);
            await pumpAtSize(
              tester,
              () => _buildScope(
                child: const DashboardScreen(),
                fakeVax: fakeVax,
                textScaleFactor: scale,
              ),
              phoneSmall,
            );
            expectNoOverflow(tester);
          },
        );
      }
    });
  });
}
