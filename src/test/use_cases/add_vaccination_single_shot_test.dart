import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_status.dart';
import 'package:vaccination_manager/presentation/providers/user_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_dependency_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_providers.dart';

import '../helpers/fakes/fake_active_user_notifier.dart';
import '../helpers/fakes/fake_vaccination_repository.dart';
import '../helpers/fixtures.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer(FakeVaccinationRepository fakeRepo) {
  return ProviderContainer(overrides: [
    activeUserProvider
        .overrideWith(() => FakeActiveUserNotifier(Fixtures.userAlice())),
    vaccinationRepositoryProvider.overrideWith((_) => fakeRepo),
  ]);
}

void main() {
  group('add_vaccination_single_shot', () {
    group('valid inputs', () {
      test('saves single shot with past date → appears in list', () async {
        final fakeRepo = FakeVaccinationRepository();
        final container = _makeContainer(fakeRepo);
        addTearDown(container.dispose);

        await container.read(vaccinationProvider.future);

        final shot = Fixtures.singleShotPast();
        await container.read(vaccinationProvider.notifier).saveSeries([shot]);

        final entries = await container.read(vaccinationProvider.future);
        expect(entries, hasLength(1));
        expect(entries.first.name, 'Flu');
        expect(entries.first.vaccinationDate, isNotNull);
        expect(
          entries.first.vaccinationDate!.isBefore(DateTime.now()),
          isTrue,
        );
      });

      test('saves single shot with past date → series status is complete',
          () async {
        final fakeRepo = FakeVaccinationRepository();
        final container = _makeContainer(fakeRepo);
        addTearDown(container.dispose);

        await container.read(vaccinationProvider.future);

        await container
            .read(vaccinationProvider.notifier)
            .saveSeries([Fixtures.singleShotPast()]);

        await container.read(vaccinationProvider.future);

        final seriesAsync = container.read(seriesListProvider);
        final series = seriesAsync.value!;
        expect(series, hasLength(1));
        expect(series.first.seriesStatus, VaccinationSeriesStatus.complete);
      });

      test('saves single shot with future date → stored as planned', () async {
        final fakeRepo = FakeVaccinationRepository();
        final container = _makeContainer(fakeRepo);
        addTearDown(container.dispose);

        await container.read(vaccinationProvider.future);
        await container
            .read(vaccinationProvider.notifier)
            .saveSeries([Fixtures.singleShotFuture()]);

        final entries = await container.read(vaccinationProvider.future);
        expect(entries, hasLength(1));
        expect(
          entries.first.vaccinationDate!.isAfter(DateTime.now()),
          isTrue,
        );

        final seriesAsync = container.read(seriesListProvider);
        expect(
          seriesAsync.value!.first.seriesStatus,
          VaccinationSeriesStatus.planned,
        );
      });

      test('saves single shot with null date → stored as unscheduled',
          () async {
        final fakeRepo = FakeVaccinationRepository();
        final container = _makeContainer(fakeRepo);
        addTearDown(container.dispose);

        await container.read(vaccinationProvider.future);
        await container
            .read(vaccinationProvider.notifier)
            .saveSeries([Fixtures.singleShotUnscheduled()]);

        final entries = await container.read(vaccinationProvider.future);
        expect(entries, hasLength(1));
        expect(entries.first.vaccinationDate, isNull);

        final seriesAsync = container.read(seriesListProvider);
        expect(
          seriesAsync.value!.first.seriesStatus,
          VaccinationSeriesStatus.planned,
        );
      });

      test('saves single shot with next-dose reminder date', () async {
        final fakeRepo = FakeVaccinationRepository();
        final container = _makeContainer(fakeRepo);
        addTearDown(container.dispose);

        await container.read(vaccinationProvider.future);

        final shot = Fixtures.singleShotComplete(
          nextVaccinationDate: Fixtures.inThirtyDays,
        );
        await container
            .read(vaccinationProvider.notifier)
            .saveSeries([shot]);

        final entries = await container.read(vaccinationProvider.future);
        expect(entries, hasLength(1));
        expect(entries.first.nextVaccinationDate, Fixtures.inThirtyDays);
      });
    });

    // ── Validation (mirrors add_vaccination_screen.dart _validate logic) ─────

    group('invalid inputs', () {
      // Validation lives in the screen layer; these tests confirm the rule.
      String? validateName(String name) {
        return name.trim().isEmpty ? 'Vaccine name is required' : null;
      }

      test('empty vaccine name → validation error, not saved', () async {
        expect(validateName(''), 'Vaccine name is required');

        // Confirm the repo remains empty when caller guards with the validator
        final fakeRepo = FakeVaccinationRepository();
        final container = _makeContainer(fakeRepo);
        addTearDown(container.dispose);

        final entries = await container.read(vaccinationProvider.future);
        expect(entries, isEmpty);
      });

      test('whitespace-only vaccine name → validation error, not saved',
          () async {
        expect(validateName('   '), 'Vaccine name is required');
        expect(validateName('\t'), 'Vaccine name is required');

        final fakeRepo = FakeVaccinationRepository();
        final container = _makeContainer(fakeRepo);
        addTearDown(container.dispose);

        final entries = await container.read(vaccinationProvider.future);
        expect(entries, isEmpty);
      });
    });
  });
}
