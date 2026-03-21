import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/data/repositories/random_user_repository.dart';
import 'package:vaccination_manager/domain/entities/random_user_entity.dart';
import 'package:vaccination_manager/domain/usecases/fetch_random_user_usecase.dart';

final randomUserRepositoryProvider = Provider<RandomUserRepositoryImpl>((ref) {
  return RandomUserRepositoryImpl();
});

final fetchRandomUserUseCaseProvider = Provider<FetchRandomUserUseCase>((ref) {
  return FetchRandomUserUseCase(ref.read(randomUserRepositoryProvider));
});

final randomUserProvider = AsyncNotifierProvider<RandomUserViewModel, RandomUserEntity>(RandomUserViewModel.new);

class RandomUserViewModel extends AsyncNotifier<RandomUserEntity> {
  late final FetchRandomUserUseCase _fetchUser;

  @override
  Future<RandomUserEntity> build() async {
    _fetchUser = ref.read(fetchRandomUserUseCaseProvider);
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
