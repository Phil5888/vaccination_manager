import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/user_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_providers.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class AddVaccinationScreen extends ConsumerStatefulWidget {
  const AddVaccinationScreen({
    super.key,
    this.existingSeries,
    this.existingEntry,
  });

  /// Preferred: editing a whole series.
  final VaccinationSeriesEntity? existingSeries;

  /// Backward compat: editing a single entry (treated as 1-shot series).
  final VaccinationEntryEntity? existingEntry;

  @override
  ConsumerState<AddVaccinationScreen> createState() =>
      _AddVaccinationScreenState();
}

class _AddVaccinationScreenState extends ConsumerState<AddVaccinationScreen> {
  final _nameController = TextEditingController();

  int _shotCount = 1; // 1–5
  List<DateTime?> _shotDates = [null]; // length always == _shotCount

  // Single-shot next-dose
  bool _scheduleNextDose = false;
  DateTime? _nextDoseDate;

  // Validation
  String? _nameError;
  String? _datesError;

  bool _isSaving = false;
  bool _isEditing = false;
  VaccinationSeriesEntity? _editingSeries;

  // IDs from existing shots (to pass back on save so DB rows are updated)
  List<int?> _existingIds = [];

  @override
  void initState() {
    super.initState();
    _initFromArguments();
  }

