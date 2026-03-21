import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// The app's main title displayed in the AppBar
  ///
  /// In en, this message translates to:
  /// **'Flutter Playground'**
  String get title;

  /// Label for the settings page or drawer item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Label for the language selection dropdown
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language label
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// German language label
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// Label for the theme settings section
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Toggle label for dark mode switch
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Generic error message label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Drawer header title
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menue;

  /// Title for the dashboard screen
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Label for the save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Label for the cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Label for the edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Label indicating that a feature is enabled or active
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get on;

  /// Label indicating that a feature is disabled or inactive
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get off;

  /// Label for the user management section
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// Title shown when no user exists yet
  ///
  /// In en, this message translates to:
  /// **'Welcome to Vaccination Manager'**
  String get welcomeTitle;

  /// Body text shown on the welcome screen
  ///
  /// In en, this message translates to:
  /// **'Create the first user profile to start managing vaccinations.'**
  String get welcomeBody;

  /// Primary action label to create the first user
  ///
  /// In en, this message translates to:
  /// **'Create first user'**
  String get createFirstUser;

  /// Label for the username field
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Label for the profile picture selector
  ///
  /// In en, this message translates to:
  /// **'Profile picture'**
  String get profilePicture;

  /// Button label to pick a profile picture
  ///
  /// In en, this message translates to:
  /// **'Choose picture'**
  String get choosePicture;

  /// Button label to replace the current profile picture
  ///
  /// In en, this message translates to:
  /// **'Change picture'**
  String get changePicture;

  /// Button label to remove the selected profile picture
  ///
  /// In en, this message translates to:
  /// **'Remove picture'**
  String get removePicture;

  /// Button label to switch the active user
  ///
  /// In en, this message translates to:
  /// **'Switch user'**
  String get switchUser;

  /// Label for the user management screen
  ///
  /// In en, this message translates to:
  /// **'Manage users'**
  String get manageUsers;

  /// Button label to add a new user
  ///
  /// In en, this message translates to:
  /// **'Add user'**
  String get addUser;

  /// Button label to edit an existing user
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// Label for the currently active user
  ///
  /// In en, this message translates to:
  /// **'Active user'**
  String get activeUser;

  /// Headline shown when the app has no user profiles
  ///
  /// In en, this message translates to:
  /// **'No users yet'**
  String get noUsersTitle;

  /// Help text shown when no users exist
  ///
  /// In en, this message translates to:
  /// **'Add a user to personalize the app with a name and profile picture.'**
  String get noUsersBody;

  /// Title for the quick user switch sheet
  ///
  /// In en, this message translates to:
  /// **'Switch active user'**
  String get quickSwitchTitle;

  /// Label shown next to the current active user
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentUser;

  /// Hint shown when there is only one user
  ///
  /// In en, this message translates to:
  /// **'Only one user is stored on this device.'**
  String get singleUserHint;

  /// Hint shown when multiple users are available
  ///
  /// In en, this message translates to:
  /// **'{count} users are stored on this device.'**
  String multipleUsersHint(int count);

  /// Message shown after a user profile is saved
  ///
  /// In en, this message translates to:
  /// **'User saved successfully.'**
  String get saveUserSuccess;

  /// Validation message shown when the username is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a username.'**
  String get usernameValidation;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
