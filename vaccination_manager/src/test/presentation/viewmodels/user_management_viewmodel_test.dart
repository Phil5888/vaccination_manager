import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/domain/entities/app_user_entity.dart';
import 'package:vaccination_manager/domain/usecases/get_users_usecase.dart';
import 'package:vaccination_manager/domain/usecases/save_user_usecase.dart';
import 'package:vaccination_manager/domain/usecases/switch_active_user_usecase.dart';
import 'package:vaccination_manager/presentation/viewmodels/user_management_viewmodel.dart';

import '../../helpers/fakes/fake_app_user_repository.dart';

void main() {
  group('UserManagementViewModel', () {
    late FakeAppUserRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = FakeAppUserRepository(
        seedUsers: [AppUserEntity(id: 1, username: 'Existing User', profilePicture: null, isActive: true, createdAt: DateTime(2026, 1, 1))],
      );

      container = ProviderContainer(
        overrides: [
          getUsersUseCaseProvider.overrideWithValue(GetUsersUseCase(repository)),
          saveUserUseCaseProvider.overrideWithValue(SaveUserUseCase(repository)),
          switchActiveUserUseCaseProvider.overrideWithValue(SwitchActiveUserUseCase(repository)),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('loads users and resolves active user on build', () async {
      final state = await container.read(userManagementProvider.future);

      expect(state.hasUsers, isTrue);
      expect(state.activeUser?.username, 'Existing User');
    });

    test('saveUser trims username and refreshes state', () async {
      await container.read(userManagementProvider.future);

      await container.read(userManagementProvider.notifier).saveUser(username: '  New Person  ', profilePicture: null);

      final state = await container.read(userManagementProvider.future);
      expect(state.users.map((u) => u.username), contains('New Person'));
    });

    test('saveUser keeps active state when editing', () async {
      await container.read(userManagementProvider.future);

      await container.read(userManagementProvider.notifier).saveUser(id: 1, username: 'Updated Name', keepCurrentActiveState: true);

      expect(repository.lastSavedUser?.isActive, isTrue);
      final state = await container.read(userManagementProvider.future);
      expect(state.activeUser?.username, 'Updated Name');
    });

    test('switchUser updates active user', () async {
      await container.read(userManagementProvider.future);
      await container.read(userManagementProvider.notifier).saveUser(username: 'Second User', profilePicture: null);

      await container.read(userManagementProvider.notifier).switchUser(2);

      final state = await container.read(userManagementProvider.future);
      expect(repository.lastSwitchedUserId, 2);
      expect(state.activeUser?.id, 2);
    });
  });
}
