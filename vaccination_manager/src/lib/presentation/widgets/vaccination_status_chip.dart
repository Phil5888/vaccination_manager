import 'package:flutter/material.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';

class VaccinationStatusChip extends StatelessWidget {
  const VaccinationStatusChip({super.key, required this.status});

  final VaccinationDueStatus status;

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    late final Color backgroundColor;
    late final Color foregroundColor;
    late final String label;

    switch (status) {
      case VaccinationDueStatus.overdue:
        backgroundColor = colors.errorContainer;
        foregroundColor = colors.onErrorContainer;
        label = local.overdue;
      case VaccinationDueStatus.dueSoon:
        backgroundColor = colors.tertiaryContainer;
        foregroundColor = colors.onTertiaryContainer;
        label = local.dueSoon;
      case VaccinationDueStatus.upToDate:
        backgroundColor = colors.secondaryContainer;
        foregroundColor = colors.onSecondaryContainer;
        label = local.upToDate;
    }

    return Chip(
      label: Text(label),
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(color: foregroundColor),
      side: BorderSide.none,
    );
  }
}
