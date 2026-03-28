import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_providers.dart';

class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final vaccinationsAsync = ref.watch(vaccinationProvider);
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          vaccinationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text('${local.error}: $e',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.error)),
            ),
            data: (vaccinations) => _RecordsBody(
              vaccinations: vaccinations,
              topPadding: topPadding,
              bottomPadding: bottomPadding,
              local: local,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ),

          // Glassmorphic top bar
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
                      EdgeInsets.only(top: topPadding, left: 20, right: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            local.vaccinationRecords,
                            style: textTheme.titleLarge?.copyWith(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamed(Routes.vaccinationAdd),
                          icon: Icon(Icons.add, color: colorScheme.primary),
                          tooltip: local.addVaccination,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // FAB
          Positioned(
            right: 24,
            bottom: bottomPadding + 80,
            child: _RecordsFab(colorScheme: colorScheme),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _RecordsBody extends ConsumerWidget {
  const _RecordsBody({
    required this.vaccinations,
    required this.topPadding,
    required this.bottomPadding,
    required this.local,
    required this.colorScheme,
    required this.textTheme,
  });

  final List<VaccinationEntryEntity> vaccinations;
  final double topPadding;
  final double bottomPadding;
  final AppLocalizations local;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  /// Group vaccinations by lowercased name preserving first-seen order.
  Map<String, List<VaccinationEntryEntity>> _groupByName(
      List<VaccinationEntryEntity> list) {
    final groups = <String, List<VaccinationEntryEntity>>{};
    for (final v in list) {
      final key = v.name.toLowerCase();
      groups.putIfAbsent(key, () => []).add(v);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (vaccinations.isEmpty) {
      return _EmptyState(
        local: local,
        colorScheme: colorScheme,
        textTheme: textTheme,
        topPadding: topPadding,
      );
    }

    final groups = _groupByName(vaccinations);
    final dateFmt = DateFormat('MMM dd, yyyy');

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          20, topPadding + 72, 20, bottomPadding + 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groups.entries.map((entry) {
          // Sort shots within group by date ascending (oldest = dose 1)
          final shots = List.of(entry.value)
            ..sort((a, b) => a.vaccinationDate.compareTo(b.vaccinationDate));

          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header — use display name from first entry
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        shots.first.name,
                        style: textTheme.titleSmall?.copyWith(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${shots.length}',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Shot rows
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: List.generate(shots.length, (i) {
                      final shot = shots[i];
                      final isLast = i == shots.length - 1;
                      return _ShotRow(
                        shot: shot,
                        doseNumber: i + 1,
                        isLast: isLast,
                        dateFmt: dateFmt,
                        local: local,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        onTap: () => Navigator.of(context).pushNamed(
                          Routes.vaccinationAdd,
                          arguments: shot,
                        ),
                        onDelete: () => _confirmDelete(context, ref, shot),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    VaccinationEntryEntity shot,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(local.deleteShot),
        content: Text(local.deleteShotConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(local.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
                foregroundColor: colorScheme.error),
            child: Text(local.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && shot.id != null) {
      await ref.read(vaccinationProvider.notifier).deleteShot(shot.id!);
    }
  }
}

// ---------------------------------------------------------------------------
// Shot row
// ---------------------------------------------------------------------------

class _ShotRow extends StatelessWidget {
  const _ShotRow({
    required this.shot,
    required this.doseNumber,
    required this.isLast,
    required this.dateFmt,
    required this.local,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
    required this.onDelete,
  });

  final VaccinationEntryEntity shot;
  final int doseNumber;
  final bool isLast;
  final DateFormat dateFmt;
  final AppLocalizations local;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOverdue = shot.nextVaccinationDate != null &&
        shot.nextVaccinationDate!.isBefore(now);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.vertical(
            top: doseNumber == 1
                ? const Radius.circular(20)
                : Radius.zero,
            bottom: isLast ? const Radius.circular(20) : Radius.zero,
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Dose indicator
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color:
                        colorScheme.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '$doseNumber',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Date + next date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFmt.format(shot.vaccinationDate),
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (shot.nextVaccinationDate != null)
                        Row(
                          children: [
                            Icon(
                              isOverdue
                                  ? Icons.warning_amber_outlined
                                  : Icons.event_outlined,
                              size: 12,
                              color: isOverdue
                                  ? colorScheme.error
                                  : colorScheme.tertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Next: ${dateFmt.format(shot.nextVaccinationDate!)}',
                              style: textTheme.labelSmall?.copyWith(
                                color: isOverdue
                                    ? colorScheme.error
                                    : colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Delete button
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline,
                      size: 20, color: colorScheme.onSurfaceVariant),
                  tooltip: local.deleteShot,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.local,
    required this.colorScheme,
    required this.textTheme,
    required this.topPadding,
  });

  final AppLocalizations local;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: topPadding + 64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.vaccines_outlined,
                size: 56, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              local.noVaccinationRecords,
              style: textTheme.titleMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  Navigator.of(context).pushNamed(Routes.vaccinationAdd),
              icon: const Icon(Icons.add),
              label: Text(local.addVaccination),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FAB
// ---------------------------------------------------------------------------

class _RecordsFab extends StatelessWidget {
  const _RecordsFab({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(Routes.vaccinationAdd),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.primaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
