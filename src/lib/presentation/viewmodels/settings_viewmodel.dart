import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/data/repositories/settings_repository.dart';

/// Exposes a shared [SettingsRepository] instance to the provider graph.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

class SettingsState {
  final Locale locale;
  final bool isDarkMode;
  final int leadTimeDays;

  SettingsState({
    required this.locale,
    required this.isDarkMode,
    this.leadTimeDays = 30,
  });

  SettingsState copyWith({Locale? locale, bool? isDarkMode, int? leadTimeDays}) {
    return SettingsState(
      locale: locale ?? this.locale,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      leadTimeDays: leadTimeDays ?? this.leadTimeDays,
    );
  }
}

class SettingsViewModel extends Notifier<SettingsState> {
  late final SettingsRepository _repo;

  @override
  SettingsState build() {
    _repo = SettingsRepository();
    _load();
    return SettingsState(
      locale: Locale(WidgetsBinding.instance.platformDispatcher.locale.languageCode),
      isDarkMode: false,
    );
  }

  Future<void> _load() async {
    final String? lang = await _repo.getLanguage();
    final bool dark = await _repo.getDarkMode();
    final int leadTime = await _repo.getLeadTimeDays();
    state = SettingsState(
      locale: Locale(lang ?? WidgetsBinding.instance.platformDispatcher.locale.languageCode),
      isDarkMode: dark,
      leadTimeDays: leadTime,
    );
  }

  Future<void> setLanguage(String? lang) async {
    if (lang != null) {
      await _repo.setLanguage(lang);
      state = state.copyWith(locale: Locale(lang));
    }
  }

  Future<void> setDarkMode(bool value) async {
    await _repo.setDarkMode(value);
    state = state.copyWith(isDarkMode: value);
  }

  Future<void> setLeadTimeDays(int days) async {
    await _repo.setLeadTimeDays(days);
    state = state.copyWith(leadTimeDays: days);
  }
}

final settingsProvider = NotifierProvider<SettingsViewModel, SettingsState>(SettingsViewModel.new);
