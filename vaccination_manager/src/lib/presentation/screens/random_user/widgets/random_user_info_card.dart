import 'package:flutter/material.dart';
import 'package:vaccination_manager/data/models/random_user_model.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';

class RandomUserInfoCard extends StatelessWidget {
  final RandomUser user;
  final VoidCallback? onEdit;

  const RandomUserInfoCard({super.key, required this.user, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 50, backgroundImage: NetworkImage(user.picture.large)),
            const SizedBox(height: 16),
            Text('${user.name.title} ${user.name.first} ${user.name.last}', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(user.email),
            const SizedBox(height: 8),
            Text('${local.gender}: ${user.gender}'),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(icon: const Icon(Icons.edit), label: Text(local.edit), onPressed: onEdit),
            ),
          ],
        ),
      ),
    );
  }
}
