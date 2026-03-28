import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_status.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_providers.dart';

// ---------------------------------------------------------------------------
// VaccinationSeriesCard
// ---------------------------------------------------------------------------

class VaccinationSeriesCard extends StatefulWidget {
  const VaccinationSeriesCard({
    super.key,
    required this.series,
    required this.onEdit,
    required this.onDelete,
  });

  final VaccinationSeriesEntity series;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<VaccinationSeriesCard> createState() => _VaccinationSeriesCardState();
}

class _VaccinationSeriesCardState extends State<VaccinationSeriesCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final series = widget.series;
    final pct = (series.progressPercentage * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title + status badge ──────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    series.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _SeriesStatusBadge(
                  status: series.seriesStatus,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  local: local,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Progress bar ─────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: series.progressPercentage,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: _progressColor(series.seriesStatus, colorScheme),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${local.progressDone(series.completedShots, series.totalShots)}  ·  $pct%',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // ── Expand/collapse toggle ────────────────────────────────────
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  Icon(
                    _expanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _expanded ? local.hideDetails : local.showDetails,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // ── Expandable shot timeline ──────────────────────────────────
            if (_expanded) ...[
              const SizedBox(height: 12),
              ...series.shots.map(
                (shot) => _ShotTimelineRow(
                  shot: shot,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  local: local,
                ),
              ),
            ],

            // ── Action buttons ────────────────────────────────────────────
            const SizedBox(height: 12),
            Row(
              children: [
                // Record Next Shot button
                if (series.seriesStatus != VaccinationSeriesStatus.complete) ...[
                  Expanded(
                    child: _RecordNextShotButton(
                      series: series,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      local: local,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Edit button
                IconButton(
                  onPressed: widget.onEdit,
                  icon: Icon(Icons.edit_outlined,
                      size: 20, color: colorScheme.primary),
                  tooltip: local.edit,
                  style: IconButton.styleFrom(
                    backgroundColor:
                        colorScheme.primaryContainer.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _progressColor(
      VaccinationSeriesStatus status, ColorScheme colorScheme) {
    switch (status) {
      case VaccinationSeriesStatus.complete:
        return colorScheme.tertiary;
      case VaccinationSeriesStatus.inProgress:
        return colorScheme.primary;
      case VaccinationSeriesStatus.planned:
        return colorScheme.secondary;
      case VaccinationSeriesStatus.overdue:
        return colorScheme.error;
    }
  }
}

// ---------------------------------------------------------------------------
// Status badge
// ---------------------------------------------------------------------------

class _SeriesStatusBadge extends StatelessWidget {
  const _SeriesStatusBadge({
    required this.status,
    required this.colorScheme,
    required this.textTheme,
    required this.local,
  });

  final VaccinationSeriesStatus status;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations local;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label;

    switch (status) {
      case VaccinationSeriesStatus.complete:
        bg = colorScheme.tertiary;
        fg = colorScheme.onTertiary;
        label = local.statusComplete;
        break;
      case VaccinationSeriesStatus.inProgress:
        bg = colorScheme.primary;
        fg = colorScheme.onPrimary;
        label = local.statusInProgress;
        break;
      case VaccinationSeriesStatus.planned:
        bg = colorScheme.secondary;
        fg = colorScheme.onSecondary;
        label = local.statusPlanned;
        break;
      case VaccinationSeriesStatus.overdue:
        bg = colorScheme.error;
        fg = colorScheme.onError;
        label = local.statusOverdue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
// Shot timeline row
// ---------------------------------------------------------------------------

class _ShotTimelineRow extends StatelessWidget {
  const _ShotTimelineRow({
    required this.shot,
    required this.colorScheme,
    required this.textTheme,
    required this.local,
  });

  final VaccinationEntryEntity shot;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations local;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM dd, yyyy');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final IconData icon;
    final Color iconColor;
    final String statusLabel;
    final String dateLabel;

    if (shot.vaccinationDate == null) {
      icon = Icons.radio_button_unchecked;
      iconColor = colorScheme.onSurfaceVariant;
      statusLabel = local.shotStatusUnscheduled;
      dateLabel = local.shotStatusUnscheduled;
    } else {
      final d = DateTime(
          shot.vaccinationDate!.year,
          shot.vaccinationDate!.month,
          shot.vaccinationDate!.day);
      if (d.isAfter(today)) {
        icon = Icons.schedule;
        iconColor = colorScheme.primary;
        statusLabel = local.shotStatusPlanned;
      } else {
        icon = Icons.check_circle;
        iconColor = colorScheme.tertiary;
        statusLabel = local.shotStatusCompleted;
      }
      dateLabel = dateFmt.format(shot.vaccinationDate!);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${local.shot(shot.shotNumber)}  ·  $dateLabel',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusLabel,
              style: textTheme.labelSmall?.copyWith(
                color: iconColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Record Next Shot button (opens bottom sheet)
// ---------------------------------------------------------------------------

class _RecordNextShotButton extends ConsumerWidget {
  const _RecordNextShotButton({
    required this.series,
    required this.colorScheme,
    required this.textTheme,
    required this.local,
  });

  final VaccinationSeriesEntity series;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations local;

  int get _nextShotIndex {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (var i = 0; i < series.shots.length; i++) {
      final d = series.shots[i].vaccinationDate;
      if (d == null || d.isAfter(today)) return i;
    }
    return series.shots.length - 1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextIdx = _nextShotIndex;
    final shotNumber = series.shots[nextIdx].shotNumber;

    return FilledButton.tonal(
      onPressed: () => _showRecordSheet(context, ref, nextIdx, shotNumber),
      style: FilledButton.styleFrom(
        backgroundColor:
            colorScheme.primaryContainer.withValues(alpha: 0.5),
        foregroundColor: colorScheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_circle_outline, size: 16,
              color: colorScheme.onPrimaryContainer),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              local.recordNextShot,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showRecordSheet(
    BuildContext context,
    WidgetRef ref,
    int shotIdx,
    int shotNumber,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _RecordNextShotSheet(
        series: series,
        shotIdx: shotIdx,
        shotNumber: shotNumber,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Record Next Shot Bottom Sheet
// ---------------------------------------------------------------------------

class _RecordNextShotSheet extends ConsumerStatefulWidget {
  const _RecordNextShotSheet({
    required this.series,
    required this.shotIdx,
    required this.shotNumber,
  });

  final VaccinationSeriesEntity series;
  final int shotIdx;
  final int shotNumber;

  @override
  ConsumerState<_RecordNextShotSheet> createState() =>
      _RecordNextShotSheetState();
}

class _RecordNextShotSheetState
    extends ConsumerState<_RecordNextShotSheet> {
  late DateTime _date;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final updatedShots = List.of(widget.series.shots).map((s) {
        if (s.shotNumber == widget.series.shots[widget.shotIdx].shotNumber) {
          return s.copyWith(vaccinationDate: _date);
        }
        return s;
      }).toList();
      await ref.read(vaccinationProvider.notifier).saveSeries(updatedShots);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateFmt = DateFormat('MMM dd, yyyy');
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
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
          const SizedBox(height: 20),

          Text(
            local.recordNextShotTitle(widget.shotNumber),
            style: textTheme.titleLarge?.copyWith(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.series.name,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Date picker
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 18, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    dateFmt.format(_date),
                    style: textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurface),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          FilledButton(
            onPressed: _isSaving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: colorScheme.onPrimary),
                  )
                : Text(
                    local.save,
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
