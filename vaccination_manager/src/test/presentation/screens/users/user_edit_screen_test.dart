import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/domain/entities/app_user_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/user_management/user_management_providers.dart';
import 'package:vaccination_manager/presentation/screens/users/user_edit_screen.dart';
import 'package:vaccination_manager/presentation/viewmodels/user_management_viewmodel.dart';

class TestUserManagementViewModel extends UserManagementViewModel {
  TestUserManagementViewModel(this.initialState);

  final UserManagementState initialState;
  final List<int> switchedUserIds = <int>[];

  @override
  Future<UserManagementState> build() async => initialState;

  @override
  Future<void> switchUser(int userId) async {
    switchedUserIds.add(userId);
    final updatedUsers = [for (final user in initialState.users) user.copyWith(isActive: user.id == userId)];
    state = AsyncData(UserManagementState(users: updatedUsers, activeUser: updatedUsers.firstWhere((user) => user.id == userId)));
  }
}

void main() {
  group('UserEditScreen', () {
    testWidgets('shows switch button for inactive user and switches active user', (tester) async {
      final users = [
        AppUserEntity(id: 1, username: 'Anna', profilePicture: null, isActive: true, createdAt: DateTime(2026, 1, 1)),
        AppUserEntity(id: 2, username: 'Ben', profilePicture: null, isActive: false, createdAt: DateTime(2026, 1, 2)),
      ];
      final viewModel = TestUserManagementViewModel(UserManagementState(users: users, activeUser: users.first));

      await tester.pumpWidget(_buildTestApp(viewModel: viewModel, initialUser: users.last));
      await tester.pumpAndSettle();

      expect(find.text('Switch user'), findsOneWidget);

      await tester.tap(find.text('Switch user'));
      await tester.pumpAndSettle();

      expect(viewModel.switchedUserIds, [2]);
      expect(find.text('Dashboard Route Stub'), findsOneWidget);
    });

    testWidgets('does not show switch button for current user', (tester) async {
      final users = [AppUserEntity(id: 1, username: 'Anna', profilePicture: null, isActive: true, createdAt: DateTime(2026, 1, 1))];
      final viewModel = TestUserManagementViewModel(UserManagementState(users: users, activeUser: users.first));

      await tester.pumpWidget(_buildTestApp(viewModel: viewModel, initialUser: users.first));
      await tester.pumpAndSettle();

      expect(find.text('Switch user'), findsNothing);
      expect(find.text('Current'), findsOneWidget);
    });
  });
}

Widget _buildTestApp({required TestUserManagementViewModel viewModel, required AppUserEntity initialUser}) {
  return ProviderScope(
    overrides: [userManagementProvider.overrideWith(() => viewModel)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: Routes.userEdit,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case Routes.userEdit:
            return MaterialPageRoute(builder: (_) => UserEditScreen(initialUser: initialUser));
          case Routes.dashboard:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(body: Center(child: Text('Dashboard Route Stub'))),
            );
          default:
            return null;
        }
      },
    ),
  );
}
