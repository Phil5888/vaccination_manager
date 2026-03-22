import 'package:flutter/material.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vaccination_manager/presentation/navigation/app_router.dart';
import 'package:vaccination_manager/presentation/providers/settings/settings_providers.dart';
import 'package:vaccination_manager/presentation/screens/startup/app_startup_gate.dart';
import 'package:vaccination_manager/presentation/viewmodels/theme_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final localeCode = ref.watch(settingsProvider).locale.languageCode;

    return MaterialApp(
      title: 'Vaccination Manager',
      theme: theme,
      onGenerateRoute: AppRouter.generateRoute,
      home: const AppStartupGate(),
      locale: Locale(localeCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    );
  }
}
