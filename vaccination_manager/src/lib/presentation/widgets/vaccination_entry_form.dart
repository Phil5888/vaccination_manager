import 'package:flutter/material.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';

enum VaccinationCourseMode { oneShot, multiShot }

typedef VaccinationEntrySubmit = Future<void> Function(String name, List<DateTime> shotDates, DateTime expirationDate);

class VaccinationEntryForm extends StatefulWidget {
  const VaccinationEntryForm({super.key, required this.submitLabel, required this.onSubmit, this.initialName, this.initialShotDates, this.initialExpirationDate, this.initialMode, this.onCancel});

  final String submitLabel;
  final VaccinationEntrySubmit onSubmit;
  final String? initialName;
  final List<DateTime>? initialShotDates;
  final DateTime? initialExpirationDate;
  final VaccinationCourseMode? initialMode;
  final VoidCallback? onCancel;

  @override
  State<VaccinationEntryForm> createState() => _VaccinationEntryFormState();
}

class _VaccinationEntryFormState extends State<VaccinationEntryForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final List<TextEditingController> _shotDateControllers = [];
  late final TextEditingController _expirationDateController;

  late VaccinationCourseMode _mode;
  final List<DateTime?> _shotDates = [];
  DateTime? _expirationDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _expirationDateController = TextEditingController();

    _mode = widget.initialMode ?? ((widget.initialShotDates?.length ?? 0) > 1 ? VaccinationCourseMode.multiShot : VaccinationCourseMode.oneShot);

    final initialDates = widget.initialShotDates;
    if (initialDates != null && initialDates.isNotEmpty) {
      _shotDates.addAll(initialDates);
    } else {
      _shotDates.add(null);
    }

    _expirationDate = widget.initialExpirationDate;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncDateControllers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _expirationDateController.dispose();
    for (final controller in _shotDateControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(local.vaccinationName, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return local.vaccinationNameValidation;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Text(local.vaccinationModeLabel, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(label: Text(local.vaccinationModeOneShot), selected: _mode == VaccinationCourseMode.oneShot, onSelected: _isSaving ? null : (_) => _changeMode(VaccinationCourseMode.oneShot)),
              ChoiceChip(label: Text(local.vaccinationModeMultiShot), selected: _mode == VaccinationCourseMode.multiShot, onSelected: _isSaving ? null : (_) => _changeMode(VaccinationCourseMode.multiShot)),
            ],
          ),
          const SizedBox(height: 16),
          Text(local.shotDatesLabel, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FormField<List<DateTime?>>(
            initialValue: _shotDates,
            validator: (_) {
              if (_shotDates.isEmpty || _shotDates.any((date) => date == null)) {
                return local.shotDatesValidation;
              }

              final uniqueDateKeys = _shotDates.map((date) => _dateKey(date!)).toSet();
              if (uniqueDateKeys.length != _shotDates.length) {
                return local.duplicateShotDateValidation;
              }

              return null;
            },
            builder: (field) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...List.generate(_shotDates.length, (index) {
                    final shotDate = _shotDates[index];
                    final isPlanned = shotDate != null && _dateOnly(shotDate).isAfter(_dateOnly(DateTime.now()));
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == _shotDates.length - 1 ? 0 : 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(local.shotNumber(index + 1), style: Theme.of(context).textTheme.titleSmall),
                                const SizedBox(height: 4),
                                TextFormField(
                                  controller: _shotDateControllers[index],
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      onPressed: _isSaving
                                          ? null
                                          : () async {
                                              await _pickShotDate(context, index);
                                              field.didChange(_shotDates);
                                            },
                                      icon: const Icon(Icons.calendar_today),
                                    ),
                                  ),
                                  onTap: _isSaving
                                      ? null
                                      : () async {
                                          await _pickShotDate(context, index);
                                          field.didChange(_shotDates);
                                        },
                                ),
                                const SizedBox(height: 4),
                                Text(isPlanned ? local.plannedShot : local.recordedShot, style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          if (_mode == VaccinationCourseMode.multiShot && _shotDates.length > 1) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: local.removeShot,
                              onPressed: _isSaving
                                  ? null
                                  : () {
                                      setState(() {
                                        _removeShotAt(index);
                                      });
                                      field.didChange(_shotDates);
                                    },
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                  if (_mode == VaccinationCourseMode.multiShot) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _isSaving
                          ? null
                          : () {
                              setState(_addShot);
                              field.didChange(_shotDates);
                            },
                      icon: const Icon(Icons.add),
                      label: Text(local.addAnotherShot),
                    ),
                  ],
                  if (field.errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(field.errorText!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Text(local.vaccinationExpiresOn, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _expirationDateController,
            readOnly: true,
            decoration: InputDecoration(
              suffixIcon: IconButton(onPressed: _isSaving ? null : () => _pickExpirationDate(context), icon: const Icon(Icons.event_available)),
            ),
            onTap: _isSaving ? null : () => _pickExpirationDate(context),
            validator: (_) {
              if (_expirationDate == null) {
                return local.vaccinationExpiresValidation;
              }

              final definedShotDates = _shotDates.whereType<DateTime>().toList();
              if (definedShotDates.isEmpty) {
                return null;
              }

              final latestShot = definedShotDates.reduce((a, b) => a.isAfter(b) ? a : b);
              if (_dateOnly(_expirationDate!).isBefore(_dateOnly(latestShot))) {
                return local.vaccinationExpiresOrderValidation;
              }

              return null;
            },
          ),
          const SizedBox(height: 8),
          Text(local.futureShotHint, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text(widget.submitLabel),
              ),
              if (widget.onCancel != null) OutlinedButton(onPressed: _isSaving ? null : widget.onCancel, child: Text(local.cancel)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickShotDate(BuildContext context, int index) async {
    final local = AppLocalizations.of(context)!;
    final picked = await showDatePicker(context: context, initialDate: _shotDates[index] ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100), helpText: local.vaccinationDate, confirmText: local.chooseDate);
    if (picked == null) {
      return;
    }
    setState(() {
      _shotDates[index] = picked;
      _syncDateControllers();
    });
  }

  Future<void> _pickExpirationDate(BuildContext context) async {
    final local = AppLocalizations.of(context)!;
    final initialDate = _expirationDate ?? DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(2000), lastDate: DateTime(2100), helpText: local.vaccinationExpiresOn, confirmText: local.chooseDate);
    if (picked == null) {
      return;
    }
    setState(() {
      _expirationDate = picked;
      _syncDateControllers();
    });
  }

  Future<void> _changeMode(VaccinationCourseMode mode) async {
    if (_mode == mode) {
      return;
    }

    if (mode == VaccinationCourseMode.oneShot && _shotDates.length > 1) {
      final local = AppLocalizations.of(context)!;
      final shouldSwitch = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(local.switchToOneShotTitle),
            content: Text(local.switchToOneShotBody(_shotDates.length - 1)),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(local.switchToOneShotCancel)),
              FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(local.switchToOneShotConfirm)),
            ],
          );
        },
      );

      if (shouldSwitch != true) {
        return;
      }

      final keptShot = _shotDates.whereType<DateTime>().toList()..sort((a, b) => b.compareTo(a));
      _shotDates
        ..clear()
        ..add(keptShot.isEmpty ? null : keptShot.first);
      _syncDateControllers();
    }

    setState(() {
      _mode = mode;
      if (_mode == VaccinationCourseMode.multiShot && _shotDates.isEmpty) {
        _addShot();
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.onSubmit(_nameController.text.trim(), _shotDates.whereType<DateTime>().toList(), _expirationDate!);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _syncDateControllers() {
    final localizations = MaterialLocalizations.of(context);
    while (_shotDateControllers.length < _shotDates.length) {
      _shotDateControllers.add(TextEditingController());
    }
    while (_shotDateControllers.length > _shotDates.length) {
      _shotDateControllers.removeLast().dispose();
    }

    for (var i = 0; i < _shotDates.length; i++) {
      final date = _shotDates[i];
      _shotDateControllers[i].text = date == null ? '' : localizations.formatCompactDate(date);
    }

    _expirationDateController.text = _expirationDate == null ? '' : localizations.formatCompactDate(_expirationDate!);
  }

  void _addShot() {
    _shotDates.add(null);
    _syncDateControllers();
  }

  void _removeShotAt(int index) {
    if (_shotDates.length == 1) {
      return;
    }
    _shotDates.removeAt(index);
    _syncDateControllers();
  }

  String _dateKey(DateTime value) {
    final date = _dateOnly(value);
    return '${date.year}-${date.month}-${date.day}';
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
