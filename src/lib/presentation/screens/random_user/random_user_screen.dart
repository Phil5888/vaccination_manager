import 'package:flutter/material.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/screens/random_user/widgets/random_user_info_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/presentation/viewmodels/random_user_viewmodel.dart';

class RandomUserScreen extends ConsumerWidget {
  const RandomUserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(randomUserProvider);

    final notifier = ref.read(randomUserProvider.notifier);
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(local.randomUser),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: notifier.refreshUser),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.randomUserEdit);
            },
          ),
        ],
      ),
      body: userState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (user) => RandomUserInfoCard(user: user, onEdit: () => Navigator.of(context).pushNamed(Routes.randomUserEdit)),
      ),
    );
  }
}
