import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/user_dependency_providers.dart';
import 'package:vaccination_manager/presentation/providers/user_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_dependency_providers.dart';
import 'package:vaccination_manager/presentation/screens/profile/create_profile_screen.dart';
import 'package:vaccination_manager/presentation/screens/profile/profile_screen.dart';
import 'package:vaccination_manager/presentation/viewmodels/settings_viewmodel.dart';

import '../../helpers/fakes/fake_active_user_notifier.dart';
import '../../helpers/fakes/fake_settings_repository.dart';
import '../../helpers/fakes/fake_user_repository.dart';
import '../../helpers/fakes/fake_vaccination_repository.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/screen_sizes.dart';

// ---------------------------------------------------------------------------
// Local helpers
// ---------------------------------------------------------------------------

Widget _localizedApp({required Widget child}) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateRoute: (settings) =>
          MaterialPageRoute(builder: (_) => const SizedBox()),
      home: Scaffold(body: child),
    );

Widget _buildProfileScope({
  required Widget child,
  FakeUserRepository? fakeUserRepo,
}) {
  final userRepo = fakeUserRepo ?? FakeUserRepository()
    ..seedAll([Fixtures.userAlice(), Fixtures.userBob()]);

  return ProviderScope(
    overrides: [
      activeUserProvider
          .overrideWith(() => FakeActiveUserNotifier(Fixtures.userAlice())),
      userRepositoryProvider.overrideWith((_) => userRepo),
      vaccinationRepositoryProvider
          .overrideWith((_) => FakeVaccinationRepository()),
      settingsRepositoryProvider
          .overrideWith((_) => FakeSettingsRepository()),
    ],
    child: _localizedApp(child: child),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ProfileScreen', () {
    group('no overflow — ProfileScreen', () {
      for (final size in allScreenSizes) {
        testWidgets('at ${size.width}x${size.height}', (tester) async {
          final fakeUserRepo = FakeUserRepository()
            ..seedAll([Fixtures.userAlice(), Fixtures.userBob()]);

          await pumpAtSize(
            tester,
            () => _buildProfileScope(
              child: const ProfileScreen(),
              fakeUserRepo: fakeUserRepo,
            ),
            size,
          );
          expectNoOverflow(tester);
        });
      }
    });

    group('no overflow — CreateProfileScreen add mode', () {
      for (final size in allScreenSizes) {
        testWidgets(
          'at ${size.width}x${size.height}',
          (tester) async {
            await pumpAtSize(
              tester,
              () => _buildProfileScope(child: const CreateProfileScreen()),
              size,
            );
            expectNoOverflow(tester);
          },
        );
      }
    });

    group('no overflow — CreateProfileScreen edit mode', () {
      for (final size in allScreenSizes) {
        testWidgets(
          'at ${size.width}x${size.height}',
          (tester) async {
            await pumpAtSize(
              tester,
              () => _buildProfileScope(
                child: CreateProfileScreen(existingUser: Fixtures.userAlice()),
              ),
              size,
            );
            expectNoOverflow(tester);
          },
        );
      }
    });
  });
}
