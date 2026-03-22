import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/vaccination/vaccination_providers.dart';
import 'package:vaccination_manager/presentation/screens/vaccinations/vaccination_edit_screen.dart';
import 'package:vaccination_manager/presentation/viewmodels/vaccination_viewmodel.dart';
import 'package:vaccination_manager/presentation/widgets/user_avatar.dart';
import 'package:vaccination_manager/presentation/widgets/vaccination_status_chip.dart';

class VaccinationsScreen extends ConsumerWidget {
  const VaccinationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;
    final vaccinationState = ref.watch(vaccinationsProvider);
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(local.vaccinations),
        actions: [IconButton(icon: const Icon(Icons.add), tooltip: local.addVaccination, onPressed: () => Navigator.of(context).pushNamed(Routes.vaccinationEdit))],
      ),
      body: vaccinationState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('${local.error}: $error')),
        data: (state) {
          final filteredSeries = state.filteredSeriesAt(today);

          if (!state.hasActiveUser) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(local.noUsersBody, textAlign: TextAlign.center),
              ),
            );
          }

          if (!state.hasVaccinations) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(local.noVaccinationsTitle, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(local.noVaccinationsBody, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          FilledButton.icon(onPressed: () => Navigator.of(context).pushNamed(Routes.vaccinationEdit), icon: const Icon(Icons.add), label: Text(local.addVaccination)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          if (filteredSeries.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _VaccinationSummaryCard(state: state, referenceDate: today),
                const SizedBox(height: 16),
                _VaccinationFilterBar(selectedFilter: state.selectedFilter),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(local.noVaccinationsForFilter, textAlign: TextAlign.center),
                  ),
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _VaccinationSummaryCard(state: state, referenceDate: today),
              const SizedBox(height: 16),
              _VaccinationFilterBar(selectedFilter: state.selectedFilter),
              const SizedBox(height: 16),
              ...filteredSeries.map(
                (series) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _VaccinationSeriesCard(series: series),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => Navigator.of(context).pushNamed(Routes.vaccinationEdit), icon: const Icon(Icons.add), label: Text(local.addVaccination)),
    );
  }
}

class _VaccinationFilterBar extends ConsumerWidget {
  const _VaccinationFilterBar({required this.selectedFilter});

  final VaccinationReminderFilter selectedFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(label: Text(local.filterAll), selected: selectedFilter == VaccinationReminderFilter.all, onSelected: (_) => ref.read(vaccinationsProvider.notifier).setFilter(VaccinationReminderFilter.all)),
        ChoiceChip(label: Text(local.filterOverdue), selected: selectedFilter == VaccinationReminderFilter.overdue, onSelected: (_) => ref.read(vaccinationsProvider.notifier).setFilter(VaccinationReminderFilter.overdue)),
        ChoiceChip(label: Text(local.filterDueSoon), selected: selectedFilter == VaccinationReminderFilter.dueSoon, onSelected: (_) => ref.read(vaccinationsProvider.notifier).setFilter(VaccinationReminderFilter.dueSoon)),
        ChoiceChip(label: Text(local.filterUpToDate), selected: selectedFilter == VaccinationReminderFilter.upToDate, onSelected: (_) => ref.read(vaccinationsProvider.notifier).setFilter(VaccinationReminderFilter.upToDate)),
      ],
    );
  }
}

class _VaccinationSummaryCard extends StatelessWidget {
  const _VaccinationSummaryCard({required this.state, required this.referenceDate});

  final VaccinationOverviewState state;
  final DateTime referenceDate;

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final activeUser = state.activeUser!;
    final nextDueSeries = state.nextDueSeriesAt(referenceDate);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(user: activeUser, radius: 24),
                const SizedBox(width: 12),
                Expanded(child: Text(local.recordForUser(activeUser.username), style: Theme.of(context).textTheme.titleLarge)),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _SummaryValue(label: local.shotsRecorded, value: state.series.fold<int>(0, (count, series) => count + series.shotCount).toString()),
                _SummaryValue(label: local.overdueVaccinations, value: state.overdueCountAt(referenceDate).toString()),
                _SummaryValue(label: local.upcomingVaccinations, value: state.dueSoonCountAt(referenceDate).toString()),
              ],
            ),
            if (nextDueSeries != null) ...[
              const SizedBox(height: 16),
              Text(nextDueSeries.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  VaccinationStatusChip(status: nextDueSeries.statusAt(referenceDate)),
                  Text('${local.nextDue}: ${MaterialLocalizations.of(context).formatCompactDate(nextDueSeries.nextDueDateAt(referenceDate))}'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _VaccinationSeriesCard extends StatelessWidget {
  const _VaccinationSeriesCard({required this.series});

  final VaccinationSeriesEntity series;

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final materialLocalizations = MaterialLocalizations.of(context);
    final referenceDate = DateTime.now();

    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(series.name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${local.shotsRecorded}: ${series.shotCount}'),
              Text('${local.lastShot}: ${materialLocalizations.formatCompactDate(series.lastShotDate)}'),
              Text('${local.nextDue}: ${materialLocalizations.formatCompactDate(series.nextDueDateAt(referenceDate))}'),
            ],
          ),
        ),
        trailing: VaccinationStatusChip(status: series.statusAt(referenceDate)),
        children: [
          ...List.generate(series.entries.length, (index) {
            final shotIndex = series.shotCount - index;
            final entry = series.entries[index];
            return _VaccinationEntryTile(entry: entry, shotIndex: shotIndex);
          }),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).pushNamed(Routes.vaccinationEdit, arguments: VaccinationEditArguments(initialVaccinationName: series.name)),
              icon: const Icon(Icons.add),
              label: Text(local.addShot),
            ),
          ),
        ],
      ),
    );
  }
}

class _VaccinationEntryTile extends StatelessWidget {
  const _VaccinationEntryTile({required this.entry, required this.shotIndex});

  final VaccinationEntryEntity entry;
  final int shotIndex;

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final materialLocalizations = MaterialLocalizations.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(local.shotNumber(shotIndex)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${local.vaccinationDate}: ${materialLocalizations.formatCompactDate(entry.vaccinationDate)}'),
          Text('${local.nextVaccinationRequired}: ${materialLocalizations.formatCompactDate(entry.nextVaccinationRequiredDate)}'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: local.editVaccination,
            onPressed: () => Navigator.of(context).pushNamed(
              Routes.vaccinationEdit,
              arguments: VaccinationEditArguments(initialEntry: entry, initialVaccinationName: entry.name),
            ),
          ),
          Consumer(
            builder: (context, ref, _) {
              return IconButton(icon: const Icon(Icons.delete_outline), tooltip: local.deleteVaccination, onPressed: () => _confirmDelete(context, ref));
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final local = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(local.deleteVaccination),
          content: Text(local.deleteVaccinationConfirmation(shotIndex, entry.name)),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(local.cancel)),
            FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(local.delete)),
          ],
        );
      },
    );

    if (shouldDelete != true || entry.id == null) {
      return;
    }

    try {
      await ref.read(vaccinationsProvider.notifier).deleteVaccination(entry.id!);
      if (!context.mounted) {
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text(local.deleteVaccinationSuccess)));
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text('${local.error}: $error')));
    }
  }
}
