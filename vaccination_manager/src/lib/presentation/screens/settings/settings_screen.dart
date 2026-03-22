import 'package:flutter/material.dart';
import 'package:vaccination_manager/core/utils/localization_utils.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/presentation/providers/settings/settings_providers.dart';
import 'package:vaccination_manager/presentation/providers/user_management/user_management_providers.dart';
import 'package:vaccination_manager/presentation/widgets/user_avatar.dart';
import 'package:vaccination_manager/presentation/widgets/user_switcher_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final usersState = ref.watch(userManagementProvider);
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
          const SizedBox(height: 24),
          Text(local.activeUser, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          usersState.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('${local.error}: $error'),
            data: (state) {
              final activeUser = state.activeUser;
              if (activeUser == null) {
                return Text(local.noUsersBody);
              }

              return Card(
                child: ListTile(
                  leading: UserAvatar(user: activeUser, radius: 22),
                  title: Text(activeUser.username),
                  subtitle: Text(state.users.length == 1 ? local.singleUserHint : local.multipleUsersHint(state.users.length)),
                  trailing: FilledButton.tonal(onPressed: () => showUserSwitcherSheet(context, ref), child: Text(local.switchUser)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
