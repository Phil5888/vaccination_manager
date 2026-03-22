import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/core/constants/app_component_styles.dart';
import 'package:vaccination_manager/core/constants/app_spacing.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/domain/entities/app_user_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/user_management/user_management_providers.dart';
import 'package:vaccination_manager/presentation/viewmodels/user_management_viewmodel.dart';
import 'package:vaccination_manager/presentation/widgets/user_avatar.dart';
import 'package:vaccination_manager/presentation/widgets/user_switcher_sheet.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  Future<void> _openSearch(UserManagementState state) async {
    if (!state.hasUsers) {
      return;
    }

    final selectedUser = await Navigator.of(context).push<AppUserEntity>(MaterialPageRoute(builder: (_) => _UserSearchScreen(users: state.users)));

    if (!mounted || selectedUser == null) {
      return;
    }

    await Navigator.of(context).pushNamed(Routes.userEdit, arguments: selectedUser);
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final userState = ref.watch(userManagementProvider);
    final data = userState.asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(local.manageUsers),
        actions: [
          if (data?.hasUsers ?? false)
            Padding(
              padding: AppSpacing.actionPadding,
              child: IconButton.filledTonal(style: AppComponentStyles.appBarSecondaryIconButton(context), icon: const Icon(Icons.search), tooltip: local.searchUsers, onPressed: () => _openSearch(data!)),
            ),
          Padding(
            padding: AppSpacing.actionPadding,
            child: IconButton.filled(style: AppComponentStyles.appBarPrimaryIconButton(context), icon: const Icon(Icons.add), tooltip: local.addUser, onPressed: () => Navigator.of(context).pushNamed(Routes.userEdit)),
          ),
          IconButton(icon: const Icon(Icons.swap_horiz), onPressed: () => showUserSwitcherSheet(context, ref)),
        ],
      ),
      body: userState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('${local.error}: $error')),
        data: (state) {
          if (!state.hasUsers) {
            return Center(
              child: Padding(
                padding: AppSpacing.contentPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(local.noUsersTitle, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text(local.noUsersBody, textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: AppSpacing.listPadding,
            itemCount: state.users.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final user = state.users[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  leading: UserAvatar(user: user, radius: 24),
                  title: Text(user.username),
                  subtitle: user.isActive ? Text(local.currentUser) : null,
                  trailing: Wrap(
                    spacing: 8,
                    children: [
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
    );
  }
}

class _UserSearchScreen extends StatefulWidget {
  const _UserSearchScreen({required this.users});

  final List<AppUserEntity> users;

  @override
  State<_UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<_UserSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<AppUserEntity> _matchesFor(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return const <AppUserEntity>[];
    }

    final matches = widget.users.where((user) => user.username.toLowerCase().contains(normalized)).toList();
    matches.sort((a, b) {
      final aStarts = a.username.toLowerCase().startsWith(normalized);
      final bStarts = b.username.toLowerCase().startsWith(normalized);
      if (aStarts != bStarts) {
        return aStarts ? -1 : 1;
      }
      return a.username.toLowerCase().compareTo(b.username.toLowerCase());
    });
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final matches = _matchesFor(_controller.text);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: (_) => setState(() {}),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: local.searchUsersHint,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  setState(() {
                    _controller.clear();
                  });
                  return;
                }
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          if (_controller.text.trim().isEmpty) {
            return Center(
              child: Padding(
                padding: AppSpacing.contentPadding,
                child: Text(local.searchUsersStart, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
              ),
            );
          }

          if (matches.isEmpty) {
            return Center(
              child: Padding(
                padding: AppSpacing.contentPadding,
                child: Text(local.searchUsersNoMatches, textAlign: TextAlign.center),
              ),
            );
          }

          return ListView.separated(
            padding: AppSpacing.searchResultsPadding,
            itemBuilder: (context, index) {
              final user = matches[index];
              return ListTile(
                tileColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                leading: UserAvatar(user: user, radius: 20),
                title: Text(user.username),
                subtitle: user.isActive ? Text(local.currentUser) : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pop(user),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemCount: matches.length,
          );
        },
      ),
    );
  }
}
