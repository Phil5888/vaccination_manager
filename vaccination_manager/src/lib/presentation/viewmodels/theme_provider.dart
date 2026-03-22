import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/core/constants/app_theme.dart';
import 'package:vaccination_manager/presentation/providers/settings/settings_providers.dart';

final themeProvider = Provider<ThemeData>((ref) {
  final isDark = ref.watch(settingsProvider).isDarkMode;
  return isDark ? AppTheme.dark : AppTheme.light;
});
