import 'package:flutter/material.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/presentation/viewmodels/random_user_viewmodel.dart';

class RandomUserNameForm extends ConsumerStatefulWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const RandomUserNameForm({super.key, required this.onSave, required this.onCancel});

  @override
  ConsumerState<RandomUserNameForm> createState() => _RandomUserNameFormState();
}

class _RandomUserNameFormState extends ConsumerState<RandomUserNameForm> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(randomUserProvider).value;
    _firstNameController = TextEditingController(text: user?.name.first ?? '');
    _lastNameController = TextEditingController(text: user?.name.last ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _handleSave() {
    ref.read(randomUserProvider.notifier).updateName(first: _firstNameController.text, last: _lastNameController.text);
    final local = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(local.nameSaved), duration: Duration(seconds: 2)));

    widget.onSave();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _firstNameController,
            decoration: InputDecoration(labelText: local.firstName),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _lastNameController,
            decoration: InputDecoration(labelText: local.lastName),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(onPressed: widget.onCancel, icon: const Icon(Icons.cancel), label: Text(local.cancel)),
              ElevatedButton.icon(onPressed: _handleSave, icon: const Icon(Icons.save), label: Text(local.save)),
            ],
          ),
        ],
      ),
    );
  }
}
