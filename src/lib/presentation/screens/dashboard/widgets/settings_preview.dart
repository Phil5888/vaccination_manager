import 'package:flutter/material.dart';
import 'package:vaccination_manager/core/utils/localization_utils.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/presentation/viewmodels/settings_viewmodel.dart';

class SettingsPreviewCard extends ConsumerWidget {
  const SettingsPreviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final local = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(local.settings, style: Theme.of(context).textTheme.titleLarge),
            Text('${local.language}: ${getLanguageLabel(context, settings.locale.languageCode, withFlag: true)}'),
            Text('${local.darkMode}: ${settings.isDarkMode ? local.on : local.off}'),
          ],
        ),
      ),
    );
  }
}
