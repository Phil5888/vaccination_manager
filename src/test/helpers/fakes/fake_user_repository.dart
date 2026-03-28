import 'package:vaccination_manager/domain/entities/user_entity.dart';
import 'package:vaccination_manager/domain/repositories/user_repository.dart';

/// In-memory [UserRepository] for tests.
class FakeUserRepository implements UserRepository {
  final List<UserEntity> _store = [];
  int _nextId = 1;

  /// Pre-populate the store. Users without an id get one auto-assigned.
  void seedAll(List<UserEntity> users) {
    _store.clear();
    _nextId = 1;
    for (final u in users) {
      if (u.id != null) {
        _store.add(u);
        if (u.id! >= _nextId) _nextId = u.id! + 1;
      } else {
        _store.add(u.copyWith(id: _nextId++));
      }
    }
  }

  @override
  Future<List<UserEntity>> getAllUsers() async => List.of(_store);

  @override
  Future<UserEntity?> getUserById(int id) async {
    try {
      return _store.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserEntity> createUser(UserEntity user) async {
    final created = user.copyWith(id: _nextId++);
    _store.add(created);
    return created;
  }

  @override
  Future<UserEntity> updateUser(UserEntity user) async {
    final idx = _store.indexWhere((u) => u.id == user.id);
    if (idx >= 0) {
      _store[idx] = user;
    }
    return user;
  }

  @override
  Future<void> deleteUser(int id) async {
    _store.removeWhere((u) => u.id == id);
  }
}
