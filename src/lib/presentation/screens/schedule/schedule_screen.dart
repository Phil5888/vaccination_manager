import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/domain/entities/reminder_status.dart';
import 'package:vaccination_manager/domain/usecases/vaccination/get_vaccination_reminders_use_case.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_providers.dart';

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
                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                        20, 0, 20, bottomPadding + 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ReminderCard(
                            reminder: reminders[index],
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                Routes.vaccinationAdd,
                                arguments: reminders[index].series.latestShot,
                              );
                            },
                          ),
                        ),
                        childCount: reminders.length,
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

          // ── FAB ──────────────────────────────────────────────────────────
          Positioned(
            right: 24,
            bottom: bottomPadding + 80,
            child: GestureDetector(
              onTap: () =>
                  Navigator.of(context).pushNamed(Routes.vaccinationAdd),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child:
                    const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ),
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
// Reminder card
// ---------------------------------------------------------------------------

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.reminder,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
  });

  final VaccinationReminder reminder;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;

  Color _dotColor() {
    switch (reminder.status) {
      case ReminderStatus.overdue:
        return colorScheme.error;
      case ReminderStatus.dueSoon:
        return colorScheme.tertiary;
      case ReminderStatus.upToDate:
        return colorScheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final series = reminder.series;
    final nextDate = series.nextVaccinationDate;
    final dateFmt = DateFormat('MMM dd, yyyy');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status dot
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _dotColor(),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    series.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    local.shotCount(series.shots.length),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (nextDate != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${local.nextDose}: ${dateFmt.format(nextDate)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Status chip
            _StatusChip(
              status: reminder.status,
              nextDate: nextDate,
              colorScheme: colorScheme,
              textTheme: textTheme,
              local: local,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status chip
// ---------------------------------------------------------------------------

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.nextDate,
    required this.colorScheme,
    required this.textTheme,
    required this.local,
  });

  final ReminderStatus status;
  final DateTime? nextDate;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations local;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label;

    switch (status) {
      case ReminderStatus.overdue:
        bg = colorScheme.errorContainer;
        fg = colorScheme.onErrorContainer;
        label = local.statusOverdue;
        break;
      case ReminderStatus.dueSoon:
        bg = colorScheme.tertiaryContainer;
        fg = colorScheme.onTertiaryContainer;
        label = nextDate != null
            ? local.statusDueSoon(DateFormat('MMM dd').format(nextDate!))
            : local.statusDueSoon('');
        break;
      case ReminderStatus.upToDate:
        bg = colorScheme.secondaryContainer;
        fg = colorScheme.onSecondaryContainer;
        label = local.statusUpToDate;
        break;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
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
