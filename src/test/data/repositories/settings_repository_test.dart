// Tests for SettingsRepository — the real implementation backed by
// SharedPreferences. Uses SharedPreferences.setMockInitialValues to provide
// a clean in-memory store without any platform channel I/O.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaccination_manager/data/repositories/settings_repository.dart';

void main() {
  setUp(() {
    // Reset shared_preferences to empty state before every test so tests
    // are fully isolated.
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsRepository', () {
    group('getDarkMode', () {
      test('returns false when key is absent (default)', () async {
        final repo = SettingsRepository();
        expect(await repo.getDarkMode(), isFalse);
      });

      test('returns stored value after setDarkMode', () async {
        final repo = SettingsRepository();
        await repo.setDarkMode(true);
        expect(await repo.getDarkMode(), isTrue);
      });

      test('round-trip false after toggling back', () async {
        final repo = SettingsRepository();
        await repo.setDarkMode(true);
        await repo.setDarkMode(false);
        expect(await repo.getDarkMode(), isFalse);
      });
    });

    group('getLanguage', () {
      test('returns null when key is absent', () async {
        final repo = SettingsRepository();
        expect(await repo.getLanguage(), isNull);
      });

      test('returns stored value after setLanguage', () async {
        final repo = SettingsRepository();
        await repo.setLanguage('de');
        expect(await repo.getLanguage(), 'de');
      });
    });

    group('getLeadTimeDays', () {
      test('returns 30 when key is absent (default)', () async {
        final repo = SettingsRepository();
        expect(await repo.getLeadTimeDays(), 30);
      });

      test('returns stored value after setLeadTimeDays', () async {
        final repo = SettingsRepository();
        await repo.setLeadTimeDays(14);
        expect(await repo.getLeadTimeDays(), 14);
      });

      test('stores 0 correctly (minimum boundary)', () async {
        final repo = SettingsRepository();
        await repo.setLeadTimeDays(0);
        expect(await repo.getLeadTimeDays(), 0);
      });
    });

    group('getNotificationPreferences', () {
      test('returns correct defaults when no keys are stored', () async {
        final repo = SettingsRepository();
        final prefs = await repo.getNotificationPreferences();
        expect(prefs.notificationsEnabled, isTrue);
        expect(prefs.calendarSyncEnabled, isFalse);
        expect(prefs.reminderAdvanceDays, 7);
        expect(prefs.notificationHour, 9);
        expect(prefs.notificationMinute, 0);
      });

      test('setNotificationsEnabled persists correctly', () async {
        final repo = SettingsRepository();
        await repo.setNotificationsEnabled(false);
        final prefs = await repo.getNotificationPreferences();
        expect(prefs.notificationsEnabled, isFalse);
      });

      test('setCalendarSyncEnabled persists correctly', () async {
        final repo = SettingsRepository();
        await repo.setCalendarSyncEnabled(true);
        final prefs = await repo.getNotificationPreferences();
        expect(prefs.calendarSyncEnabled, isTrue);
      });

      test('setReminderAdvanceDays persists correctly', () async {
        final repo = SettingsRepository();
        await repo.setReminderAdvanceDays(14);
        final prefs = await repo.getNotificationPreferences();
        expect(prefs.reminderAdvanceDays, 14);
      });

      test('setNotificationTimeOfDay persists both hour and minute', () async {
        final repo = SettingsRepository();
        await repo.setNotificationTimeOfDay(15, 30);
        final prefs = await repo.getNotificationPreferences();
        expect(prefs.notificationHour, 15);
        expect(prefs.notificationMinute, 30);
      });

      test('partial updates do not change other fields', () async {
        final repo = SettingsRepository();
        await repo.setNotificationsEnabled(false);
        // Other fields must remain at their defaults
        final prefs = await repo.getNotificationPreferences();
        expect(prefs.calendarSyncEnabled, isFalse);
        expect(prefs.reminderAdvanceDays, 7);
        expect(prefs.notificationHour, 9);
        expect(prefs.notificationMinute, 0);
      });
    });
  });
}
