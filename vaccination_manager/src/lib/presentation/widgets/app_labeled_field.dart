import 'package:flutter/material.dart';
import 'package:vaccination_manager/core/constants/app_spacing.dart';

class AppLabeledField extends StatelessWidget {
  const AppLabeledField({super.key, required this.label, required this.child, this.helper, this.labelStyle, this.labelToFieldSpacing = AppSpacing.sm, this.fieldToHelperSpacing = AppSpacing.xxs});

  final String label;
  final Widget child;
  final Widget? helper;
  final TextStyle? labelStyle;
  final double labelToFieldSpacing;
  final double fieldToHelperSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle ?? Theme.of(context).textTheme.titleMedium),
        SizedBox(height: labelToFieldSpacing),
        child,
        if (helper != null) ...[SizedBox(height: fieldToHelperSpacing), helper!],
      ],
    );
  }
}
