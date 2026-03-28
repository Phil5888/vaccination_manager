import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/domain/entities/user_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/user_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final activeUserAsync = ref.watch(activeUserProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: activeUserAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('${local.error}: $e')),
          data: (user) => _ProfileBody(
            user: user,
            local: local,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile body (extracted so it rebuilds cleanly when user is non-null)
// ---------------------------------------------------------------------------
class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({
    required this.user,
    required this.local,
    required this.colorScheme,
    required this.textTheme,
  });

  final UserEntity? user;
  final AppLocalizations local;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (user == null) {
      return Center(
        child: Text(
          local.noProfilesFound,
          style: textTheme.bodyLarge
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          // ── Avatar ──────────────────────────────────────────────────────
          Center(
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surfaceContainerHigh,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _initials(user!.username),
                  style: textTheme.headlineLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // ── Username ─────────────────────────────────────────────────────
          Center(
            child: Text(
              user!.username,
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // ── Action cards ─────────────────────────────────────────────────
          _ActionCard(
            icon: Icons.edit_outlined,
            label: local.editProfile,
            colorScheme: colorScheme,
            textTheme: textTheme,
            onTap: () => Navigator.of(context).pushNamed(
              Routes.profileCreate,
              arguments: user,
            ),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.switch_account_outlined,
            label: local.switchProfile,
            colorScheme: colorScheme,
            textTheme: textTheme,
            onTap: () => _showProfileSwitcher(context, ref),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.settings_outlined,
            label: local.settings,
            colorScheme: colorScheme,
            textTheme: textTheme,
            onTap: () => Navigator.of(context).pushNamed(Routes.settings),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showProfileSwitcher(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _ProfileSwitcherSheet(
        currentUserId: user?.id,
        local: local,
        colorScheme: colorScheme,
        textTheme: textTheme,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action card widget
// ---------------------------------------------------------------------------
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.titleSmall
                      ?.copyWith(color: colorScheme.onSurface),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile switcher bottom sheet
// ---------------------------------------------------------------------------
class _ProfileSwitcherSheet extends ConsumerWidget {
  const _ProfileSwitcherSheet({
    required this.currentUserId,
    required this.local,
    required this.colorScheme,
    required this.textTheme,
  });

  final int? currentUserId;
  final AppLocalizations local;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(userListProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              local.profileSwitcher,
              style: textTheme.titleLarge
                  ?.copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            usersAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('${local.error}: $e')),
              data: (users) {
                if (users.isEmpty) {
                  return Text(
                    local.noProfilesFound,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: users.map((u) {
                    final isActive = u.id == currentUserId;
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 4),
                      leading: CircleAvatar(
                        backgroundColor: isActive
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerHigh,
                        child: Text(
                          _initials(u.username),
                          style: textTheme.labelLarge?.copyWith(
                            color: isActive
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      title: Text(
                        u.username,
                        style: textTheme.titleSmall
                            ?.copyWith(color: colorScheme.onSurface),
                      ),
                      trailing: isActive
                          ? Icon(Icons.check,
                              color: colorScheme.primary)
                          : null,
                      onTap: () async {
                        await ref
                            .read(activeUserProvider.notifier)
                            .setActiveUser(u.id!);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    );
                  }).toList(),
                );
              },
            ),
            const Divider(height: 24),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: CircleAvatar(
                backgroundColor:
                    colorScheme.primaryContainer.withValues(alpha: 0.4),
                child: Icon(Icons.add, color: colorScheme.primary),
              ),
              title: Text(
                local.addNewProfile,
                style: textTheme.titleSmall
                    ?.copyWith(color: colorScheme.primary),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(Routes.profileCreate);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

