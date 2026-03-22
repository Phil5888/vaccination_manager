import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/domain/entities/app_user_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/usecases/delete_vaccination_usecase.dart';
import 'package:vaccination_manager/domain/usecases/get_vaccinations_for_user_usecase.dart';
import 'package:vaccination_manager/domain/usecases/save_vaccination_usecase.dart';
import 'package:vaccination_manager/presentation/providers/user_management/user_management_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination/vaccination_dependency_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination/vaccination_providers.dart';
import 'package:vaccination_manager/presentation/viewmodels/user_management_viewmodel.dart';
import 'package:vaccination_manager/presentation/viewmodels/vaccination_viewmodel.dart';

import '../../helpers/fakes/fake_vaccination_repository.dart';

class _TestUserManagementViewModel extends UserManagementViewModel {
  _TestUserManagementViewModel(this.initialState);

  final UserManagementState initialState;

  @override
  Future<UserManagementState> build() async => initialState;
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

void main() {
  group('VaccinationViewModel', () {
    late FakeVaccinationRepository repository;
    late ProviderContainer container;
    final activeUser = AppUserEntity(id: 1, username: 'Alice', profilePicture: null, isActive: true, createdAt: DateTime(2026, 1, 1));

    setUp(() {
      repository = FakeVaccinationRepository(
        seedEntries: [
          VaccinationEntryEntity(id: 1, userId: 1, name: 'COVID-19', vaccinationDate: DateTime(2026, 1, 10), nextVaccinationRequiredDate: DateTime(2026, 7, 10), createdAt: DateTime(2026, 1, 10)),
          VaccinationEntryEntity(id: 2, userId: 1, name: 'COVID-19', vaccinationDate: DateTime(2026, 3, 10), nextVaccinationRequiredDate: DateTime(2026, 9, 10), createdAt: DateTime(2026, 3, 10)),
          VaccinationEntryEntity(id: 3, userId: 2, name: 'FSME', vaccinationDate: DateTime(2026, 2, 5), nextVaccinationRequiredDate: DateTime(2026, 8, 5), createdAt: DateTime(2026, 2, 5)),
        ],
      );

      container = ProviderContainer(
        overrides: [
          userManagementProvider.overrideWith(() => _TestUserManagementViewModel(UserManagementState(users: [activeUser], activeUser: activeUser))),
          getVaccinationsForUserUseCaseProvider.overrideWithValue(GetVaccinationsForUserUseCase(repository)),
          saveVaccinationUseCaseProvider.overrideWithValue(SaveVaccinationUseCase(repository)),
          deleteVaccinationUseCaseProvider.overrideWithValue(DeleteVaccinationUseCase(repository)),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('loads and groups vaccination entries for the active user only', () async {
      final state = await container.read(vaccinationsProvider.future);

      expect(state.activeUser?.username, 'Alice');
      expect(state.series, hasLength(1));
      expect(state.series.first.name, 'COVID-19');
      expect(state.series.first.shotCount, 2);
    });

    test('saveVaccination stores a new entry for the active user', () async {
      await container.read(vaccinationsProvider.future);

      await container.read(vaccinationsProvider.notifier).saveVaccination(name: 'FSME', vaccinationDate: DateTime(2026, 4, 1), nextVaccinationRequiredDate: DateTime(2026, 10, 1));

      final state = await container.read(vaccinationsProvider.future);
      expect(repository.lastSavedEntry?.userId, 1);
      expect(state.series.map((series) => series.name), contains('FSME'));
    });

    test('deleteVaccination removes one shot and refreshes grouped state', () async {
      await container.read(vaccinationsProvider.future);

      await container.read(vaccinationsProvider.notifier).deleteVaccination(2);

      final state = await container.read(vaccinationsProvider.future);
      expect(repository.lastDeletedVaccinationId, 2);
      expect(state.series, hasLength(1));
      expect(state.series.first.shotCount, 1);
    });

    test('setFilter updates selected filter in state', () async {
      await container.read(vaccinationsProvider.future);

      container.read(vaccinationsProvider.notifier).setFilter(VaccinationReminderFilter.overdue);

      final state = container.read(vaccinationsProvider).asData!.value;
      expect(state.selectedFilter, VaccinationReminderFilter.overdue);
    });

    test('switches from user with vaccinations to user with vaccinations without reinitialization crash', () async {
      final users = [activeUser, AppUserEntity(id: 2, username: 'Bob', profilePicture: null, isActive: false, createdAt: DateTime(2026, 1, 2))];
      final switchableUserViewModel = _SwitchableUserManagementViewModel(users: users, activeUser: activeUser);

      final switchContainer = ProviderContainer(
        overrides: [
          userManagementProvider.overrideWith(() => switchableUserViewModel),
          getVaccinationsForUserUseCaseProvider.overrideWithValue(GetVaccinationsForUserUseCase(repository)),
          saveVaccinationUseCaseProvider.overrideWithValue(SaveVaccinationUseCase(repository)),
          deleteVaccinationUseCaseProvider.overrideWithValue(DeleteVaccinationUseCase(repository)),
        ],
      );
      addTearDown(switchContainer.dispose);

      final initialState = await switchContainer.read(vaccinationsProvider.future);
      expect(initialState.activeUser?.username, 'Alice');
      expect(initialState.series.map((series) => series.name), contains('COVID-19'));
      expect(initialState.series.map((series) => series.name), isNot(contains('FSME')));

      switchableUserViewModel.setActiveUser(2);
      await Future<void>.microtask(() {});

      final switchedState = await switchContainer.read(vaccinationsProvider.future);
      expect(switchedState.activeUser?.username, 'Bob');
      expect(switchedState.series, hasLength(1));
      expect(switchedState.series.first.name, 'FSME');
    });

    test('switches from user with vaccinations to user without vaccinations without reinitialization crash', () async {
      final bob = AppUserEntity(id: 2, username: 'Bob', profilePicture: null, isActive: false, createdAt: DateTime(2026, 1, 2));
      final switchableUserViewModel = _SwitchableUserManagementViewModel(users: [activeUser, bob], activeUser: activeUser);
      final switchRepository = FakeVaccinationRepository(
        seedEntries: [VaccinationEntryEntity(id: 1, userId: 1, name: 'COVID-19', vaccinationDate: DateTime(2026, 1, 10), nextVaccinationRequiredDate: DateTime(2026, 7, 10), createdAt: DateTime(2026, 1, 10))],
      );

      final switchContainer = ProviderContainer(
        overrides: [
          userManagementProvider.overrideWith(() => switchableUserViewModel),
          getVaccinationsForUserUseCaseProvider.overrideWithValue(GetVaccinationsForUserUseCase(switchRepository)),
          saveVaccinationUseCaseProvider.overrideWithValue(SaveVaccinationUseCase(switchRepository)),
          deleteVaccinationUseCaseProvider.overrideWithValue(DeleteVaccinationUseCase(switchRepository)),
        ],
      );
      addTearDown(switchContainer.dispose);

      final initialState = await switchContainer.read(vaccinationsProvider.future);
      expect(initialState.activeUser?.username, 'Alice');
      expect(initialState.series, hasLength(1));
      expect(initialState.series.first.name, 'COVID-19');

      switchableUserViewModel.setActiveUser(2);
      await Future<void>.microtask(() {});

      final switchedState = await switchContainer.read(vaccinationsProvider.future);
      expect(switchedState.activeUser?.username, 'Bob');
      expect(switchedState.series, isEmpty);
    });

    test('switches from user without vaccinations to user with vaccinations without reinitialization crash', () async {
      final bob = AppUserEntity(id: 2, username: 'Bob', profilePicture: null, isActive: false, createdAt: DateTime(2026, 1, 2));
      final switchableUserViewModel = _SwitchableUserManagementViewModel(users: [activeUser, bob], activeUser: activeUser);
      final switchRepository = FakeVaccinationRepository(
        seedEntries: [VaccinationEntryEntity(id: 2, userId: 2, name: 'FSME', vaccinationDate: DateTime(2026, 2, 10), nextVaccinationRequiredDate: DateTime(2026, 8, 10), createdAt: DateTime(2026, 2, 10))],
      );

      final switchContainer = ProviderContainer(
        overrides: [
          userManagementProvider.overrideWith(() => switchableUserViewModel),
          getVaccinationsForUserUseCaseProvider.overrideWithValue(GetVaccinationsForUserUseCase(switchRepository)),
          saveVaccinationUseCaseProvider.overrideWithValue(SaveVaccinationUseCase(switchRepository)),
          deleteVaccinationUseCaseProvider.overrideWithValue(DeleteVaccinationUseCase(switchRepository)),
        ],
      );
      addTearDown(switchContainer.dispose);

      final initialState = await switchContainer.read(vaccinationsProvider.future);
      expect(initialState.activeUser?.username, 'Alice');
      expect(initialState.series, isEmpty);

      switchableUserViewModel.setActiveUser(2);
      await Future<void>.microtask(() {});

      final switchedState = await switchContainer.read(vaccinationsProvider.future);
      expect(switchedState.activeUser?.username, 'Bob');
      expect(switchedState.series, hasLength(1));
      expect(switchedState.series.first.name, 'FSME');
    });

    test('switches from user without vaccinations to user without vaccinations without reinitialization crash', () async {
      final bob = AppUserEntity(id: 2, username: 'Bob', profilePicture: null, isActive: false, createdAt: DateTime(2026, 1, 2));
      final switchableUserViewModel = _SwitchableUserManagementViewModel(users: [activeUser, bob], activeUser: activeUser);
      final switchRepository = FakeVaccinationRepository(seedEntries: const []);

      final switchContainer = ProviderContainer(
        overrides: [
          userManagementProvider.overrideWith(() => switchableUserViewModel),
          getVaccinationsForUserUseCaseProvider.overrideWithValue(GetVaccinationsForUserUseCase(switchRepository)),
          saveVaccinationUseCaseProvider.overrideWithValue(SaveVaccinationUseCase(switchRepository)),
          deleteVaccinationUseCaseProvider.overrideWithValue(DeleteVaccinationUseCase(switchRepository)),
        ],
      );
      addTearDown(switchContainer.dispose);

      final initialState = await switchContainer.read(vaccinationsProvider.future);
      expect(initialState.activeUser?.username, 'Alice');
      expect(initialState.series, isEmpty);

      switchableUserViewModel.setActiveUser(2);
      await Future<void>.microtask(() {});

      final switchedState = await switchContainer.read(vaccinationsProvider.future);
      expect(switchedState.activeUser?.username, 'Bob');
      expect(switchedState.series, isEmpty);
    });
  });
}
