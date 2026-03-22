import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/vaccination/vaccination_providers.dart';
import 'package:vaccination_manager/presentation/widgets/vaccination_entry_form.dart';

class VaccinationEditArguments {
  const VaccinationEditArguments({this.initialEntry, this.initialVaccinationName});

  final VaccinationEntryEntity? initialEntry;
  final String? initialVaccinationName;
}

class VaccinationEditScreen extends ConsumerWidget {
  const VaccinationEditScreen({super.key, this.arguments});

  final VaccinationEditArguments? arguments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;
    final initialEntry = arguments?.initialEntry;

    return Scaffold(
      appBar: AppBar(title: Text(initialEntry == null ? local.addVaccination : local.editVaccination)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: VaccinationEntryForm(
                  submitLabel: local.save,
                  initialName: initialEntry?.name ?? arguments?.initialVaccinationName,
                  initialVaccinationDate: initialEntry?.vaccinationDate,
                  initialNextVaccinationRequiredDate: initialEntry?.nextVaccinationRequiredDate,
                  onCancel: () => Navigator.of(context).pop(),
                  onSubmit: (name, vaccinationDate, nextVaccinationRequiredDate) async {
                    await ref.read(vaccinationsProvider.notifier).saveVaccination(id: initialEntry?.id, name: name, vaccinationDate: vaccinationDate, nextVaccinationRequiredDate: nextVaccinationRequiredDate);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(local.saveVaccinationSuccess)));
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
