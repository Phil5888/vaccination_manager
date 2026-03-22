// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get title => 'Flutter Spielplatz';

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
  String dashboardHeroGreeting(String username) {
    return 'Willkommen zurück, $username';
  }

  @override
  String get dashboardHeroSubtitle => 'Hier ist dein Impfüberblick für heute.';

  @override
  String get dashboardUpcomingTitle => 'Bevorstehende Impfungen';

  @override
  String get dashboardAllGoodTitle => 'Alles ist in Ordnung';

  @override
  String get dashboardAllGoodBody => 'Keine Impfung ist bald fällig oder überfällig.';

  @override
  String get dashboardOpenVaccinations => 'Impfungen öffnen';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

  @override
  String get on => 'An';

  @override
  String get off => 'Aus';

  @override
  String get users => 'Benutzer';

  @override
  String get vaccinations => 'Impfungen';

  @override
  String get welcomeTitle => 'Willkommen beim Impfmanager';

  @override
  String get welcomeBody => 'Erstellen Sie das erste Benutzerprofil, um Impfungen zu verwalten.';

  @override
  String get createFirstUser => 'Ersten Benutzer erstellen';

  @override
  String get username => 'Benutzername';

  @override
  String get profilePicture => 'Profilbild';

  @override
  String get choosePicture => 'Bild auswählen';

  @override
  String get changePicture => 'Bild ändern';

  @override
  String get removePicture => 'Bild entfernen';

  @override
  String get switchUser => 'Benutzer wechseln';

  @override
  String get manageUsers => 'Benutzer verwalten';

  @override
  String get addUser => 'Benutzer hinzufügen';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get activeUser => 'Aktiver Benutzer';

  @override
  String get noUsersTitle => 'Noch keine Benutzer';

  @override
  String get noUsersBody => 'Fügen Sie einen Benutzer hinzu, um die App mit Namen und Profilbild zu personalisieren.';

  @override
  String get quickSwitchTitle => 'Aktiven Benutzer wechseln';

  @override
  String get currentUser => 'Aktuell';

  @override
  String get singleUserHint => 'Nur ein Benutzer ist auf diesem Gerät gespeichert.';

  @override
  String multipleUsersHint(int count) {
    return '$count Benutzer sind auf diesem Gerät gespeichert.';
  }

  @override
  String get saveUserSuccess => 'Benutzer erfolgreich gespeichert.';

  @override
  String get usernameValidation => 'Bitte geben Sie einen Benutzernamen ein.';

  @override
  String get vaccinationStatus => 'Impfstatus';

  @override
  String get noVaccinationsTitle => 'Noch keine Impfeinträge';

  @override
  String get noVaccinationsBody => 'Fügen Sie die erste Impfung für diesen Benutzer hinzu, um Impfverlauf und nächste Termine zu verfolgen.';

  @override
  String get addVaccination => 'Impfung hinzufügen';

  @override
  String get searchVaccinations => 'Impfungen suchen';

  @override
  String get searchVaccinationsHint => 'Impfungen suchen';

  @override
  String get searchVaccinationsStart => 'Tippe, um nach Impfnamen zu suchen.';

  @override
  String get searchVaccinationsNoMatches => 'Keine passenden Impfungen gefunden.';

  @override
  String get addShot => 'Impfdosis hinzufügen';

  @override
  String get editVaccination => 'Impfung bearbeiten';

  @override
  String get vaccinationName => 'Impfung';

  @override
  String get vaccinationDate => 'Impfdatum';

  @override
  String get nextVaccinationRequired => 'Nächste Impfung fällig';

  @override
  String get shotsRecorded => 'Erfasste Dosen';

  @override
  String get lastShot => 'Letzte Dosis';

  @override
  String get nextDue => 'Nächster Termin';

  @override
  String get overdue => 'Überfällig';

  @override
  String get dueSoon => 'Bald fällig';

  @override
  String get upToDate => 'Aktuell';

  @override
  String recordForUser(String username) {
    return 'Einträge für $username';
  }

  @override
  String get upcomingVaccinations => 'Bevorstehende Impfungen';

  @override
  String get overdueVaccinations => 'Überfällige Impfungen';

  @override
  String get vaccinationNameValidation => 'Bitte geben Sie einen Impfnamen ein.';

  @override
  String get vaccinationDateValidation => 'Bitte wählen Sie das Impfdatum aus.';

  @override
  String get nextVaccinationDateValidation => 'Bitte wählen Sie das Datum für die nächste Impfung aus.';

  @override
  String get nextVaccinationDateOrderValidation => 'Das Datum der nächsten Impfung muss nach dem Impfdatum liegen.';

  @override
  String get saveVaccinationSuccess => 'Impfung erfolgreich gespeichert.';

  @override
  String get chooseDate => 'Datum wählen';

  @override
  String shotNumber(int count) {
    return 'Dosis $count';
  }

  @override
  String get deleteVaccination => 'Dosis löschen';

  @override
  String deleteVaccinationConfirmation(int shotIndex, String vaccinationName) {
    return 'Dosis $shotIndex von $vaccinationName löschen?';
  }

  @override
  String get deleteVaccinationSuccess => 'Dosis gelöscht.';

  @override
  String get filterAll => 'Alle';

  @override
  String get filterOverdue => 'Überfällig';

  @override
  String get filterDueSoon => 'Bald fällig';

  @override
  String get filterUpToDate => 'Aktuell';

  @override
  String get noVaccinationsForFilter => 'Keine Impfserien entsprechen diesem Filter.';

  @override
  String get vaccinationModeLabel => 'Impfverlauf';

  @override
  String get vaccinationModeOneShot => 'Einmalimpfung';

  @override
  String get vaccinationModeMultiShot => 'Mehrfachimpfung';

  @override
  String get shotDatesLabel => 'Impftermine';

  @override
  String get addAnotherShot => 'Weiteren Termin hinzufügen';

  @override
  String get removeShot => 'Termin entfernen';

  @override
  String get plannedShot => 'Geplanter Termin';

  @override
  String get recordedShot => 'Erfasster Termin';

  @override
  String get vaccinationExpiresOn => 'Impfschutz gültig bis';

  @override
  String get vaccinationExpiresValidation => 'Bitte wählen Sie das Ablaufdatum des Impfschutzes aus.';

  @override
  String get vaccinationExpiresOrderValidation => 'Das Ablaufdatum muss am oder nach dem letzten Impftermin liegen.';

  @override
  String get shotDatesValidation => 'Bitte fügen Sie mindestens einen Impftermin hinzu.';

  @override
  String get duplicateShotDateValidation => 'Jeder Impftermin muss eindeutig sein.';

  @override
  String get switchToOneShotTitle => 'In Einmalimpfung umwandeln?';

  @override
  String switchToOneShotBody(int removedCount) {
    return 'Dabei werden $removedCount Termin(e) entfernt. Nur der aktuellste Termin bleibt erhalten.';
  }

  @override
  String get switchToOneShotConfirm => 'Umwandeln';

  @override
  String get switchToOneShotCancel => 'Mehrfachimpfung behalten';

  @override
  String get futureShotHint => 'Termine in der Zukunft sind erlaubt und werden als bevorstehende Erinnerungen gewertet.';
}
