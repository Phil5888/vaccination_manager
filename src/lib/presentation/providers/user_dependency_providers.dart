import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/data/repositories/user_repository_impl.dart';
import 'package:vaccination_manager/domain/repositories/user_repository.dart';
import 'package:vaccination_manager/domain/usecases/user/create_user_use_case.dart';
import 'package:vaccination_manager/domain/usecases/user/delete_user_use_case.dart';
import 'package:vaccination_manager/domain/usecases/user/get_user_by_id_use_case.dart';
import 'package:vaccination_manager/domain/usecases/user/get_users_use_case.dart';
import 'package:vaccination_manager/domain/usecases/user/update_user_use_case.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl();
});

final createUserUseCaseProvider = Provider<CreateUserUseCase>((ref) {
  return CreateUserUseCase(ref.watch(userRepositoryProvider));
});

final getUsersUseCaseProvider = Provider<GetUsersUseCase>((ref) {
  return GetUsersUseCase(ref.watch(userRepositoryProvider));
});

final getUserByIdUseCaseProvider = Provider<GetUserByIdUseCase>((ref) {
  return GetUserByIdUseCase(ref.watch(userRepositoryProvider));
});

final updateUserUseCaseProvider = Provider<UpdateUserUseCase>((ref) {
  return UpdateUserUseCase(ref.watch(userRepositoryProvider));
});

final deleteUserUseCaseProvider = Provider<DeleteUserUseCase>((ref) {
  return DeleteUserUseCase(ref.watch(userRepositoryProvider));
});