  void _initFromArguments() {
    if (widget.existingSeries != null) {
      final series = widget.existingSeries!;
      _isEditing = true;
      _editingSeries = series;
      _nameController.text = series.name;
      _shotCount = series.shots.length.clamp(1, 5);
      _shotDates = List.generate(
        _shotCount,
        (i) => i < series.shots.length ? series.shots[i].vaccinationDate : null,
      );
      _existingIds = List.generate(
        _shotCount,
        (i) => i < series.shots.length ? series.shots[i].id : null,
      );
      // Next dose from single-shot compat
      if (series.shots.length == 1) {
        final nv = series.shots.first.nextVaccinationDate;
        if (nv != null) {
          _scheduleNextDose = true;
          _nextDoseDate = nv;
        }
      }
    } else if (widget.existingEntry != null) {
      final entry = widget.existingEntry!;
      _isEditing = true;
      _nameController.text = entry.name;
      _shotCount = 1;
      _shotDates = [entry.vaccinationDate];
      _existingIds = [entry.id];
      if (entry.nextVaccinationDate != null) {
        _scheduleNextDose = true;
        _nextDoseDate = entry.nextVaccinationDate;
      }
    } else {
      _shotDates = [null];
      _existingIds = [null];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ── Shot count stepper ────────────────────────────────────────────────────

  void _decrementShots() {
    if (_shotCount <= 1) return;
    setState(() {
      _shotCount--;
      _shotDates = _shotDates.sublist(0, _shotCount);
      _existingIds = _existingIds.sublist(0, _shotCount);
      _datesError = null;
    });
  }

  void _incrementShots() {
    if (_shotCount >= 5) return;
    setState(() {
      _shotCount++;
      _shotDates = [..._shotDates, null];
      _existingIds = [..._existingIds, null];
      _datesError = null;
    });
  }

  // ── Date pickers ──────────────────────────────────────────────────────────

  Future<void> _pickShotDate(int index) async {
    final initial = _shotDates[index] ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      setState(() {
        _shotDates[index] = picked;
        _datesError = null;
      });
    }
  }

  Future<void> _pickNextDoseDate() async {
    final initial = _nextDoseDate ??
        (_shotDates.isNotEmpty && _shotDates.last != null
            ? _shotDates.last!.add(const Duration(days: 30))
            : DateTime.now().add(const Duration(days: 30)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) setState(() => _nextDoseDate = picked);
  }

  // ── Validation ────────────────────────────────────────────────────────────

  bool _validate() {
    bool ok = true;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _nameError = 'Vaccine name is required';
      ok = false;
    } else {
      _nameError = null;
    }

    // Check date ordering: shot N must be on or after shot N-1
    for (var i = 1; i < _shotCount; i++) {
      final prev = _shotDates[i - 1];
      final curr = _shotDates[i];
      if (prev != null && curr != null && curr.isBefore(prev)) {
        _datesError = 'Shot ${i + 1} date must be on or after Shot $i date';
        ok = false;
        break;
      }
    }
    if (ok) _datesError = null;

    setState(() {});
    return ok;
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_validate()) return;

    final activeUser = await ref.read(activeUserProvider.future);
    if (activeUser == null) return;

    setState(() => _isSaving = true);
    try {
      final name = _nameController.text.trim();
      final shots = List.generate(_shotCount, (i) {
        final isLast = i == _shotCount - 1;
        return VaccinationEntryEntity(
          id: i < _existingIds.length ? _existingIds[i] : null,
          userId: activeUser.id!,
          name: name,
          shotNumber: i + 1,
          totalShots: _shotCount,
          vaccinationDate: _shotDates[i],
          nextVaccinationDate:
              isLast && _shotCount == 1 && _scheduleNextDose
                  ? _nextDoseDate
                  : null,
        );
      });

      await ref.read(vaccinationProvider.notifier).saveSeries(shots);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Delete series ─────────────────────────────────────────────────────────

  Future<void> _deleteSeries() async {
    final local = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final series = _editingSeries;
    if (series == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(local.deleteSeriesTitle),
        content: Text(local.deleteSeriesConfirm(series.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(local.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            child: Text(local.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref
          .read(vaccinationProvider.notifier)
          .deleteSeries(series.userId, series.name);
      if (mounted) Navigator.of(context).pop();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final topPadding = MediaQuery.of(context).padding.top;
    final dateFmt = DateFormat('MMM dd, yyyy');

    // Previously used names from all vaccinations
    final vaccinationsAsync = ref.watch(vaccinationProvider);
    final previousNames = vaccinationsAsync.whenData((entries) {
      final seen = <String>{};
      return entries
          .map((e) => e.name)
          .where((n) {
            final key = n.toLowerCase();
            return seen.add(key);
          })
          .toList();
    }).when(data: (v) => v, error: (_, _) => <String>[], loading: () => <String>[]);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: _BottomSaveBar(
        label: local.saveVaccination,
        enabled: !_isSaving,
        isSaving: _isSaving,
        colorScheme: colorScheme,
        textTheme: textTheme,
        onSave: _save,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, topPadding + 80, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  _isEditing ? local.editVaccination : local.addVaccination,
                  style: textTheme.headlineMedium?.copyWith(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Keep your medical profile up to date by logging vaccinations.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Form card ─────────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vaccine name
                      _FieldLabel(
                          label: local.vaccineName,
                          colorScheme: colorScheme,
                          textTheme: textTheme),
                      const SizedBox(height: 6),
                      TextField(
                        key: const Key('vaccineNameField'),
                        controller: _nameController,
                        onChanged: (_) => setState(() => _nameError = null),
                        style: textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                          hintText: 'e.g. Influenza, COVID-19 Booster…',
                          hintStyle: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6),
                          ),
                          errorText: _nameError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: colorScheme.primary, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: colorScheme.error, width: 1),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),

                      // Previously used chips
                      if (previousNames.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          local.previouslyUsed,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: previousNames.map((name) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ActionChip(
                                  label: Text(
                                    name,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  backgroundColor:
                                      colorScheme.primaryContainer
                                          .withValues(alpha: 0.5),
                                  side: BorderSide.none,
                                  onPressed: () {
                                    _nameController.text = name;
                                    setState(() => _nameError = null);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // ── Shot count stepper ─────────────────────────────
                      _FieldLabel(
                          label: local.numberOfShots,
                          colorScheme: colorScheme,
                          textTheme: textTheme),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _StepperButton(
                            icon: Icons.remove,
                            onTap: _decrementShots,
                            enabled: _shotCount > 1,
                            colorScheme: colorScheme,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '$_shotCount',
                            style: textTheme.headlineSmall?.copyWith(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 16),
                          _StepperButton(
                            icon: Icons.add,
                            onTap: _incrementShots,
                            enabled: _shotCount < 5,
                            colorScheme: colorScheme,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Shot date rows ─────────────────────────────────
                      ...List.generate(_shotCount, (i) {
                        return _ShotDateRow(
                          shotNumber: i + 1,
                          date: _shotDates[i],
                          dateFmt: dateFmt,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                          local: local,
                          onPickDate: () => _pickShotDate(i),
                          onClearDate: () => setState(() {
                            _shotDates[i] = null;
                            _datesError = null;
                          }),
                        );
                      }),

                      // Dates ordering error
                      if (_datesError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _datesError!,
                          style: textTheme.bodySmall
                              ?.copyWith(color: colorScheme.error),
                        ),
                      ],

                      // ── Next Dose (single-shot only) ───────────────────
                      if (_shotCount == 1) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                local.scheduleNextDose,
                                style: textTheme.titleSmall?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Switch(
                              value: _scheduleNextDose,
                              activeThumbColor: colorScheme.primary,
                              onChanged: (val) {
                                setState(() {
                                  _scheduleNextDose = val;
                                  if (!val) _nextDoseDate = null;
                                });
                              },
                            ),
                          ],
                        ),
                        if (_scheduleNextDose) ...[
                          const SizedBox(height: 8),
                          _FieldLabel(
                              label: local.nextDoseDate,
                              colorScheme: colorScheme,
                              textTheme: textTheme),
                          const SizedBox(height: 6),
                          _DatePickerField(
                            value: _nextDoseDate != null
                                ? dateFmt.format(_nextDoseDate!)
                                : local.tapToSetDate,
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                            onTap: _pickNextDoseDate,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),

                // ── Delete button (edit mode only) ─────────────────────────
                if (_isEditing && _editingSeries != null) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _deleteSeries,
                      icon: Icon(Icons.delete_outline,
                          color: colorScheme.error, size: 20),
                      label: Text(
                        local.deleteSeriesTitle,
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: colorScheme.error.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ],
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
                      .withValues(alpha: 0.85),
                  padding:
                      EdgeInsets.only(top: topPadding, left: 4, right: 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.arrow_back_ios_new,
                            color: colorScheme.onSurface, size: 20),
                      ),
                      Expanded(
                        child: Text(
                          _isEditing
                              ? local.editVaccination
                              : local.addVaccination,
                          style: textTheme.titleMedium?.copyWith(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shot date row
// ---------------------------------------------------------------------------

class _ShotDateRow extends StatelessWidget {
  const _ShotDateRow({
    required this.shotNumber,
    required this.date,
    required this.dateFmt,
    required this.colorScheme,
    required this.textTheme,
    required this.local,
    required this.onPickDate,
    required this.onClearDate,
  });

  final int shotNumber;
  final DateTime? date;
  final DateFormat dateFmt;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations local;
  final VoidCallback onPickDate;
  final VoidCallback onClearDate;

  String _statusLabel() {
    if (date == null) return local.shotStatusUnscheduled;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date!.year, date!.month, date!.day);
    if (d.isAfter(today)) return local.shotStatusPlanned;
    return local.shotStatusCompleted;
  }

  Color _statusColor() {
    if (date == null) return colorScheme.onSurfaceVariant;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date!.year, date!.month, date!.day);
    if (d.isAfter(today)) return colorScheme.primary;
    return colorScheme.tertiary;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            // Shot label
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                local.shot(shotNumber),
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),

            // Date text
            Expanded(
              child: Text(
                date != null ? dateFmt.format(date!) : local.tapToSetDate,
                style: textTheme.bodyMedium?.copyWith(
                  color: date != null
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ),

            // Status chip — Flexible so it yields space on small screens
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor().withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel(),
                  style: textTheme.labelSmall?.copyWith(
                    color: _statusColor(),
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 4),

            // Calendar pick button
            IconButton(
              onPressed: onPickDate,
              icon: Icon(Icons.calendar_today_outlined,
                  size: 18, color: colorScheme.primary),
              visualDensity: VisualDensity.compact,
              tooltip: 'Set date',
            ),

            // Clear button
            if (date != null)
              IconButton(
                onPressed: onClearDate,
                icon: Icon(Icons.close,
                    size: 16, color: colorScheme.onSurfaceVariant),
                visualDensity: VisualDensity.compact,
                tooltip: 'Clear date',
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stepper button
// ---------------------------------------------------------------------------

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
    required this.colorScheme,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Field label
// ---------------------------------------------------------------------------

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.label,
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: textTheme.labelMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Date picker field
// ---------------------------------------------------------------------------

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.value,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
  });

  final String value;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 18, color: colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom save bar
// ---------------------------------------------------------------------------

class _BottomSaveBar extends StatelessWidget {
  const _BottomSaveBar({
    required this.label,
    required this.enabled,
    required this.isSaving,
    required this.colorScheme,
    required this.textTheme,
    required this.onSave,
  });

  final String label;
  final bool enabled;
  final bool isSaving;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding + 12),
      color: colorScheme.surface,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: enabled ? onSave : null,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            disabledBackgroundColor:
                colorScheme.primary.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isSaving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : Text(
                  label,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}

