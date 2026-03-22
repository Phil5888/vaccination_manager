import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/presentation/viewmodels/settings_viewmodel.dart';

final settingsProvider = NotifierProvider<SettingsViewModel, SettingsState>(SettingsViewModel.new);
