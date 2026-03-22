import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/vaccination/vaccination_providers.dart';
import 'package:vaccination_manager/presentation/widgets/vaccination_status_chip.dart';

class VaccinationPreviewCard extends ConsumerWidget {
  const VaccinationPreviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;
    final vaccinationState = ref.watch(vaccinationsProvider);
    final today = DateTime.now();

    return vaccinationState.when(
      loading: () => const Card(
        child: Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
      ),
      error: (error, _) => Card(
        child: Padding(padding: const EdgeInsets.all(16), child: Text('${local.error}: $error')),
      ),
      data: (state) {
        final nextDue = state.nextDueSeriesAt(today);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(local.vaccinationStatus, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (!state.hasActiveUser)
                  Text(local.noUsersBody)
                else if (!state.hasVaccinations) ...[
                  Text(local.noVaccinationsTitle, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(local.noVaccinationsBody),
                ] else ...[
                  Text(local.recordForUser(state.activeUser!.username), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text('${local.overdueVaccinations}: ${state.overdueCountAt(today)}'),
                  Text('${local.upcomingVaccinations}: ${state.dueSoonCountAt(today)}'),
                  if (nextDue != null) ...[
                    const SizedBox(height: 12),
                    Text(nextDue.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    VaccinationStatusChip(status: nextDue.statusAt(today)),
                    const SizedBox(height: 8),
                    Text('${local.nextDue}: ${MaterialLocalizations.of(context).formatCompactDate(nextDue.nextRequiredDate)}'),
                  ],
                ],
                const SizedBox(height: 16),
                FilledButton.tonal(onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(Routes.vaccinations, (route) => false), child: Text(local.vaccinations)),
              ],
            ),
          ),
        );
      },
    );
  }
}
