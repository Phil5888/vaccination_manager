// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'Flutter Playground';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get german => 'German';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get error => 'Error';

  @override
  String get menue => 'Menu';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get edit => 'Edit';

  @override
  String get on => 'on';

  @override
  String get off => 'off';

  @override
  String get users => 'Users';

  @override
  String get welcomeTitle => 'Welcome to Vaccination Manager';

  @override
  String get welcomeBody => 'Create the first user profile to start managing vaccinations.';

  @override
  String get createFirstUser => 'Create first user';

  @override
  String get username => 'Username';

  @override
  String get profilePicture => 'Profile picture';

  @override
  String get choosePicture => 'Choose picture';

  @override
  String get changePicture => 'Change picture';

  @override
  String get removePicture => 'Remove picture';

  @override
  String get switchUser => 'Switch user';

  @override
  String get manageUsers => 'Manage users';

  @override
  String get addUser => 'Add user';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get activeUser => 'Active user';

  @override
  String get noUsersTitle => 'No users yet';

  @override
  String get noUsersBody => 'Add a user to personalize the app with a name and profile picture.';

  @override
  String get quickSwitchTitle => 'Switch active user';

  @override
  String get currentUser => 'Current';

  @override
  String get singleUserHint => 'Only one user is stored on this device.';

  @override
  String multipleUsersHint(int count) {
    return '$count users are stored on this device.';
  }

  @override
  String get saveUserSuccess => 'User saved successfully.';

  @override
  String get usernameValidation => 'Please enter a username.';
}
