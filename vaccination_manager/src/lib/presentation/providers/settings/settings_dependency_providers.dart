import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/core/services/reminder_sync_service.dart';
import 'package:vaccination_manager/data/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final reminderSyncServiceProvider = Provider<ReminderSyncService>((ref) {
  return ReminderSyncService();
});
