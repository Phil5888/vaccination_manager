import 'package:flutter/material.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vaccination_manager/presentation/navigation/app_router.dart';
import 'package:vaccination_manager/presentation/viewmodels/settings_viewmodel.dart';
import 'package:vaccination_manager/presentation/viewmodels/theme_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final localeCode = ref.watch(settingsProvider).locale.languageCode;

    return MaterialApp(
      title: 'Flutter Playground Riverpod',
      theme: theme,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: Routes.dashboard,
      locale: Locale(localeCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    );
  }
}
