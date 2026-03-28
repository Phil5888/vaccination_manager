import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/presentation/providers/user_providers.dart';
import 'package:vaccination_manager/presentation/screens/main/main_screen.dart';

class AppStartupGate extends ConsumerWidget {
  const AppStartupGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(userListProvider);

    return usersAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
      data: (users) {
        if (users.isEmpty) {
          // Use addPostFrameCallback so we don't navigate during build.
          // This gate is only mounted at app startup — once we navigate away,
          // this widget is removed from the tree and will never re-fire.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed(Routes.welcome);
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Users exist — go straight to the shell. Never navigated back to here
        // after profile creation (CreateProfileScreen pushes MainScreen directly).
        return const MainScreen();
      },
    );
  }
}
