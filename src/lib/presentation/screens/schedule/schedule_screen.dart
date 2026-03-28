import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/domain/entities/reminder_status.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_providers.dart';
import 'package:vaccination_manager/presentation/widgets/vaccination_series_card.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final filter = ref.watch(scheduleFilterProvider);
    final filteredAsync = ref.watch(filteredRemindersProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // ── Main content ────────────────────────────────────────────────
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: topPadding + 72),
              ),

              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        local.vaccinationSchedule,
                        style: textTheme.headlineMedium?.copyWith(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(DateTime.now()),
                        style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Filter bar
              SliverToBoxAdapter(
                child: _FilterBar(
                  currentFilter: filter,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  local: local,
                  onFilterChanged: (f) =>
                      ref.read(scheduleFilterProvider.notifier).setFilter(f),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Reminder list
              filteredAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      '${local.error}: $e',
                      style: textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.error),
                    ),
                  ),
                ),
                data: (reminders) {
                  if (reminders.isEmpty) {
                    return SliverToBoxAdapter(
                      child: _EmptyState(
                        message: local.noVaccinationsFilter,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        onAdd: () => Navigator.of(context)
                            .pushNamed(Routes.vaccinationAdd),
                      ),
                    );
                  }

                  // Sort: overdue first, dueSoon, upToDate
                  final sorted = List.of(reminders)
                    ..sort((a, b) {
                      int order(ReminderStatus s) {
                        switch (s) {
                          case ReminderStatus.overdue:
                            return 0;
                          case ReminderStatus.dueSoon:
                            return 1;
                          case ReminderStatus.upToDate:
                            return 2;
                        }
                      }

                      final ao = order(a.status);
                      final bo = order(b.status);
                      if (ao != bo) return ao.compareTo(bo);
                      final aDate = a.series.nextActionDate;
                      final bDate = b.series.nextActionDate;
                      if (aDate == null && bDate == null) return 0;
                      if (aDate == null) return 1;
                      if (bDate == null) return -1;
                      return aDate.compareTo(bDate);
                    });

                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                        20, 0, 20, bottomPadding + 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, index) {
                          final reminder = sorted[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: VaccinationSeriesCard(
                              series: reminder.series,
                              onEdit: () => Navigator.of(context).pushNamed(
                                Routes.vaccinationAdd,
                                arguments: reminder.series,
                              ),
                              onDelete: () {},
                            ),
                          );
                        },
                        childCount: sorted.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // ── Glassmorphic top bar ─────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: topPadding + 64,
                  color: colorScheme.surfaceContainerLowest
                      .withValues(alpha: 0.8),
                  padding:
                      EdgeInsets.only(top: topPadding, left: 20, right: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      local.vaccinationSchedule,
                      style: textTheme.titleMedium?.copyWith(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── FAB moved to Scaffold.floatingActionButton ────────────────
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bar
// ---------------------------------------------------------------------------

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.currentFilter,
    required this.colorScheme,
    required this.textTheme,
    required this.local,
    required this.onFilterChanged,
  });

  final ReminderFilter currentFilter;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations local;
  final ValueChanged<ReminderFilter> onFilterChanged;

  String _label(ReminderFilter f) {
    switch (f) {
      case ReminderFilter.all:
        return local.filterAll;
      case ReminderFilter.overdue:
        return local.filterOverdue;
      case ReminderFilter.dueSoon:
        return local.filterDueSoon;
      case ReminderFilter.upToDate:
        return local.filterUpToDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: ReminderFilter.values.map((f) {
          final isSelected = f == currentFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onFilterChanged(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _label(f),
                  style: textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
    required this.colorScheme,
    required this.textTheme,
    required this.onAdd,
  });

  final String message;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
      child: Column(
        children: [
          Icon(Icons.event_available_outlined,
              size: 56, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            message,
            style: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: onAdd,
            style: TextButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              local.addVaccination,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
