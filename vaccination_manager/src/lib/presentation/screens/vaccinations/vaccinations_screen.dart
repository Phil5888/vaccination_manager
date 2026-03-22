import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/core/constants/app_component_styles.dart';
import 'package:vaccination_manager/core/constants/app_spacing.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/vaccination/vaccination_providers.dart';
import 'package:vaccination_manager/presentation/screens/vaccinations/vaccination_edit_screen.dart';
import 'package:vaccination_manager/presentation/viewmodels/vaccination_viewmodel.dart';
import 'package:vaccination_manager/presentation/widgets/user_avatar.dart';
import 'package:vaccination_manager/presentation/widgets/vaccination_status_chip.dart';

class VaccinationsScreen extends ConsumerStatefulWidget {
  const VaccinationsScreen({super.key});

  @override
  ConsumerState<VaccinationsScreen> createState() => _VaccinationsScreenState();
}

class _VaccinationsScreenState extends ConsumerState<VaccinationsScreen> {
  final Map<String, GlobalKey> _seriesItemKeys = <String, GlobalKey>{};
  String? _expandedSeriesKey;

  String _seriesKeyFromName(String name) {
    return name.trim().toLowerCase();
  }

  GlobalKey _seriesKeyFor(String normalizedSeriesName) {
    return _seriesItemKeys.putIfAbsent(normalizedSeriesName, GlobalKey.new);
  }

