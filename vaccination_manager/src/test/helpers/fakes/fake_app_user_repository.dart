import 'package:vaccination_manager/domain/entities/app_user_entity.dart';
import 'package:vaccination_manager/domain/repositories/app_user_repository.dart';

class FakeAppUserRepository implements AppUserRepository {
  FakeAppUserRepository({List<AppUserEntity>? seedUsers}) : _users = List<AppUserEntity>.from(seedUsers ?? const []);

  final List<AppUserEntity> _users;
  AppUserEntity? lastSavedUser;
  int? lastSwitchedUserId;

  @override
  Future<List<AppUserEntity>> getUsers() async {
    return List<AppUserEntity>.from(_users);
  }

  @override
  Future<AppUserEntity> saveUser(AppUserEntity user) async {
    final normalized = user.copyWith(username: user.username.trim());
    lastSavedUser = normalized;

    if (normalized.id == null) {
      final nextId = _users.isEmpty ? 1 : (_users.map((it) => it.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
      final shouldActivate = _users.isEmpty || normalized.isActive;
      final created = normalized.copyWith(id: nextId, isActive: shouldActivate);

      if (shouldActivate) {
        _deactivateAll();
      }
      _users.add(created);
      return created;
    }

    final index = _users.indexWhere((it) => it.id == normalized.id);
    if (index == -1) {
      throw StateError('Cannot update user ${normalized.id}.');
    }

    if (normalized.isActive) {
      _deactivateAll();
    }

    _users[index] = normalized;
    return normalized;
  }

  @override
  Future<void> switchActiveUser(int userId) async {
    lastSwitchedUserId = userId;
    final index = _users.indexWhere((it) => it.id == userId);
    if (index == -1) {
      throw StateError('Cannot activate missing user $userId.');
    }

    _deactivateAll();
    _users[index] = _users[index].copyWith(isActive: true);
  }

  void _deactivateAll() {
    for (var i = 0; i < _users.length; i++) {
      _users[i] = _users[i].copyWith(isActive: false);
    }
  }
}
