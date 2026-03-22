import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/domain/entities/app_user_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/user_management/user_management_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination/vaccination_providers.dart';
import 'package:vaccination_manager/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:vaccination_manager/presentation/screens/dashboard/widgets/settings_preview.dart';
import 'package:vaccination_manager/presentation/viewmodels/user_management_viewmodel.dart';
import 'package:vaccination_manager/presentation/viewmodels/vaccination_viewmodel.dart';

class _TestUserManagementViewModel extends UserManagementViewModel {
  _TestUserManagementViewModel(this.initialState);

  final UserManagementState initialState;

  @override
  Future<UserManagementState> build() async => initialState;
}

class _TestVaccinationViewModel extends VaccinationViewModel {
  _TestVaccinationViewModel(this.initialState);

  final VaccinationOverviewState initialState;

  @override
  Future<VaccinationOverviewState> build() async => initialState;
}

void main() {
  final activeUser = AppUserEntity(id: 1, username: 'Alice', profilePicture: null, isActive: true, createdAt: DateTime(2026, 1, 1));

  testWidgets('shows welcome greeting for the active user', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        userState: UserManagementState(users: [activeUser], activeUser: activeUser),
        vaccinationState: VaccinationOverviewState(activeUser: activeUser, series: const []),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Welcome back, Alice'), findsOneWidget);
    expect(find.text('No vaccination records yet'), findsOneWidget);
  });

  testWidgets('shows all-clear state when nothing is due soon or overdue', (tester) async {
    final now = DateTime.now();
    final upToDateSeries = VaccinationSeriesEntity(
      name: 'Tetanus',
      entries: [
        VaccinationEntryEntity(id: 1, userId: 1, name: 'Tetanus', vaccinationDate: now.subtract(const Duration(days: 20)), nextVaccinationRequiredDate: now.add(const Duration(days: 120)), createdAt: now.subtract(const Duration(days: 20))),
      ],
    );

    await tester.pumpWidget(
      _buildTestApp(
        userState: UserManagementState(users: [activeUser], activeUser: activeUser),
        vaccinationState: VaccinationOverviewState(activeUser: activeUser, series: [upToDateSeries]),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Everything is alright'), findsOneWidget);
    expect(find.text('No vaccinations are due soon or overdue.'), findsOneWidget);
    expect(find.text('Tetanus'), findsNothing);
  });

  testWidgets('does not render settings preview card on dashboard', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        userState: UserManagementState(users: [activeUser], activeUser: activeUser),
        vaccinationState: VaccinationOverviewState(activeUser: activeUser, series: const []),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(SettingsPreviewCard), findsNothing);
  });
}

Widget _buildTestApp({required UserManagementState userState, required VaccinationOverviewState vaccinationState}) {
  return ProviderScope(
    overrides: [userManagementProvider.overrideWith(() => _TestUserManagementViewModel(userState)), vaccinationsProvider.overrideWith(() => _TestVaccinationViewModel(vaccinationState))],
    child: MaterialApp(locale: const Locale('en'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: const DashboardScreen()),
  );
}
