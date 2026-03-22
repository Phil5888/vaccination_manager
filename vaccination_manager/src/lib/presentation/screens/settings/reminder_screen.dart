import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/core/constants/app_spacing.dart';
import 'package:vaccination_manager/core/constants/reminder_lead_time.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/settings/settings_dependency_providers.dart';
import 'package:vaccination_manager/presentation/providers/settings/settings_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination/vaccination_providers.dart';

class ReminderScreen extends ConsumerStatefulWidget {
  const ReminderScreen({super.key});

  @override
  ConsumerState<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends ConsumerState<ReminderScreen> {
  bool _syncInProgress = false;

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(local.reminders)),
      body: ListView(
        padding: AppSpacing.listPadding,
        children: [
          Text(local.notificationLeadTime, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<ReminderLeadTime>(
            initialValue: settings.reminderLeadTime,
            items: [
              DropdownMenuItem(value: ReminderLeadTime.threeDays, child: Text(local.reminderLeadTime3Days)),
              DropdownMenuItem(value: ReminderLeadTime.oneWeek, child: Text(local.reminderLeadTime1Week)),
              DropdownMenuItem(value: ReminderLeadTime.twoWeeks, child: Text(local.reminderLeadTime2Weeks)),
              DropdownMenuItem(value: ReminderLeadTime.oneMonth, child: Text(local.reminderLeadTime1Month)),
              DropdownMenuItem(value: ReminderLeadTime.twoMonths, child: Text(local.reminderLeadTime2Months)),
              DropdownMenuItem(value: ReminderLeadTime.threeMonths, child: Text(local.reminderLeadTime3Months)),
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).setReminderLeadTime(value);
              }
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Card(
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(local.reminderSyncDescription, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: _syncInProgress ? null : _syncReminders,
                    icon: _syncInProgress ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.sync),
                    label: Text(local.syncRemindersNow),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _syncReminders() async {
    final local = AppLocalizations.of(context)!;
    final vaccinationState = ref.read(vaccinationsProvider).asData?.value;

    if (vaccinationState == null || !vaccinationState.hasActiveUser) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(local.noUsersBody)));
      return;
    }

    setState(() => _syncInProgress = true);
    try {
      final settings = ref.read(settingsProvider);
      final service = ref.read(reminderSyncServiceProvider);
      final result = await service.syncForUser(user: vaccinationState.activeUser!, series: vaccinationState.series, leadTime: settings.reminderLeadTime);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(local.reminderSyncSuccess(result.createdCalendarEntries, result.updatedCalendarEntries, result.removedCalendarEntries, result.scheduledNotifications))));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${local.error}: $error')));
    } finally {
      if (mounted) {
        setState(() => _syncInProgress = false);
      }
    }
  }
}
