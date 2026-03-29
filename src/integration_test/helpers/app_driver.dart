// Integration test helpers.
//
// Provides [pumpApp] which boots the real app (real SQLite, real navigation)
// and [resetDatabase] which wipes the database between tests so each test
// starts with a clean slate.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vaccination_manager/core/database/app_database.dart';
import 'package:vaccination_manager/main.dart' as app;

export 'package:integration_test/integration_test.dart';

/// Call once in [setUpAll] to initialise the integration test binding.
void initIntegrationTest() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
}

/// Wipe the database and restart the app.  Call in [setUp] for each test.
Future<void> resetAndPumpApp(WidgetTester tester) async {
  await AppDatabase.resetForTesting();
  app.main();
  // Give the app enough time to finish its initial async build (startup gate,
  // provider initialisation, SQLite open).
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

/// Convenience: wait up to [timeout] for a condition that requires async
/// platform work (e.g. navigation animations settling after a tap).
Future<void> settleOrTimeout(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  await tester.pumpAndSettle(timeout);
}
