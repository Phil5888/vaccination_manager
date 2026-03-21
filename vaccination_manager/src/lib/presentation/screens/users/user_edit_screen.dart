import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/domain/entities/app_user_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/viewmodels/user_management_viewmodel.dart';
import 'package:vaccination_manager/presentation/widgets/user_profile_form.dart';

class UserEditScreen extends ConsumerWidget {
  const UserEditScreen({super.key, this.initialUser});

  final AppUserEntity? initialUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(initialUser == null ? local.addUser : local.editProfile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: UserProfileForm(
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
          ),
        ),
      ),
    );
  }
}
