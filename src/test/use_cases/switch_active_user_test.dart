import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/domain/entities/user_entity.dart';
import 'package:vaccination_manager/presentation/providers/user_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_dependency_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_providers.dart';

import '../helpers/fakes/fake_active_user_notifier.dart';
import '../helpers/fakes/fake_vaccination_repository.dart';
import '../helpers/fixtures.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a container with a mutable active-user notifier so we can switch
/// users mid-test by casting the notifier reference.
ProviderContainer _makeContainer(
  FakeVaccinationRepository fakeRepo,
  UserEntity initialUser,
) {
  return ProviderContainer(overrides: [
    activeUserProvider
        .overrideWith(() => FakeActiveUserNotifier(initialUser)),
    vaccinationRepositoryProvider.overrideWith((_) => fakeRepo),
  ]);
}

void main() {
  group('switch_active_user', () {
    // QA-VAX-REG-USER-SWITCH-001
    test('user A (has records) → user B (has records): shows only B records',
        () async {
      final fakeRepo = FakeVaccinationRepository();
      fakeRepo.seedAll([
        Fixtures.singleShotPast(name: 'Flu', userId: 1), // Alice
        Fixtures.singleShotPast(name: 'MMR', userId: 2), // Bob
      ]);

      final container =
          _makeContainer(fakeRepo, Fixtures.userAlice());
      addTearDown(container.dispose);

      // Initial state: Alice's records
      final aliceEntries = await container.read(vaccinationProvider.future);
      expect(aliceEntries.map((e) => e.name), contains('Flu'));
      expect(aliceEntries.map((e) => e.name), isNot(contains('MMR')));

      // Switch to Bob
      (container.read(activeUserProvider.notifier) as FakeActiveUserNotifier)
          .setUser(Fixtures.userBob());

      final bobEntries = await container.read(vaccinationProvider.future);
      expect(bobEntries.map((e) => e.name), contains('MMR'));
      expect(bobEntries.map((e) => e.name), isNot(contains('Flu')));
    });

    // QA-VAX-REG-USER-SWITCH-002
    test('user A (has records) → user B (no records): shows empty list',
        () async {
      final fakeRepo = FakeVaccinationRepository();
      fakeRepo.seedAll([
        Fixtures.singleShotPast(name: 'Flu', userId: 1), // Alice only
      ]);

      final container =
          _makeContainer(fakeRepo, Fixtures.userAlice());
      addTearDown(container.dispose);

      await container.read(vaccinationProvider.future);

      // Switch to Bob (no records)
      (container.read(activeUserProvider.notifier) as FakeActiveUserNotifier)
          .setUser(Fixtures.userBob());

      final bobEntries = await container.read(vaccinationProvider.future);
      expect(bobEntries, isEmpty);
    });

    // QA-VAX-REG-USER-SWITCH-003
    test('user A (no records) → user B (has records): shows B records',
        () async {
      final fakeRepo = FakeVaccinationRepository();
      fakeRepo.seedAll([
        Fixtures.singleShotPast(name: 'MMR', userId: 2), // Bob only
      ]);

      final container =
          _makeContainer(fakeRepo, Fixtures.userAlice()); // Alice has no records
      addTearDown(container.dispose);

      final aliceEntries = await container.read(vaccinationProvider.future);
      expect(aliceEntries, isEmpty);

      // Switch to Bob
      (container.read(activeUserProvider.notifier) as FakeActiveUserNotifier)
          .setUser(Fixtures.userBob());

      final bobEntries = await container.read(vaccinationProvider.future);
      expect(bobEntries, hasLength(1));
      expect(bobEntries.first.name, 'MMR');
    });

    // QA-VAX-REG-USER-SWITCH-004
    test('user A (no records) → user B (no records): empty list remains',
        () async {
      final fakeRepo = FakeVaccinationRepository();
      // No records seeded for either user

      final container =
          _makeContainer(fakeRepo, Fixtures.userAlice());
      addTearDown(container.dispose);

      await container.read(vaccinationProvider.future);

      // Switch to Bob
      (container.read(activeUserProvider.notifier) as FakeActiveUserNotifier)
          .setUser(Fixtures.userBob());

      final bobEntries = await container.read(vaccinationProvider.future);
      expect(bobEntries, isEmpty);
    });
  });
}
