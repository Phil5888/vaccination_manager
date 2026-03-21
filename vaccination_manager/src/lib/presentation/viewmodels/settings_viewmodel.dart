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

class SettingsViewModel extends StateNotifier<SettingsState> {
  final SettingsRepository _repo;

  SettingsViewModel(this._repo) : super(SettingsState(locale: Locale('en'), isDarkMode: false)) {
    _load();
  }

  Future<void> _load() async {
    final String? lang = await _repo.getLanguage();
    final bool dark = await _repo.getDarkMode();
    state = SettingsState(locale: Locale(lang ?? WidgetsBinding.instance.platformDispatcher.locale.languageCode), isDarkMode: dark);
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
}

final settingsProvider = StateNotifierProvider<SettingsViewModel, SettingsState>((ref) => SettingsViewModel(SettingsRepository()));
