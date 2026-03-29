// Integration tests — tab navigation and FAB → AddVaccinationScreen.
//
// These tests verify the critical navigation paths that caused the app-freeze
// regression (duplicate FloatingActionButton hero tags):
//
//   • Tapping the FAB on Records/Schedule/Dashboard tabs opens AddVaccinationScreen
//   • Tapping the FAB on the Profile tab must NOT happen (no FAB)
//   • Pressing back from AddVaccinationScreen returns to MainScreen
//   • All four tabs are reachable without a crash
//
// Run on device:
//   flutter test integration_test/navigation_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/presentation/screens/main/main_screen.dart';
import 'package:vaccination_manager/presentation/screens/vaccination/add_vaccination_screen.dart';
import 'package:vaccination_manager/presentation/screens/welcome/welcome_screen.dart';

import 'helpers/app_driver.dart';

// ---------------------------------------------------------------------------
// Helper: seed a user then land on MainScreen
// ---------------------------------------------------------------------------

Future<void> _seedUserAndReachMainScreen(WidgetTester tester) async {
  await resetAndPumpApp(tester);

  // If we land on welcome, create a profile first.
  if (find.byType(WelcomeScreen).evaluate().isNotEmpty) {
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Nav Tester');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create Profile'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  expect(find.byType(MainScreen), findsOneWidget);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  initIntegrationTest();

  group('Tab navigation', () {
    testWidgets(
      'all four tabs are reachable without a crash',
      (tester) async {
        await _seedUserAndReachMainScreen(tester);

        // Dashboard (0) — already on it
        expect(find.byType(MainScreen), findsOneWidget);

        // Records (1)
        await tester.tap(find.byIcon(Icons.description_outlined));
        await settleOrTimeout(tester);
        expect(find.byType(MainScreen), findsOneWidget,
            reason: 'MainScreen should survive navigation to Records tab');

        // Schedule (2)
        await tester.tap(find.byIcon(Icons.event_outlined));
        await settleOrTimeout(tester);
        expect(find.byType(MainScreen), findsOneWidget,
            reason: 'MainScreen should survive navigation to Schedule tab');

        // Profile (3)
        await tester.tap(find.byIcon(Icons.person_outline));
        await settleOrTimeout(tester);
        expect(find.byType(MainScreen), findsOneWidget,
            reason: 'MainScreen should survive navigation to Profile tab');
      },
    );

    testWidgets(
      'FAB is absent on Profile tab',
      (tester) async {
        await _seedUserAndReachMainScreen(tester);

        await tester.tap(find.byIcon(Icons.person_outline));
        await settleOrTimeout(tester);

        expect(find.byType(FloatingActionButton), findsNothing,
            reason: 'Profile tab must not show a FAB');
      },
    );
  });

  group('FAB → AddVaccinationScreen navigation', () {
    testWidgets(
      'FAB on Dashboard tab opens AddVaccinationScreen',
      (tester) async {
        await _seedUserAndReachMainScreen(tester);

        // Dashboard is the initial tab.
        final fab = find.byType(FloatingActionButton);
        expect(fab, findsOneWidget);

        await tester.tap(fab);
        await settleOrTimeout(tester);

        expect(find.byType(AddVaccinationScreen), findsOneWidget,
            reason: 'AddVaccinationScreen must appear after tapping FAB on Dashboard');
      },
    );

    testWidgets(
      'FAB on Records tab opens AddVaccinationScreen',
      (tester) async {
        await _seedUserAndReachMainScreen(tester);

        await tester.tap(find.byIcon(Icons.description_outlined));
        await settleOrTimeout(tester);

        await tester.tap(find.byType(FloatingActionButton));
        await settleOrTimeout(tester);

        expect(find.byType(AddVaccinationScreen), findsOneWidget,
            reason: 'AddVaccinationScreen must appear after tapping FAB on Records tab');
      },
    );

    testWidgets(
      'FAB on Schedule tab opens AddVaccinationScreen',
      (tester) async {
        await _seedUserAndReachMainScreen(tester);

        await tester.tap(find.byIcon(Icons.event_outlined));
        await settleOrTimeout(tester);

        await tester.tap(find.byType(FloatingActionButton));
        await settleOrTimeout(tester);

        expect(find.byType(AddVaccinationScreen), findsOneWidget,
            reason: 'AddVaccinationScreen must appear after tapping FAB on Schedule tab');
      },
    );

    testWidgets(
      'back navigation from AddVaccinationScreen returns to MainScreen',
      (tester) async {
        await _seedUserAndReachMainScreen(tester);

        await tester.tap(find.byType(FloatingActionButton));
        await settleOrTimeout(tester);
        expect(find.byType(AddVaccinationScreen), findsOneWidget);

        // Pop via the navigator.
        final NavigatorState navigator = tester.state(find.byType(Navigator));
        navigator.pop();
        await settleOrTimeout(tester);

        expect(find.byType(MainScreen), findsOneWidget);
        expect(find.byType(AddVaccinationScreen), findsNothing);
      },
    );
  });
}
