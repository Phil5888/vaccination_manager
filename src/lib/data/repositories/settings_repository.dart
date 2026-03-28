import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaccination_manager/domain/entities/notification_preference_entity.dart';

class SettingsRepository {
  static const _keyLang = 'language';
  static const _keyTheme = 'darkMode';
  static const _leadTimeDaysKey = 'leadTimeDays';
  static const _keyNotificationsEnabled = 'notificationsEnabled';
  static const _keyCalendarSyncEnabled = 'calendarSyncEnabled';
  static const _keyReminderAdvanceDays = 'reminderAdvanceDays';
  static const _keyNotificationHour = 'notificationHour';
  static const _keyNotificationMinute = 'notificationMinute';

  Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLang);
  }

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTheme) ?? false;
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLang, language);
  }

  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTheme, isDark);
  }

  Future<int> getLeadTimeDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_leadTimeDaysKey) ?? 30;
  }

  Future<void> setLeadTimeDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_leadTimeDaysKey, days);
  }

  Future<NotificationPreferenceEntity> getNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationPreferenceEntity(
      notificationsEnabled:
          prefs.getBool(_keyNotificationsEnabled) ?? true,
      calendarSyncEnabled:
          prefs.getBool(_keyCalendarSyncEnabled) ?? false,
      reminderAdvanceDays:
          prefs.getInt(_keyReminderAdvanceDays) ?? 7,
      notificationHour:
          prefs.getInt(_keyNotificationHour) ?? 9,
      notificationMinute:
          prefs.getInt(_keyNotificationMinute) ?? 0,
    );
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, value);
  }

  Future<void> setCalendarSyncEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCalendarSyncEnabled, value);
  }

  Future<void> setReminderAdvanceDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyReminderAdvanceDays, days);
  }

  Future<void> setNotificationTimeOfDay(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyNotificationHour, hour);
    await prefs.setInt(_keyNotificationMinute, minute);
  }
}
