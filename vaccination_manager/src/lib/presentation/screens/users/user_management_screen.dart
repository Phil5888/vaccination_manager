import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/viewmodels/user_management_viewmodel.dart';
import 'package:vaccination_manager/presentation/widgets/user_avatar.dart';
import 'package:vaccination_manager/presentation/widgets/user_switcher_sheet.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;
    final userState = ref.watch(userManagementProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(local.manageUsers),
        actions: [IconButton(icon: const Icon(Icons.swap_horiz), onPressed: () => showUserSwitcherSheet(context, ref))],
      ),
      body: userState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('${local.error}: $error')),
        data: (state) {
          if (!state.hasUsers) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(local.noUsersTitle, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(local.noUsersBody, textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.users.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = state.users[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: UserAvatar(user: user, radius: 24),
                  title: Text(user.username),
                  subtitle: user.isActive ? Text(local.currentUser) : null,
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      if (!user.isActive) FilledButton.tonal(onPressed: () => ref.read(userManagementProvider.notifier).switchUser(user.id!), child: Text(local.switchUser)),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: local.editProfile,
                        onPressed: () => Navigator.of(context).pushNamed(Routes.userEdit, arguments: user),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => Navigator.of(context).pushNamed(Routes.userEdit), icon: const Icon(Icons.add), label: Text(local.addUser)),
    );
  }
}
