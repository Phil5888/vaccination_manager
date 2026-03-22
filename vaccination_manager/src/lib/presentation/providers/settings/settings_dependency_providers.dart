import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/data/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});
