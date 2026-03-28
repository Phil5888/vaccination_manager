import 'package:flutter/material.dart';
import 'package:vaccination_manager/l10n/app_localizations.dart';
import 'package:vaccination_manager/presentation/screens/random_user/widgets/random_user_name_form.dart';

class RandomUserEditScreen extends StatelessWidget {
  const RandomUserEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(local.edit)),
      body: RandomUserNameForm(onSave: () => Navigator.of(context).pop(), onCancel: () => Navigator.of(context).pop()),
    );
  }
}
