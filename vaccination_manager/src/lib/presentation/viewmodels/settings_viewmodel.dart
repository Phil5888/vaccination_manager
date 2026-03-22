import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/core/constants/reminder_lead_time.dart';
import 'package:vaccination_manager/data/repositories/settings_repository.dart';
import 'package:vaccination_manager/presentation/providers/settings/settings_dependency_providers.dart';

class SettingsState {
  final Locale locale;
  final bool isDarkMode;
  final ReminderLeadTime reminderLeadTime;

  SettingsState({required this.locale, required this.isDarkMode, required this.reminderLeadTime});

  SettingsState copyWith({Locale? locale, bool? isDarkMode, ReminderLeadTime? reminderLeadTime}) {
    return SettingsState(locale: locale ?? this.locale, isDarkMode: isDarkMode ?? this.isDarkMode, reminderLeadTime: reminderLeadTime ?? this.reminderLeadTime);
  }
}

class SettingsViewModel extends Notifier<SettingsState> {
  late final SettingsRepository _repo;

  @override
  SettingsState build() {
    _repo = ref.read(settingsRepositoryProvider);
    _load();
    return SettingsState(locale: const Locale('en'), isDarkMode: false, reminderLeadTime: ReminderLeadTime.oneWeek);
  }

  Future<void> _load() async {
    final String? lang = await _repo.getLanguage();
    final bool dark = await _repo.getDarkMode();
    final reminderLeadTime = ReminderLeadTime.fromStorageKey(await _repo.getReminderLeadTime());
    state = SettingsState(locale: Locale(lang ?? WidgetsBinding.instance.platformDispatcher.locale.languageCode), isDarkMode: dark, reminderLeadTime: reminderLeadTime);
  }

  void setLanguage(String? lang) async {
    if (lang != null) {
      await _repo.setLanguage(lang);
      state = state.copyWith(locale: Locale(lang));
    }
  }

  void setDarkMode(bool value) async {
    await _repo.setDarkMode(value);
    state = state.copyWith(isDarkMode: value);
  }

  Future<void> setReminderLeadTime(ReminderLeadTime value) async {
    await _repo.setReminderLeadTime(value.storageKey);
    state = state.copyWith(reminderLeadTime: value);
  }
}
