import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/core/database/app_database.dart';
import 'package:vaccination_manager/data/repositories/app_user_repository_impl.dart';
import 'package:vaccination_manager/domain/entities/app_user_entity.dart';
import 'package:vaccination_manager/domain/usecases/get_users_usecase.dart';
import 'package:vaccination_manager/domain/usecases/save_user_usecase.dart';
import 'package:vaccination_manager/domain/usecases/switch_active_user_usecase.dart';

class UserManagementState {
  const UserManagementState({required this.users, required this.activeUser});

  final List<AppUserEntity> users;
  final AppUserEntity? activeUser;

  bool get hasUsers => users.isNotEmpty;
}

final appUserRepositoryProvider = Provider<AppUserRepositoryImpl>((ref) {
  return AppUserRepositoryImpl(database: AppDatabase.instance);
});

final getUsersUseCaseProvider = Provider<GetUsersUseCase>((ref) {
  return GetUsersUseCase(ref.read(appUserRepositoryProvider));
});

final saveUserUseCaseProvider = Provider<SaveUserUseCase>((ref) {
  return SaveUserUseCase(ref.read(appUserRepositoryProvider));
});

final switchActiveUserUseCaseProvider = Provider<SwitchActiveUserUseCase>((ref) {
  return SwitchActiveUserUseCase(ref.read(appUserRepositoryProvider));
});

final userManagementProvider = AsyncNotifierProvider<UserManagementViewModel, UserManagementState>(UserManagementViewModel.new);

final activeUserProvider = Provider<AppUserEntity?>((ref) {
  return ref.watch(userManagementProvider).asData?.value.activeUser;
});

class UserManagementViewModel extends AsyncNotifier<UserManagementState> {
  late final GetUsersUseCase _getUsers;
  late final SaveUserUseCase _saveUser;
  late final SwitchActiveUserUseCase _switchActiveUser;

  @override
  Future<UserManagementState> build() async {
    _getUsers = ref.read(getUsersUseCaseProvider);
    _saveUser = ref.read(saveUserUseCaseProvider);
    _switchActiveUser = ref.read(switchActiveUserUseCaseProvider);
    return _loadState();
  }

  Future<AppUserEntity> saveUser({int? id, required String username, Uint8List? profilePicture, bool keepCurrentActiveState = false}) async {
    final existing = _userById(id);
    final savedUser = await _saveUser(
      AppUserEntity(id: id, username: username.trim(), profilePicture: profilePicture, isActive: keepCurrentActiveState ? existing?.isActive ?? false : false, createdAt: existing?.createdAt ?? DateTime.now()),
    );

    await refresh();
    return savedUser;
  }

  Future<void> switchUser(int userId) async {
    await _switchActiveUser(userId);
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadState);
  }

  AppUserEntity? _userById(int? id) {
    if (id == null) {
      return null;
    }

    final currentState = state.asData?.value;
    if (currentState == null) {
      return null;
    }

    for (final user in currentState.users) {
      if (user.id == id) {
        return user;
      }
    }

    return null;
  }

  Future<UserManagementState> _loadState() async {
    final users = await _getUsers();
    AppUserEntity? activeUser;

    for (final user in users) {
      if (user.isActive) {
        activeUser = user;
        break;
      }
    }

    return UserManagementState(users: users, activeUser: activeUser);
  }
}
