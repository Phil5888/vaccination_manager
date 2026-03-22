import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/domain/entities/app_user_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/user_management/user_management_providers.dart';
import 'package:vaccination_manager/presentation/screens/users/user_management_screen.dart';
import 'package:vaccination_manager/presentation/viewmodels/user_management_viewmodel.dart';

class TestUserManagementViewModel extends UserManagementViewModel {
  TestUserManagementViewModel(this.initialState);

  final UserManagementState initialState;

  @override
  Future<UserManagementState> build() async => initialState;
}

void main() {
  group('UserManagementScreen', () {
    testWidgets('renders empty state when no users exist', (tester) async {
      await tester.pumpWidget(_buildTestApp(viewModelFactory: () => TestUserManagementViewModel(const UserManagementState(users: [], activeUser: null))));

      await tester.pumpAndSettle();

      expect(find.text('No users yet'), findsOneWidget);
      expect(find.text('Add a user to personalize the app with a name and profile picture.'), findsOneWidget);
    });

    testWidgets('renders users without inline switch button', (tester) async {
      final users = [
        AppUserEntity(id: 1, username: 'Anna', profilePicture: null, isActive: true, createdAt: DateTime(2026, 1, 1)),
        AppUserEntity(id: 2, username: 'Ben', profilePicture: null, isActive: false, createdAt: DateTime(2026, 1, 2)),
      ];

      await tester.pumpWidget(
        _buildTestApp(
          viewModelFactory: () => TestUserManagementViewModel(UserManagementState(users: users, activeUser: users.first)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Anna'), findsOneWidget);
      expect(find.text('Ben'), findsOneWidget);
      expect(find.text('Current'), findsOneWidget);
      expect(find.text('Switch user'), findsNothing);
    });

    testWidgets('top add button opens user edit route', (tester) async {
      await tester.pumpWidget(_buildTestApp(viewModelFactory: () => TestUserManagementViewModel(const UserManagementState(users: [], activeUser: null))));

      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Add user'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Route Stub'), findsOneWidget);
    });

    testWidgets('search selects user and opens edit route directly', (tester) async {
      final users = [
        AppUserEntity(id: 1, username: 'Anna', profilePicture: null, isActive: true, createdAt: DateTime(2026, 1, 1)),
        AppUserEntity(id: 2, username: 'Benedict', profilePicture: null, isActive: false, createdAt: DateTime(2026, 1, 2)),
      ];

      await tester.pumpWidget(
        _buildTestApp(
          viewModelFactory: () => TestUserManagementViewModel(UserManagementState(users: users, activeUser: users.first)),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'ben');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Benedict').first);
      await tester.pumpAndSettle();

      expect(find.text('Edit Route Stub'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(UserManagementScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

Widget _buildTestApp({required TestUserManagementViewModel Function() viewModelFactory}) {
  return ProviderScope(
    overrides: [userManagementProvider.overrideWith(viewModelFactory)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {
        Routes.userEdit: (_) => Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('Edit Route Stub')),
        ),
      },
      home: const UserManagementScreen(),
    ),
  );
}
