import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/domain/entities/app_user_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/domain/usecases/delete_vaccination_usecase.dart';
import 'package:vaccination_manager/domain/usecases/get_users_usecase.dart';
import 'package:vaccination_manager/domain/usecases/get_vaccinations_for_user_usecase.dart';
import 'package:vaccination_manager/domain/usecases/save_user_usecase.dart';
import 'package:vaccination_manager/domain/usecases/save_vaccination_usecase.dart';
import 'package:vaccination_manager/domain/usecases/switch_active_user_usecase.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/providers/user_management/user_management_dependency_providers.dart';
import 'package:vaccination_manager/presentation/providers/user_management/user_management_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination/vaccination_dependency_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination/vaccination_providers.dart';
import 'package:vaccination_manager/presentation/screens/users/user_management_screen.dart';
import 'package:vaccination_manager/presentation/screens/vaccinations/vaccinations_screen.dart';
import 'package:vaccination_manager/presentation/viewmodels/user_management_viewmodel.dart';
import 'package:vaccination_manager/presentation/viewmodels/vaccination_viewmodel.dart';

import '../../helpers/fakes/fake_app_user_repository.dart';
import '../../helpers/fakes/fake_vaccination_repository.dart';

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
  group('Bulk Data Stress', () {
    test('UserManagementViewModel handles 25 users and switching active user', () async {
      final users = _buildUsers(count: 25, activeId: 1);
      final repository = FakeAppUserRepository(seedUsers: users);

      final container = ProviderContainer(
        overrides: [
          getUsersUseCaseProvider.overrideWithValue(GetUsersUseCase(repository)),
          saveUserUseCaseProvider.overrideWithValue(SaveUserUseCase(repository)),
          switchActiveUserUseCaseProvider.overrideWithValue(SwitchActiveUserUseCase(repository)),
        ],
      );
      addTearDown(container.dispose);

      final initialState = await container.read(userManagementProvider.future);
      expect(initialState.users, hasLength(25));
      expect(initialState.activeUser?.id, 1);

      await container.read(userManagementProvider.notifier).switchUser(25);

      final switchedState = await container.read(userManagementProvider.future);
      expect(switchedState.users, hasLength(25));
      expect(switchedState.activeUser?.id, 25);
    });

    test('VaccinationViewModel handles 200 vaccinations with one-shot and multi-shot mix', () async {
      final activeUser = AppUserEntity(id: 1, username: 'Stress User', profilePicture: null, isActive: true, createdAt: DateTime(2026, 1, 1));
      final entries = _buildVaccinationEntries(userId: 1, totalEntries: 200);
      final repository = FakeVaccinationRepository(seedEntries: entries);

      final container = ProviderContainer(
        overrides: [
          userManagementProvider.overrideWith(() => _TestUserManagementViewModel(UserManagementState(users: [activeUser], activeUser: activeUser))),
          getVaccinationsForUserUseCaseProvider.overrideWithValue(GetVaccinationsForUserUseCase(repository)),
          saveVaccinationUseCaseProvider.overrideWithValue(SaveVaccinationUseCase(repository)),
          deleteVaccinationUseCaseProvider.overrideWithValue(DeleteVaccinationUseCase(repository)),
        ],
      );
      addTearDown(container.dispose);

      final state = await container.read(vaccinationsProvider.future);
      final totalLoadedEntries = state.series.fold<int>(0, (sum, series) => sum + series.shotCount);
      final hasMultiShotSeries = state.series.any((series) => series.shotCount > 1);
      final hasOneShotSeries = state.series.any((series) => series.shotCount == 1);

      expect(totalLoadedEntries, 200);
      expect(hasMultiShotSeries, isTrue);
      expect(hasOneShotSeries, isTrue);
    });

    testWidgets('UserManagementScreen remains usable with 25 users', (tester) async {
      final users = _buildUsers(count: 25, activeId: 1);
      final activeUser = users.firstWhere((user) => user.isActive);

      await tester.pumpWidget(
        _buildTestApp(
          screen: const UserManagementScreen(),
          userState: UserManagementState(users: users, activeUser: activeUser),
          vaccinationState: const VaccinationOverviewState(activeUser: null, series: []),
        ),
      );

      await tester.pumpAndSettle();

      final target = find.text('User 25');
      await tester.scrollUntilVisible(target, 200);

      expect(target, findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('VaccinationsScreen remains usable with 200 vaccinations', (tester) async {
      final activeUser = AppUserEntity(id: 1, username: 'Stress User', profilePicture: null, isActive: true, createdAt: DateTime(2026, 1, 1));
      final entries = _buildVaccinationEntries(userId: 1, totalEntries: 200);
      final groupedByName = <String, List<VaccinationEntryEntity>>{};
      for (final entry in entries) {
        groupedByName.putIfAbsent(entry.name, () => <VaccinationEntryEntity>[]).add(entry);
      }
      final series = groupedByName.entries.map((pair) => VaccinationSeriesEntity(name: pair.key, entries: pair.value)).toList();

      await tester.pumpWidget(
        _buildTestApp(
          screen: const VaccinationsScreen(),
          userState: UserManagementState(users: [activeUser], activeUser: activeUser),
          vaccinationState: VaccinationOverviewState(activeUser: activeUser, series: series),
        ),
      );

      await tester.pumpAndSettle();

      final scrollable = find.byType(Scrollable).first;
      await tester.fling(scrollable, const Offset(0, -900), 1800);
      await tester.pumpAndSettle();
      await tester.fling(scrollable, const Offset(0, -900), 1800);
      await tester.pumpAndSettle();

      expect(find.byType(ExpansionTile), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}

List<AppUserEntity> _buildUsers({required int count, required int activeId}) {
  return List<AppUserEntity>.generate(count, (index) {
    final id = index + 1;
    return AppUserEntity(id: id, username: 'User $id', profilePicture: null, isActive: id == activeId, createdAt: DateTime(2026, 1, id <= 28 ? id : 28));
  });
}

List<VaccinationEntryEntity> _buildVaccinationEntries({required int userId, required int totalEntries}) {
  final entries = <VaccinationEntryEntity>[];
  var idCounter = 1;

  // 50 multi-shot series with 2 shots each -> 100 entries.
  for (var seriesIndex = 1; seriesIndex <= 50; seriesIndex++) {
    for (var shot = 0; shot < 2; shot++) {
      final day = ((seriesIndex + shot) % 28) + 1;
      entries.add(
        VaccinationEntryEntity(
          id: idCounter++,
          userId: userId,
          name: 'Series $seriesIndex',
          vaccinationDate: DateTime(2026, ((seriesIndex + shot) % 12) + 1, day),
          nextVaccinationRequiredDate: DateTime(2027, ((seriesIndex + 1) % 12) + 1, day),
          createdAt: DateTime(2026, 1, 1),
        ),
      );
    }
  }

  // 100 one-shot series -> 100 entries (Series 51..150).
  for (var seriesIndex = 51; seriesIndex <= 150; seriesIndex++) {
    final day = (seriesIndex % 28) + 1;
    entries.add(
      VaccinationEntryEntity(
        id: idCounter++,
        userId: userId,
        name: 'Series $seriesIndex',
        vaccinationDate: DateTime(2026, (seriesIndex % 12) + 1, day),
        nextVaccinationRequiredDate: DateTime(2027, ((seriesIndex + 2) % 12) + 1, day),
        createdAt: DateTime(2026, 1, 1),
      ),
    );
  }

  if (entries.length != totalEntries) {
    throw StateError('Generated ${entries.length} entries, expected $totalEntries.');
  }

  return entries;
}

Widget _buildTestApp({required Widget screen, required UserManagementState userState, required VaccinationOverviewState vaccinationState}) {
  return ProviderScope(
    overrides: [userManagementProvider.overrideWith(() => _TestUserManagementViewModel(userState)), vaccinationsProvider.overrideWith(() => _TestVaccinationViewModel(vaccinationState))],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {Routes.userEdit: (_) => const Scaffold(), Routes.vaccinationEdit: (_) => const Scaffold()},
      home: screen,
    ),
  );
}
