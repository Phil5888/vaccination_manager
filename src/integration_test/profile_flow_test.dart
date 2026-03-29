// Integration tests — user profile flows.
//
// Verifies profile creation and editing in the running app:
//   • Edited profile name is reflected on the Profile tab after saving
//   • Profile screen displays the correct initials derived from the name
//
// Run on device:
//   flutter test integration_test/profile_flow_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/presentation/screens/main/main_screen.dart';

import 'helpers/app_driver.dart';

// ---------------------------------------------------------------------------
// Helper: reach the Profile tab
// ---------------------------------------------------------------------------

Future<void> _reachProfileTab(WidgetTester tester) async {
  await resetAndSeedUser(tester, name: 'Profile Tester');
  await navigateToTab(tester, Icons.person_outline);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  initIntegrationTest();

  group('Profile flow', () {
    testWidgets(
      'edit profile name → updated name shown on Profile tab',
      (tester) async {
        await _reachProfileTab(tester);

        // Tap the "Edit Profile" button on the Profile tab.
        await tester.tap(find.text('Edit Profile'));
        await settleOrTimeout(tester);

        // The CreateProfileScreen should open in edit mode.
        // The name field already contains the current name — clear it and type a new one.
        final nameField = find.widgetWithText(TextField, 'Profile Tester');
        expect(nameField, findsOneWidget,
            reason:
                'Name field must be pre-filled with the current profile name');

        await tester.tap(nameField);
        await tester.pumpAndSettle();
        await tester.enterText(nameField, 'Renamed User');
        await tester.pumpAndSettle();

        // Save (button label is "Save" in edit mode).
        await tester.tap(find.text('Save'));
        await settleOrTimeout(tester);

        // After saving, we should be back on the Profile tab (the edit screen
        // pops back to MainScreen).
        expect(find.byType(MainScreen), findsOneWidget);

        // The updated name must appear on the Profile tab.
        expect(find.text('Renamed User'), findsWidgets,
            reason: 'Updated profile name must be visible on the Profile tab');
        expect(find.text('Profile Tester'), findsNothing,
            reason: 'Old profile name must no longer be shown');
      },
    );

    testWidgets(
      'profile tab shows correct initials from the username',
      (tester) async {
        // Seed a user with a specific name so we can predict the initials.
        // "Jane Doe" → initials "JD".
        await resetAndPumpApp(tester);
        await seedUser(tester, name: 'Jane Doe');
        await navigateToTab(tester, Icons.person_outline);

        expect(find.text('JD'), findsOneWidget,
            reason: 'Profile tab must display correct initials for "Jane Doe"');
      },
    );

    testWidgets(
      'single-word name shows first-letter initial on Profile tab',
      (tester) async {
        await resetAndPumpApp(tester);
        await seedUser(tester, name: 'Alice');
        await navigateToTab(tester, Icons.person_outline);

        expect(find.text('A'), findsOneWidget,
            reason:
                'Single-word name "Alice" must display initial "A" on Profile tab');
      },
    );
  });
}
