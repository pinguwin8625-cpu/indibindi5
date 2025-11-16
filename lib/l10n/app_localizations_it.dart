// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'IndiBindi';

  @override
  String get home => 'Home';

  @override
  String get myBookings => 'Le Mie Prenotazioni';

  @override
  String get inbox => 'Inbox';

  @override
  String get account => 'Account';

  @override
  String get uploadPhoto => 'Upload Photo';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get selectRoute => 'Seleziona un percorso per iniziare';

  @override
  String get driver => 'Autista';

  @override
  String get rider => 'Passeggero';

  @override
  String get origin => 'Partenza';

  @override
  String get destination => 'Destinazione';

  @override
  String get selectOrigin => 'Seleziona Partenza';

  @override
  String get selectDestination => 'Seleziona Destinazione';

  @override
  String get departureTime => 'Orario di Partenza';

  @override
  String get arrivalTime => 'Orario di Arrivo';

  @override
  String get selectTime => 'Seleziona Orario';

  @override
  String get seats => 'Posti';

  @override
  String get selectSeats => 'Scegli Posti';

  @override
  String get chooseYourRoute => 'Scegli Il Tuo Percorso';

  @override
  String get chooseYourSeats => 'Scegli i tuoi posti';

  @override
  String get availableSeats => 'Available Seats';

  @override
  String get chooseYourSeat => 'Choose Your Seat';

  @override
  String get selectYourSeat => 'Select your seat';

  @override
  String seatsAvailable(int count) {
    return '$count seat(s) available';
  }

  @override
  String seatsSelected(int count) {
    return '$count seat(s) selected';
  }

  @override
  String get chooseYourStops => 'Scegli Le Tue Fermate';

  @override
  String get pickUpTime => 'Orario di Ritiro';

  @override
  String get dropOffTime => 'Orario di Consegna';

  @override
  String get today => 'Oggi';

  @override
  String get tomorrow => 'Domani';

  @override
  String get done => 'Fatto';

  @override
  String get cancel => 'Annulla';

  @override
  String get mon => 'Lun';

  @override
  String get tue => 'Mar';

  @override
  String get wed => 'Mer';

  @override
  String get thu => 'Gio';

  @override
  String get fri => 'Ven';

  @override
  String get sat => 'Sab';

  @override
  String get sun => 'Dom';

  @override
  String get jan => 'Gen';

  @override
  String get feb => 'Feb';

  @override
  String get mar => 'Mar';

  @override
  String get apr => 'Apr';

  @override
  String get may => 'Mag';

  @override
  String get jun => 'Giu';

  @override
  String get jul => 'Lug';

  @override
  String get aug => 'Ago';

  @override
  String get sep => 'Set';

  @override
  String get oct => 'Ott';

  @override
  String get nov => 'Nov';

  @override
  String get dec => 'Dic';

  @override
  String get confirmBooking => 'Conferma Prenotazione';

  @override
  String get bookingConfirmed => 'Prenotazione Confermata!';

  @override
  String get back => 'Indietro';

  @override
  String get next => 'Avanti';

  @override
  String get save => 'Salva';

  @override
  String get saved => 'Salvato';

  @override
  String get personalInformation => 'Informazioni Personali';

  @override
  String get name => 'Nome';

  @override
  String get surname => 'Cognome';

  @override
  String get phoneNumber => 'Numero di Telefono';

  @override
  String get email => 'Indirizzo Email';

  @override
  String get enterName => 'Inserisci il tuo nome';

  @override
  String get enterSurname => 'Inserisci il tuo cognome';

  @override
  String get enterPhone => 'Inserisci numero di telefono';

  @override
  String get enterEmail => 'Inserisci la tua email';

  @override
  String get pleaseEnterName => 'Per favore inserisci il tuo nome';

  @override
  String get pleaseEnterSurname => 'Per favore inserisci il tuo cognome';

  @override
  String get pleaseEnterPhone => 'Per favore inserisci numero di telefono';

  @override
  String get pleaseEnterValidEmail => 'Per favore inserisci un\'email valida';

  @override
  String get informationSaved => 'Informazioni salvate con successo!';

  @override
  String get vehicleInformation => 'Informazioni Veicolo';

  @override
  String get brand => 'Marca';

  @override
  String get model => 'Modello';

  @override
  String get color => 'Colore';

  @override
  String get licensePlate => 'Targa';

  @override
  String get selectBrand => 'Seleziona marca';

  @override
  String get selectModel => 'Seleziona modello';

  @override
  String get selectColor => 'Seleziona colore';

  @override
  String get selectBrandFirst => 'Seleziona prima una marca';

  @override
  String get enterLicensePlate => 'Inserisci targa';

  @override
  String examplePlate(String plate) {
    return 'Esempio: $plate';
  }

  @override
  String get pleaseSelectBrand => 'Per favore seleziona una marca';

  @override
  String get pleaseEnterPlate => 'Per favore inserisci targa';

  @override
  String get vehicleSaved => 'Informazioni veicolo salvate con successo!';

  @override
  String get settings => 'Impostazioni';

  @override
  String get notifications => 'Notifiche';

  @override
  String get pushNotifications => 'Notifiche Push';

  @override
  String get pushNotificationsDesc =>
      'Ricevi notifiche sugli aggiornamenti del viaggio';

  @override
  String get location => 'Posizione';

  @override
  String get locationServices => 'Servizi di Localizzazione';

  @override
  String get locationServicesDesc =>
      'Consenti all\'app di accedere alla tua posizione';

  @override
  String get appearance => 'Aspetto';

  @override
  String get darkMode => 'Modalità Scura';

  @override
  String get darkModeDesc => 'Usa tema scuro';

  @override
  String get language => 'Lingua';

  @override
  String get selectLanguage => 'Seleziona Lingua';

  @override
  String languageChanged(String language) {
    return 'Lingua cambiata in $language';
  }

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyPolicy => 'Informativa sulla Privacy';

  @override
  String get termsOfService => 'Termini di Servizio';

  @override
  String get data => 'Dati';

  @override
  String get downloadMyData => 'Scarica i Miei Dati';

  @override
  String get clearCache => 'Cancella Cache';

  @override
  String get clearCacheTitle => 'Cancella Cache';

  @override
  String get clearCacheMessage =>
      'Sei sicuro di voler cancellare tutti i dati memorizzati? Questa azione non può essere annullata.';

  @override
  String get cacheCleared => 'Cache cancellata con successo';

  @override
  String get preparingData => 'Preparazione dei tuoi dati per il download...';

  @override
  String version(String version) {
    return 'Versione $version';
  }

  @override
  String get rideHistory => 'Storico Viaggi';

  @override
  String get help => 'Help';

  @override
  String get faq => 'FAQ';

  @override
  String get support => 'Support';

  @override
  String get helpAndSupport => 'Aiuto e Supporto';

  @override
  String get about => 'Informazioni';

  @override
  String get logout => 'Esci';

  @override
  String get deleteAccount => 'Elimina Account';

  @override
  String get white => 'Bianco';

  @override
  String get black => 'Nero';

  @override
  String get silver => 'Argento';

  @override
  String get gray => 'Grigio';

  @override
  String get red => 'Rosso';

  @override
  String get blue => 'Blu';

  @override
  String get green => 'Verde';

  @override
  String get yellow => 'Giallo';

  @override
  String get orange => 'Arancione';

  @override
  String get brown => 'Marrone';

  @override
  String get beige => 'Beige';

  @override
  String get gold => 'Oro';

  @override
  String get purple => 'Viola';

  @override
  String get pink => 'Rosa';

  @override
  String get turquoise => 'Turchese';

  @override
  String get bronze => 'Bronzo';

  @override
  String get maroon => 'Marrone scuro';

  @override
  String get navyBlue => 'Blu Navy';

  @override
  String get other => 'Altro';

  @override
  String get noBookingsYet => 'Nessuna prenotazione ancora.';

  @override
  String get passenger => 'Passeggero';

  @override
  String get bookingCompleted => 'Prenotazione Completata';

  @override
  String get completeBooking => 'Completa Prenotazione';

  @override
  String get noAvailableSeats => 'Nessun Posto Disponibile';

  @override
  String get whenDoYouWantToTravel => 'Quando vuoi viaggiare?';

  @override
  String get matchingRides => 'Corse Corrispondenti';

  @override
  String get withDriver => 'Con';

  @override
  String get atTime => 'alle';

  @override
  String get upcoming => 'Prossimi';

  @override
  String get ongoing => 'In Corso';

  @override
  String get archive => 'Archivio';

  @override
  String get unarchive => 'Disarchivia';

  @override
  String get canceledRides => 'Cancellati';

  @override
  String get completed => 'Completato';

  @override
  String get canceled => 'Cancellato';

  @override
  String get suggestRoute => 'Suggerisci un nuovo percorso';

  @override
  String get suggestStop => 'Suggerisci una nuova fermata';
}
