import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
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
  group('record_next_shot', () {
    test(
        'record next shot on planned series → shot has date, status becomes inProgress',
        () async {
      final fakeRepo = FakeVaccinationRepository();
      // Seed with 3-shot COVID series: shot 1 done, shots 2+3 unscheduled
      fakeRepo.seedAll(Fixtures.threeShots(
        d1: Fixtures.thirtyDaysAgo,
        d2: null,
        d3: null,
      ));

      final container = _makeContainer(fakeRepo);
      addTearDown(container.dispose);

      await container.read(vaccinationProvider.future);

      // Record shot 2 with yesterday's date
      final updated = [
        VaccinationEntryEntity(
          userId: 1,
          name: 'COVID-19',
          shotNumber: 1,
          totalShots: 3,
          vaccinationDate: Fixtures.thirtyDaysAgo,
        ),
        VaccinationEntryEntity(
          userId: 1,
          name: 'COVID-19',
          shotNumber: 2,
          totalShots: 3,
          vaccinationDate: Fixtures.yesterday,
        ),
        VaccinationEntryEntity(
          userId: 1,
          name: 'COVID-19',
          shotNumber: 3,
          totalShots: 3,
          vaccinationDate: null,
        ),
      ];
      await container.read(vaccinationProvider.notifier).saveSeries(updated);

      await container.read(vaccinationProvider.future);
      final seriesAsync = container.read(seriesListProvider);
      final series = seriesAsync.value!;
      expect(series, hasLength(1));
      expect(series.first.completedShots, 2);
      expect(series.first.seriesStatus, VaccinationSeriesStatus.inProgress);
    });

    test('record last remaining shot → series becomes complete', () async {
      final fakeRepo = FakeVaccinationRepository();
      fakeRepo.seedAll(Fixtures.threeShots(
        d1: Fixtures.thirtyDaysAgo,
        d2: Fixtures.yesterday,
        d3: null,
      ));

      final container = _makeContainer(fakeRepo);
      addTearDown(container.dispose);

      await container.read(vaccinationProvider.future);

      // Record shot 3 (the last remaining)
      final updated = [
        VaccinationEntryEntity(
          userId: 1,
          name: 'COVID-19',
          shotNumber: 1,
          totalShots: 3,
          vaccinationDate: Fixtures.thirtyDaysAgo,
        ),
        VaccinationEntryEntity(
          userId: 1,
          name: 'COVID-19',
          shotNumber: 2,
          totalShots: 3,
          vaccinationDate: Fixtures.yesterday,
        ),
        VaccinationEntryEntity(
          userId: 1,
          name: 'COVID-19',
          shotNumber: 3,
          totalShots: 3,
          vaccinationDate: Fixtures.yesterday,
        ),
      ];
      await container.read(vaccinationProvider.notifier).saveSeries(updated);

      await container.read(vaccinationProvider.future);
      final seriesAsync = container.read(seriesListProvider);
      final series = seriesAsync.value!;
      expect(series.first.seriesStatus, VaccinationSeriesStatus.complete);
      expect(series.first.completedShots, 3);
    });

    test('record shot updates only the target shot, others unchanged',
        () async {
      final fakeRepo = FakeVaccinationRepository();
      fakeRepo.seedAll(Fixtures.threeShots(
        d1: Fixtures.thirtyDaysAgo,
        d2: null,
        d3: null,
      ));

      final container = _makeContainer(fakeRepo);
      addTearDown(container.dispose);

      await container.read(vaccinationProvider.future);

      // Only update shot 2, preserve shot 1 date and shot 3 null
      final updated = [
        VaccinationEntryEntity(
          userId: 1,
          name: 'COVID-19',
          shotNumber: 1,
          totalShots: 3,
          vaccinationDate: Fixtures.thirtyDaysAgo,
        ),
        VaccinationEntryEntity(
          userId: 1,
          name: 'COVID-19',
          shotNumber: 2,
          totalShots: 3,
          vaccinationDate: Fixtures.yesterday,
        ),
        VaccinationEntryEntity(
          userId: 1,
          name: 'COVID-19',
          shotNumber: 3,
          totalShots: 3,
          vaccinationDate: null,
        ),
      ];
      await container.read(vaccinationProvider.notifier).saveSeries(updated);

      final entries = await container.read(vaccinationProvider.future);
      final shots = entries
          .where((e) => e.name == 'COVID-19')
          .toList()
        ..sort((a, b) => a.shotNumber.compareTo(b.shotNumber));

      expect(shots[0].vaccinationDate, Fixtures.thirtyDaysAgo); // unchanged
      expect(shots[1].vaccinationDate, Fixtures.yesterday); // updated
      expect(shots[2].vaccinationDate, isNull); // unchanged
    });
  });
}
