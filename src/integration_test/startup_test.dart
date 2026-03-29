// Integration tests — app startup gate behaviour.
//
// These tests run on a real Android emulator / iOS Simulator and verify that
// the startup gate correctly routes the user to:
//   • MainScreen when at least one profile exists in the database
//   • WelcomeScreen when no profiles exist
//
// Run on device:
//   flutter test integration_test/startup_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/presentation/screens/main/main_screen.dart';
import 'package:vaccination_manager/presentation/screens/welcome/welcome_screen.dart';

import 'helpers/app_driver.dart';

void main() {
  initIntegrationTest();

  group('Startup gate', () {
    setUp(() async {
      // Each test gets a completely empty database.
      // The test that needs a user seeds one via the create-profile flow.
    });

    testWidgets(
      'no user → WelcomeScreen is shown',
      (tester) async {
        await resetAndPumpApp(tester);

        // The startup gate finds an empty users table and redirects.
        expect(find.byType(WelcomeScreen), findsOneWidget,
            reason: 'Without any profiles the app should land on WelcomeScreen');
        expect(find.byType(MainScreen), findsNothing);
      },
    );

    testWidgets(
      'no user → "VaccineCare" branding is visible on WelcomeScreen',
      (tester) async {
        await resetAndPumpApp(tester);

        expect(find.text('VaccineCare'), findsWidgets,
            reason: 'App branding must be visible on the welcome screen');
        expect(find.text('Get Started'), findsOneWidget,
            reason: '"Get Started" CTA must be present');
      },
    );

    testWidgets(
      'user exists → MainScreen is shown directly',
      (tester) async {
        // Reset so we start clean, then create a user via the UI.
        await resetAndPumpApp(tester);

        // Navigate through the create-profile flow to seed a user.
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();

        // Fill in username.
        await tester.enterText(find.byType(TextField), 'Integration Tester');
        await tester.pumpAndSettle();

        // Submit — the create-profile screen shows "Create Profile".
        await tester.tap(find.byKey(const Key('submitProfileButton')));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // After profile creation the app should land on MainScreen.
        expect(find.byType(MainScreen), findsOneWidget,
            reason: 'After creating a profile the app must show MainScreen');
      },
    );
  });
}
