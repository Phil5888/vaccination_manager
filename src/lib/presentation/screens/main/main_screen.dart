import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/domain/entities/reminder_status.dart';
import 'package:vaccination_manager/presentation/providers/navigation_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_providers.dart';
import 'package:vaccination_manager/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:vaccination_manager/presentation/screens/profile/profile_screen.dart';
import 'package:vaccination_manager/presentation/screens/records/records_screen.dart';
import 'package:vaccination_manager/presentation/screens/schedule/schedule_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  static const _screens = <Widget>[
    DashboardScreen(),
    RecordsScreen(),
    ScheduleScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabProvider);
    final local = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final remindersAsync = ref.watch(vaccinationRemindersProvider);
    final overdueCount = remindersAsync.whenOrNull(
          data: (list) =>
              list.where((r) => r.status == ReminderStatus.overdue).length,
        ) ??
        0;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBody: true,
      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
      // FAB shown on all content tabs except Profile (index 3)
      floatingActionButton: selectedIndex != 3
          ? FloatingActionButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(Routes.vaccinationAdd),
              tooltip: local.addVaccination,
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _GlassNavBar(
        selectedIndex: selectedIndex,
        isDark: isDark,
        colorScheme: colorScheme,
        onDestinationSelected: (index) =>
            ref.read(selectedTabProvider.notifier).selectTab(index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: local.dashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.description_outlined),
            selectedIcon: const Icon(Icons.description),
            label: local.navRecords,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: overdueCount > 0,
              label: Text('$overdueCount'),
              child: const Icon(Icons.event_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: overdueCount > 0,
              label: Text('$overdueCount'),
              child: const Icon(Icons.event),
            ),
            label: local.navSchedule,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: local.navProfile,
          ),
        ],
      ),
    );
  }
}

/// A Material 3 [NavigationBar] wrapped in a glassmorphism container.
///
/// The blur + semi-transparent background mirrors the mockup's
/// `bg-white/80 backdrop-blur-2xl` treatment.
class _GlassNavBar extends StatelessWidget {
  const _GlassNavBar({
    required this.selectedIndex,
    required this.isDark,
    required this.colorScheme,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final bool isDark;
  final ColorScheme colorScheme;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final baseColor = isDark
        ? colorScheme.surfaceContainerLow
        : colorScheme.surfaceContainerLowest;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        // Override only the icon colour so selected icons use onPrimaryContainer
        // (#C8DAFF light / #D6E3FF dark) — designed for contrast on the
        // primaryContainer indicator pill. M3's default pairing is
        // onSecondaryContainer which clashes with a primaryContainer indicator.
        child: Theme(
          data: Theme.of(context).copyWith(
            navigationBarTheme: NavigationBarThemeData(
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return IconThemeData(color: colorScheme.onPrimaryContainer);
                }
                return IconThemeData(color: colorScheme.onSurfaceVariant);
              }),
            ),
          ),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: destinations,
            // Semi-transparent background for the glass effect
            backgroundColor: baseColor.withAlpha(isDark ? 200 : 220),
            surfaceTintColor: colorScheme.surfaceTint,
            indicatorColor: colorScheme.primaryContainer,
            shadowColor: Colors.transparent,
            elevation: 0,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
        ),
      ),
    );
  }
}

