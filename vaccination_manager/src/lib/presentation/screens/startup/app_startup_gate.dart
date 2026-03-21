import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/screens/main/main_screen.dart';
import 'package:vaccination_manager/presentation/screens/welcome/welcome_screen.dart';
import 'package:vaccination_manager/presentation/viewmodels/user_management_viewmodel.dart';

class AppStartupGate extends ConsumerWidget {
  const AppStartupGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;
    final userState = ref.watch(userManagementProvider);

    return userState.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('${local.error}: $error', textAlign: TextAlign.center),
          ),
        ),
      ),
      data: (state) => state.hasUsers ? const MainScreen() : const WelcomeScreen(),
    );
  }
}
