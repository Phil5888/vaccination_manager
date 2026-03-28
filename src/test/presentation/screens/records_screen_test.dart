import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/domain/entities/user_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/user_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_dependency_providers.dart';
import 'package:vaccination_manager/presentation/screens/records/records_screen.dart';
import 'package:vaccination_manager/presentation/viewmodels/settings_viewmodel.dart';

import '../../helpers/fakes/fake_active_user_notifier.dart';
import '../../helpers/fakes/fake_settings_repository.dart';
import '../../helpers/fakes/fake_vaccination_repository.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/screen_sizes.dart';

// ---------------------------------------------------------------------------
// Local helpers
// ---------------------------------------------------------------------------

const _userCharlie = UserEntity(id: 3, username: 'Charlie');

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

Widget _buildScope({
  required FakeVaccinationRepository fakeVax,
  required FakeActiveUserNotifier activeUser,
}) =>
    ProviderScope(
      overrides: [
        activeUserProvider.overrideWith(() => activeUser),
        vaccinationRepositoryProvider.overrideWith((_) => fakeVax),
        settingsRepositoryProvider
            .overrideWith((_) => FakeSettingsRepository()),
      ],
      child: _localizedApp(child: const RecordsScreen()),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('RecordsScreen', () {
    group('no overflow — empty state', () {
      for (final size in allScreenSizes) {
        testWidgets('at ${size.width}x${size.height}', (tester) async {
          final fakeVax = FakeVaccinationRepository();
          await pumpAtSize(
            tester,
            () => _buildScope(
              fakeVax: fakeVax,
              activeUser: FakeActiveUserNotifier(Fixtures.userAlice()),
            ),
            size,
          );
          expectNoOverflow(tester);
        });
      }
    });

    group('no overflow — with data', () {
      for (final size in allScreenSizes) {
        testWidgets('at ${size.width}x${size.height}', (tester) async {
          final fakeVax = FakeVaccinationRepository();
          fakeVax.seedAll([
            // Single complete shot
            Fixtures.singleShotPast(name: 'Flu', userId: 1),
            // In-progress 3-shot series
            ...Fixtures.threeShots(
              name: 'COVID-19',
              userId: 1,
              d1: Fixtures.thirtyDaysAgo,
              d2: Fixtures.yesterday,
              d3: null,
            ),
            // Overdue: complete shot with past next-vaccination date
            Fixtures.singleShotComplete(
              name: 'Tetanus',
              userId: 1,
              nextVaccinationDate: Fixtures.thirtyDaysAgo,
            ),
          ]);
          await pumpAtSize(
            tester,
            () => _buildScope(
              fakeVax: fakeVax,
              activeUser: FakeActiveUserNotifier(Fixtures.userAlice()),
            ),
            size,
          );
          expectNoOverflow(tester);
        });
      }
    });

    group('stress — 10 series', () {
      testWidgets('10 series × 3 shots renders without overflow at phoneSmall',
          (tester) async {
        final fakeVax = FakeVaccinationRepository();
        final entries = <VaccinationEntryEntity>[];
        for (int i = 1; i <= 10; i++) {
          entries.addAll(Fixtures.threeShots(
            name: 'Vaccine $i',
            userId: 1,
            d1: Fixtures.thirtyDaysAgo,
            d2: Fixtures.yesterday,
            d3: null,
          ));
        }
        fakeVax.seedAll(entries);

        await pumpAtSize(
          tester,
          () => _buildScope(
            fakeVax: fakeVax,
            activeUser: FakeActiveUserNotifier(Fixtures.userAlice()),
          ),
          phoneSmall,
        );
        expectNoOverflow(tester);
        expect(find.byType(RecordsScreen), findsOneWidget);
      });
    });

    group('stress — 100 vaccinations across 3 users', () {
      late FakeVaccinationRepository fakeVax;

      setUp(() {
        fakeVax = FakeVaccinationRepository();
        final entries = <VaccinationEntryEntity>[];

        // User 1 (Alice, id=1): 40 shots
        // 20 single-shot entries
        for (int i = 1; i <= 20; i++) {
          entries.add(VaccinationEntryEntity(
            userId: 1,
            name: 'SingleVax $i',
            shotNumber: 1,
            totalShots: 1,
            vaccinationDate: Fixtures.yesterday,
          ));
        }
        // 10 two-shot series = 20 shots
        for (int i = 1; i <= 10; i++) {
          entries.add(VaccinationEntryEntity(
            userId: 1,
            name: 'DualVax $i',
            shotNumber: 1,
            totalShots: 2,
            vaccinationDate: Fixtures.thirtyDaysAgo,
          ));
          entries.add(VaccinationEntryEntity(
            userId: 1,
            name: 'DualVax $i',
            shotNumber: 2,
            totalShots: 2,
            vaccinationDate: Fixtures.yesterday,
          ));
        }

        // User 2 (Bob, id=2): 35 shots
        // 5 single shots
        for (int i = 1; i <= 5; i++) {
          entries.add(VaccinationEntryEntity(
            userId: 2,
            name: 'BobSingle $i',
            shotNumber: 1,
            totalShots: 1,
            vaccinationDate: Fixtures.yesterday,
          ));
        }
        // 10 three-shot series = 30 shots
        for (int i = 1; i <= 10; i++) {
          entries.addAll(Fixtures.threeShots(
            name: 'BobTriple $i',
            userId: 2,
            d1: Fixtures.thirtyDaysAgo,
            d2: Fixtures.yesterday,
            d3: null,
          ));
        }

        // User 3 (Charlie, id=3): 25 shots
        for (int i = 1; i <= 25; i++) {
          entries.add(VaccinationEntryEntity(
            userId: 3,
            name: 'CharlieVax $i',
            shotNumber: 1,
            totalShots: 1,
            vaccinationDate: Fixtures.yesterday,
          ));
        }

        fakeVax.seedAll(entries);
      });

      testWidgets('no overflow for user 1 (Alice, 40 shots)', (tester) async {
        await pumpAtSize(
          tester,
          () => _buildScope(
            fakeVax: fakeVax,
            activeUser: FakeActiveUserNotifier(Fixtures.userAlice()), // id=1
          ),
          phoneSmall,
        );
        expectNoOverflow(tester);
      });

      testWidgets('no overflow for user 2 (Bob, 35 shots)', (tester) async {
        await pumpAtSize(
          tester,
          () => _buildScope(
            fakeVax: fakeVax,
            activeUser: FakeActiveUserNotifier(Fixtures.userBob()), // id=2
          ),
          phoneSmall,
        );
        expectNoOverflow(tester);
      });

      testWidgets('no overflow for user 3 (Charlie, 25 shots)', (tester) async {
        await pumpAtSize(
          tester,
          () => _buildScope(
            fakeVax: fakeVax,
            activeUser: FakeActiveUserNotifier(_userCharlie), // id=3
          ),
          phoneSmall,
        );
        expectNoOverflow(tester);
      });

      test('user 1 raw shot count is 40', () {
        // 20 single-shot + 10 × 2 dual-shot = 40
        expect(fakeVax.all.where((e) => e.userId == 1).length, 40);
      });

      test('user 2 raw shot count is 35', () {
        // 5 single + 10 × 3 triple = 35
        expect(fakeVax.all.where((e) => e.userId == 2).length, 35);
      });

      test('user 3 raw shot count is 25', () {
        expect(fakeVax.all.where((e) => e.userId == 3).length, 25);
      });
    });
  });
}
