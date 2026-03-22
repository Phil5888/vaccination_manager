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
import 'package:vaccination_manager/presentation/screens/vaccinations/vaccinations_screen.dart';
import 'package:vaccination_manager/presentation/viewmodels/user_management_viewmodel.dart';
import 'package:vaccination_manager/presentation/viewmodels/vaccination_viewmodel.dart';

class _TestVaccinationViewModel extends VaccinationViewModel {
  _TestVaccinationViewModel(this.initialState);

  final VaccinationOverviewState initialState;
  VaccinationReminderFilter? selectedFilter;
  int? deletedVaccinationId;

  @override
  Future<VaccinationOverviewState> build() async => initialState;

  @override
  void setFilter(VaccinationReminderFilter filter) {
    selectedFilter = filter;
  }

  @override
  Future<void> deleteVaccination(int vaccinationId) async {
    deletedVaccinationId = vaccinationId;
  }
}

class _SwitchableUserManagementViewModel extends UserManagementViewModel {
  _SwitchableUserManagementViewModel({required List<AppUserEntity> users, required AppUserEntity activeUser}) : _users = users, _activeUser = activeUser;

  final List<AppUserEntity> _users;
  AppUserEntity _activeUser;

  @override
  Future<UserManagementState> build() async {
    return UserManagementState(users: _withActive(_activeUser.id), activeUser: _activeUser);
  }

  void setActiveUser(int userId) {
    _activeUser = _users.firstWhere((user) => user.id == userId);
    state = AsyncData(UserManagementState(users: _withActive(userId), activeUser: _activeUser));
  }

  List<AppUserEntity> _withActive(int? activeId) {
    return _users.map((user) => user.copyWith(isActive: user.id == activeId)).toList();
  }
}

class _UserAwareVaccinationViewModel extends VaccinationViewModel {
  _UserAwareVaccinationViewModel(this._statesByUserId);

  final Map<int, VaccinationOverviewState> _statesByUserId;

  @override
  Future<VaccinationOverviewState> build() async {
    final userState = await ref.watch(userManagementProvider.future);
    final userId = userState.activeUser?.id;

    if (userId == null) {
      return const VaccinationOverviewState(activeUser: null, series: []);
    }

    return _statesByUserId[userId] ?? VaccinationOverviewState(activeUser: userState.activeUser, series: const []);
  }
}

