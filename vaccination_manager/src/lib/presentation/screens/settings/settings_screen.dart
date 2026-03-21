import 'package:flutter/material.dart';
import 'package:vaccination_manager/core/utils/localization_utils.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/presentation/viewmodels/settings_viewmodel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: MediaQuery.of(context).size.width < 800 ? AppBar(title: Text(local.settings)) : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(local.language, style: TextStyle(fontSize: 18)),
          DropdownButton<String>(
            value: settings.locale.languageCode,
            items: AppLocalizations.supportedLocales.map((locale) => DropdownMenuItem<String>(value: locale.languageCode, child: Text(getLanguageLabel(context, locale.languageCode, withFlag: true)))).toList(),
            onChanged: notifier.setLanguage,
          ),
          const SizedBox(height: 24),
          Text(local.theme, style: TextStyle(fontSize: 18)),
          SwitchListTile(title: Text(local.darkMode), value: settings.isDarkMode, onChanged: notifier.setDarkMode),
        ],
      ),
    );
  }
}
