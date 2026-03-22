import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/core/constants/app_spacing.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/user_management/user_management_providers.dart';
import 'package:vaccination_manager/presentation/widgets/user_profile_form.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: AppSpacing.contentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(local.welcomeTitle, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.md),
                Text(local.welcomeBody, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.xl),
                Card(
                  child: Padding(
                    padding: AppSpacing.contentPadding,
                    child: UserProfileForm(
                      submitLabel: local.createFirstUser,
                      onSubmit: (username, picture) async {
                        await ref.read(userManagementProvider.notifier).saveUser(username: username, profilePicture: picture);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
