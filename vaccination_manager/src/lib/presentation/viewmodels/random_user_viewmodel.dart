import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/data/models/random_user_model.dart';
import 'package:vaccination_manager/data/repositories/random_user_repository.dart';
import 'package:vaccination_manager/domain/usecases/fetch_random_user_usecase.dart';

final randomUserProvider = AsyncNotifierProvider<RandomUserViewModel, RandomUser>(RandomUserViewModel.new);

class RandomUserViewModel extends AsyncNotifier<RandomUser> {
  late final FetchRandomUserUseCase _fetchUser;

  @override
  Future<RandomUser> build() async {
    final repository = RandomUserRepository();
    _fetchUser = FetchRandomUserUseCase(repository);
    return await _fetchUser();
  }

  Future<void> refreshUser() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchUser());
  }

  void updateName({required String first, required String last}) {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(
      name: current.name.copyWith(first: first, last: last),
    );
    state = AsyncData(updated);
  }
}
