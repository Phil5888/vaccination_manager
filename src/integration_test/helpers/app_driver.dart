// Integration test helpers.
//
// Provides helpers that boot the real app (real SQLite, real navigation) and
// reset state between tests so each test starts with a clean slate.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vaccination_manager/core/database/app_database.dart';
import 'package:vaccination_manager/main.dart' as app;
import 'package:vaccination_manager/presentation/screens/main/main_screen.dart';
import 'package:vaccination_manager/presentation/screens/welcome/welcome_screen.dart';

export 'package:integration_test/integration_test.dart';

/// Call once in [setUpAll] to initialise the integration test binding.
void initIntegrationTest() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Prevent google_fonts from hitting fonts.gstatic.com during tests.
  // Without this the first test fails with a SocketException in sandboxed
  // environments (CI, iOS simulator, restricted networks).
  GoogleFonts.config.allowRuntimeFetching = false;
}

/// Wipe the database and restart the app.  Call in [setUp] for each test.
Future<void> resetAndPumpApp(WidgetTester tester) async {
  await AppDatabase.resetForTesting();
  app.main();
  // AppStartupGate shows a CircularProgressIndicator while it queries SQLite
  // and then navigates via addPostFrameCallback — a continuous animation that
  // prevents a plain pumpAndSettle from ever settling.  Instead, pump in small
  // steps until the startup routing completes (WelcomeScreen for an empty DB,
  // MainScreen if users already exist), then do a final settle for animations.
  const maxWait = Duration(seconds: 15);
  const step = Duration(milliseconds: 200);
  var elapsed = Duration.zero;
  while (elapsed < maxWait) {
    await tester.pump(step);
    elapsed += step;
    if (find.byType(WelcomeScreen).evaluate().isNotEmpty ||
        find.byType(MainScreen).evaluate().isNotEmpty) {
      // Routing done — let any entrance animations finish.
      await tester.pumpAndSettle(const Duration(seconds: 2));
      return;
    }
  }
  // Timeout: fall through and let the next assertion report the failure.
  await tester.pump();
}

/// Create a user via the Welcome → Create Profile UI flow and land on
/// [MainScreen].  Safe to call even when the app has already navigated past
/// the welcome screen (no-op in that case).
///
/// Call after [resetAndPumpApp] when a test needs a seeded user profile.
Future<void> seedUser(WidgetTester tester, {String name = 'Test User'}) async {
  if (find.byType(WelcomeScreen).evaluate().isNotEmpty) {
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    final nameField = find.byType(TextField);
    await tester.enterText(nameField, name);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('submitProfileButton')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }
  expect(find.byType(MainScreen), findsOneWidget,
      reason: 'Expected to land on MainScreen after seeding user "$name"');
}

/// Reset the app and seed a user in one step.  Most integration tests should
/// start with this call.
Future<void> resetAndSeedUser(WidgetTester tester,
    {String name = 'Test User'}) async {
  await resetAndPumpApp(tester);
  await seedUser(tester, name: name);
}

/// Navigate to the named [tab] of [MainScreen] by tapping its bottom-nav icon.
/// [tabIcon] should be an icon that uniquely identifies the **unselected** tab
/// (e.g. [Icons.description_outlined] for Records).
///
/// If the finder returns no results the tab is already active (the navigation
/// bar is showing its selectedIcon variant), so the tap is skipped.
Future<void> navigateToTab(WidgetTester tester, IconData tabIcon) async {
  final finder = find.byIcon(tabIcon);
  if (finder.evaluate().isEmpty) return; // already on this tab
  await tester.tap(finder);
  await settleOrTimeout(tester);
}

/// Convenience: wait up to [timeout] for a condition that requires async
/// platform work (e.g. navigation animations settling after a tap).
Future<void> settleOrTimeout(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  await tester.pumpAndSettle(timeout);
}
