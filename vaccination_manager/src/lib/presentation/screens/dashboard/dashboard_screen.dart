import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/user_management/user_management_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination/vaccination_providers.dart';
import 'package:vaccination_manager/presentation/widgets/user_avatar.dart';
import 'package:vaccination_manager/presentation/widgets/user_switcher_sheet.dart';
import 'package:vaccination_manager/presentation/widgets/vaccination_status_chip.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;
    final userState = ref.watch(userManagementProvider);
    final vaccinationState = ref.watch(vaccinationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(local.dashboard)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            return isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _WelcomeDashboardCard(userState: userState, vaccinationState: vaccinationState),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 7,
                        child: _UpcomingVaccinationsCard(vaccinationState: vaccinationState, userState: userState),
                      ),
                    ],
                  )
                : ListView(
                    children: [
                      _WelcomeDashboardCard(userState: userState, vaccinationState: vaccinationState),
                      const SizedBox(height: 16),
                      _UpcomingVaccinationsCard(vaccinationState: vaccinationState, userState: userState),
                    ],
                  );
          },
        ),
      ),
    );
  }
}

class _WelcomeDashboardCard extends ConsumerWidget {
  const _WelcomeDashboardCard({required this.userState, required this.vaccinationState});

  final AsyncValue userState;
  final AsyncValue vaccinationState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;
    final now = DateTime.now();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: userState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('${local.error}: $error'),
          data: (state) {
            final activeUser = state.activeUser;
            if (activeUser == null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(local.noUsersTitle, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(local.noUsersBody),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: () => Navigator.of(context).pushNamed(Routes.userEdit), child: Text(local.addUser)),
                ],
              );
            }

            final vaccinationData = vaccinationState.asData?.value;
            final overdue = vaccinationData?.overdueCountAt(now) ?? 0;
            final dueSoon = vaccinationData?.dueSoonCountAt(now) ?? 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UserAvatar(user: activeUser, radius: 28),
                    const SizedBox(width: 12),
                    Expanded(child: Text(local.dashboardHeroGreeting(activeUser.username), style: Theme.of(context).textTheme.headlineSmall)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(local.dashboardHeroSubtitle, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('${local.overdue}: $overdue')),
                    Chip(label: Text('${local.dueSoon}: $dueSoon')),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.tonalIcon(onPressed: () => showUserSwitcherSheet(context, ref), icon: const Icon(Icons.swap_horiz), label: Text(local.switchUser)),
                    OutlinedButton.icon(onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(Routes.users, (route) => false), icon: const Icon(Icons.manage_accounts_outlined), label: Text(local.manageUsers)),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _UpcomingVaccinationsCard extends StatelessWidget {
  const _UpcomingVaccinationsCard({required this.vaccinationState, required this.userState});

  final AsyncValue vaccinationState;
  final AsyncValue userState;

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final now = DateTime.now();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: vaccinationState.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text('${local.error}: $error'),
          data: (state) {
            if (!state.hasActiveUser) {
              return Text(local.noUsersBody);
            }

            if (!state.hasVaccinations) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(local.noVaccinationsTitle, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(local.noVaccinationsBody),
                  const SizedBox(height: 16),
                  FilledButton.tonal(onPressed: () => Navigator.of(context).pushNamed(Routes.vaccinationEdit), child: Text(local.addVaccination)),
                ],
              );
            }

            final dueSeries = state.series.where((series) {
              final status = series.statusAt(now);
              return status == VaccinationDueStatus.overdue || status == VaccinationDueStatus.dueSoon;
            }).toList();

            dueSeries.sort((VaccinationSeriesEntity a, VaccinationSeriesEntity b) {
              final aStatusWeight = _statusWeight(a.statusAt(now));
              final bStatusWeight = _statusWeight(b.statusAt(now));
              if (aStatusWeight != bStatusWeight) {
                return aStatusWeight.compareTo(bStatusWeight);
              }
              return a.nextDueDateAt(now).compareTo(b.nextDueDateAt(now));
            });

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(local.dashboardUpcomingTitle, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('${local.overdue}: ${state.overdueCountAt(now)}')),
                    Chip(label: Text('${local.dueSoon}: ${state.dueSoonCountAt(now)}')),
                  ],
                ),
                const SizedBox(height: 16),
                if (dueSeries.isEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.verified_outlined, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 10),
                      Expanded(child: Text(local.dashboardAllGoodTitle, style: Theme.of(context).textTheme.titleMedium)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(local.dashboardAllGoodBody),
                ] else ...[
                  ...dueSeries.map(
                    (series) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(series.name),
                      subtitle: Text('${local.nextDue}: ${MaterialLocalizations.of(context).formatCompactDate(series.nextDueDateAt(now))}'),
                      trailing: VaccinationStatusChip(status: series.statusAt(now)),
                      onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(Routes.vaccinations, (route) => false),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton.tonal(onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(Routes.vaccinations, (route) => false), child: Text(local.dashboardOpenVaccinations)),
              ],
            );
          },
        ),
      ),
    );
  }

  int _statusWeight(VaccinationDueStatus status) {
    switch (status) {
      case VaccinationDueStatus.overdue:
        return 0;
      case VaccinationDueStatus.dueSoon:
        return 1;
      case VaccinationDueStatus.upToDate:
        return 2;
    }
  }
}