  Future<void> _openSearch(List<VaccinationSeriesEntity> series) async {
    if (series.isEmpty) {
      return;
    }

    final selectedSeriesName = await Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => _VaccinationSearchScreen(series: series)));

    if (!mounted || selectedSeriesName == null) {
      return;
    }

    ref.read(vaccinationsProvider.notifier).setFilter(VaccinationReminderFilter.all);

    final normalizedSeriesKey = _seriesKeyFromName(selectedSeriesName);
    setState(() {
      _expandedSeriesKey = normalizedSeriesKey;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetContext = _seriesItemKeys[normalizedSeriesKey]?.currentContext;
      if (targetContext == null || !mounted) {
        return;
      }

      Scrollable.ensureVisible(targetContext, duration: const Duration(milliseconds: 280), alignment: 0.08, curve: Curves.easeOutCubic);
    });
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final vaccinationState = ref.watch(vaccinationsProvider);
    final today = DateTime.now();
    final seriesForSearch = vaccinationState.asData?.value.series ?? const <VaccinationSeriesEntity>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(local.vaccinations),
        actions: [
          if (seriesForSearch.isNotEmpty)
            Padding(
              padding: AppSpacing.actionPadding,
              child: IconButton.filledTonal(style: AppComponentStyles.appBarSecondaryIconButton(context), icon: const Icon(Icons.search), tooltip: local.searchVaccinations, onPressed: () => _openSearch(seriesForSearch)),
            ),
          Padding(
            padding: AppSpacing.actionPaddingLast,
            child: IconButton.filled(style: AppComponentStyles.appBarPrimaryIconButton(context), icon: const Icon(Icons.add), tooltip: local.addVaccination, onPressed: () => Navigator.of(context).pushNamed(Routes.vaccinationEdit)),
          ),
        ],
      ),
      body: vaccinationState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('${local.error}: $error')),
        data: (state) {
          final filteredSeries = state.filteredSeriesAt(today);

          if (!state.hasActiveUser) {
            return Center(
              child: Padding(
                padding: AppSpacing.contentPadding,
                child: Text(local.noUsersBody, textAlign: TextAlign.center),
              ),
            );
          }

          if (!state.hasVaccinations) {
            return Center(
              child: Padding(
                padding: AppSpacing.contentPadding,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Card(
                    child: Padding(
                      padding: AppSpacing.contentPadding,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(local.noVaccinationsTitle, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: AppSpacing.sm),
                          Text(local.noVaccinationsBody, textAlign: TextAlign.center),
                          const SizedBox(height: AppSpacing.lg),
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
              padding: AppSpacing.listPadding,
              children: [
                _VaccinationSummaryCard(state: state, referenceDate: today),
                const SizedBox(height: AppSpacing.lg),
                _VaccinationFilterBar(selectedFilter: state.selectedFilter),
                const SizedBox(height: AppSpacing.lg),
                Card(
                  child: Padding(
                    padding: AppSpacing.contentPadding,
                    child: Text(local.noVaccinationsForFilter, textAlign: TextAlign.center),
                  ),
                ),
              ],
            );
          }

          return ListView(
            padding: AppSpacing.listPadding,
            children: [
              _VaccinationSummaryCard(state: state, referenceDate: today),
              const SizedBox(height: AppSpacing.lg),
              _VaccinationFilterBar(selectedFilter: state.selectedFilter),
              const SizedBox(height: AppSpacing.lg),
              ...filteredSeries.map((series) {
                final normalizedName = _seriesKeyFromName(series.name);
                return Padding(
                  key: _seriesKeyFor(normalizedName),
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _VaccinationSeriesCard(series: series, initiallyExpanded: normalizedName == _expandedSeriesKey),
                );
              }),
            ],
          );
        },
      ),
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
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(user: activeUser, radius: 24),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(local.recordForUser(activeUser.username), style: Theme.of(context).textTheme.titleLarge)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.md,
              children: [
                _SummaryValue(label: local.shotsRecorded, value: state.series.fold<int>(0, (count, series) => count + series.shotCount).toString()),
                _SummaryValue(label: local.overdueVaccinations, value: state.overdueCountAt(referenceDate).toString()),
                _SummaryValue(label: local.upcomingVaccinations, value: state.dueSoonCountAt(referenceDate).toString()),
              ],
            ),
            if (nextDueSeries != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(nextDueSeries.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  VaccinationStatusChip(status: nextDueSeries.statusAt(referenceDate)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text('${local.nextDue}: ${MaterialLocalizations.of(context).formatCompactDate(nextDueSeries.nextDueDateAt(referenceDate))}')),
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
  const _VaccinationSeriesCard({required this.series, this.initiallyExpanded = false});

  final VaccinationSeriesEntity series;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final materialLocalizations = MaterialLocalizations.of(context);
    final referenceDate = DateTime.now();

    return Card(
      child: ExpansionTile(
        key: ValueKey('${series.name.toLowerCase()}-${initiallyExpanded ? 'expanded' : 'collapsed'}'),
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        childrenPadding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        title: Text(series.name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
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
          const SizedBox(height: AppSpacing.sm),
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
    final isPlanned = _isPlanned(entry.vaccinationDate);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(local.shotNumber(shotIndex)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${local.vaccinationDate}: ${materialLocalizations.formatCompactDate(entry.vaccinationDate)}'),
          Text('${local.nextVaccinationRequired}: ${materialLocalizations.formatCompactDate(entry.nextVaccinationRequiredDate)}'),
          const SizedBox(height: 6),
          _ShotStatusBadge(label: isPlanned ? local.plannedShot : local.recordedShot, isPlanned: isPlanned),
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

  bool _isPlanned(DateTime date) {
    final today = DateTime.now();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    return dateOnly.isAfter(todayOnly);
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

class _ShotStatusBadge extends StatelessWidget {
  const _ShotStatusBadge({required this.label, required this.isPlanned});

  final String label;
  final bool isPlanned;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = isPlanned ? colorScheme.primary : colorScheme.onSurfaceVariant;
    final background = isPlanned ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md - 2, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: foreground)),
    );
  }
}

class _VaccinationSearchScreen extends StatefulWidget {
  const _VaccinationSearchScreen({required this.series});

  final List<VaccinationSeriesEntity> series;

  @override
  State<_VaccinationSearchScreen> createState() => _VaccinationSearchScreenState();
}

class _VaccinationSearchScreenState extends State<_VaccinationSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<VaccinationSeriesEntity> _matchesFor(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return const <VaccinationSeriesEntity>[];
    }

    final matches = widget.series.where((series) => series.name.toLowerCase().contains(normalized)).toList();
    matches.sort((a, b) {
      final aStarts = a.name.toLowerCase().startsWith(normalized);
      final bStarts = b.name.toLowerCase().startsWith(normalized);
      if (aStarts != bStarts) {
        return aStarts ? -1 : 1;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
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
            hintText: local.searchVaccinationsHint,
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
                child: Text(local.searchVaccinationsStart, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
              ),
            );
          }

          if (matches.isEmpty) {
            return Center(
              child: Padding(
                padding: AppSpacing.contentPadding,
                child: Text(local.searchVaccinationsNoMatches, textAlign: TextAlign.center),
              ),
            );
          }

          return ListView.separated(
            padding: AppSpacing.searchResultsPadding,
            itemBuilder: (context, index) {
              final item = matches[index];
              return ListTile(
                tileColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                title: Text(item.name),
                subtitle: Text('${local.shotsRecorded}: ${item.shotCount}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pop(item.name),
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
