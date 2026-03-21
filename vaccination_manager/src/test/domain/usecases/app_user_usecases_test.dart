import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/domain/entities/app_user_entity.dart';
import 'package:vaccination_manager/domain/usecases/get_users_usecase.dart';
import 'package:vaccination_manager/domain/usecases/save_user_usecase.dart';
import 'package:vaccination_manager/domain/usecases/switch_active_user_usecase.dart';

import '../../helpers/fakes/fake_app_user_repository.dart';

void main() {
  group('App user usecases', () {
    late FakeAppUserRepository repository;

    setUp(() {
      repository = FakeAppUserRepository(
        seedUsers: [AppUserEntity(id: 1, username: 'Anna', profilePicture: null, isActive: true, createdAt: DateTime(2026, 1, 1))],
      );
    });

    test('GetUsersUseCase returns repository data', () async {
      final useCase = GetUsersUseCase(repository);

      final users = await useCase();

      expect(users, hasLength(1));
      expect(users.first.username, 'Anna');
    });

    test('SaveUserUseCase delegates saving to repository', () async {
      final useCase = SaveUserUseCase(repository);
      final user = AppUserEntity(id: null, username: '  New User  ', profilePicture: null, isActive: false, createdAt: DateTime(2026, 1, 1));

      final saved = await useCase(user);

      expect(saved.id, isNotNull);
      expect(saved.username, 'New User');
      expect(repository.lastSavedUser?.username, 'New User');
    });

    test('SwitchActiveUserUseCase changes active user', () async {
      final saveUseCase = SaveUserUseCase(repository);
      await saveUseCase(AppUserEntity(id: null, username: 'Bob', profilePicture: null, isActive: false, createdAt: DateTime(2026, 1, 1)));

      final useCase = SwitchActiveUserUseCase(repository);
      await useCase(2);

      final users = await repository.getUsers();
      expect(repository.lastSwitchedUserId, 2);
      expect(users.firstWhere((u) => u.id == 2).isActive, isTrue);
      expect(users.firstWhere((u) => u.id == 1).isActive, isFalse);
    });
  });
}
