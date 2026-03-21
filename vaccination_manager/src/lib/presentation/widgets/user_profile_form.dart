import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';

typedef UserProfileSubmit = Future<void> Function(String username, Uint8List? picture);

class UserProfileForm extends StatefulWidget {
  const UserProfileForm({super.key, required this.submitLabel, required this.onSubmit, this.initialUsername, this.initialProfilePicture, this.onCancel});

  final String submitLabel;
  final String? initialUsername;
  final Uint8List? initialProfilePicture;
  final UserProfileSubmit onSubmit;
  final VoidCallback? onCancel;

  @override
  State<UserProfileForm> createState() => _UserProfileFormState();
}

class _UserProfileFormState extends State<UserProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  Uint8List? _picture;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.initialUsername ?? '');
    _picture = widget.initialProfilePicture;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(local.username, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _usernameController,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return local.usernameValidation;
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Text(local.profilePicture, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(radius: 32, foregroundImage: _picture == null ? null : MemoryImage(_picture!), child: _picture == null ? const Icon(Icons.person) : null),
              const SizedBox(width: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.tonal(onPressed: _isSaving ? null : _pickPicture, child: Text(_picture == null ? local.choosePicture : local.changePicture)),
                  if (_picture != null) OutlinedButton(onPressed: _isSaving ? null : () => setState(() => _picture = null), child: Text(local.removePicture)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text(widget.submitLabel),
              ),
              if (widget.onCancel != null) OutlinedButton(onPressed: _isSaving ? null : widget.onCancel, child: Text(local.cancel)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickPicture() async {
    const typeGroup = XTypeGroup(label: 'images', extensions: ['png', 'jpg', 'jpeg', 'webp']);
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) {
      return;
    }

    final bytes = await file.readAsBytes();
    if (!mounted) {
      return;
    }

    setState(() => _picture = bytes);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.onSubmit(_usernameController.text.trim(), _picture);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
