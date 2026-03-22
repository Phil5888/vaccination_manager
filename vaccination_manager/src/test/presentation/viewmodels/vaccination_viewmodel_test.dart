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
  });
}
