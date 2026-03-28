import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaccination_manager/domain/entities/user_entity.dart';
import 'package:vaccination_manager/presentation/providers/user_dependency_providers.dart';

// ---------------------------------------------------------------------------
// UserListViewModel
// ---------------------------------------------------------------------------

class UserListViewModel extends AsyncNotifier<List<UserEntity>> {
  static const _activeUserKey = 'activeUserId';

  @override
  Future<List<UserEntity>> build() async {
    return ref.watch(getUsersUseCaseProvider).call();
  }

  Future<UserEntity> createUser(String username, String? picturePath) async {
    final useCase = ref.read(createUserUseCaseProvider);
    final created = await useCase.call(
      UserEntity(username: username, profilePicturePath: picturePath),
    );
    ref.invalidateSelf();
    return created;
  }

  Future<void> deleteUser(int id) async {
    final useCase = ref.read(deleteUserUseCaseProvider);
    await useCase.call(id);

    // Clear active user if it was the deleted one
    final prefs = await SharedPreferences.getInstance();
    final activeId = prefs.getInt(_activeUserKey);
    if (activeId == id) {
      await prefs.remove(_activeUserKey);
      ref.invalidate(activeUserProvider);
    }

    ref.invalidateSelf();
  }
}

final userListProvider =
    AsyncNotifierProvider<UserListViewModel, List<UserEntity>>(
  UserListViewModel.new,
);

// ---------------------------------------------------------------------------
// ActiveUserViewModel
// ---------------------------------------------------------------------------

class ActiveUserViewModel extends AsyncNotifier<UserEntity?> {
  static const _activeUserKey = 'activeUserId';

  @override
  Future<UserEntity?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_activeUserKey);
    if (id == null) return null;
    return ref.watch(getUserByIdUseCaseProvider).call(id);
  }

  Future<void> setActiveUser(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_activeUserKey, id);
    ref.invalidateSelf();
  }

  Future<void> updateUser(UserEntity user) async {
    final useCase = ref.read(updateUserUseCaseProvider);
    await useCase.call(user);
    ref.invalidateSelf();
    ref.invalidate(userListProvider);
  }
}

final activeUserProvider =
    AsyncNotifierProvider<ActiveUserViewModel, UserEntity?>(
  ActiveUserViewModel.new,
);
