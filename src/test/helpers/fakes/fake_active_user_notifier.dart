import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/domain/entities/user_entity.dart';
import 'package:vaccination_manager/presentation/providers/user_providers.dart';

/// A test-only [ActiveUserViewModel] that returns a fixed [UserEntity?] from
/// its build and allows mutating the active user mid-test via [setUser].
///
/// Extends [ActiveUserViewModel] (not the raw [AsyncNotifier]) so that it
/// satisfies the type constraint of [activeUserProvider.overrideWith].
class FakeActiveUserNotifier extends ActiveUserViewModel {
  FakeActiveUserNotifier(this._currentUser);

  UserEntity? _currentUser;

  @override
  Future<UserEntity?> build() async => _currentUser;

  /// Updates the notifier state without rebuilding from [build].
  void setUser(UserEntity? user) {
    _currentUser = user;
    state = AsyncData(user);
  }
}
