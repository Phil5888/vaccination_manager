import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/core/constants/app_spacing.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
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
    final initialSeriesName = arguments?.initialVaccinationName ?? initialEntry?.name;
    final overviewState = ref.watch(vaccinationsProvider).asData?.value;
    final initialSeries = _findSeries(overviewState?.series ?? const [], initialSeriesName);
    final initialShotDates = initialSeries?.entries.map((entry) => entry.vaccinationDate).toList() ?? (initialEntry == null ? <DateTime>[] : <DateTime>[initialEntry.vaccinationDate]);
    initialShotDates.sort((a, b) => a.compareTo(b));
    final initialExpirationDate = initialSeries?.nextRequiredDate ?? initialEntry?.nextVaccinationRequiredDate;
    final initialMode = initialShotDates.length > 1 ? VaccinationCourseMode.multiShot : VaccinationCourseMode.oneShot;

    return Scaffold(
      appBar: AppBar(title: Text(initialEntry == null ? local.addVaccination : local.editVaccination)),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Card(
              child: Padding(
                padding: AppSpacing.contentPadding,
                child: VaccinationEntryForm(
                  submitLabel: local.save,
                  initialName: initialSeriesName,
                  initialShotDates: initialShotDates,
                  initialExpirationDate: initialExpirationDate,
                  initialMode: initialMode,
                  onCancel: () => Navigator.of(context).pop(),
                  onSubmit: (name, shotDates, expirationDate) async {
                    await ref.read(vaccinationsProvider.notifier).saveVaccinationCourse(name: name, shotDates: shotDates, expirationDate: expirationDate, existingSeriesName: initialSeriesName);

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

  VaccinationSeriesEntity? _findSeries(List<VaccinationSeriesEntity> series, String? name) {
    if (name == null) {
      return null;
    }
    final key = name.trim().toLowerCase();
    for (final item in series) {
      if (item.name.trim().toLowerCase() == key) {
        return item;
      }
    }
    return null;
  }
}
