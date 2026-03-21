import 'package:flutter/material.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/presentation/screens/random_user/widgets/random_user_info_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/presentation/viewmodels/random_user_viewmodel.dart';

class UserPreviewCard extends ConsumerWidget {
  const UserPreviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(randomUserProvider);

    return userState.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
      data: (user) => RandomUserInfoCard(user: user, onEdit: () => Navigator.of(context).pushNamed(Routes.randomUserEdit)),
    );
  }
}
