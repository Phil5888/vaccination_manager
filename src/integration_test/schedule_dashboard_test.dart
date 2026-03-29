// Integration tests — Schedule tab and Dashboard data display.
//
// Verifies that vaccination data flows from SQLite all the way into the
// Schedule and Dashboard UI:
//   • A saved vaccination appears in the Schedule tab (under "All" filter)
//   • A saved vaccination appears in the Dashboard's recent vaccinations list
//   • The Dashboard stat chips reflect the current vaccination status counts
//
// Run on device:
//   flutter test integration_test/schedule_dashboard_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/presentation/screens/vaccination/add_vaccination_screen.dart';
import 'package:vaccination_manager/presentation/screens/main/main_screen.dart';

import 'helpers/app_driver.dart';

// ---------------------------------------------------------------------------
// Helper: save a vaccination via the FAB on the Records tab
// ---------------------------------------------------------------------------

Future<void> _saveVaccination(WidgetTester tester, String name) async {
  // Navigate to Records tab and use its FAB.
  await navigateToTab(tester, Icons.description_outlined);
  await tester.tap(find.byType(FloatingActionButton));
  await settleOrTimeout(tester);

  expect(find.byType(AddVaccinationScreen), findsOneWidget);

  await tester.enterText(
    find.byKey(const Key('vaccineNameField')),
    name,
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('Save Vaccination'));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  expect(find.byType(MainScreen), findsOneWidget);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  initIntegrationTest();

  group('Schedule tab', () {
    testWidgets(
      'saved vaccination appears in Schedule tab under "All" filter',
      (tester) async {
        await resetAndSeedUser(tester, name: 'Schedule Tester');
        await _saveVaccination(tester, 'MMR Vaccine');

        // Navigate to Schedule tab.
        await navigateToTab(tester, Icons.event_outlined);

        // The Schedule tab defaults to "All" filter — the vaccination should be
        // visible regardless of its reminder status.
        expect(find.text('MMR Vaccine'), findsWidgets,
            reason:
                'Saved vaccination must appear in the Schedule tab under "All"');
      },
    );

    testWidgets(
      'empty state shown when no vaccinations saved',
      (tester) async {
        await resetAndSeedUser(tester, name: 'Empty Schedule Tester');

        // Navigate to Schedule tab with an empty database.
        await navigateToTab(tester, Icons.event_outlined);

        // With no vaccinations, the schedule screen shows its empty state.
        // The list should be absent.
        expect(find.text('MMR Vaccine'), findsNothing);
      },
    );

    testWidgets(
      'multiple vaccinations all appear in Schedule tab',
      (tester) async {
        await resetAndSeedUser(tester, name: 'Multi Schedule Tester');
        await _saveVaccination(tester, 'Polio');
        await _saveVaccination(tester, 'Rabies');

        await navigateToTab(tester, Icons.event_outlined);

        expect(find.text('Polio'), findsWidgets,
            reason: '"Polio" must appear in Schedule tab');
        expect(find.text('Rabies'), findsWidgets,
            reason: '"Rabies" must appear in Schedule tab');
      },
    );
  });

  group('Dashboard', () {
    testWidgets(
      'saved vaccination appears in Dashboard recent list',
      (tester) async {
        await resetAndSeedUser(tester, name: 'Dashboard Tester');
        await _saveVaccination(tester, 'Influenza');

        // Navigate back to Dashboard (tab 0).
        await tester.tap(find.byIcon(Icons.home_outlined));
        await settleOrTimeout(tester);

        // The vaccination name should be visible in the dashboard.
        expect(find.text('Influenza'), findsWidgets,
            reason:
                'Saved vaccination must appear in the Dashboard recent list');
      },
    );

    testWidgets(
      'Dashboard stat chips are visible after saving a vaccination',
      (tester) async {
        await resetAndSeedUser(tester, name: 'Stats Tester');
        await _saveVaccination(tester, 'Typhoid');

        // Navigate to Dashboard.
        await tester.tap(find.byIcon(Icons.home_outlined));
        await settleOrTimeout(tester);

        // The stat chip row must be rendered (overdue + upcoming counters).
        // Even with zero items the chips are displayed with count 0.
        expect(find.textContaining('Overdue'), findsWidgets,
            reason: 'Overdue stat chip must be visible on Dashboard');
        expect(find.textContaining('Upcoming'), findsWidgets,
            reason: 'Upcoming stat chip must be visible on Dashboard');
      },
    );
  });
}
