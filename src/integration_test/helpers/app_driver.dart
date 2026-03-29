// Integration test helpers.
//
// Provides helpers that boot the real app (real SQLite, real navigation) and
// reset state between tests so each test starts with a clean slate.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vaccination_manager/app.dart';
import 'package:vaccination_manager/core/database/app_database.dart';
import 'package:vaccination_manager/presentation/screens/main/main_screen.dart';
import 'package:vaccination_manager/presentation/screens/profile/create_profile_screen.dart';
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
///
/// Uses [UniqueKey] on the root [ProviderScope] so Flutter is forced to
/// unmount the old element (and its [ProviderContainer]) and mount a fresh
/// one.  Without this, `runApp(const ProviderScope(...))` is effectively a
/// no-op on the second call: `const` produces the same Dart object both
/// times, Flutter's `canUpdate` returns `true` (same type + null key), and
/// the existing element — and therefore the entire old widget tree — is
/// preserved in place rather than replaced.
Future<void> resetAndPumpApp(WidgetTester tester) async {
  await AppDatabase.resetForTesting();
  // UniqueKey guarantees canUpdate() → false → old ProviderScope is unmounted
  // and a brand-new ProviderContainer starts with clean state.
  runApp(ProviderScope(key: UniqueKey(), child: const MyApp()));
  // resetForTesting always wipes the database, so the new app will always
  // land on WelcomeScreen.  Poll in short steps to avoid stalling on the
  // CircularProgressIndicator that AppStartupGate shows while it queries
  // SQLite (a continuous animation that prevents pumpAndSettle from settling).
  await _waitFor(tester, find.byType(WelcomeScreen));
}

/// Create a user via the Welcome → Create Profile UI flow and land on
/// [MainScreen].  Safe to call even when the app has already navigated past
/// the welcome screen (no-op in that case).
///
/// Call after [resetAndPumpApp] when a test needs a seeded user profile.
Future<void> seedUser(WidgetTester tester, {String name = 'Test User'}) async {
  if (find.byType(WelcomeScreen).evaluate().isNotEmpty) {
    // WelcomeScreen may be in the tree before its content is rendered (e.g.
    // localizations still loading after a mid-test runApp restart). Poll
    // for the button text so we never tap before the widget is fully built.
    await _waitFor(tester, find.text('Get Started'));
    await tester.tap(find.text('Get Started'));
    await _waitFor(tester, find.byType(CreateProfileScreen));

    final nameField = find.byType(TextField);
    await tester.enterText(nameField, name);
    await tester.pump();

    await tester.tap(find.byKey(const Key('submitProfileButton')));
    await _waitFor(tester, find.byType(MainScreen));
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
/// Scopes the search to the [NavigationBar] widget so that identical icons
/// appearing in page content (e.g. Icons.person_outline used as a text-field
/// suffix on CreateProfileScreen during a route transition) are not matched.
///
/// If the finder returns no results the tab is already active (the navigation
/// bar is showing its selectedIcon variant), so the tap is skipped.
Future<void> navigateToTab(WidgetTester tester, IconData tabIcon) async {
  final finder = find.descendant(
    of: find.byType(NavigationBar),
    matching: find.byIcon(tabIcon),
  );
  if (finder.evaluate().isEmpty) return; // already on this tab
  await tester.tap(finder.first);
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

/// Poll [tester] in 200 ms steps until [finder] matches at least one widget
/// or [maxWait] elapses.  Unlike [WidgetTester.pumpAndSettle], this never
/// stalls on continuous animations (e.g. CircularProgressIndicator).
Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration maxWait = const Duration(seconds: 15),
}) async {
  const step = Duration(milliseconds: 200);
  var elapsed = Duration.zero;
  while (elapsed < maxWait) {
    await tester.pump(step);
    elapsed += step;
    if (finder.evaluate().isNotEmpty) return;
  }
  // Exceeded maxWait — one final pump so the caller's assertion can report
  // exactly what is (or isn't) in the tree.
  await tester.pump();
}
