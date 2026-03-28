import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/domain/entities/reminder_status.dart';
import 'package:vaccination_manager/presentation/providers/user_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_dependency_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_providers.dart';
import 'package:vaccination_manager/presentation/viewmodels/settings_viewmodel.dart';

import '../../helpers/fakes/fake_active_user_notifier.dart';
import '../../helpers/fakes/fake_settings_repository.dart';
import '../../helpers/fakes/fake_vaccination_repository.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeVaccinationRepository fakeRepo;

  ProviderContainer makeContainer({int leadTimeDays = 30}) {
    return ProviderContainer(overrides: [
      activeUserProvider
          .overrideWith(() => FakeActiveUserNotifier(Fixtures.userAlice())),
      vaccinationRepositoryProvider.overrideWith((_) => fakeRepo),
      settingsRepositoryProvider
          .overrideWith((_) => FakeSettingsRepository(leadTimeDays: leadTimeDays)),
    ]);
  }

  setUp(() {
    fakeRepo = FakeVaccinationRepository();
  });

  group('VaccinationRemindersViewModel', () {
    test('returns empty list when no vaccinations exist', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final reminders =
          await container.read(vaccinationRemindersProvider.future);
      expect(reminders, isEmpty);
    });

    test('complete series with no next-dose reminder → upToDate', () async {
      fakeRepo.seedAll([Fixtures.singleShotPast(userId: 1)]);
      final container = makeContainer();
      addTearDown(container.dispose);

      final reminders =
          await container.read(vaccinationRemindersProvider.future);
      expect(reminders.length, 1);
      expect(reminders.first.status, ReminderStatus.upToDate);
    });

    test('series due within lead time → dueSoon', () async {
      fakeRepo.seedAll([
        Fixtures.singleShotFuture(userId: 1), // 30 days ahead
      ]);
      final container = makeContainer(leadTimeDays: 60);
      addTearDown(container.dispose);

      final reminders =
          await container.read(vaccinationRemindersProvider.future);
      expect(reminders.length, 1);
      expect(reminders.first.status, ReminderStatus.dueSoon);
    });

    test('series due beyond lead time → upToDate', () async {
      fakeRepo.seedAll([
        Fixtures.singleShotFuture(userId: 1), // 30 days ahead
      ]);
      final container = makeContainer(leadTimeDays: 14);
      addTearDown(container.dispose);

      final reminders =
          await container.read(vaccinationRemindersProvider.future);
      expect(reminders.length, 1);
      expect(reminders.first.status, ReminderStatus.upToDate);
    });

    test('single-shot with overdue next-vaccination-date → overdue', () async {
      fakeRepo.seedAll([
        Fixtures.singleShotComplete(
          userId: 1,
          nextVaccinationDate: Fixtures.thirtyDaysAgo,
        ),
      ]);
      final container = makeContainer();
      addTearDown(container.dispose);

      final reminders =
          await container.read(vaccinationRemindersProvider.future);
      expect(reminders.length, 1);
      expect(reminders.first.status, ReminderStatus.overdue);
    });

    test('mixed statuses returned in order: overdue, dueSoon, upToDate',
        () async {
      fakeRepo.seedAll([
        // upToDate: complete, no next reminder
        Fixtures.singleShotPast(name: 'Flu', userId: 1),
        // dueSoon: planned in 5 days, lead time 30 → dueSoon
        Fixtures.singleShotFuture(name: 'Hepatitis A', userId: 1)
            .copyWith(
          vaccinationDate:
              Fixtures.today.add(const Duration(days: 5)),
        ),
        // overdue: next dose was 30 days ago
        Fixtures.singleShotComplete(
          name: 'Tetanus',
          userId: 1,
          nextVaccinationDate: Fixtures.thirtyDaysAgo,
        ),
      ]);
      final container = makeContainer(leadTimeDays: 30);
      addTearDown(container.dispose);

      final reminders =
          await container.read(vaccinationRemindersProvider.future);
      expect(reminders.length, 3);
      expect(reminders[0].status, ReminderStatus.overdue);
      expect(reminders[1].status, ReminderStatus.dueSoon);
      expect(reminders[2].status, ReminderStatus.upToDate);
    });

    test('respects custom lead time from settings', () async {
      // Shot is 20 days away
      fakeRepo.seedAll([
        Fixtures.singleShotUnscheduled(userId: 1).copyWith(
          vaccinationDate: Fixtures.today.add(const Duration(days: 20)),
        ),
      ]);

      // With 30-day lead time → dueSoon
      final containerA = makeContainer(leadTimeDays: 30);
      addTearDown(containerA.dispose);
      final remindersA =
          await containerA.read(vaccinationRemindersProvider.future);
      expect(remindersA.first.status, ReminderStatus.dueSoon);

      // With 7-day lead time → upToDate
      final containerB = makeContainer(leadTimeDays: 7);
      addTearDown(containerB.dispose);
      final remindersB =
          await containerB.read(vaccinationRemindersProvider.future);
      expect(remindersB.first.status, ReminderStatus.upToDate);
    });
  });

  group('filteredRemindersProvider', () {
    test('filter=all returns all reminders', () async {
      fakeRepo.seedAll([
        Fixtures.singleShotPast(name: 'Flu', userId: 1),
        Fixtures.singleShotFuture(name: 'COVID', userId: 1),
      ]);
      final container = makeContainer();
      addTearDown(container.dispose);
      await container.read(vaccinationRemindersProvider.future);

      final filtered = container.read(filteredRemindersProvider);
      filtered.whenData((list) => expect(list.length, 2));
    });

    test('filter=overdue returns only overdue reminders', () async {
      fakeRepo.seedAll([
        Fixtures.singleShotPast(name: 'Flu', userId: 1),
        Fixtures.singleShotComplete(
          name: 'Tetanus',
          userId: 1,
          nextVaccinationDate: Fixtures.thirtyDaysAgo,
        ),
      ]);
      final container = makeContainer();
      addTearDown(container.dispose);
      await container.read(vaccinationRemindersProvider.future);

      container
          .read(scheduleFilterProvider.notifier)
          .setFilter(ReminderFilter.overdue);
      final filtered = container.read(filteredRemindersProvider);
      filtered.whenData((list) {
        expect(list.length, 1);
        expect(list.first.series.name, 'Tetanus');
      });
    });
  });
}
