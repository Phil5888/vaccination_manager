// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'Vaccination Manager';

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
  String get navRecords => 'Records';

  @override
  String get navSchedule => 'Schedule';

  @override
  String get navProfile => 'Profile';

  @override
  String get myRecords => 'My Records';

  @override
  String get statCompleted => '– Completed';

  @override
  String get statUpcoming => '– Upcoming';

  @override
  String get statOverdue => '– Overdue';

  @override
  String get priorityDue => 'Priority Due';

  @override
  String get noUpcomingVaccinations => 'No upcoming vaccinations';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get welcome => 'Welcome';

  @override
  String get welcomeSubtitle => 'Your personal vaccination companion';

  @override
  String get getStarted => 'Get Started';

  @override
  String get createProfile => 'Create Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get fullName => 'Full Name';

  @override
  String get choosePhoto => 'Choose Photo';

  @override
  String get saveProfile => 'Save';

  @override
  String get switchProfile => 'Switch Profile';

  @override
  String get addNewProfile => 'Add New Profile';

  @override
  String get profileSwitcher => 'Profiles';

  @override
  String get deleteProfile => 'Delete Profile';

  @override
  String get noProfilesFound => 'No profiles found';

  @override
  String get addVaccination => 'Add Vaccination';

  @override
  String get editVaccination => 'Edit Vaccination';

  @override
  String get saveVaccination => 'Save Vaccination';

  @override
  String get vaccineName => 'Vaccine Name';

  @override
  String get dateAdministered => 'Date Administered';

  @override
  String get nextDoseDate => 'Next Dose Date';

  @override
  String get scheduleNextDose => 'Schedule Next Dose';

  @override
  String get vaccinationRecords => 'Vaccination Records';

  @override
  String get noVaccinationRecords => 'No vaccination records yet';

  @override
  String get deleteShot => 'Delete Shot';

  @override
  String get deleteShotConfirm => 'Delete this vaccination shot?';

  @override
  String get delete => 'Delete';

  @override
  String get recentRecords => 'Recent Records';

  @override
  String get seeSchedule => 'See Schedule';

  @override
  String get viewFullHistory => 'View Full History';

  @override
  String get dueNow => 'Due Now';

  @override
  String completedCount(int count) {
    return '$count Completed';
  }

  @override
  String upcomingCount(int count) {
    return '$count Upcoming';
  }

  @override
  String overdueCount(int count) {
    return '$count Overdue';
  }

  @override
  String dose(int number) {
    return 'Dose $number';
  }

  @override
  String get nextDose => 'Next dose';

  @override
  String get vaccinationSchedule => 'Vaccination Schedule';

  @override
  String get filterAll => 'All';

  @override
  String get filterOverdue => 'Overdue';

  @override
  String get filterDueSoon => 'Due Soon';

  @override
  String get filterUpToDate => 'Up to Date';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String statusDueSoon(String date) {
    return 'Due $date';
  }

  @override
  String get statusUpToDate => 'Up to Date';

  @override
  String shotCount(int count) {
    return '$count shot(s)';
  }

  @override
  String get noVaccinationsFilter => 'No vaccinations match this filter';

  @override
  String get oneShotMode => 'One Shot';

  @override
  String get multiShotMode => 'Multi Shot';

  @override
  String get switchToOneShotTitle => 'Switch to One Shot?';

  @override
  String get switchToOneShotBody =>
      'This will remove all additional shots from this series. This cannot be undone.';

  @override
  String get confirm => 'Confirm';

  @override
  String get addAnotherShot => 'Add Another Shot';

  @override
  String get leadTimeDays => 'Reminder lead time (days)';

  @override
  String get appearance => 'Appearance';

  @override
  String get reminders => 'Reminders';

  @override
  String get about => 'About';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get reminderLeadTimeLabel => 'Reminder lead time';

  @override
  String days(int count) {
    return '$count days';
  }

  @override
  String shot(int number) {
    return 'Shot $number';
  }

  @override
  String get numberOfShots => 'Number of shots';

  @override
  String get tapToSetDate => 'Tap to set date';

  @override
  String get shotStatusCompleted => 'Completed';

  @override
  String get shotStatusPlanned => 'Planned';

  @override
  String get shotStatusUnscheduled => 'Unscheduled';

  @override
  String get statusComplete => 'Complete';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusPlanned => 'Planned';

  @override
  String progressDone(int completed, int total) {
    return 'Done $completed of $total';
  }

  @override
  String get previouslyUsed => 'Previously added';

  @override
  String get recordNextShot => 'Record Next Shot';

  @override
  String recordNextShotTitle(int number) {
    return 'Record Shot $number';
  }

  @override
  String get deleteSeriesTitle => 'Delete Series';

  @override
  String deleteSeriesConfirm(String name) {
    return 'Delete all records for \"$name\"? This cannot be undone.';
  }

  @override
  String get showDetails => 'Show details';

  @override
  String get hideDetails => 'Hide details';

  @override
  String get exportToCalendar => 'Export to calendar';
}
