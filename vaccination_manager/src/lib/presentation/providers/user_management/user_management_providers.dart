import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/domain/entities/app_user_entity.dart';
import 'package:vaccination_manager/presentation/viewmodels/user_management_viewmodel.dart';

final userManagementProvider = AsyncNotifierProvider<UserManagementViewModel, UserManagementState>(UserManagementViewModel.new);

final activeUserProvider = Provider<AppUserEntity?>((ref) {
  return ref.watch(userManagementProvider).asData?.value.activeUser;
});
