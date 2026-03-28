// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get title => 'Impfmanager';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get english => 'Englisch';

  @override
  String get german => 'Deutsch';

  @override
  String get theme => 'Thema';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get error => 'Fehler';

  @override
  String get menue => 'Menü';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get on => 'An';

  @override
  String get off => 'Aus';

  @override
  String get navRecords => 'Einträge';

  @override
  String get navSchedule => 'Zeitplan';

  @override
  String get navProfile => 'Profil';

  @override
  String get myRecords => 'Meine Einträge';

  @override
  String get statCompleted => '– Abgeschlossen';

  @override
  String get statUpcoming => '– Bevorstehend';

  @override
  String get statOverdue => '– Überfällig';

  @override
  String get priorityDue => 'Priorität fällig';

  @override
  String get noUpcomingVaccinations => 'Keine bevorstehenden Impfungen';

  @override
  String get comingSoon => 'Demnächst verfügbar';

  @override
  String get welcome => 'Willkommen';

  @override
  String get welcomeSubtitle => 'Dein persönlicher Impfbegleiter';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get createProfile => 'Profil erstellen';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get fullName => 'Vollständiger Name';

  @override
  String get choosePhoto => 'Foto wählen';

  @override
  String get saveProfile => 'Speichern';

  @override
  String get switchProfile => 'Profil wechseln';

  @override
  String get addNewProfile => 'Neues Profil hinzufügen';

  @override
  String get profileSwitcher => 'Profile';

  @override
  String get deleteProfile => 'Profil löschen';

  @override
  String get noProfilesFound => 'Keine Profile gefunden';

  @override
  String get addVaccination => 'Impfung hinzufügen';

  @override
  String get editVaccination => 'Impfung bearbeiten';

  @override
  String get saveVaccination => 'Impfung speichern';

  @override
  String get vaccineName => 'Impfstoffname';

  @override
  String get dateAdministered => 'Verabreichungsdatum';

  @override
  String get nextDoseDate => 'Nächste Dosisdatum';

  @override
  String get scheduleNextDose => 'Nächste Dosis planen';

  @override
  String get vaccinationRecords => 'Impfeinträge';

  @override
  String get noVaccinationRecords => 'Noch keine Impfeinträge';

  @override
  String get deleteShot => 'Eintrag löschen';

  @override
  String get deleteShotConfirm => 'Diesen Impfeintrag löschen?';

  @override
  String get delete => 'Löschen';

  @override
  String get recentRecords => 'Neueste Einträge';

  @override
  String get seeSchedule => 'Zeitplan anzeigen';

  @override
  String get viewFullHistory => 'Gesamte Geschichte anzeigen';

  @override
  String get dueNow => 'Jetzt fällig';

  @override
  String completedCount(int count) {
    return '$count Abgeschlossen';
  }

  @override
  String upcomingCount(int count) {
    return '$count Bevorstehend';
  }

  @override
  String overdueCount(int count) {
    return '$count Überfällig';
  }

  @override
  String dose(int number) {
    return 'Dosis $number';
  }

  @override
  String get nextDose => 'Nächste Dosis';

  @override
  String get vaccinationSchedule => 'Impfplan';

  @override
  String get filterAll => 'Alle';

  @override
  String get filterOverdue => 'Überfällig';

  @override
  String get filterDueSoon => 'Bald fällig';

  @override
  String get filterUpToDate => 'Aktuell';

  @override
  String get statusOverdue => 'Überfällig';

  @override
  String statusDueSoon(String date) {
    return 'Fällig $date';
  }

  @override
  String get statusUpToDate => 'Aktuell';

  @override
  String shotCount(int count) {
    return '$count Impfdosis(en)';
  }

  @override
  String get noVaccinationsFilter =>
      'Keine Impfungen entsprechen diesem Filter';

  @override
  String get oneShotMode => 'Einmalig';

  @override
  String get multiShotMode => 'Mehrfachdosis';

  @override
  String get switchToOneShotTitle => 'Zu einmaliger Dosis wechseln?';

  @override
  String get switchToOneShotBody =>
      'Dadurch werden alle zusätzlichen Dosen dieser Serie entfernt. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get addAnotherShot => 'Weitere Dosis hinzufügen';

  @override
  String get leadTimeDays => 'Erinnerungsvorlaufzeit (Tage)';

  @override
  String get appearance => 'Aussehen';

  @override
  String get reminders => 'Erinnerungen';

  @override
  String get about => 'Über';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get reminderLeadTimeLabel => 'Erinnerungsvorlaufzeit';

  @override
  String days(int count) {
    return '$count Tage';
  }

  @override
  String shot(int number) {
    return 'Dosis $number';
  }

  @override
  String get numberOfShots => 'Anzahl der Impfungen';

  @override
  String get tapToSetDate => 'Datum auswählen';

  @override
  String get shotStatusCompleted => 'Verabreicht';

  @override
  String get shotStatusPlanned => 'Geplant';

  @override
  String get shotStatusUnscheduled => 'Nicht geplant';

  @override
  String get statusComplete => 'Abgeschlossen';

  @override
  String get statusInProgress => 'In Bearbeitung';

  @override
  String get statusPlanned => 'Geplant';

  @override
  String progressDone(int completed, int total) {
    return '$completed von $total abgeschlossen';
  }

  @override
  String get previouslyUsed => 'Bereits eingetragen';

  @override
  String get recordNextShot => 'Nächste Impfung erfassen';

  @override
  String recordNextShotTitle(int number) {
    return 'Impfung $number erfassen';
  }

  @override
  String get deleteSeriesTitle => 'Serie löschen';

  @override
  String deleteSeriesConfirm(String name) {
    return 'Alle Einträge für \"$name\" löschen? Dies kann nicht rückgängig gemacht werden.';
  }

  @override
  String get showDetails => 'Details anzeigen';

  @override
  String get hideDetails => 'Details ausblenden';

  @override
  String get exportToCalendar => 'In Kalender exportieren';
}
