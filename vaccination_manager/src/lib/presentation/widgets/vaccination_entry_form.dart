import 'package:flutter/material.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';

typedef VaccinationEntrySubmit = Future<void> Function(String name, DateTime vaccinationDate, DateTime nextVaccinationRequiredDate);

class VaccinationEntryForm extends StatefulWidget {
  const VaccinationEntryForm({super.key, required this.submitLabel, required this.onSubmit, this.initialName, this.initialVaccinationDate, this.initialNextVaccinationRequiredDate, this.onCancel});

  final String submitLabel;
  final VaccinationEntrySubmit onSubmit;
  final String? initialName;
  final DateTime? initialVaccinationDate;
  final DateTime? initialNextVaccinationRequiredDate;
  final VoidCallback? onCancel;

  @override
  State<VaccinationEntryForm> createState() => _VaccinationEntryFormState();
}

class _VaccinationEntryFormState extends State<VaccinationEntryForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _vaccinationDateController;
  late final TextEditingController _nextVaccinationDateController;

  DateTime? _vaccinationDate;
  DateTime? _nextVaccinationRequiredDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _vaccinationDateController = TextEditingController();
    _nextVaccinationDateController = TextEditingController();
    _vaccinationDate = widget.initialVaccinationDate;
    _nextVaccinationRequiredDate = widget.initialNextVaccinationRequiredDate;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncDateControllers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _vaccinationDateController.dispose();
    _nextVaccinationDateController.dispose();
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
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: local.vaccinationName),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return local.vaccinationNameValidation;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _vaccinationDateController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: local.vaccinationDate,
              suffixIcon: IconButton(onPressed: _isSaving ? null : () => _pickVaccinationDate(context), icon: const Icon(Icons.calendar_today)),
            ),
            onTap: _isSaving ? null : () => _pickVaccinationDate(context),
            validator: (_) {
              if (_vaccinationDate == null) {
                return local.vaccinationDateValidation;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nextVaccinationDateController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: local.nextVaccinationRequired,
              suffixIcon: IconButton(onPressed: _isSaving ? null : () => _pickNextVaccinationDate(context), icon: const Icon(Icons.event_available)),
            ),
            onTap: _isSaving ? null : () => _pickNextVaccinationDate(context),
            validator: (_) {
              if (_nextVaccinationRequiredDate == null) {
                return local.nextVaccinationDateValidation;
              }
              if (_vaccinationDate != null && !_nextVaccinationRequiredDate!.isAfter(_vaccinationDate!)) {
                return local.nextVaccinationDateOrderValidation;
              }
              return null;
            },
          ),
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

  Future<void> _pickVaccinationDate(BuildContext context) async {
    final local = AppLocalizations.of(context)!;
    final picked = await showDatePicker(context: context, initialDate: _vaccinationDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100), helpText: local.vaccinationDate, confirmText: local.chooseDate);
    if (picked == null) {
      return;
    }
    setState(() {
      _vaccinationDate = picked;
      _syncDateControllers();
    });
  }

  Future<void> _pickNextVaccinationDate(BuildContext context) async {
    final local = AppLocalizations.of(context)!;
    final initialDate = _nextVaccinationRequiredDate ?? _vaccinationDate?.add(const Duration(days: 30)) ?? DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(2000), lastDate: DateTime(2100), helpText: local.nextVaccinationRequired, confirmText: local.chooseDate);
    if (picked == null) {
      return;
    }
    setState(() {
      _nextVaccinationRequiredDate = picked;
      _syncDateControllers();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.onSubmit(_nameController.text.trim(), _vaccinationDate!, _nextVaccinationRequiredDate!);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _syncDateControllers() {
    final localizations = MaterialLocalizations.of(context);
    _vaccinationDateController.text = _vaccinationDate == null ? '' : localizations.formatCompactDate(_vaccinationDate!);
    _nextVaccinationDateController.text = _nextVaccinationRequiredDate == null ? '' : localizations.formatCompactDate(_nextVaccinationRequiredDate!);
  }
}
