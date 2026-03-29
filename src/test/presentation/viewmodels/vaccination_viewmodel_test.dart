import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_status.dart';
import 'package:vaccination_manager/presentation/providers/user_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_dependency_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_providers.dart';

import '../../helpers/fakes/fake_active_user_notifier.dart';
import '../../helpers/fakes/fake_vaccination_repository.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeVaccinationRepository fakeRepo;

  /// Creates a container with fake overrides and a fixed active user.
  ProviderContainer makeContainer({int? activeUserId}) {
    final user = activeUserId == 1
        ? Fixtures.userAlice()
        : activeUserId == 2
        ? Fixtures.userBob()
        : null;
    return ProviderContainer(overrides: [activeUserProvider.overrideWith(() => FakeActiveUserNotifier(user)), vaccinationRepositoryProvider.overrideWith((_) => fakeRepo)]);
  }

  setUp(() {
    fakeRepo = FakeVaccinationRepository();
  });

  group('VaccinationViewModel', () {
    test('build() with active user returns that user\'s entries', () async {
      fakeRepo.seedAll([Fixtures.singleShotPast(name: 'Flu', userId: 1), Fixtures.singleShotPast(name: 'MMR', userId: 2)]);
      final container = makeContainer(activeUserId: 1);
      addTearDown(container.dispose);

      final entries = await container.read(vaccinationProvider.future);
      expect(entries.length, 1);
      expect(entries.first.name, 'Flu');
    });

    test('build() with null active user returns empty list', () async {
      fakeRepo.seedAll([Fixtures.singleShotPast()]);
      final container = makeContainer(activeUserId: null);
      addTearDown(container.dispose);

      final entries = await container.read(vaccinationProvider.future);
      expect(entries, isEmpty);
    });

    test('saveSeries() adds entries to state', () async {
      final container = makeContainer(activeUserId: 1);
      addTearDown(container.dispose);
      await container.read(vaccinationProvider.future);

      await container.read(vaccinationProvider.notifier).saveSeries(Fixtures.threeShots(userId: 1));

      final entries = await container.read(vaccinationProvider.future);
      expect(entries.length, 3);
      expect(entries.every((e) => e.name == 'COVID-19'), isTrue);
    });

    test('saveSeries() replaces existing series with same name', () async {
      fakeRepo.seedAll(Fixtures.threeShots(userId: 1));
      final container = makeContainer(activeUserId: 1);
      addTearDown(container.dispose);
      await container.read(vaccinationProvider.future);

      // Save a 2-shot version of the same vaccine
      final twoShots = [Fixtures.threeShots(userId: 1).first.copyWith(totalShots: 2), Fixtures.threeShots(userId: 1)[1].copyWith(totalShots: 2)];
      await container.read(vaccinationProvider.notifier).saveSeries(twoShots);

      final entries = await container.read(vaccinationProvider.future);
      final covidEntries = entries.where((e) => e.name == 'COVID-19').toList();
      expect(covidEntries.length, 2);
    });

    test('deleteShot() removes exactly one entry', () async {
      fakeRepo.seedAll(Fixtures.threeShots(userId: 1));
      final container = makeContainer(activeUserId: 1);
      addTearDown(container.dispose);
      final before = await container.read(vaccinationProvider.future);
      final idToDelete = before.first.id!;

      await container.read(vaccinationProvider.notifier).deleteShot(idToDelete);

      final after = await container.read(vaccinationProvider.future);
      expect(after.length, 2);
      expect(after.every((e) => e.id != idToDelete), isTrue);
    });

    test('deleteSeries() removes all shots in the series', () async {
      fakeRepo.seedAll([...Fixtures.threeShots(name: 'COVID-19', userId: 1), Fixtures.singleShotPast(name: 'Flu', userId: 1)]);
      final container = makeContainer(activeUserId: 1);
      addTearDown(container.dispose);
      await container.read(vaccinationProvider.future);

      await container.read(vaccinationProvider.notifier).deleteSeries(1, 'COVID-19');

      final entries = await container.read(vaccinationProvider.future);
      expect(entries.length, 1);
      expect(entries.first.name, 'Flu');
    });

    test('saveSeries() does not affect another user\'s entries', () async {
      fakeRepo.seedAll([Fixtures.singleShotPast(name: 'Flu', userId: 2)]);
      final container = makeContainer(activeUserId: 1);
      addTearDown(container.dispose);
      await container.read(vaccinationProvider.future);

      await container.read(vaccinationProvider.notifier).saveSeries([Fixtures.singleShotPast(name: 'Tetanus', userId: 1)]);

      // User 2's shot must still be in the repo
      final user2Entries = await fakeRepo.getVaccinationsForUser(2);
      expect(user2Entries.length, 1);
      expect(user2Entries.first.name, 'Flu');
    });
  });

  group('seriesListProvider', () {
    test('derives series from vaccination entries', () async {
      fakeRepo.seedAll(Fixtures.threeShots(userId: 1, d1: Fixtures.thirtyDaysAgo, d2: Fixtures.yesterday, d3: null));
      final container = makeContainer(activeUserId: 1);
      addTearDown(container.dispose);

      // Await entries first so the derived provider has data
      await container.read(vaccinationProvider.future);
      final seriesAsync = container.read(seriesListProvider);

      seriesAsync.when(
        data: (list) {
          expect(list.length, 1);
          expect(list.first.name, 'COVID-19');
          expect(list.first.completedShots, 2);
          expect(list.first.seriesStatus, VaccinationSeriesStatus.inProgress);
        },
        loading: () => fail('Should not be loading after entries resolved'),
        error: (e, _) => fail('Should not error: $e'),
      );
    });
  });
}
