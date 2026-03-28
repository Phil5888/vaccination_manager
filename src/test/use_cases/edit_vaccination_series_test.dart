import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
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
  group('edit_vaccination_series', () {
    test('rename vaccine → old series gone, new name series present', () async {
      final fakeRepo = FakeVaccinationRepository();
      fakeRepo.seedAll([Fixtures.singleShotPast(name: 'Flu')]);

      final container = _makeContainer(fakeRepo);
      addTearDown(container.dispose);

      await container.read(vaccinationProvider.future);

      // Step 1: delete the old series
      await container
          .read(vaccinationProvider.notifier)
          .deleteSeries(1, 'Flu');

      // Step 2: save with the new name
      final renamed = VaccinationEntryEntity(
        userId: 1,
        name: 'Influenza',
        shotNumber: 1,
        totalShots: 1,
        vaccinationDate: Fixtures.yesterday,
      );
      await container
          .read(vaccinationProvider.notifier)
          .saveSeries([renamed]);

      final entries = await container.read(vaccinationProvider.future);
      final names = entries.map((e) => e.name).toSet();
      expect(names, isNot(contains('Flu')));
      expect(names, contains('Influenza'));
    });

    test('reduce shot count 3→2 → third shot removed from repo', () async {
      final fakeRepo = FakeVaccinationRepository();
      fakeRepo.seedAll(Fixtures.threeShots(
        d1: Fixtures.thirtyDaysAgo,
        d2: Fixtures.yesterday,
        d3: Fixtures.yesterday,
      ));

      final container = _makeContainer(fakeRepo);
      addTearDown(container.dispose);

      await container.read(vaccinationProvider.future);

      // Save 2-shot version (same name → replaces all existing)
      final twoShots = [
        VaccinationEntryEntity(
          userId: 1,
          name: 'COVID-19',
          shotNumber: 1,
          totalShots: 2,
          vaccinationDate: Fixtures.thirtyDaysAgo,
        ),
        VaccinationEntryEntity(
          userId: 1,
          name: 'COVID-19',
          shotNumber: 2,
          totalShots: 2,
          vaccinationDate: Fixtures.yesterday,
        ),
      ];
      await container
          .read(vaccinationProvider.notifier)
          .saveSeries(twoShots);

      final entries = await container.read(vaccinationProvider.future);
      final covid = entries.where((e) => e.name == 'COVID-19').toList();
      expect(covid, hasLength(2));
      expect(covid.map((e) => e.totalShots).toSet(), {2});
    });

    test('increase shot count 1→3 → 2 null-date shots added', () async {
      final fakeRepo = FakeVaccinationRepository();
      fakeRepo.seedAll([Fixtures.singleShotPast(name: 'Flu')]);

      final container = _makeContainer(fakeRepo);
      addTearDown(container.dispose);

      await container.read(vaccinationProvider.future);

      // Save expanded 3-shot version (same name replaces the old single shot)
      final threeShots = [
        VaccinationEntryEntity(
          userId: 1,
          name: 'Flu',
          shotNumber: 1,
          totalShots: 3,
          vaccinationDate: Fixtures.yesterday,
        ),
        VaccinationEntryEntity(
          userId: 1,
          name: 'Flu',
          shotNumber: 2,
          totalShots: 3,
          vaccinationDate: null,
        ),
        VaccinationEntryEntity(
          userId: 1,
          name: 'Flu',
          shotNumber: 3,
          totalShots: 3,
          vaccinationDate: null,
        ),
      ];
      await container
          .read(vaccinationProvider.notifier)
          .saveSeries(threeShots);

      final entries = await container.read(vaccinationProvider.future);
      final flu =
          entries.where((e) => e.name == 'Flu').toList()
            ..sort((a, b) => a.shotNumber.compareTo(b.shotNumber));

      expect(flu, hasLength(3));
      expect(flu[0].vaccinationDate, isNotNull); // shot 1 dated
      expect(flu[1].vaccinationDate, isNull); // shot 2 null
      expect(flu[2].vaccinationDate, isNull); // shot 3 null
    });

    test('edit shot date → date updated, other shots unchanged', () async {
      final fakeRepo = FakeVaccinationRepository();
      fakeRepo.seedAll(Fixtures.threeShots(
        d1: Fixtures.thirtyDaysAgo,
        d2: null,
        d3: null,
      ));

      final container = _makeContainer(fakeRepo);
      addTearDown(container.dispose);

      await container.read(vaccinationProvider.future);

      // Update shot 2 to yesterday; shots 1 and 3 unchanged
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
      await container
          .read(vaccinationProvider.notifier)
          .saveSeries(updated);

      final entries = await container.read(vaccinationProvider.future);
      final shots = entries
          .where((e) => e.name == 'COVID-19')
          .toList()
        ..sort((a, b) => a.shotNumber.compareTo(b.shotNumber));

      expect(shots[0].vaccinationDate, Fixtures.thirtyDaysAgo);
      expect(shots[1].vaccinationDate, Fixtures.yesterday);
      expect(shots[2].vaccinationDate, isNull);
    });
  });
}
