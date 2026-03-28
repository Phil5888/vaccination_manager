import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/data/models/random_user_model.dart';
import 'package:vaccination_manager/data/repositories/random_user_repository.dart';
import 'package:vaccination_manager/domain/usecases/fetch_random_user_usecase.dart';

final randomUserRepositoryProvider = Provider<RandomUserRepository>((ref) {
  return RandomUserRepository();
});

final fetchRandomUserUseCaseProvider = Provider<FetchRandomUserUseCase>((ref) {
  final repository = ref.watch(randomUserRepositoryProvider);
  return FetchRandomUserUseCase(repository);
});

final randomUserProvider = AsyncNotifierProvider<RandomUserViewModel, RandomUser>(RandomUserViewModel.new);

class RandomUserViewModel extends AsyncNotifier<RandomUser> {
  @override
  Future<RandomUser> build() async {
    final fetchUser = ref.read(fetchRandomUserUseCaseProvider);
    return fetchUser();
  }

  Future<void> refreshUser() async {
    final fetchUser = ref.read(fetchRandomUserUseCaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(fetchUser.call);
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
