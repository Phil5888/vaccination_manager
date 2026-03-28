import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier that holds the currently selected bottom-nav tab index for [MainScreen].
///
/// Other screens (e.g. Dashboard) can read/write this notifier to
/// programmatically switch tabs without pushing a new named route.
///
/// Tab indices:
///   0 — Dashboard
///   1 — Records
///   2 — Schedule
///   3 — Profile
class SelectedTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void selectTab(int index) => state = index;
}

final selectedTabProvider = NotifierProvider<SelectedTabNotifier, int>(
  SelectedTabNotifier.new,
);
