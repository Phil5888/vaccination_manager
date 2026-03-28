import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/user_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_dependency_providers.dart';
import 'package:vaccination_manager/presentation/screens/vaccination/add_vaccination_screen.dart';
import 'package:vaccination_manager/presentation/viewmodels/settings_viewmodel.dart';

import '../../helpers/fakes/fake_active_user_notifier.dart';
import '../../helpers/fakes/fake_settings_repository.dart';
import '../../helpers/fakes/fake_vaccination_repository.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/screen_sizes.dart';

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

VaccinationSeriesEntity _singleShotCompleteSeries() {
  final shot = Fixtures.singleShotPast(name: 'Flu', userId: 1)
      .copyWith(id: 1, shotNumber: 1, totalShots: 1);
  return VaccinationSeriesEntity(name: 'Flu', userId: 1, shots: [shot]);
}

VaccinationSeriesEntity _threeShotInProgressSeries() {
  final shots = Fixtures.threeShots(
    name: 'COVID-19',
    userId: 1,
    d1: Fixtures.thirtyDaysAgo,
    d2: Fixtures.yesterday,
    d3: null,
  ).asMap().entries.map((e) => e.value.copyWith(id: e.key + 10)).toList();
  return VaccinationSeriesEntity(name: 'COVID-19', userId: 1, shots: shots);
}

VaccinationSeriesEntity _longNameSeries() {
  final shot = VaccinationEntryEntity(
    id: 99,
    userId: 1,
    name: 'Diphtheria-Tetanus-Pertussis-Hepatitis B-Polio (DTaP-HepB-IPV)',
    shotNumber: 1,
    totalShots: 1,
    vaccinationDate: Fixtures.yesterday,
  );
  return VaccinationSeriesEntity(
    name: 'Diphtheria-Tetanus-Pertussis-Hepatitis B-Polio (DTaP-HepB-IPV)',
    userId: 1,
    shots: [shot],
  );
}

// ---------------------------------------------------------------------------
// Local helpers
// ---------------------------------------------------------------------------

Widget _localizedApp({required Widget child}) => MaterialApp(
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
      home: Scaffold(body: child),
    );

Widget _buildScope({required Widget child}) => ProviderScope(
      overrides: [
        activeUserProvider
            .overrideWith(() => FakeActiveUserNotifier(Fixtures.userAlice())),
        vaccinationRepositoryProvider
            .overrideWith((_) => FakeVaccinationRepository()),
        settingsRepositoryProvider
            .overrideWith((_) => FakeSettingsRepository()),
      ],
      child: _localizedApp(child: child),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AddVaccinationScreen', () {
    group('no overflow — add mode', () {
      for (final size in allScreenSizes) {
        testWidgets(
          'at ${size.width}x${size.height}',
          (tester) async {
            await pumpAtSize(
              tester,
              () => _buildScope(child: const AddVaccinationScreen()),
              size,
            );
            expectNoOverflow(tester);
          },
        );
      }
    });

    group('no overflow — edit mode (single shot)', () {
      for (final size in allScreenSizes) {
        testWidgets(
          'at ${size.width}x${size.height}',
          (tester) async {
            await pumpAtSize(
              tester,
              () => _buildScope(
                child: AddVaccinationScreen(
                  existingSeries: _singleShotCompleteSeries(),
                ),
              ),
              size,
            );
            expectNoOverflow(tester);
          },
        );
      }
    });

    group('no overflow — edit mode (3-shot series)', () {
      for (final size in allScreenSizes) {
        testWidgets(
          'at ${size.width}x${size.height}',
          (tester) async {
            await pumpAtSize(
              tester,
              () => _buildScope(
                child: AddVaccinationScreen(
                  existingSeries: _threeShotInProgressSeries(),
                ),
              ),
              size,
            );
            expectNoOverflow(tester);
          },
        );
      }
    });

    group('stress — long vaccine name', () {
      testWidgets(
        'renders 59-char vaccine name without overflow at phoneSmall',
        (tester) async {
          const longName =
              'Diphtheria-Tetanus-Pertussis-Hepatitis B-Polio (DTaP-HepB-IPV)';
          await pumpAtSize(
            tester,
            () => _buildScope(
              child: AddVaccinationScreen(
                existingSeries: _longNameSeries(),
              ),
            ),
            phoneSmall,
          );
          expectNoOverflow(tester);
          // The vaccine name should be visible in the name field
          expect(find.text(longName), findsOneWidget);
        },
      );
    });
  });
}
