import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/user_management/user_management_providers.dart';
import 'package:vaccination_manager/presentation/screens/startup/app_startup_gate.dart';
import 'package:vaccination_manager/presentation/viewmodels/user_management_viewmodel.dart';

class StartupGateTestUserManagementViewModel extends UserManagementViewModel {
  StartupGateTestUserManagementViewModel(this.initialState);

  final UserManagementState initialState;

  @override
  Future<UserManagementState> build() async => initialState;
}

void main() {
  testWidgets('shows welcome screen if there are no stored users', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [userManagementProvider.overrideWith(() => StartupGateTestUserManagementViewModel(const UserManagementState(users: [], activeUser: null)))],
        child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: const AppStartupGate()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Welcome to Vaccination Manager'), findsOneWidget);
    expect(find.text('Create first user'), findsOneWidget);
  });
}
