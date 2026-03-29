// Integration tests — vaccination CRUD operations.
//
// Verifies the full data lifecycle in the running app (real SQLite):
//   • Edit an existing vaccination series name
//   • Delete a vaccination series (confirm dialog → gone from Records)
//   • Cancel delete → vaccination still present in Records
//   • Save a 2-shot vaccination → series card reflects two shots
//
// Run on device:
//   flutter test integration_test/vaccination_crud_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/presentation/screens/vaccination/add_vaccination_screen.dart';
import 'package:vaccination_manager/presentation/screens/main/main_screen.dart';

import 'helpers/app_driver.dart';

// ---------------------------------------------------------------------------
// Helper: reach Records tab with a clean DB and a seeded user
// ---------------------------------------------------------------------------

Future<void> _reachRecordsTab(WidgetTester tester) async {
  await resetAndSeedUser(tester, name: 'CRUD Tester');
  await navigateToTab(tester, Icons.description_outlined);
}

// ---------------------------------------------------------------------------
// Helper: add a vaccination from the Records tab FAB
// ---------------------------------------------------------------------------

Future<void> _addVaccination(WidgetTester tester, String name,
    {int extraShots = 0}) async {
  await tester.tap(find.byType(FloatingActionButton));
  await settleOrTimeout(tester);

  expect(find.byType(AddVaccinationScreen), findsOneWidget);

  // Enter vaccine name.
  await tester.enterText(
    find.byKey(const Key('vaccineNameField')),
    name,
  );
  await tester.pumpAndSettle();

  // Optionally increment shot count.
  for (var i = 0; i < extraShots; i++) {
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pumpAndSettle();
  }

  // Save.
  await tester.tap(find.text('Save Vaccination'));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  expect(find.byType(MainScreen), findsOneWidget,
      reason: 'Expected to return to MainScreen after saving');
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  initIntegrationTest();

  group('Vaccination CRUD', () {
    // ────────────────────────────────────────────────────────────────────────
    // Edit
    // ────────────────────────────────────────────────────────────────────────

    testWidgets(
      'edit vaccination name → updated name shown in Records',
      (tester) async {
        await _reachRecordsTab(tester);
        await _addVaccination(tester, 'OldName');

        // Verify original name is in Records.
        expect(find.text('OldName'), findsWidgets);

        // Tap the edit icon button on the card.
        await tester.tap(find.byIcon(Icons.edit_outlined).first);
        await settleOrTimeout(tester);

        expect(find.byType(AddVaccinationScreen), findsOneWidget,
            reason: 'Edit icon should open AddVaccinationScreen');

        // Clear name field and enter new name.
        final nameField = find.widgetWithText(TextField, 'OldName');
        await tester.tap(nameField);
        await tester.pumpAndSettle();
        await tester.enterText(nameField, 'NewName');
        await tester.pumpAndSettle();

        // Save updated series.
        await tester.tap(find.text('Save Vaccination'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.byType(MainScreen), findsOneWidget);
        expect(find.text('NewName'), findsWidgets,
            reason: 'Updated name must appear in Records list');
        expect(find.text('OldName'), findsNothing,
            reason: 'Old name must no longer appear');
      },
    );

    // ────────────────────────────────────────────────────────────────────────
    // Delete — confirm
    // ────────────────────────────────────────────────────────────────────────

    testWidgets(
      'delete vaccination → series removed from Records after confirmation',
      (tester) async {
        await _reachRecordsTab(tester);
        await _addVaccination(tester, 'DeleteMe');

        expect(find.text('DeleteMe'), findsWidgets);

        // Tap the delete icon button on the card.
        await tester.tap(find.byIcon(Icons.delete_outline).first);
        await settleOrTimeout(tester);

        // Confirm dialog should appear.
        expect(find.byType(AlertDialog), findsOneWidget,
            reason: 'Delete confirmation dialog must appear');

        // Tap "Delete" to confirm.
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.text('DeleteMe'), findsNothing,
            reason: 'Deleted series must not appear in Records');
      },
    );

    // ────────────────────────────────────────────────────────────────────────
    // Delete — cancel
    // ────────────────────────────────────────────────────────────────────────

    testWidgets(
      'cancel delete → vaccination remains in Records',
      (tester) async {
        await _reachRecordsTab(tester);
        await _addVaccination(tester, 'KeepMe');

        expect(find.text('KeepMe'), findsWidgets);

        // Tap delete icon then cancel the dialog.
        await tester.tap(find.byIcon(Icons.delete_outline).first);
        await settleOrTimeout(tester);
        expect(find.byType(AlertDialog), findsOneWidget);

        await tester.tap(find.text('Cancel'));
        await settleOrTimeout(tester);

        expect(find.text('KeepMe'), findsWidgets,
            reason: 'Vaccination must still appear after cancelling delete');
      },
    );

    // ────────────────────────────────────────────────────────────────────────
    // Multi-shot
    // ────────────────────────────────────────────────────────────────────────

    testWidgets(
      'save a 2-shot vaccination → series card shows 2 total shots',
      (tester) async {
        await _reachRecordsTab(tester);

        // Add with 1 extra increment → shotCount = 2.
        await _addVaccination(tester, 'Hepatitis A', extraShots: 1);

        // The series card progress label shows "X / 2".
        expect(find.textContaining('/ 2'), findsWidgets,
            reason:
                'Records card must show 2 total shots for a 2-shot series');
        expect(find.text('Hepatitis A'), findsWidgets);
      },
    );
  });
}
