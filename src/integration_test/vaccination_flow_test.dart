// Integration tests — core vaccination save flow.
//
// Verifies the full round-trip:
//   open AddVaccinationScreen → fill name → save → vaccination appears in Records
//
// This test exercises real SQLite (sqflite) and the full Riverpod provider
// graph; no fakes are used.
//
// Run on device:
//   flutter test integration_test/vaccination_flow_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/presentation/screens/main/main_screen.dart';
import 'package:vaccination_manager/presentation/screens/welcome/welcome_screen.dart';

import 'helpers/app_driver.dart';

// ---------------------------------------------------------------------------
// Helper: seed a user and land on the Records tab
// ---------------------------------------------------------------------------

Future<void> _reachRecordsTab(WidgetTester tester) async {
  await resetAndPumpApp(tester);

  if (find.byType(WelcomeScreen).evaluate().isNotEmpty) {
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Flow Tester');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('submitProfileButton')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  expect(find.byType(MainScreen), findsOneWidget);

  // Navigate to Records tab.
  await tester.tap(find.byIcon(Icons.description_outlined));
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  initIntegrationTest();

  group('Vaccination save flow', () {
    testWidgets(
      'save a single-shot vaccination → it appears in the Records list',
      (tester) async {
        await _reachRecordsTab(tester);

        // Open add screen.
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Enter vaccine name.
        final nameField = find.widgetWithText(TextField, 'Vaccine Name');
        expect(nameField, findsOneWidget,
            reason: 'Vaccine Name field must be present on AddVaccinationScreen');
        await tester.enterText(nameField, 'Influenza');
        await tester.pumpAndSettle();

        // Save.
        await tester.tap(find.text('Save Vaccination'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should be back on MainScreen (AddVaccinationScreen popped).
        expect(find.byType(MainScreen), findsOneWidget,
            reason: 'After saving, the app should return to MainScreen');

        // The vaccination name should now be visible in the Records list.
        expect(find.text('Influenza'), findsWidgets,
            reason: 'Saved vaccination "Influenza" must appear in the Records list');
      },
    );

    testWidgets(
      'saving two vaccinations — both appear in Records',
      (tester) async {
        await _reachRecordsTab(tester);

        for (final name in ['Tetanus', 'Hepatitis B']) {
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          await tester.enterText(
            find.widgetWithText(TextField, 'Vaccine Name'),
            name,
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Save Vaccination'));
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }

        expect(find.text('Tetanus'), findsWidgets);
        expect(find.text('Hepatitis B'), findsWidgets);
      },
    );

    testWidgets(
      'cancelling AddVaccinationScreen does not save anything',
      (tester) async {
        await _reachRecordsTab(tester);

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Type a name but do NOT save — pop via navigator instead.
        await tester.enterText(
          find.widgetWithText(TextField, 'Vaccine Name'),
          'ShouldNotAppear',
        );
        await tester.pumpAndSettle();

        final NavigatorState navigator = tester.state(find.byType(Navigator));
        navigator.pop();
        await tester.pumpAndSettle();

        expect(find.text('ShouldNotAppear'), findsNothing,
            reason: 'Discarded vaccination must not appear in Records');
      },
    );
  });
}
