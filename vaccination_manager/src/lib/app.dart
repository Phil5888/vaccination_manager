import 'package:flutter/material.dart';
import 'package:vaccination_manager/core/constants/app_theme.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vaccination_manager/presentation/navigation/app_router.dart';
import 'package:vaccination_manager/presentation/screens/startup/app_startup_gate.dart';
import 'package:vaccination_manager/presentation/providers/settings/settings_providers.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Vaccination Manager',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: settings.locale,
      onGenerateRoute: AppRouter.generateRoute,
      home: const AppStartupGate(),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    );
  }
}
