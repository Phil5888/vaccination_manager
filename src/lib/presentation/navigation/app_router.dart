import 'package:flutter/material.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/domain/entities/user_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/presentation/screens/profile/create_profile_screen.dart';
import 'package:vaccination_manager/presentation/screens/settings/settings_screen.dart';
import 'package:vaccination_manager/presentation/screens/startup/app_startup_gate.dart';
import 'package:vaccination_manager/presentation/screens/vaccination/add_vaccination_screen.dart';
import 'package:vaccination_manager/presentation/screens/welcome/welcome_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.main:
        return MaterialPageRoute(builder: (_) => const AppStartupGate());
      case Routes.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case Routes.profileCreate:
        final user = settings.arguments as UserEntity?;
        return MaterialPageRoute(
          builder: (_) => CreateProfileScreen(existingUser: user),
        );
      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case Routes.vaccinationAdd:
        final entry = settings.arguments as VaccinationEntryEntity?;
        return MaterialPageRoute(
          builder: (_) => AddVaccinationScreen(existingEntry: entry),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('404 – Route Not Found')),
          ),
        );
    }
  }
}