void main() {
  final activeUser = AppUserEntity(id: 1, username: 'Alice', profilePicture: null, isActive: true, createdAt: DateTime(2026, 1, 1));

  testWidgets('shows empty state when the active user has no vaccinations', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        viewModelFactory: () => _TestVaccinationViewModel(VaccinationOverviewState(activeUser: activeUser, series: const [])),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No vaccination records yet'), findsOneWidget);
    expect(find.text('Add vaccination'), findsWidgets);
  });

  testWidgets('shows grouped series details for multiple shots', (tester) async {
    final series = VaccinationSeriesEntity(
      name: 'COVID-19',
      entries: [
        VaccinationEntryEntity(id: 1, userId: 1, name: 'COVID-19', vaccinationDate: DateTime(2026, 3, 10), nextVaccinationRequiredDate: DateTime(2026, 9, 10), createdAt: DateTime(2026, 3, 10)),
        VaccinationEntryEntity(id: 2, userId: 1, name: 'COVID-19', vaccinationDate: DateTime(2026, 1, 10), nextVaccinationRequiredDate: DateTime(2026, 7, 10), createdAt: DateTime(2026, 1, 10)),
      ],
    );

    await tester.pumpWidget(
      _buildTestApp(
        viewModelFactory: () => _TestVaccinationViewModel(VaccinationOverviewState(activeUser: activeUser, series: [series])),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('COVID-19'), findsWidgets);
    await tester.tap(find.text('COVID-19').last);
    await tester.pumpAndSettle();

    expect(find.text('Shot 2'), findsOneWidget);
    expect(find.text('Add shot'), findsOneWidget);
  });

  testWidgets('tapping reminder filter calls setFilter with selected status', (tester) async {
    final model = _TestVaccinationViewModel(
      VaccinationOverviewState(
        activeUser: activeUser,
        selectedFilter: VaccinationReminderFilter.all,
        series: [
          VaccinationSeriesEntity(
            name: 'COVID-19',
            entries: [VaccinationEntryEntity(id: 1, userId: 1, name: 'COVID-19', vaccinationDate: DateTime(2026, 3, 10), nextVaccinationRequiredDate: DateTime(2026, 3, 15), createdAt: DateTime(2026, 3, 10))],
          ),
        ],
      ),
    );

    await tester.pumpWidget(_buildTestApp(viewModelFactory: () => model));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Overdue'));
    await tester.pump();

    expect(model.selectedFilter, VaccinationReminderFilter.overdue);
  });

  testWidgets('delete flow confirms and triggers shot deletion', (tester) async {
    tester.view.physicalSize = const Size(1400, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final model = _TestVaccinationViewModel(
      VaccinationOverviewState(
        activeUser: activeUser,
        series: [
          VaccinationSeriesEntity(
            name: 'COVID-19',
            entries: [VaccinationEntryEntity(id: 7, userId: 1, name: 'COVID-19', vaccinationDate: DateTime(2026, 3, 10), nextVaccinationRequiredDate: DateTime(2026, 9, 10), createdAt: DateTime(2026, 3, 10))],
          ),
        ],
      ),
    );

    await tester.pumpWidget(_buildTestApp(viewModelFactory: () => model));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ExpansionTile).first);
    await tester.pumpAndSettle();

    final deleteButton = find.byIcon(Icons.delete_outline).first;
    await tester.scrollUntilVisible(deleteButton, 80);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.text('Delete shot'), findsOneWidget);
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(model.deletedVaccinationId, 7);
  });

  testWidgets('while vaccinations are visible, switching active user updates records without crash', (tester) async {
    final bob = AppUserEntity(id: 2, username: 'Bob', profilePicture: null, isActive: false, createdAt: DateTime(2026, 1, 2));
    final switchableUserViewModel = _SwitchableUserManagementViewModel(users: [activeUser, bob], activeUser: activeUser);

    final aliceState = VaccinationOverviewState(
      activeUser: activeUser,
      series: [
        VaccinationSeriesEntity(
          name: 'COVID-19',
          entries: [VaccinationEntryEntity(id: 1, userId: 1, name: 'COVID-19', vaccinationDate: DateTime(2026, 1, 10), nextVaccinationRequiredDate: DateTime(2026, 7, 10), createdAt: DateTime(2026, 1, 10))],
        ),
      ],
    );
    final bobState = VaccinationOverviewState(
      activeUser: bob,
      series: [
        VaccinationSeriesEntity(
          name: 'FSME',
          entries: [VaccinationEntryEntity(id: 2, userId: 2, name: 'FSME', vaccinationDate: DateTime(2026, 2, 10), nextVaccinationRequiredDate: DateTime(2026, 8, 10), createdAt: DateTime(2026, 2, 10))],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userManagementProvider.overrideWith(() => switchableUserViewModel),
          vaccinationsProvider.overrideWith(() => _UserAwareVaccinationViewModel({1: aliceState, 2: bobState})),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routes: {Routes.vaccinationEdit: (_) => const Scaffold(body: Center(child: Text('Vaccination Edit Stub')))},
          home: const VaccinationsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final context = tester.element(find.byType(VaccinationsScreen));
    final local = AppLocalizations.of(context)!;

    expect(find.text(local.recordForUser('Alice')), findsOneWidget);
    expect(find.widgetWithText(ExpansionTile, 'COVID-19'), findsOneWidget);
    expect(find.widgetWithText(ExpansionTile, 'FSME'), findsNothing);

    switchableUserViewModel.setActiveUser(2);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text(local.recordForUser('Bob')), findsOneWidget);
    expect(find.widgetWithText(ExpansionTile, 'FSME'), findsOneWidget);
    expect(find.widgetWithText(ExpansionTile, 'COVID-19'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('while vaccinations are visible, switching active user to empty records updates empty state without crash', (tester) async {
    final bob = AppUserEntity(id: 2, username: 'Bob', profilePicture: null, isActive: false, createdAt: DateTime(2026, 1, 2));
    final switchableUserViewModel = _SwitchableUserManagementViewModel(users: [activeUser, bob], activeUser: activeUser);

    final aliceState = VaccinationOverviewState(
      activeUser: activeUser,
      series: [
        VaccinationSeriesEntity(
          name: 'COVID-19',
          entries: [VaccinationEntryEntity(id: 1, userId: 1, name: 'COVID-19', vaccinationDate: DateTime(2026, 1, 10), nextVaccinationRequiredDate: DateTime(2026, 7, 10), createdAt: DateTime(2026, 1, 10))],
        ),
      ],
    );
    final bobState = VaccinationOverviewState(activeUser: bob, series: const []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userManagementProvider.overrideWith(() => switchableUserViewModel),
          vaccinationsProvider.overrideWith(() => _UserAwareVaccinationViewModel({1: aliceState, 2: bobState})),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routes: {Routes.vaccinationEdit: (_) => const Scaffold(body: Center(child: Text('Vaccination Edit Stub')))},
          home: const VaccinationsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final context = tester.element(find.byType(VaccinationsScreen));
    final local = AppLocalizations.of(context)!;

    expect(find.widgetWithText(ExpansionTile, 'COVID-19'), findsOneWidget);
    expect(find.text(local.noVaccinationsTitle), findsNothing);

    switchableUserViewModel.setActiveUser(2);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ExpansionTile, 'COVID-19'), findsNothing);
    expect(find.text(local.noVaccinationsTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('while empty state is visible, switching active user updates to vaccination records without crash', (tester) async {
    final bob = AppUserEntity(id: 2, username: 'Bob', profilePicture: null, isActive: false, createdAt: DateTime(2026, 1, 2));
    final switchableUserViewModel = _SwitchableUserManagementViewModel(users: [activeUser, bob], activeUser: activeUser);

    final aliceState = VaccinationOverviewState(activeUser: activeUser, series: const []);
    final bobState = VaccinationOverviewState(
      activeUser: bob,
      series: [
        VaccinationSeriesEntity(
          name: 'FSME',
          entries: [VaccinationEntryEntity(id: 2, userId: 2, name: 'FSME', vaccinationDate: DateTime(2026, 2, 10), nextVaccinationRequiredDate: DateTime(2026, 8, 10), createdAt: DateTime(2026, 2, 10))],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userManagementProvider.overrideWith(() => switchableUserViewModel),
          vaccinationsProvider.overrideWith(() => _UserAwareVaccinationViewModel({1: aliceState, 2: bobState})),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routes: {Routes.vaccinationEdit: (_) => const Scaffold(body: Center(child: Text('Vaccination Edit Stub')))},
          home: const VaccinationsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final context = tester.element(find.byType(VaccinationsScreen));
    final local = AppLocalizations.of(context)!;

    expect(find.text(local.noVaccinationsTitle), findsOneWidget);
    expect(find.widgetWithText(ExpansionTile, 'FSME'), findsNothing);

    switchableUserViewModel.setActiveUser(2);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text(local.recordForUser('Bob')), findsOneWidget);
    expect(find.widgetWithText(ExpansionTile, 'FSME'), findsOneWidget);
    expect(find.text(local.noVaccinationsTitle), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('while empty state is visible, switching active user with no records keeps empty state without crash', (tester) async {
    final bob = AppUserEntity(id: 2, username: 'Bob', profilePicture: null, isActive: false, createdAt: DateTime(2026, 1, 2));
    final switchableUserViewModel = _SwitchableUserManagementViewModel(users: [activeUser, bob], activeUser: activeUser);

    final aliceState = VaccinationOverviewState(activeUser: activeUser, series: const []);
    final bobState = VaccinationOverviewState(activeUser: bob, series: const []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userManagementProvider.overrideWith(() => switchableUserViewModel),
          vaccinationsProvider.overrideWith(() => _UserAwareVaccinationViewModel({1: aliceState, 2: bobState})),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routes: {Routes.vaccinationEdit: (_) => const Scaffold(body: Center(child: Text('Vaccination Edit Stub')))},
          home: const VaccinationsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final context = tester.element(find.byType(VaccinationsScreen));
    final local = AppLocalizations.of(context)!;

    expect(find.text(local.noVaccinationsTitle), findsOneWidget);

    switchableUserViewModel.setActiveUser(2);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text(local.noVaccinationsTitle), findsOneWidget);
    expect(find.byType(ExpansionTile), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Widget _buildTestApp({required _TestVaccinationViewModel Function() viewModelFactory}) {
  return ProviderScope(
    overrides: [vaccinationsProvider.overrideWith(viewModelFactory)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {Routes.vaccinationEdit: (_) => const Scaffold(body: Center(child: Text('Vaccination Edit Stub')))},
      home: const VaccinationsScreen(),
    ),
  );
}
