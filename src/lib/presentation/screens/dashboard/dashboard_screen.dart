import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/domain/entities/reminder_status.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/domain/usecases/vaccination/get_vaccination_reminders_use_case.dart';
import 'package:vaccination_manager/presentation/providers/navigation_providers.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/user_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_providers.dart';
import 'package:vaccination_manager/presentation/widgets/vaccination_series_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final activeUserAsync = ref.watch(activeUserProvider);
    final seriesAsync = ref.watch(seriesListProvider);
    final remindersAsync = ref.watch(vaccinationRemindersProvider);
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // ── Scrollable content ────────────────────────────────────────────
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                20, topPadding + 72, 20, bottomPadding + 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  local.myRecords,
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

                // ── Stat chips ─────────────────────────────────────────────
                remindersAsync.when(
                  loading: () => _StatChipsRow(
                    completed: 0,
                    upcoming: 0,
                    overdue: 0,
                    local: local,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (reminders) {
                    final overdue = reminders
                        .where((r) => r.status == ReminderStatus.overdue)
                        .length;
                    final upcoming = reminders
                        .where((r) => r.status == ReminderStatus.dueSoon)
                        .length;
                    final completed = reminders
                        .where((r) => r.status == ReminderStatus.upToDate)
                        .length;
                    return _StatChipsRow(
                      completed: completed,
                      upcoming: upcoming,
                      overdue: overdue,
                      local: local,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    );
                  },
                ),
                const SizedBox(height: 28),

                // ── Priority Due section ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        local.priorityDue,
                        style: textTheme.titleLarge?.copyWith(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: TextButton(
                          onPressed: () {
                            ref
                                .read(selectedTabProvider.notifier)
                                .selectTab(2);
                          },
                          child: Text(
                            local.seeSchedule.toUpperCase(),
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                remindersAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (reminders) => _PriorityDueSection(
                    reminders: reminders,
                    local: local,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Recent Records section ──────────────────────────────────
                Text(
                  local.recentRecords,
                  style: textTheme.titleLarge?.copyWith(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                seriesAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (seriesList) => _RecentRecordsSection(
                    seriesList: seriesList,
                    local: local,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    onViewAll: () =>
                        ref.read(selectedTabProvider.notifier).selectTab(1),
                  ),
                ),
              ],
            ),
          ),

          // ── Glassmorphic top bar ──────────────────────────────────────────
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
                  padding: EdgeInsets.only(
                      top: topPadding, left: 16, right: 8),
                  child: Row(
                    children: [
                      // Avatar circle with initials
                      activeUserAsync.when(
                        loading: () => _AvatarCircle(
                            initials: '?', colorScheme: colorScheme),
                        error: (_, _) => _AvatarCircle(
                            initials: '?', colorScheme: colorScheme),
                        data: (user) => _AvatarCircle(
                          initials: user != null
                              ? _initials(user.username)
                              : '?',
                          colorScheme: colorScheme,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // App name + subtitle
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'VaccineCare',
                                style: textTheme.titleMedium?.copyWith(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w900,
                                  color: colorScheme.primary,
                                ),
                              ),
                              Text(
                                'PERSONAL PROFILE',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Swap button
                      activeUserAsync.when(
                        loading: () => const SizedBox(width: 40),
                        error: (_, _) => const SizedBox(width: 40),
                        data: (user) => IconButton(
                          onPressed: () =>
                              _showProfileSwitcher(context, ref, user?.id,
                                  colorScheme, textTheme, local),
                          icon: Icon(Icons.swap_horiz,
                              color: colorScheme.primary),
                          tooltip: local.switchProfile,
                          style: IconButton.styleFrom(
                            backgroundColor: colorScheme.surfaceContainerHigh,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── FAB moved to Scaffold.floatingActionButton ────────────────────
        ],
      ),
    );
  }

  void _showProfileSwitcher(
    BuildContext context,
    WidgetRef ref,
    int? currentUserId,
    ColorScheme colorScheme,
    TextTheme textTheme,
    AppLocalizations local,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _ProfileSwitcherSheet(
        currentUserId: currentUserId,
        local: local,
        colorScheme: colorScheme,
        textTheme: textTheme,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Avatar circle
// ---------------------------------------------------------------------------

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle(
      {required this.initials, required this.colorScheme});

  final String initials;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.15),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat chips row
// ---------------------------------------------------------------------------

class _StatChipsRow extends StatelessWidget {
  const _StatChipsRow({
    required this.completed,
    required this.upcoming,
    required this.overdue,
    required this.local,
    required this.colorScheme,
    required this.textTheme,
  });

  final int completed, upcoming, overdue;
  final AppLocalizations local;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            dot: colorScheme.secondary,
            bg: colorScheme.secondaryContainer.withValues(alpha: 0.3),
            label: local.completedCount(completed),
            textColor: colorScheme.secondary,
            textTheme: textTheme,
          ),
          const SizedBox(width: 10),
          _Chip(
            dot: colorScheme.tertiary,
            bg: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
            label: local.upcomingCount(upcoming),
            textColor: colorScheme.tertiary,
            textTheme: textTheme,
          ),
          const SizedBox(width: 10),
          _Chip(
            dot: colorScheme.error,
            bg: colorScheme.errorContainer.withValues(alpha: 0.3),
            label: local.overdueCount(overdue),
            textColor: colorScheme.error,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.dot,
    required this.bg,
    required this.label,
    required this.textColor,
    required this.textTheme,
  });

  final Color dot, bg, textColor;
  final String label;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Priority Due section
// ---------------------------------------------------------------------------

class _PriorityDueSection extends StatelessWidget {
  const _PriorityDueSection({
    required this.reminders,
    required this.local,
    required this.colorScheme,
    required this.textTheme,
  });

  final List<VaccinationReminder> reminders;
  final AppLocalizations local;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  List<VaccinationReminder> _priorityEntries() {
    return reminders
        .where((r) =>
            r.status == ReminderStatus.overdue ||
            r.status == ReminderStatus.dueSoon)
        .take(2)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final priority = _priorityEntries();
    if (priority.isEmpty) {
      return _EmptyPriorityCard(
        message: local.noUpcomingVaccinations,
        colorScheme: colorScheme,
        textTheme: textTheme,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary card (first item)
        _PrimaryPriorityCard(
          reminder: priority.first,
          local: local,
          colorScheme: colorScheme,
          textTheme: textTheme,
        ),
        // Secondary card (second item if present)
        if (priority.length > 1) ...[
          const SizedBox(height: 12),
          _SecondaryPriorityCard(
            reminder: priority[1],
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ],
      ],
    );
  }
}

class _PrimaryPriorityCard extends StatelessWidget {
  const _PrimaryPriorityCard({
    required this.reminder,
    required this.local,
    required this.colorScheme,
    required this.textTheme,
  });

  final VaccinationReminder reminder;
  final AppLocalizations local;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final isOverdue = reminder.status == ReminderStatus.overdue;
    final nextDate = reminder.series.nextVaccinationDate;
    final badgeLabel = isOverdue
        ? local.dueNow
        : nextDate != null
            ? 'Due ${DateFormat('MMM yyyy').format(nextDate)}'
            : '';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.03),
                    colorScheme.primaryContainer.withValues(alpha: 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.15),
                            colorScheme.primaryContainer
                                .withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.vaccines_outlined,
                          color: colorScheme.primary),
                    ),
                    // Badge
                    if (badgeLabel.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOverdue
                              ? colorScheme.tertiary
                              : colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badgeLabel,
                          style: textTheme.labelSmall?.copyWith(
                            color: isOverdue
                                ? colorScheme.onTertiary
                                : colorScheme.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  reminder.series.name,
                  style: textTheme.headlineSmall?.copyWith(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  local.nextDose,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryPriorityCard extends StatelessWidget {
  const _SecondaryPriorityCard({
    required this.reminder,
    required this.colorScheme,
    required this.textTheme,
  });

  final VaccinationReminder reminder;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final nextDate = reminder.series.nextVaccinationDate;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.calendar_month_outlined,
                color: colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.series.name,
                  style: textTheme.titleSmall?.copyWith(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (nextDate != null)
                  Text(
                    'Due ${DateFormat('MMM yyyy').format(nextDate)}',
                    style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          if (nextDate != null)
            Text(
              DateFormat('MMM yyyy').format(nextDate).toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyPriorityCard extends StatelessWidget {
  const _EmptyPriorityCard({
    required this.message,
    required this.colorScheme,
    required this.textTheme,
  });

  final String message;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(Icons.vaccines_outlined,
              size: 40, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            message,
            style: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recent Records section
// ---------------------------------------------------------------------------

class _RecentRecordsSection extends StatelessWidget {
  const _RecentRecordsSection({
    required this.seriesList,
    required this.local,
    required this.colorScheme,
    required this.textTheme,
    required this.onViewAll,
  });

  final List<VaccinationSeriesEntity> seriesList;
  final AppLocalizations local;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    // Sort by most recent shot date DESC, take up to 3
    final sorted = List.of(seriesList)
      ..sort((a, b) {
        final aDate = a.shots
            .map((s) => s.vaccinationDate)
            .whereType<DateTime>()
            .fold<DateTime?>(null, (best, d) => best == null || d.isAfter(best) ? d : best);
        final bDate = b.shots
            .map((s) => s.vaccinationDate)
            .whereType<DateTime>()
            .fold<DateTime?>(null, (best, d) => best == null || d.isAfter(best) ? d : best);
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
    final recent = sorted.take(3).toList();

    if (recent.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          local.noVaccinationRecords,
          style: textTheme.bodyMedium
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return Column(
      children: [
        ...recent.map((series) => VaccinationSeriesCard(
              series: series,
              onEdit: () => Navigator.of(context).pushNamed(
                Routes.vaccinationAdd,
                arguments: series,
              ),
              onDelete: () {}, // Handled in Records screen
            )),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              local.viewFullHistory.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Profile Switcher bottom sheet (mirrors ProfileScreen implementation)
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

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

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
                  return Text(local.noProfilesFound,
                      style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant));
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
                      title: Text(u.username,
                          style: textTheme.titleSmall
                              ?.copyWith(color: colorScheme.onSurface)),
                      trailing: isActive
                          ? Icon(Icons.check, color: colorScheme.primary)
                          : null,
                      onTap: () async {
                        await ref
                            .read(activeUserProvider.notifier)
                            .setActiveUser(u.id!);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
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
              title: Text(local.addNewProfile,
                  style: textTheme.titleSmall
                      ?.copyWith(color: colorScheme.primary)),
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
}

