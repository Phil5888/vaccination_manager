import 'package:flutter/material.dart';
import 'package:vaccination_manager/core/constants/routes.dart';
import 'package:vaccination_manager/domain/entities/app_user_entity.dart';
import 'package:vaccination_manager/presentation/screens/vaccinations/vaccination_edit_screen.dart';
import 'package:vaccination_manager/presentation/screens/vaccinations/vaccinations_screen.dart';
import 'package:vaccination_manager/presentation/screens/users/user_edit_screen.dart';
import 'package:vaccination_manager/presentation/screens/users/user_management_screen.dart';
import 'package:vaccination_manager/presentation/screens/settings/reminder_screen.dart';
import 'package:vaccination_manager/presentation/screens/welcome/welcome_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case Routes.vaccinations:
        return MaterialPageRoute(builder: (_) => const VaccinationsScreen());
      case Routes.vaccinationEdit:
        return MaterialPageRoute(builder: (_) => VaccinationEditScreen(arguments: settings.arguments as VaccinationEditArguments?));
      case Routes.users:
        return MaterialPageRoute(builder: (_) => const UserManagementScreen());
      case Routes.userEdit:
        return MaterialPageRoute(builder: (_) => UserEditScreen(initialUser: settings.arguments as AppUserEntity?));
      case Routes.reminders:
        return MaterialPageRoute(builder: (_) => const ReminderScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('No route defined'))),
        );
    }
  }
}
