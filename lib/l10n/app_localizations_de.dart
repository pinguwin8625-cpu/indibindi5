// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'IndiBindi';

  @override
  String get home => 'Startseite';

  @override
  String get myBookings => 'Meine Buchungen';

  @override
  String get inbox => 'Posteingang';

  @override
  String get account => 'Konto';

  @override
  String get uploadPhoto => 'Foto Hochladen';

  @override
  String get changePhoto => 'Foto Ändern';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galerie';

  @override
  String get takePhoto => 'Foto Aufnehmen';

  @override
  String get chooseFromGallery => 'Aus Galerie Wählen';

  @override
  String get removePhoto => 'Foto Entfernen';

  @override
  String get selectRoute => 'Wählen Sie eine Route zum Starten';

  @override
  String get driver => 'Fahrer';

  @override
  String get rider => 'Fahrgast';

  @override
  String get origin => 'Abfahrtsort';

  @override
  String get destination => 'Zielort';

  @override
  String get selectOrigin => 'Abfahrtsort Auswählen';

  @override
  String get selectDestination => 'Zielort Auswählen';

  @override
  String get departureTime => 'Abfahrtszeit';

  @override
  String get arrivalTime => 'Ankunftszeit';

  @override
  String get selectTime => 'Zeit Auswählen';

  @override
  String get seats => 'Sitze';

  @override
  String get selectSeats => 'Sitze Auswählen';

  @override
  String get chooseYourRoute => 'welche route?';

  @override
  String get chooseYourSeats => 'Wählen Sie Ihre Sitze';

  @override
  String get availableSeats => 'null Plätze verfügbar';

  @override
  String get chooseYourSeat => 'Wählen Sie Ihren Sitzplatz';

  @override
  String get selectYourSeat => 'Wählen Sie Ihren Sitzplatz';

  @override
  String get available => 'Verfügbar';

  @override
  String get unavailable => 'Nicht Verfügbar';

  @override
  String seatsAvailable(int count) {
    return 'Plätze verfügbar';
  }

  @override
  String seatsSelected(int count) {
    return '$count Plätze ausgewählt';
  }

  @override
  String get chooseYourStops => 'Wählen Sie Ihre Haltestellen';

  @override
  String get pickUpTime => 'Abholung';

  @override
  String get dropOffTime => 'Absetzung';

  @override
  String get today => 'Heute';

  @override
  String get tomorrow => 'Morgen';

  @override
  String get done => 'Fertig';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get mon => 'Mo';

  @override
  String get tue => 'Di';

  @override
  String get wed => 'Mi';

  @override
  String get thu => 'Do';

  @override
  String get fri => 'Fr';

  @override
  String get sat => 'Sa';

  @override
  String get sun => 'So';

  @override
  String get jan => 'Jan';

  @override
  String get feb => 'Feb';

  @override
  String get mar => 'Mär';

  @override
  String get apr => 'Apr';

  @override
  String get may => 'Mai';

  @override
  String get jun => 'Jun';

  @override
  String get jul => 'Jul';

  @override
  String get aug => 'Aug';

  @override
  String get sep => 'Sep';

  @override
  String get oct => 'Okt';

  @override
  String get nov => 'Nov';

  @override
  String get dec => 'Dez';

  @override
  String get confirmBooking => 'Buchung Bestätigen';

  @override
  String get bookingConfirmed => 'Buchung Bestätigt!';

  @override
  String get back => 'Zurück';

  @override
  String get next => 'Weiter';

  @override
  String get save => 'Speichern';

  @override
  String get saved => 'Gespeichert';

  @override
  String get personalInformation => 'Persönliche Informationen';

  @override
  String get name => 'Vorname';

  @override
  String get surname => 'Nachname';

  @override
  String get phoneNumber => 'Mobiltelefonnummer';

  @override
  String get email => 'E-Mail-Adresse';

  @override
  String get enterName => 'Geben Sie Ihren Vornamen ein';

  @override
  String get enterSurname => 'Geben Sie Ihren Nachnamen ein';

  @override
  String get enterPhone => 'Telefonnummer eingeben';

  @override
  String get enterEmail => 'Geben Sie Ihre E-Mail ein';

  @override
  String get pleaseEnterName => 'Bitte geben Sie Ihren Vornamen ein';

  @override
  String get pleaseEnterSurname => 'Bitte geben Sie Ihren Nachnamen ein';

  @override
  String get pleaseEnterPhone => 'Bitte Telefonnummer eingeben';

  @override
  String get pleaseEnterValidEmail => 'Bitte geben Sie eine gültige E-Mail ein';

  @override
  String get informationSaved => 'Informationen erfolgreich gespeichert!';

  @override
  String get vehicleInformation => 'Fahrzeuginformationen';

  @override
  String get brand => 'Marke';

  @override
  String get model => 'Modell';

  @override
  String get color => 'Farbe';

  @override
  String get licensePlate => 'Kennzeichen';

  @override
  String get selectBrand => 'Marke auswählen';

  @override
  String get selectModel => 'Modell auswählen';

  @override
  String get selectColor => 'Farbe auswählen';

  @override
  String get selectBrandFirst => 'Wählen Sie zuerst eine Marke';

  @override
  String get enterLicensePlate => 'Kennzeichen eingeben';

  @override
  String examplePlate(String plate) {
    return 'Beispiel: $plate';
  }

  @override
  String get pleaseSelectBrand => 'Bitte wählen Sie eine Marke';

  @override
  String get pleaseEnterPlate => 'Bitte Kennzeichen eingeben';

  @override
  String get vehicleSaved => 'Fahrzeuginformationen erfolgreich gespeichert!';

  @override
  String get settings => 'Einstellungen';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get pushNotifications => 'Push-Benachrichtigungen';

  @override
  String get pushNotificationsDesc =>
      'Benachrichtigungen über Fahrt-Updates erhalten';

  @override
  String get location => 'Standort';

  @override
  String get locationServices => 'Standortdienste';

  @override
  String get locationServicesDesc =>
      'Der App Zugriff auf Ihren Standort erlauben';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get darkModeDesc => 'Dunkles Theme verwenden';

  @override
  String get language => 'Sprache';

  @override
  String get selectLanguage => 'Sprache Auswählen';

  @override
  String languageChanged(String language) {
    return 'Sprache geändert zu $language';
  }

  @override
  String get privacy => 'Datenschutz';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get data => 'Daten';

  @override
  String get downloadMyData => 'Meine Daten Herunterladen';

  @override
  String get clearCache => 'Cache Leeren';

  @override
  String get clearCacheTitle => 'Cache Leeren';

  @override
  String get clearCacheMessage =>
      'Sind Sie sicher, dass Sie alle zwischengespeicherten Daten löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get cacheCleared => 'Cache erfolgreich geleert';

  @override
  String get preparingData => 'Ihre Daten werden zum Download vorbereitet...';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get rideHistory => 'Fahrtverlauf';

  @override
  String get help => 'Hilfe';

  @override
  String get faq => 'FAQ';

  @override
  String get support => 'Support';

  @override
  String get helpAndSupport => 'Hilfe und Support';

  @override
  String get about => 'Über';

  @override
  String get logout => 'Abmelden';

  @override
  String get clearMyBookings => 'Meine Buchungen Löschen';

  @override
  String get deleteAccount => 'Konto Löschen';

  @override
  String get white => 'Weiß';

  @override
  String get black => 'Schwarz';

  @override
  String get silver => 'Silber';

  @override
  String get gray => 'Grau';

  @override
  String get red => 'Rot';

  @override
  String get blue => 'Blau';

  @override
  String get green => 'Grün';

  @override
  String get yellow => 'Gelb';

  @override
  String get orange => 'Orange';

  @override
  String get brown => 'Braun';

  @override
  String get beige => 'Beige';

  @override
  String get gold => 'Gold';

  @override
  String get purple => 'Lila';

  @override
  String get pink => 'Rosa';

  @override
  String get turquoise => 'Türkis';

  @override
  String get bronze => 'Bronze';

  @override
  String get maroon => 'Kastanienbraun';

  @override
  String get navyBlue => 'Marineblau';

  @override
  String get other => 'Andere';

  @override
  String get noBookingsYet => 'Noch keine Buchungen.';

  @override
  String get passenger => 'Passagier';

  @override
  String get bookingCompleted => 'Buchung Abgeschlossen';

  @override
  String get completeBooking => 'Buchung Abschließen';

  @override
  String get postRide => 'Fahrt Veröffentlichen';

  @override
  String get ridePosted => 'Fahrt Veröffentlicht';

  @override
  String get noAvailableSeats => 'Keine Plätze Verfügbar';

  @override
  String get whenDoYouWantToTravel => 'Wann möchten Sie reisen?';

  @override
  String get matchingRides => 'Passende Fahrten';

  @override
  String get withDriver => 'Mit';

  @override
  String get atTime => 'um';

  @override
  String get upcoming => 'Bevorstehend';

  @override
  String get ongoing => 'Laufend';

  @override
  String get archive => 'Archiv';

  @override
  String get unarchive => 'Aus Archiv entfernen';

  @override
  String get canceledRides => 'Storniert';

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get canceled => 'Storniert';

  @override
  String get suggestRoute => 'Neue Route vorschlagen';

  @override
  String get suggestStop => 'Neue Haltestelle vorschlagen';

  @override
  String get areYouDriverOrRider => 'bist du heute fahrer oder mitfahrer?';

  @override
  String get pickUpAndDropOff => 'von?';

  @override
  String get chooseDropOffPoint => 'nach?';

  @override
  String get tapSeatsToChangeAvailability => 'sitze tippen zum ändern';

  @override
  String get setYourTime => 'zeit?';

  @override
  String get incompleteProfile => 'Unvollständiges Profil';

  @override
  String get incompleteVehicleInfo => 'Unvollständige Fahrzeuginfo';

  @override
  String get completeProfile => 'Profil vervollständigen';

  @override
  String get addVehicle => 'Fahrzeug hinzufügen';

  @override
  String get completePersonalInfoForBooking =>
      'Bitte vervollständigen Sie Ihre persönlichen Daten (Name, Nachname, E-Mail, Telefonnummer), bevor Sie eine Fahrt buchen.';

  @override
  String get completePersonalInfoForPosting =>
      'Bitte vervollständigen Sie Ihre persönlichen Daten (Name, Nachname, E-Mail, Telefonnummer), bevor Sie eine Fahrt veröffentlichen.';

  @override
  String get completeVehicleInfoForPosting =>
      'Bitte vervollständigen Sie Ihre Fahrzeugdaten (Marke, Modell, Farbe, Kennzeichen), bevor Sie eine Fahrt veröffentlichen.';

  @override
  String get noMatchingRidesFound => 'Keine passenden Fahrten gefunden';

  @override
  String get tryAdjustingTimeOrRoute =>
      'Versuchen Sie, Zeit oder Route anzupassen';

  @override
  String get cannotBookOwnRide =>
      'Sie können keine Plätze bei Ihrer eigenen Fahrt buchen';

  @override
  String get thisIsYourRide =>
      'Dies ist Ihre Fahrt - Sie können sie nicht buchen';

  @override
  String get alreadyHaveRideScheduled =>
      'Sie haben bereits eine Fahrt zu dieser Zeit geplant';

  @override
  String get book => 'Buchen';

  @override
  String get booked => 'Gebucht';

  @override
  String get noMessagesYet => 'Noch keine Nachrichten';

  @override
  String get messagesWillAppear =>
      'Nachrichten erscheinen, wenn Sie eine Fahrt buchen';

  @override
  String get startConversation => 'Starten Sie ein Gespräch!';

  @override
  String get pleaseLoginToViewMessages =>
      'Bitte melden Sie sich an, um Nachrichten zu sehen';

  @override
  String get bookARide => 'Fahrt Buchen';

  @override
  String get cancelRide => 'Fahrt Stornieren';

  @override
  String get archived => 'Archiviert';

  @override
  String get message => 'Nachricht';

  @override
  String get rate => 'Bewerten';

  @override
  String get yourRating => 'Ihre Bewertung:';

  @override
  String rateUser(String userName) {
    return '$userName bewerten';
  }

  @override
  String get selectQualitiesThatApply =>
      'Wählen Sie die zutreffenden Eigenschaften';

  @override
  String get submitRating => 'Bewertung abgeben';

  @override
  String get safe => 'Sicher';

  @override
  String get punctual => 'Pünktlich';

  @override
  String get clean => 'Sauber';

  @override
  String get polite => 'Höflich';

  @override
  String get communicative => 'Kommunikativ';

  @override
  String get suggestion => 'Suggestion';

  @override
  String get complaint => 'Complaint';

  @override
  String get question => 'Question';

  @override
  String get delete => 'Delete';

  @override
  String get conversationArchived => 'Konversation archiviert';

  @override
  String get conversationDeleted => 'Conversation deleted';

  @override
  String get undo => 'Undo';

  @override
  String get newRouteSuggestion => 'New Route Suggestion';

  @override
  String get newStopSuggestion => 'New Stop Suggestion';

  @override
  String get hintRoleSelection =>
      'Möchtest du eine Fahrt anbieten? Wähle Fahrer! Oder möchtest du mitfahren? Wähle Mitfahrer!';

  @override
  String get hintRouteSelection =>
      'wählen Sie die Route, auf der Sie reisen werden';

  @override
  String get hintOriginSelection => 'wo beginnt Ihre Reise?';

  @override
  String get hintDestinationSelection => 'wo endet Ihre Reise?';

  @override
  String get hintTimeSelection => 'wann planen Sie zu reisen?';

  @override
  String get hintSeatSelectionDriver =>
      'tippen Sie auf Sitze, um sie für Mitfahrer verfügbar zu machen';

  @override
  String get hintSeatSelectionRider =>
      'tippen Sie auf einen Sitz, um Ihren Platz zu reservieren';

  @override
  String get hintMatchingRides => 'diese Fahrer passen zu Ihrer Route und Zeit';

  @override
  String get hintPostRide => 'überprüfen und bestätigen Sie Ihre Fahrtdetails';

  @override
  String systemNotificationDriverCanceled(String driverName, String routeName) {
    return '$driverName hat die Fahrt auf $routeName storniert';
  }

  @override
  String systemNotificationRiderCanceled(String riderName) {
    return '$riderName hat die Buchung storniert';
  }

  @override
  String systemNotificationNewRider(String riderName, String driverName) {
    return '$riderName hat einen Platz bei ${driverName}s Fahrt gebucht';
  }

  @override
  String systemNotificationRiderBooked(String riderName, String driverName) {
    return '$riderName hat einen Platz bei ${driverName}s Fahrt gebucht';
  }

  @override
  String get snackbarAdminViewOnly =>
      'Administratoren können Nachrichten nur ansehen, nicht senden';

  @override
  String get snackbarMessagingExpired =>
      'Nachrichtenperiode abgelaufen (3 Tage nach Ankunft)';

  @override
  String get snackbarPleaseLoginToSuggestStop =>
      'Bitte anmelden, um eine Haltestelle vorzuschlagen';

  @override
  String get snackbarPleaseLoginToSuggestRoute =>
      'Bitte anmelden, um eine Route vorzuschlagen';

  @override
  String get snackbarCannotBookOwnRideDetail =>
      'Sie können keinen Platz bei Ihrer eigenen Fahrt buchen. Dies verstößt gegen unsere Regeln.';

  @override
  String get snackbarAlreadyBookedThisRide =>
      'Sie haben diese Fahrt bereits gebucht';

  @override
  String snackbarConflictingBooking(String routeName) {
    return 'Sie haben eine überschneidende Buchung zu dieser Zeit: $routeName';
  }

  @override
  String snackbarSwitchedToUser(String userName) {
    return 'Gewechselt zu $userName';
  }

  @override
  String get snackbarBookingsCleared => 'Alle Buchungen wurden gelöscht';

  @override
  String get snackbarConversationsCleared => 'Alle Gespräche wurden gelöscht';

  @override
  String get snackbarRatingsCleared => 'Alle Bewertungen wurden gelöscht';

  @override
  String snackbarAlreadyRated(String userName) {
    return 'Sie haben $userName für diese Fahrt bereits bewertet';
  }

  @override
  String snackbarRatingSubmitted(String rating, String userName) {
    return 'Bewertung abgegeben: $rating Sterne für $userName';
  }

  @override
  String snackbarCopiedToClipboard(String label) {
    return '$label in die Zwischenablage kopiert';
  }

  @override
  String get snackbarCannotMessageYourself =>
      'Sie können sich nicht selbst eine Nachricht senden';

  @override
  String snackbarErrorOpeningChat(String error) {
    return 'Fehler beim Öffnen des Support-Chats: $error';
  }

  @override
  String get snackbarConversationRestored => 'Gespräch wiederhergestellt';
}
