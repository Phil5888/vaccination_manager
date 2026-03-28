import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/data/repositories/settings_repository.dart';

class SettingsState {
  final Locale locale;
  final bool isDarkMode;

  SettingsState({required this.locale, required this.isDarkMode});

  SettingsState copyWith({Locale? locale, bool? isDarkMode}) {
    return SettingsState(locale: locale ?? this.locale, isDarkMode: isDarkMode ?? this.isDarkMode);
  }
}

class SettingsViewModel extends Notifier<SettingsState> {
  late final SettingsRepository _repo;

  @override
  SettingsState build() {
    _repo = SettingsRepository();
    _load();
    return SettingsState(locale: Locale(WidgetsBinding.instance.platformDispatcher.locale.languageCode), isDarkMode: false);
  }

  Future<void> _load() async {
    final String? lang = await _repo.getLanguage();
    final bool dark = await _repo.getDarkMode();
    state = SettingsState(locale: Locale(lang ?? WidgetsBinding.instance.platformDispatcher.locale.languageCode), isDarkMode: dark);
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
}

final settingsProvider = NotifierProvider<SettingsViewModel, SettingsState>(SettingsViewModel.new);
