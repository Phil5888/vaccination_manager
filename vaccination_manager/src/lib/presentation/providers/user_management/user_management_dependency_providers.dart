import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/core/database/app_database.dart';
import 'package:vaccination_manager/data/repositories/app_user_repository_impl.dart';
import 'package:vaccination_manager/domain/usecases/get_users_usecase.dart';
import 'package:vaccination_manager/domain/usecases/save_user_usecase.dart';
import 'package:vaccination_manager/domain/usecases/switch_active_user_usecase.dart';

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
