import 'package:flutter/material.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/screens/dashboard/widgets/vaccination_preview.dart';
import 'package:vaccination_manager/presentation/screens/dashboard/widgets/settings_preview.dart';
import 'package:vaccination_manager/presentation/screens/dashboard/widgets/user_preview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(local.dashboard)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(child: UserPreviewCard()),
                      SizedBox(width: 16),
                      Expanded(child: VaccinationPreviewCard()),
                      SizedBox(width: 16),
                      Expanded(child: SettingsPreviewCard()),
                    ],
                  )
                : Column(children: const [UserPreviewCard(), SizedBox(height: 16), VaccinationPreviewCard(), SizedBox(height: 16), SettingsPreviewCard()]);
          },
        ),
      ),
    );
  }
}
