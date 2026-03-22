import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/domain/entities/app_user_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/user_management/user_management_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination/vaccination_providers.dart';
import 'package:vaccination_manager/presentation/screens/main/main_screen.dart';
import 'package:vaccination_manager/presentation/screens/users/user_management_screen.dart';
import 'package:vaccination_manager/presentation/screens/vaccinations/vaccinations_screen.dart';
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
  final activeUser = AppUserEntity(id: 1, username: 'Alex', profilePicture: null, isActive: true, createdAt: DateTime(2026, 1, 1));

  final vaccinationSeries = VaccinationSeriesEntity(
    name: 'COVID-19',
    entries: [
      VaccinationEntryEntity(
        id: 1,
        userId: 1,
        name: 'COVID-19',
        vaccinationDate: DateTime.now().subtract(const Duration(days: 20)),
        nextVaccinationRequiredDate: DateTime.now().add(const Duration(days: 12)),
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ],
  );

  testWidgets('compact landscape uses floating bottom navigation without layout exceptions', (tester) async {
    await tester.binding.setSurfaceSize(const Size(780, 360));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _buildMainScreenTestApp(
        userState: UserManagementState(users: [activeUser], activeUser: activeUser),
        vaccinationState: VaccinationOverviewState(activeUser: activeUser, series: [vaccinationSeries]),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);

    final usersDestination = find.descendant(of: find.byType(NavigationBar), matching: find.byIcon(Icons.people_outline));
    await tester.tap(usersDestination);
    await tester.pumpAndSettle();

    expect(find.byType(UserManagementScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    final vaccinationsDestination = find.descendant(of: find.byType(NavigationBar), matching: find.byIcon(Icons.vaccines_outlined));
    await tester.tap(vaccinationsDestination);
    await tester.pumpAndSettle();

    expect(find.byType(VaccinationsScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide landscape switches sections via navigation rail without layout exceptions', (tester) async {
    await tester.binding.setSurfaceSize(const Size(852, 393));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _buildMainScreenTestApp(
        userState: UserManagementState(users: [activeUser], activeUser: activeUser),
        vaccinationState: VaccinationOverviewState(activeUser: activeUser, series: [vaccinationSeries]),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.byIcon(Icons.people).first);
    await tester.pumpAndSettle();
    expect(find.byType(UserManagementScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.vaccines).first);
    await tester.pumpAndSettle();
    expect(find.byType(VaccinationsScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _buildMainScreenTestApp({required UserManagementState userState, required VaccinationOverviewState vaccinationState}) {
  return ProviderScope(
    overrides: [userManagementProvider.overrideWith(() => _TestUserManagementViewModel(userState)), vaccinationsProvider.overrideWith(() => _TestVaccinationViewModel(vaccinationState))],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {Routes.userEdit: (_) => const Scaffold(), Routes.vaccinationEdit: (_) => const Scaffold()},
      home: const MainScreen(),
    ),
  );
}
