import 'package:flutter/material.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/viewmodels/user_management_viewmodel.dart';
import 'package:vaccination_manager/presentation/widgets/user_avatar.dart';
import 'package:vaccination_manager/presentation/widgets/user_switcher_sheet.dart';

class UserPreviewCard extends ConsumerWidget {
  const UserPreviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;
    final userState = ref.watch(userManagementProvider);

    return userState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Card(
        child: Padding(padding: const EdgeInsets.all(16), child: Text('${local.error}: $error')),
      ),
      data: (state) {
        final activeUser = state.activeUser;
        if (activeUser == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(local.noUsersTitle, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(local.noUsersBody),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: () => Navigator.of(context).pushNamed(Routes.userEdit), child: Text(local.addUser)),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(local.activeUser, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Row(
                  children: [
                    UserAvatar(user: activeUser, radius: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(activeUser.username, style: Theme.of(context).textTheme.titleLarge),
                          Text(state.users.length == 1 ? local.singleUserHint : local.multipleUsersHint(state.users.length), style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.tonalIcon(onPressed: () => showUserSwitcherSheet(context, ref), icon: const Icon(Icons.swap_horiz), label: Text(local.switchUser)),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed(Routes.userEdit, arguments: activeUser),
                      icon: const Icon(Icons.edit),
                      label: Text(local.editProfile),
                    ),
                    TextButton(onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(Routes.users, (route) => false), child: Text(local.manageUsers)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
