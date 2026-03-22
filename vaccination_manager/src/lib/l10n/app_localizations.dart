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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[delegate, GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate, GlobalWidgetsLocalizations.delegate];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de'), Locale('en')];

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

  /// Title for reminder settings and sync screen
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// Subtitle for the reminder settings entry in settings screen
  ///
  /// In en, this message translates to:
  /// **'Calendar sync and notification lead time'**
  String get reminderSettingsDescription;

  /// Label for the reminder lead-time dropdown
  ///
  /// In en, this message translates to:
  /// **'Notification lead time'**
  String get notificationLeadTime;

  /// In en, this message translates to:
  /// **'3 days'**
  String get reminderLeadTime3Days;

  /// In en, this message translates to:
  /// **'1 week'**
  String get reminderLeadTime1Week;

  /// In en, this message translates to:
  /// **'2 weeks'**
  String get reminderLeadTime2Weeks;

  /// In en, this message translates to:
  /// **'1 month'**
  String get reminderLeadTime1Month;

  /// In en, this message translates to:
  /// **'2 months'**
  String get reminderLeadTime2Months;

  /// In en, this message translates to:
  /// **'3 months'**
  String get reminderLeadTime3Months;

  /// Description text on reminder sync screen
  ///
  /// In en, this message translates to:
  /// **'Sync vaccination due dates to your calendar and schedule local reminder notifications.'**
  String get reminderSyncDescription;

  /// Primary button label to trigger reminder synchronization
  ///
  /// In en, this message translates to:
  /// **'Sync reminders now'**
  String get syncRemindersNow;

  /// Feedback text after reminder synchronization
  ///
  /// In en, this message translates to:
  /// **'Reminder sync completed. Calendar created: {created}, updated: {updated}, removed: {removed}. Notifications scheduled: {scheduled}.'**
  String reminderSyncSuccess(int created, int updated, int removed, int scheduled);

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

  /// Welcome headline on dashboard for the active user
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {username}'**
  String dashboardHeroGreeting(String username);

  /// Supporting subtitle on the dashboard welcome card
  ///
  /// In en, this message translates to:
  /// **'Here is your vaccination overview for today.'**
  String get dashboardHeroSubtitle;

  /// Title for upcoming vaccinations section on dashboard
  ///
  /// In en, this message translates to:
  /// **'Upcoming vaccinations'**
  String get dashboardUpcomingTitle;

  /// Positive state title when nothing is due soon or overdue
  ///
  /// In en, this message translates to:
  /// **'Everything is alright'**
  String get dashboardAllGoodTitle;

  /// Positive state body when no vaccinations need attention
  ///
  /// In en, this message translates to:
  /// **'No vaccinations are due soon or overdue.'**
  String get dashboardAllGoodBody;

  /// Dashboard action button to open vaccinations section
  ///
  /// In en, this message translates to:
  /// **'Open vaccinations'**
  String get dashboardOpenVaccinations;

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

  /// Label for destructive delete actions
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

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

  /// Label for the vaccination section
  ///
  /// In en, this message translates to:
  /// **'Vaccinations'**
  String get vaccinations;

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

  /// Tooltip and label for opening user search
  ///
  /// In en, this message translates to:
  /// **'Search users'**
  String get searchUsers;

  /// Hint text in the user search input
  ///
  /// In en, this message translates to:
  /// **'Search users'**
  String get searchUsersHint;

  /// Empty-state hint shown before entering user search text
  ///
  /// In en, this message translates to:
  /// **'Type to search user names.'**
  String get searchUsersStart;

  /// Empty-state message when user search has no matches
  ///
  /// In en, this message translates to:
  /// **'No matching users found.'**
  String get searchUsersNoMatches;

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

  /// Title for the dashboard vaccination summary card
  ///
  /// In en, this message translates to:
  /// **'Vaccination status'**
  String get vaccinationStatus;

  /// Empty-state title shown when a user has no vaccination records
  ///
  /// In en, this message translates to:
  /// **'No vaccination records yet'**
  String get noVaccinationsTitle;

  /// Empty-state body for the vaccination feature
  ///
  /// In en, this message translates to:
  /// **'Add the first vaccination for this user to track shot history and upcoming due dates.'**
  String get noVaccinationsBody;

  /// Primary action label to add a new vaccination
  ///
  /// In en, this message translates to:
  /// **'Add vaccination'**
  String get addVaccination;

  /// Tooltip and label for opening vaccination search
  ///
  /// In en, this message translates to:
  /// **'Search vaccinations'**
  String get searchVaccinations;

  /// Hint text in the vaccination search input
  ///
  /// In en, this message translates to:
  /// **'Search vaccinations'**
  String get searchVaccinationsHint;

  /// Empty-state hint shown before entering search text
  ///
  /// In en, this message translates to:
  /// **'Type to search vaccination names.'**
  String get searchVaccinationsStart;

  /// Empty-state message for vaccination search without matches
  ///
  /// In en, this message translates to:
  /// **'No matching vaccinations found.'**
  String get searchVaccinationsNoMatches;

  /// Action label to add another shot to an existing vaccination series
  ///
  /// In en, this message translates to:
  /// **'Add shot'**
  String get addShot;

  /// Screen title label for editing a vaccination entry
  ///
  /// In en, this message translates to:
  /// **'Edit vaccination'**
  String get editVaccination;

  /// Label for the vaccination name text field
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get vaccinationName;

  /// Label for the vaccination date field
  ///
  /// In en, this message translates to:
  /// **'Date of vaccination'**
  String get vaccinationDate;

  /// Label for the next vaccination required date field
  ///
  /// In en, this message translates to:
  /// **'Next vaccination required'**
  String get nextVaccinationRequired;

  /// Label for the number of shots in a vaccination series
  ///
  /// In en, this message translates to:
  /// **'Shots recorded'**
  String get shotsRecorded;

  /// Label for the most recent shot date
  ///
  /// In en, this message translates to:
  /// **'Last shot'**
  String get lastShot;

  /// Label for the next due vaccination date
  ///
  /// In en, this message translates to:
  /// **'Next due'**
  String get nextDue;

  /// Status label for overdue vaccinations
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// Status label for soon-due vaccinations
  ///
  /// In en, this message translates to:
  /// **'Due soon'**
  String get dueSoon;

  /// Status label for vaccinations that are not due soon
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get upToDate;

  /// Headline showing the active user for the vaccination list
  ///
  /// In en, this message translates to:
  /// **'Records for {username}'**
  String recordForUser(String username);

  /// Label for the count of upcoming vaccination courses
  ///
  /// In en, this message translates to:
  /// **'Upcoming vaccinations'**
  String get upcomingVaccinations;

  /// Message shown in compact vaccination summary when there are no due-soon vaccinations
  ///
  /// In en, this message translates to:
  /// **'There are no upcoming vaccinations.'**
  String get noUpcomingVaccinations;

  /// Label for the count of overdue vaccination courses
  ///
  /// In en, this message translates to:
  /// **'Overdue vaccinations'**
  String get overdueVaccinations;

  /// Validation message when vaccination name is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a vaccination name.'**
  String get vaccinationNameValidation;

  /// Validation message when vaccination date is missing
  ///
  /// In en, this message translates to:
  /// **'Please select the vaccination date.'**
  String get vaccinationDateValidation;

  /// Validation message when next vaccination date is missing
  ///
  /// In en, this message translates to:
  /// **'Please select the next vaccination date.'**
  String get nextVaccinationDateValidation;

  /// Validation message when next vaccination date is not after the vaccination date
  ///
  /// In en, this message translates to:
  /// **'The next vaccination date must be after the vaccination date.'**
  String get nextVaccinationDateOrderValidation;

  /// Snackbar text after a vaccination entry is saved
  ///
  /// In en, this message translates to:
  /// **'Vaccination saved successfully.'**
  String get saveVaccinationSuccess;

  /// Button label used to open a date picker
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get chooseDate;

  /// Label for an item in a multi-shot vaccination history
  ///
  /// In en, this message translates to:
  /// **'Shot {count}'**
  String shotNumber(int count);

  /// Tooltip and dialog title for deleting one vaccination shot
  ///
  /// In en, this message translates to:
  /// **'Delete shot'**
  String get deleteVaccination;

  /// Confirmation message shown before deleting one vaccination shot
  ///
  /// In en, this message translates to:
  /// **'Delete Shot {shotIndex} from {vaccinationName}?'**
  String deleteVaccinationConfirmation(int shotIndex, String vaccinationName);

  /// Snackbar message shown after deleting a vaccination shot
  ///
  /// In en, this message translates to:
  /// **'Shot deleted.'**
  String get deleteVaccinationSuccess;

  /// Filter label for showing all vaccination series
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Filter label for overdue vaccination series
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get filterOverdue;

  /// Filter label for due-soon vaccination series
  ///
  /// In en, this message translates to:
  /// **'Due soon'**
  String get filterDueSoon;

  /// Filter label for up-to-date vaccination series
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get filterUpToDate;

  /// Empty-state message when the selected reminder filter has no matches
  ///
  /// In en, this message translates to:
  /// **'No vaccination series match this filter.'**
  String get noVaccinationsForFilter;

  /// Label for selecting one-shot or multi-shot vaccination mode
  ///
  /// In en, this message translates to:
  /// **'Vaccination course'**
  String get vaccinationModeLabel;

  /// Option label for one-shot vaccination mode
  ///
  /// In en, this message translates to:
  /// **'One-shot'**
  String get vaccinationModeOneShot;

  /// Option label for multi-shot vaccination mode
  ///
  /// In en, this message translates to:
  /// **'Multi-shot'**
  String get vaccinationModeMultiShot;

  /// Section label for entering vaccination shot dates
  ///
  /// In en, this message translates to:
  /// **'Shot dates'**
  String get shotDatesLabel;

  /// Button label for adding an additional shot date
  ///
  /// In en, this message translates to:
  /// **'Add another shot'**
  String get addAnotherShot;

  /// Tooltip label for removing a shot date
  ///
  /// In en, this message translates to:
  /// **'Remove shot'**
  String get removeShot;

  /// Label shown for a shot date in the future
  ///
  /// In en, this message translates to:
  /// **'Planned shot'**
  String get plannedShot;

  /// Label shown for a shot date in the past or today
  ///
  /// In en, this message translates to:
  /// **'Recorded shot'**
  String get recordedShot;

  /// Label for the vaccination expiration date
  ///
  /// In en, this message translates to:
  /// **'Vaccination expires on'**
  String get vaccinationExpiresOn;

  /// Validation message when expiration date is missing
  ///
  /// In en, this message translates to:
  /// **'Please select the vaccination expiration date.'**
  String get vaccinationExpiresValidation;

  /// Validation when expiration date is before latest shot
  ///
  /// In en, this message translates to:
  /// **'The expiration date must be on or after the latest shot date.'**
  String get vaccinationExpiresOrderValidation;

  /// Validation message when no shot date is present
  ///
  /// In en, this message translates to:
  /// **'Please add at least one shot date.'**
  String get shotDatesValidation;

  /// Validation when duplicate shot dates are entered
  ///
  /// In en, this message translates to:
  /// **'Each shot date must be unique.'**
  String get duplicateShotDateValidation;

  /// Dialog title shown when switching from multi-shot to one-shot
  ///
  /// In en, this message translates to:
  /// **'Convert to one-shot?'**
  String get switchToOneShotTitle;

  /// Dialog body warning for lossy multi-shot to one-shot conversion
  ///
  /// In en, this message translates to:
  /// **'This will remove {removedCount} shot date(s). Only the most recent shot will be kept.'**
  String switchToOneShotBody(int removedCount);

  /// Confirm button label for converting to one-shot mode
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get switchToOneShotConfirm;

  /// Cancel button label for keeping multi-shot mode
  ///
  /// In en, this message translates to:
  /// **'Keep multi-shot'**
  String get switchToOneShotCancel;

  /// Hint text explaining future planned shot behavior
  ///
  /// In en, this message translates to:
  /// **'Future shot dates are allowed and will be treated as upcoming reminders.'**
  String get futureShotHint;
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
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
