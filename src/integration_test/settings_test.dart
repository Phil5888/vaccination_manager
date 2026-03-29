// Integration tests — settings persistence across app restarts.
//
// Verifies that user preference changes made in the Settings screen are
// persisted via shared_preferences and survive an app restart (simulated by
// calling resetAndPumpApp, which resets only the SQLite database while leaving
// shared_preferences intact — exactly as a real device restart would behave).
//
// Run on device:
//   flutter test integration_test/settings_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/presentation/screens/main/main_screen.dart';
import 'package:vaccination_manager/presentation/screens/settings/settings_screen.dart';

import 'helpers/app_driver.dart';

// ---------------------------------------------------------------------------
// Helper: open Settings from the Profile tab
// ---------------------------------------------------------------------------

Future<void> _openSettings(WidgetTester tester) async {
  // Profile tab → Settings button.
  await navigateToTab(tester, Icons.person_outline);
  await tester.tap(find.byIcon(Icons.settings_outlined));
  await settleOrTimeout(tester);
  expect(find.byType(SettingsScreen), findsOneWidget,
      reason: 'Settings screen must open from the Profile tab');
}

// ---------------------------------------------------------------------------
// Helper: read the current value of the dark-mode Switch
// ---------------------------------------------------------------------------

bool _darkModeValue(WidgetTester tester) {
  final switches = find.byType(Switch);
  // The first Switch on the Settings screen is the dark-mode toggle.
  expect(switches, findsWidgets,
      reason: 'At least one Switch must exist on the Settings screen');
  return (tester.widget<Switch>(switches.first)).value;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  initIntegrationTest();

  group('Settings persistence', () {
    testWidgets(
      'dark mode toggle persists after app restart',
      (tester) async {
        // ── Part 1: toggle dark mode ──────────────────────────────────────

        await resetAndSeedUser(tester, name: 'Settings Tester');
        await _openSettings(tester);

        final bool initialDarkMode = _darkModeValue(tester);

        // Toggle to the opposite state.
        await tester.tap(find.byType(Switch).first);
        await tester.pumpAndSettle();
        final bool toggledDarkMode = _darkModeValue(tester);
        expect(toggledDarkMode, isNot(initialDarkMode),
            reason: 'Switch value must change after tapping');

        // ── Part 2: simulate app restart ──────────────────────────────────

        // resetAndPumpApp wipes SQLite but shared_preferences survives.
        await resetAndPumpApp(tester);

        // Re-seed the user (SQLite was wiped) so we can reach the UI.
        await seedUser(tester, name: 'Settings Tester');
        await _openSettings(tester);

        final bool afterRestartDarkMode = _darkModeValue(tester);
        expect(afterRestartDarkMode, equals(toggledDarkMode),
            reason:
                'Dark mode preference must survive a simulated app restart');

        // ── Cleanup: restore original state ──────────────────────────────

        // Restore the original state so subsequent test runs start clean.
        if (afterRestartDarkMode != initialDarkMode) {
          await tester.tap(find.byType(Switch).first);
          await tester.pumpAndSettle();
        }
      },
    );

    testWidgets(
      'settings screen is reachable from Profile tab',
      (tester) async {
        await resetAndSeedUser(tester, name: 'Nav Tester');
        await _openSettings(tester);
        // Verify the back button returns to MainScreen.
        await tester.tap(find.byIcon(Icons.arrow_back));
        await settleOrTimeout(tester);
        expect(find.byType(MainScreen), findsOneWidget,
            reason:
                'Back arrow on Settings screen must return to MainScreen');
      },
    );
  });
}
