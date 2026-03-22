import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/user_management/user_management_providers.dart';
import 'package:vaccination_manager/presentation/widgets/user_avatar.dart';

Future<void> showUserSwitcherSheet(BuildContext context, WidgetRef ref) {
  final local = AppLocalizations.of(context)!;
  final state = ref.read(userManagementProvider).asData?.value;
  final navigator = Navigator.of(context);

  return showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      final users = state?.users ?? const [];
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(local.quickSwitchTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (users.isEmpty)
                Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(local.noUsersBody))
              else
                ...users.map(
                  (user) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: UserAvatar(user: user, radius: 20),
                    title: Text(user.username),
                    subtitle: Text(user.isActive ? local.currentUser : local.switchUser),
                    trailing: user.isActive ? const Icon(Icons.check_circle) : null,
                    onTap: user.isActive
                        ? () => Navigator.of(context).pop()
                        : () async {
                            await ref.read(userManagementProvider.notifier).switchUser(user.id!);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              navigator.pushNamedAndRemoveUntil(Routes.dashboard, (route) => false);
                            }
                          },
                  ),
                ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.of(context).pop();
                  navigator.pushNamed(Routes.userEdit);
                },
                icon: const Icon(Icons.add),
                label: Text(local.addUser),
              ),
            ],
          ),
        ),
      );
    },
  );
}
