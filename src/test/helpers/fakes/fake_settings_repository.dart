import 'package:vaccination_manager/data/repositories/settings_repository.dart';

/// A [SettingsRepository] stub for tests that avoids SharedPreferences I/O.
class FakeSettingsRepository extends SettingsRepository {
  int _leadTimeDays;

  FakeSettingsRepository({int leadTimeDays = 30}) : _leadTimeDays = leadTimeDays;

  @override
  Future<int> getLeadTimeDays() async => _leadTimeDays;

  @override
  Future<void> setLeadTimeDays(int days) async => _leadTimeDays = days;

  @override
  Future<String?> getLanguage() async => 'en';

  @override
  Future<bool> getDarkMode() async => false;

  @override
  Future<void> setLanguage(String language) async {}

  @override
  Future<void> setDarkMode(bool isDark) async {}
}
