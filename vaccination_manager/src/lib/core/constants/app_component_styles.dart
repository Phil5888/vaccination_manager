import 'package:flutter/material.dart';
import 'package:vaccination_manager/core/constants/app_spacing.dart';

class AppComponentStyles {
  static ButtonStyle appBarPrimaryIconButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton.styleFrom(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      minimumSize: const Size(40, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
    );
  }

  static ButtonStyle appBarSecondaryIconButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton.styleFrom(
      backgroundColor: colorScheme.surfaceContainerHighest,
      foregroundColor: colorScheme.onSurface,
      minimumSize: const Size(40, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
    );
  }
}
