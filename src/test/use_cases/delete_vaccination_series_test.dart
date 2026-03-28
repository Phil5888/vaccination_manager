import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
  group('delete_vaccination_series', () {
    test('deletes all shots for the named series', () async {
      final fakeRepo = FakeVaccinationRepository();
      fakeRepo.seedAll(Fixtures.threeShots(
        d1: Fixtures.thirtyDaysAgo,
        d2: Fixtures.yesterday,
        d3: Fixtures.yesterday,
      ));

      final container = _makeContainer(fakeRepo);
      addTearDown(container.dispose);

      await container.read(vaccinationProvider.future);
      await container
          .read(vaccinationProvider.notifier)
          .deleteSeries(1, 'COVID-19');

      final entries = await container.read(vaccinationProvider.future);
      expect(entries, isEmpty);
    });

    test('does not affect shots from a different vaccine', () async {
      final fakeRepo = FakeVaccinationRepository();
      fakeRepo.seedAll([
        ...Fixtures.threeShots(
          name: 'COVID-19',
          d1: Fixtures.thirtyDaysAgo,
          d2: Fixtures.yesterday,
          d3: Fixtures.yesterday,
        ),
        Fixtures.singleShotPast(name: 'Flu'),
      ]);

      final container = _makeContainer(fakeRepo);
      addTearDown(container.dispose);

      await container.read(vaccinationProvider.future);
      await container
          .read(vaccinationProvider.notifier)
          .deleteSeries(1, 'COVID-19');

      final entries = await container.read(vaccinationProvider.future);
      expect(entries, hasLength(1));
      expect(entries.first.name, 'Flu');
    });

    test('delete of non-existent series does not throw', () async {
      final fakeRepo = FakeVaccinationRepository();
      final container = _makeContainer(fakeRepo);
      addTearDown(container.dispose);

      await container.read(vaccinationProvider.future);

      // Deleting a series that was never created should complete without error
      await expectLater(
        container
            .read(vaccinationProvider.notifier)
            .deleteSeries(1, 'NonExistent'),
        completes,
      );

      final entries = await container.read(vaccinationProvider.future);
      expect(entries, isEmpty);
    });

    test('case-insensitive name match deletes correctly', () async {
      final fakeRepo = FakeVaccinationRepository();
      fakeRepo.seedAll([Fixtures.singleShotPast(name: 'Flu')]);

      final container = _makeContainer(fakeRepo);
      addTearDown(container.dispose);

      await container.read(vaccinationProvider.future);
      // Delete with different casing
      await container
          .read(vaccinationProvider.notifier)
          .deleteSeries(1, 'FLU');

      final entries = await container.read(vaccinationProvider.future);
      expect(entries, isEmpty);
    });
  });
}
