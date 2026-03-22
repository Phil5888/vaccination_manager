import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/core/constants/app_spacing.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/domain/entities/app_user_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/user_management/user_management_providers.dart';
import 'package:vaccination_manager/presentation/widgets/user_avatar.dart';
import 'package:vaccination_manager/presentation/widgets/user_profile_form.dart';

class UserEditScreen extends ConsumerWidget {
  const UserEditScreen({super.key, this.initialUser});

  final AppUserEntity? initialUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;
    final activeUser = ref.watch(activeUserProvider);
    final isCurrentUser = initialUser?.id != null && initialUser!.id == activeUser?.id;

    return Scaffold(
      appBar: AppBar(title: Text(initialUser == null ? local.addUser : local.editProfile)),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (initialUser != null) ...[
                  Card(
                    child: Padding(
                      padding: AppSpacing.cardPadding,
                      child: Wrap(
                        spacing: AppSpacing.lg,
                        runSpacing: AppSpacing.lg,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              UserAvatar(user: initialUser!, radius: 24),
                              const SizedBox(width: AppSpacing.md),
                              Text(initialUser!.username, style: Theme.of(context).textTheme.titleMedium),
                            ],
                          ),
                          if (initialUser!.id != null)
                            isCurrentUser
                                ? Chip(avatar: const Icon(Icons.check_circle, size: 18), label: Text(local.currentUser))
                                : FilledButton.tonalIcon(
                                    onPressed: () async {
                                      await ref.read(userManagementProvider.notifier).switchUser(initialUser!.id!);
                                      if (context.mounted) {
                                        Navigator.of(context).pushNamedAndRemoveUntil(Routes.dashboard, (route) => false);
                                      }
                                    },
                                    icon: const Icon(Icons.swap_horiz),
                                    label: Text(local.switchUser),
                                  ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                UserProfileForm(
                  initialUsername: initialUser?.username,
                  initialProfilePicture: initialUser?.profilePicture,
                  submitLabel: local.save,
                  onSubmit: (username, picture) async {
                    await ref.read(userManagementProvider.notifier).saveUser(id: initialUser?.id, username: username, profilePicture: picture, keepCurrentActiveState: true);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(local.saveUserSuccess)));
                      Navigator.of(context).pop();
                    }
                  },
                  onCancel: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
