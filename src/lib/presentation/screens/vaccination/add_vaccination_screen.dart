import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/user_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_providers.dart';

// ---------------------------------------------------------------------------
// Data model for a single shot row in multi-shot mode
// ---------------------------------------------------------------------------

class _ShotRow {
  int? id; // null = new (not yet persisted)
  DateTime date;

  _ShotRow({this.id, required this.date});
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class AddVaccinationScreen extends ConsumerStatefulWidget {
  const AddVaccinationScreen({super.key, this.existingEntry});

  final VaccinationEntryEntity? existingEntry;

  @override
  ConsumerState<AddVaccinationScreen> createState() =>
      _AddVaccinationScreenState();
}

class _AddVaccinationScreenState extends ConsumerState<AddVaccinationScreen> {
  final _nameController = TextEditingController();

  // ── One-shot state ──────────────────────────────────────────────────────
  late DateTime _vaccinationDate;
  DateTime? _nextVaccinationDate;
  bool _scheduleNextDose = false;

  // ── Multi-shot state ────────────────────────────────────────────────────
  bool _isMultiShot = false;
  List<_ShotRow> _shotRows = [];
  bool _seriesInitialized = false;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      _nameController.text = widget.existingEntry!.name;
      _vaccinationDate = widget.existingEntry!.vaccinationDate;
      _nextVaccinationDate = widget.existingEntry!.nextVaccinationDate;
      _scheduleNextDose = _nextVaccinationDate != null;
    } else {
      _vaccinationDate = DateTime.now();
    }
    // Initialize shot rows with the single entry (will be expanded if series)
    _shotRows = [
      _ShotRow(
        id: widget.existingEntry?.id,
        date: widget.existingEntry?.vaccinationDate ?? DateTime.now(),
      ),
    ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ── Series initialization (edit mode) ───────────────────────────────────

  void _initializeSeries(List<VaccinationEntryEntity> vaccinations) {
    if (_seriesInitialized || widget.existingEntry == null) return;
    _seriesInitialized = true;

    final name = widget.existingEntry!.name.toLowerCase();
    final seriesShots = vaccinations
        .where((e) => e.name.toLowerCase() == name)
        .toList()
      ..sort((a, b) => a.vaccinationDate.compareTo(b.vaccinationDate));

    if (seriesShots.length > 1) {
      setState(() {
        _isMultiShot = true;
        _shotRows = seriesShots
            .map((e) => _ShotRow(id: e.id, date: e.vaccinationDate))
            .toList();
      });
    }
  }

  // ── Mode toggle ─────────────────────────────────────────────────────────

  Future<void> _handleModeToggle(bool toMultiShot) async {
    if (toMultiShot && !_isMultiShot) {
      // One-shot → multi-shot: seed rows from current one-shot date
      setState(() {
        _isMultiShot = true;
        _shotRows = [
          _ShotRow(id: widget.existingEntry?.id, date: _vaccinationDate),
        ];
      });
    } else if (!toMultiShot && _isMultiShot) {
      // Multi-shot → one-shot
      final persistedShots = _shotRows.where((r) => r.id != null).toList();
      if (persistedShots.length > 1) {
        // Need confirmation before deleting extra shots
        final confirmed = await _showSwitchToOneShotDialog();
        if (!confirmed) return;

        // Sort by date ASC, keep earliest, delete the rest
        final sorted = List.of(persistedShots)
          ..sort((a, b) => a.date.compareTo(b.date));
        for (final row in sorted.skip(1)) {
          await ref.read(vaccinationProvider.notifier).deleteShot(row.id!);
        }
        final earliest = sorted.first;
        setState(() {
          _isMultiShot = false;
          _vaccinationDate = earliest.date;
          _shotRows = [earliest];
        });
      } else {
        setState(() => _isMultiShot = false);
      }
    }
  }

  Future<bool> _showSwitchToOneShotDialog() async {
    final local = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(local.switchToOneShotTitle),
        content: Text(local.switchToOneShotBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(local.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(local.confirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ── Date pickers ─────────────────────────────────────────────────────────

  Future<void> _pickVaccinationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _vaccinationDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) setState(() => _vaccinationDate = picked);
  }

  Future<void> _pickShotDate(int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _shotRows[index].date,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) setState(() => _shotRows[index].date = picked);
  }

  Future<void> _pickNextDoseDate() async {
    final initial = _nextVaccinationDate ??
        (_isMultiShot && _shotRows.isNotEmpty
            ? _shotRows.last.date.add(const Duration(days: 30))
            : _vaccinationDate.add(const Duration(days: 30)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) setState(() => _nextVaccinationDate = picked);
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final activeUser = await ref.read(activeUserProvider.future);
    if (activeUser == null) return;

    setState(() => _isSaving = true);
    try {
      if (_isMultiShot) {
        for (var i = 0; i < _shotRows.length; i++) {
          final row = _shotRows[i];
          final isLast = i == _shotRows.length - 1;
          final entry = VaccinationEntryEntity(
            id: row.id,
            userId: activeUser.id!,
            name: name,
            vaccinationDate: row.date,
            nextVaccinationDate:
                isLast && _scheduleNextDose ? _nextVaccinationDate : null,
          );
          await ref.read(vaccinationProvider.notifier).saveVaccination(entry);
        }
      } else {
        final entry = VaccinationEntryEntity(
          id: widget.existingEntry?.id,
          userId: activeUser.id!,
          name: name,
          vaccinationDate: _vaccinationDate,
          nextVaccinationDate: _scheduleNextDose ? _nextVaccinationDate : null,
        );
        await ref.read(vaccinationProvider.notifier).saveVaccination(entry);
      }
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final topPadding = MediaQuery.of(context).padding.top;
    final isEdit = widget.existingEntry != null;
    final nameIsEmpty = _nameController.text.trim().isEmpty;
    final dateFmt = DateFormat('MMM dd, yyyy');

    // Initialize series from loaded vaccinations (edit mode)
    ref.listen(vaccinationProvider, (_, next) {
      next.whenData((vaccinations) {
        if (!_seriesInitialized) _initializeSeries(vaccinations);
      });
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: _BottomSaveBar(
        label: local.saveVaccination,
        enabled: !nameIsEmpty && !_isSaving,
        isSaving: _isSaving,
        colorScheme: colorScheme,
        textTheme: textTheme,
        onSave: _save,
      ),
      body: Stack(
        children: [
          // Scrollable form content
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, topPadding + 72, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Screen header
                Text(
                  isEdit ? local.editVaccination : local.addVaccination,
                  style: textTheme.headlineMedium?.copyWith(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ensure your medical profile stays up to date by logging new vaccinations.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Mode toggle ──────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ModeToggleButton(
                          label: local.oneShotMode,
                          isSelected: !_isMultiShot,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                          onTap: () => _handleModeToggle(false),
                        ),
                      ),
                      Expanded(
                        child: _ModeToggleButton(
                          label: local.multiShotMode,
                          isSelected: _isMultiShot,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                          onTap: () => _handleModeToggle(true),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

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
                      // Vaccine Name
                      _FieldLabel(
                          label: local.vaccineName,
                          colorScheme: colorScheme),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _nameController,
                        onChanged: (_) => setState(() {}),
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
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── One-shot fields ──────────────────────────────────
                      if (!_isMultiShot) ...[
                        _FieldLabel(
                            label: local.dateAdministered,
                            colorScheme: colorScheme),
                        const SizedBox(height: 6),
                        _DatePickerField(
                          value: dateFmt.format(_vaccinationDate),
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                          onTap: _pickVaccinationDate,
                        ),
                        const SizedBox(height: 20),
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
                              onChanged: (val) {
                                setState(() {
                                  _scheduleNextDose = val;
                                  if (!val) _nextVaccinationDate = null;
                                  if (val && _nextVaccinationDate == null) {
                                    _nextVaccinationDate = _vaccinationDate
                                        .add(const Duration(days: 30));
                                  }
                                });
                              },
                              activeThumbColor: colorScheme.primary,
                            ),
                          ],
                        ),
                        if (_scheduleNextDose) ...[
                          const SizedBox(height: 12),
                          _FieldLabel(
                              label: local.nextDoseDate,
                              colorScheme: colorScheme,
                              isSecondary: true),
                          const SizedBox(height: 6),
                          _DatePickerField(
                            value: _nextVaccinationDate != null
                                ? dateFmt.format(_nextVaccinationDate!)
                                : '—',
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                            onTap: _pickNextDoseDate,
                            isSecondary: true,
                          ),
                        ],
                      ],

                      // ── Multi-shot fields ────────────────────────────────
                      if (_isMultiShot) ...[
                        _FieldLabel(
                            label: local.dateAdministered,
                            colorScheme: colorScheme),
                        const SizedBox(height: 10),
                        ...List.generate(_shotRows.length, (index) {
                          final row = _shotRows[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _DatePickerField(
                                    value: dateFmt.format(row.date),
                                    colorScheme: colorScheme,
                                    textTheme: textTheme,
                                    onTap: () => _pickShotDate(index),
                                    prefixLabel: local.shot(index + 1),
                                  ),
                                ),
                                if (_shotRows.length > 1) ...[
                                  const SizedBox(width: 8),
                                  _RemoveShotButton(
                                    colorScheme: colorScheme,
                                    onPressed: () async {
                                      if (row.id != null) {
                                        await ref
                                            .read(
                                                vaccinationProvider.notifier)
                                            .deleteShot(row.id!);
                                      }
                                      setState(
                                          () => _shotRows.removeAt(index));
                                    },
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),

                        // Add Another Shot
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              final lastDate = _shotRows.isNotEmpty
                                  ? _shotRows.last.date
                                  : DateTime.now();
                              _shotRows.add(_ShotRow(
                                date: lastDate.add(const Duration(days: 30)),
                              ));
                            });
                          },
                          icon: Icon(Icons.add_circle_outline,
                              color: colorScheme.primary, size: 20),
                          label: Text(
                            local.addAnotherShot,
                            style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.primary),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Schedule next dose toggle (applies to last shot)
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
                              onChanged: (val) {
                                setState(() {
                                  _scheduleNextDose = val;
                                  if (!val) _nextVaccinationDate = null;
                                  if (val && _nextVaccinationDate == null) {
                                    final base = _shotRows.isNotEmpty
                                        ? _shotRows.last.date
                                        : DateTime.now();
                                    _nextVaccinationDate =
                                        base.add(const Duration(days: 30));
                                  }
                                });
                              },
                              activeThumbColor: colorScheme.primary,
                            ),
                          ],
                        ),
                        if (_scheduleNextDose) ...[
                          const SizedBox(height: 12),
                          _FieldLabel(
                              label: local.nextDoseDate,
                              colorScheme: colorScheme,
                              isSecondary: true),
                          const SizedBox(height: 6),
                          _DatePickerField(
                            value: _nextVaccinationDate != null
                                ? dateFmt.format(_nextVaccinationDate!)
                                : '—',
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                            onTap: _pickNextDoseDate,
                            isSecondary: true,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
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
                      .withValues(alpha: 0.8),
                  padding:
                      EdgeInsets.only(top: topPadding, left: 8, right: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: colorScheme.onSurface),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Text(
                          isEdit
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
// Internal widgets
// ---------------------------------------------------------------------------

class _ModeToggleButton extends StatelessWidget {
  const _ModeToggleButton({
    required this.label,
    required this.isSelected,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.surfaceContainerLowest
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _RemoveShotButton extends StatelessWidget {
  const _RemoveShotButton({
    required this.colorScheme,
    required this.onPressed,
  });

  final ColorScheme colorScheme;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorScheme.errorContainer.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(Icons.remove_circle_outline,
              color: colorScheme.error, size: 20),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.label,
    required this.colorScheme,
    this.isSecondary = false,
  });

  final String label;
  final ColorScheme colorScheme;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isSecondary ? colorScheme.tertiary : colorScheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.value,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
    this.isSecondary = false,
    this.prefixLabel,
  });

  final String value;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;
  final bool isSecondary;

  /// Optional label shown before the date value (e.g. "Shot 1").
  final String? prefixLabel;

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
            if (prefixLabel != null) ...[
              Text(
                prefixLabel!,
                style: textTheme.labelSmall?.copyWith(
                  color: isSecondary
                      ? colorScheme.tertiary
                      : colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
            ] else ...[
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: isSecondary
                    ? colorScheme.tertiary
                    : colorScheme.primary,
              ),
              const SizedBox(width: 10),
            ],
            Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.calendar_today_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}

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
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color:
                colorScheme.surfaceContainerLowest.withValues(alpha: 0.9),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: enabled
                        ? LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primaryContainer,
                            ],
                          )
                        : null,
                    color: enabled ? null : colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: enabled
                        ? [
                            BoxShadow(
                              color: colorScheme.primary
                                  .withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: ElevatedButton(
                    onPressed: enabled ? onSave : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            label,
                            style: textTheme.titleMedium?.copyWith(
                              color: enabled
                                  ? Colors.white
                                  : colorScheme.onSurfaceVariant,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

