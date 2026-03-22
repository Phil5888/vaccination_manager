import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const _keyLang = 'language';
  static const _keyTheme = 'darkMode';
  static const _keyReminderLeadTime = 'reminderLeadTime';

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

  Future<String?> getReminderLeadTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyReminderLeadTime);
  }

  Future<void> setReminderLeadTime(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyReminderLeadTime, value);
  }
}
