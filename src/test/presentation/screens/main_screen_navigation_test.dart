import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/domain/entities/user_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/navigation/app_router.dart';
import 'package:vaccination_manager/presentation/providers/user_dependency_providers.dart';
import 'package:vaccination_manager/presentation/providers/user_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_dependency_providers.dart';
import 'package:vaccination_manager/presentation/screens/main/main_screen.dart';
import 'package:vaccination_manager/presentation/screens/vaccination/add_vaccination_screen.dart';
import 'package:vaccination_manager/presentation/viewmodels/settings_viewmodel.dart';

import '../../helpers/fakes/fake_active_user_notifier.dart';
import '../../helpers/fakes/fake_settings_repository.dart';
import '../../helpers/fakes/fake_user_repository.dart';
import '../../helpers/fakes/fake_vaccination_repository.dart';
import '../../helpers/fixtures.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildApp({
  required UserEntity activeUser,
  FakeVaccinationRepository? fakeVax,
}) {
  final fakeUserRepo = FakeUserRepository()..seedAll([activeUser]);
  final fakeVaxRepo = fakeVax ?? FakeVaccinationRepository();

  return ProviderScope(
    overrides: [
      userRepositoryProvider.overrideWith((_) => fakeUserRepo),
      activeUserProvider
          .overrideWith(() => FakeActiveUserNotifier(activeUser)),
      vaccinationRepositoryProvider.overrideWith((_) => fakeVaxRepo),
      settingsRepositoryProvider
          .overrideWith((_) => FakeSettingsRepository()),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateRoute: AppRouter.generateRoute,
      home: const MainScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('MainScreen – FAB navigation', () {
    testWidgets(
      'tapping FAB on Records tab navigates to AddVaccinationScreen',
      (tester) async {
        await tester.pumpWidget(_buildApp(activeUser: Fixtures.userAlice()));
        await tester.pumpAndSettle();

        // Navigate to the Records tab (index 1) to expose the FAB.
        final recordsTab = find.byIcon(Icons.description_outlined);
        expect(recordsTab, findsOneWidget,
            reason: 'Records tab icon should be in the nav bar');
        await tester.tap(recordsTab);
        await tester.pumpAndSettle();

        // FAB should now be visible.
        final fab = find.byType(FloatingActionButton);
        expect(fab, findsOneWidget, reason: 'FAB must be visible on Records tab');

        // Tap FAB — this should push AddVaccinationScreen.
        await tester.tap(fab);
        await tester.pumpAndSettle();

        // AddVaccinationScreen must be on screen.
        expect(
          find.byType(AddVaccinationScreen),
          findsOneWidget,
          reason: 'AddVaccinationScreen should appear after tapping the FAB',
        );
      },
    );

    testWidgets(
      'tapping FAB on Schedule tab navigates to AddVaccinationScreen',
      (tester) async {
        await tester.pumpWidget(_buildApp(activeUser: Fixtures.userAlice()));
        await tester.pumpAndSettle();

        // Navigate to Schedule tab (index 2).
        final scheduleTab = find.byIcon(Icons.event_outlined);
        expect(scheduleTab, findsOneWidget);
        await tester.tap(scheduleTab);
        await tester.pumpAndSettle();

        final fab = find.byType(FloatingActionButton);
        expect(fab, findsOneWidget, reason: 'FAB must be visible on Schedule tab');

        await tester.tap(fab);
        await tester.pumpAndSettle();

        expect(
          find.byType(AddVaccinationScreen),
          findsOneWidget,
          reason: 'AddVaccinationScreen should appear after tapping FAB on Schedule tab',
        );
      },
    );

    testWidgets(
      'FAB is shown on Dashboard tab (index 0)',
      (tester) async {
        await tester.pumpWidget(_buildApp(activeUser: Fixtures.userAlice()));
        await tester.pumpAndSettle();

        // Dashboard is the initial tab — FAB should be present.
        expect(find.byType(FloatingActionButton), findsOneWidget,
            reason: 'FAB must appear on Dashboard tab');
      },
    );

    testWidgets(
      'FAB is NOT shown on Profile tab (index 3)',
      (tester) async {
        await tester.pumpWidget(_buildApp(activeUser: Fixtures.userAlice()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.person_outline));
        await tester.pumpAndSettle();

        expect(find.byType(FloatingActionButton), findsNothing,
            reason: 'FAB must not appear on Profile tab');
      },
    );

    testWidgets(
      'AddVaccinationScreen can be popped back to MainScreen',
      (tester) async {
        await tester.pumpWidget(_buildApp(activeUser: Fixtures.userAlice()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.description_outlined));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.byType(AddVaccinationScreen), findsOneWidget);

        // Press the back button / navigator pop.
        final NavigatorState navigator = tester.state(find.byType(Navigator));
        navigator.pop();
        await tester.pumpAndSettle();

        expect(find.byType(MainScreen), findsOneWidget);
        expect(find.byType(AddVaccinationScreen), findsNothing);
      },
    );
  });
}
