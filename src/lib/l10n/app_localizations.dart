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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// The app's main title
  ///
  /// In en, this message translates to:
  /// **'Vaccination Manager'**
  String get title;

  /// Label for the settings page or nav item
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

  /// Bottom navigation label for the Records tab
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get navRecords;

  /// Bottom navigation label for the Schedule tab
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get navSchedule;

  /// Bottom navigation label for the Profile tab
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Heading on the Dashboard screen
  ///
  /// In en, this message translates to:
  /// **'My Records'**
  String get myRecords;

  /// Placeholder stat chip: completed vaccinations
  ///
  /// In en, this message translates to:
  /// **'– Completed'**
  String get statCompleted;

  /// Placeholder stat chip: upcoming vaccinations
  ///
  /// In en, this message translates to:
  /// **'– Upcoming'**
  String get statUpcoming;

  /// Placeholder stat chip: overdue vaccinations
  ///
  /// In en, this message translates to:
  /// **'– Overdue'**
  String get statOverdue;

  /// Section heading for highest-priority upcoming vaccinations
  ///
  /// In en, this message translates to:
  /// **'Priority Due'**
  String get priorityDue;

  /// Empty-state message in the Priority Due section
  ///
  /// In en, this message translates to:
  /// **'No upcoming vaccinations'**
  String get noUpcomingVaccinations;

  /// Placeholder text for screens not yet implemented
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Title for the welcome / onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Subtitle on the welcome screen
  ///
  /// In en, this message translates to:
  /// **'Your personal vaccination companion'**
  String get welcomeSubtitle;

  /// CTA button on the welcome screen
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Title and button label for the create profile screen
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get createProfile;

  /// Label for editing an existing profile
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Label for the full name input field
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Button to select a profile picture
  ///
  /// In en, this message translates to:
  /// **'Choose Photo'**
  String get choosePhoto;

  /// Button to save the profile form
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveProfile;

  /// Button to open the profile switcher
  ///
  /// In en, this message translates to:
  /// **'Switch Profile'**
  String get switchProfile;

  /// Option in the profile switcher to create a new profile
  ///
  /// In en, this message translates to:
  /// **'Add New Profile'**
  String get addNewProfile;

  /// Title of the profile switcher bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get profileSwitcher;

  /// Action to delete a profile
  ///
  /// In en, this message translates to:
  /// **'Delete Profile'**
  String get deleteProfile;

  /// Empty state message when no profiles exist
  ///
  /// In en, this message translates to:
  /// **'No profiles found'**
  String get noProfilesFound;

  /// Title and button label for adding a vaccination
  ///
  /// In en, this message translates to:
  /// **'Add Vaccination'**
  String get addVaccination;

  /// Title for editing an existing vaccination
  ///
  /// In en, this message translates to:
  /// **'Edit Vaccination'**
  String get editVaccination;

  /// Button label to save a vaccination entry
  ///
  /// In en, this message translates to:
  /// **'Save Vaccination'**
  String get saveVaccination;

  /// Label for the vaccine name input
  ///
  /// In en, this message translates to:
  /// **'Vaccine Name'**
  String get vaccineName;

  /// Label for the date the vaccine was administered
  ///
  /// In en, this message translates to:
  /// **'Date Administered'**
  String get dateAdministered;

  /// Label for the optional next dose date field
  ///
  /// In en, this message translates to:
  /// **'Next Dose Date'**
  String get nextDoseDate;

  /// Toggle label to enable scheduling the next dose
  ///
  /// In en, this message translates to:
  /// **'Schedule Next Dose'**
  String get scheduleNextDose;

  /// Title for the vaccination records screen
  ///
  /// In en, this message translates to:
  /// **'Vaccination Records'**
  String get vaccinationRecords;

  /// Empty state message when no vaccination records exist
  ///
  /// In en, this message translates to:
  /// **'No vaccination records yet'**
  String get noVaccinationRecords;

  /// Title for the delete shot confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Shot'**
  String get deleteShot;

  /// Body text of the delete shot confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete this vaccination shot?'**
  String get deleteShotConfirm;

  /// Label for the delete action button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Section heading for recent vaccination records on the dashboard
  ///
  /// In en, this message translates to:
  /// **'Recent Records'**
  String get recentRecords;

  /// Button label to navigate to the schedule tab
  ///
  /// In en, this message translates to:
  /// **'See Schedule'**
  String get seeSchedule;

  /// Button label to navigate to the full vaccination history
  ///
  /// In en, this message translates to:
  /// **'View Full History'**
  String get viewFullHistory;

  /// Status badge for overdue vaccinations
  ///
  /// In en, this message translates to:
  /// **'Due Now'**
  String get dueNow;

  /// Stat chip showing number of completed vaccinations
  ///
  /// In en, this message translates to:
  /// **'{count} Completed'**
  String completedCount(int count);

  /// Stat chip showing number of upcoming vaccinations
  ///
  /// In en, this message translates to:
  /// **'{count} Upcoming'**
  String upcomingCount(int count);

  /// Stat chip showing number of overdue vaccinations
  ///
  /// In en, this message translates to:
  /// **'{count} Overdue'**
  String overdueCount(int count);

  /// Label for a dose in a vaccination series
  ///
  /// In en, this message translates to:
  /// **'Dose {number}'**
  String dose(int number);

  /// Label for next dose date
  ///
  /// In en, this message translates to:
  /// **'Next dose'**
  String get nextDose;

  /// Title for the vaccination schedule screen
  ///
  /// In en, this message translates to:
  /// **'Vaccination Schedule'**
  String get vaccinationSchedule;

  /// Filter chip: show all vaccinations
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Filter chip: show overdue vaccinations
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get filterOverdue;

  /// Filter chip: show vaccinations due soon
  ///
  /// In en, this message translates to:
  /// **'Due Soon'**
  String get filterDueSoon;

  /// Filter chip: show up-to-date vaccinations
  ///
  /// In en, this message translates to:
  /// **'Up to Date'**
  String get filterUpToDate;

  /// Status label: overdue
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statusOverdue;

  /// Status label: due soon with date
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String statusDueSoon(String date);

  /// Status label: up to date
  ///
  /// In en, this message translates to:
  /// **'Up to Date'**
  String get statusUpToDate;

  /// Number of shots in a series
  ///
  /// In en, this message translates to:
  /// **'{count} shot(s)'**
  String shotCount(int count);

  /// Empty state message when no vaccinations match the active filter
  ///
  /// In en, this message translates to:
  /// **'No vaccinations match this filter'**
  String get noVaccinationsFilter;

  /// Mode toggle label: one-shot mode
  ///
  /// In en, this message translates to:
  /// **'One Shot'**
  String get oneShotMode;

  /// Mode toggle label: multi-shot mode
  ///
  /// In en, this message translates to:
  /// **'Multi Shot'**
  String get multiShotMode;

  /// Dialog title when switching from multi-shot to one-shot mode
  ///
  /// In en, this message translates to:
  /// **'Switch to One Shot?'**
  String get switchToOneShotTitle;

  /// Dialog body when switching from multi-shot to one-shot mode
  ///
  /// In en, this message translates to:
  /// **'This will remove all additional shots from this series. This cannot be undone.'**
  String get switchToOneShotBody;

  /// Label for the confirm action button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Button label to add another shot in multi-shot mode
  ///
  /// In en, this message translates to:
  /// **'Add Another Shot'**
  String get addAnotherShot;

  /// Settings label for reminder lead time in days
  ///
  /// In en, this message translates to:
  /// **'Reminder lead time (days)'**
  String get leadTimeDays;

  /// Settings section header for appearance options
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Settings section header for reminder options
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// Settings section header for about information
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// App version label in the about section
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// Label for the reminder lead time stepper row
  ///
  /// In en, this message translates to:
  /// **'Reminder lead time'**
  String get reminderLeadTimeLabel;

  /// Number of days label
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String days(int count);

  /// Label for a shot number in multi-shot mode
  ///
  /// In en, this message translates to:
  /// **'Shot {number}'**
  String shot(int number);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

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
