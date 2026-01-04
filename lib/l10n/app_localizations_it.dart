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
  String get inbox => 'Posta in Arrivo';

  @override
  String get account => 'Account';

  @override
  String get uploadPhoto => 'Carica Foto';

  @override
  String get changePhoto => 'Cambia Foto';

  @override
  String get camera => 'Fotocamera';

  @override
  String get gallery => 'Galleria';

  @override
  String get takePhoto => 'Scatta Foto';

  @override
  String get chooseFromGallery => 'Scegli dalla Galleria';

  @override
  String get removePhoto => 'Rimuovi Foto';

  @override
  String get selectRoute => 'Seleziona un percorso per iniziare';

  @override
  String get selectRouteTitle => 'Select Route';

  @override
  String get selectStops => 'Select Stops';

  @override
  String get findRides => 'Find Rides';

  @override
  String get screenTitleRole => 'Role';

  @override
  String get screenTitleRoute => 'Route';

  @override
  String get screenTitleStopsTime => 'Stops & Time';

  @override
  String get screenTitleSeat => 'Seats';

  @override
  String get seatsHelperText =>
      'Tap seats to mark them available/unavailable for riders. (All available by default!)';

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
  String get chooseYourRoute => 'quale percorso?';

  @override
  String get chooseYourSeats => 'Scegli i tuoi posti';

  @override
  String get availableSeats => 'null posti disponibili';

  @override
  String get chooseYourSeat => 'Scegli il tuo posto';

  @override
  String get selectYourSeat => 'Seleziona il tuo posto';

  @override
  String get available => 'Disponibile';

  @override
  String get unavailable => 'Non Disponibile';

  @override
  String seatsAvailable(int count) {
    return 'posti disponibili';
  }

  @override
  String seatsSelected(int count) {
    return '$count posti selezionati';
  }

  @override
  String get chooseYourStops => 'Scegli Le Tue Fermate';

  @override
  String get pickUpTime => 'Inizio';

  @override
  String get dropOffTime => 'Fine';

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
  String get help => 'Aiuto';

  @override
  String get faq => 'FAQ';

  @override
  String get support => 'Supporto';

  @override
  String get helpAndSupport => 'Aiuto e Supporto';

  @override
  String get about => 'Informazioni';

  @override
  String get logout => 'Esci';

  @override
  String get clearMyBookings => 'Cancella Le Mie Prenotazioni';

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
  String get postRide => 'Pubblica Corsa';

  @override
  String get ridePosted => 'Corsa Pubblicata';

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

  @override
  String get areYouDriverOrRider => 'sei autista o passeggero oggi?';

  @override
  String get pickUpAndDropOff => 'da?';

  @override
  String get hintFromStop => 'scegli la tua fermata di partenza';

  @override
  String get chooseDropOffPoint => 'a?';

  @override
  String get hintToStop => 'scegli la tua fermata di arrivo';

  @override
  String get tapSeatsToChangeAvailability => 'tocca per modificare';

  @override
  String get setYourTime => 'ora?';

  @override
  String get hintTime => 'scegli un orario di partenza o arrivo';

  @override
  String get incompleteProfile => 'Profilo Incompleto';

  @override
  String get incompleteVehicleInfo => 'Info Veicolo Incompleta';

  @override
  String get completeProfile => 'Completa Profilo';

  @override
  String get addVehicle => 'Aggiungi Veicolo';

  @override
  String get completePersonalInfoForBooking =>
      'Completa le tue informazioni personali (nome, cognome, email, telefono) prima di prenotare una corsa.';

  @override
  String get completePersonalInfoForPosting =>
      'Completa le tue informazioni personali (nome, cognome, email, telefono) prima di pubblicare una corsa.';

  @override
  String get completeVehicleInfoForPosting =>
      'Completa le informazioni del veicolo (marca, modello, colore, targa) prima di pubblicare una corsa.';

  @override
  String get noMatchingRidesFound => 'Nessuna corsa corrispondente trovata';

  @override
  String get tryAdjustingTimeOrRoute =>
      'Prova a modificare l\'orario o il percorso';

  @override
  String get cannotBookOwnRide => 'Non puoi prenotare posti sulla tua corsa';

  @override
  String get thisIsYourRide => 'Questa è la tua corsa - non puoi prenotarla';

  @override
  String get alreadyHaveRideScheduled =>
      'Hai già una corsa programmata a quest\'ora';

  @override
  String get book => 'Prenota';

  @override
  String get booked => 'Prenotato';

  @override
  String get noMessagesYet => 'Nessun messaggio ancora';

  @override
  String get messagesWillAppear =>
      'I messaggi appariranno quando prenoterai una corsa';

  @override
  String get startConversation => 'Inizia una conversazione!';

  @override
  String get pleaseLoginToViewMessages => 'Accedi per visualizzare i messaggi';

  @override
  String get bookARide => 'Prenota una Corsa';

  @override
  String get cancelRide => 'Annulla Corsa';

  @override
  String get archived => 'Archiviati';

  @override
  String get autoArchived => 'Archiviato automaticamente';

  @override
  String get userArchived => 'Archiviato';

  @override
  String get message => 'Messaggio';

  @override
  String get rate => 'Valuta';

  @override
  String get yourRating => 'La Tua Valutazione:';

  @override
  String rateUser(String userName) {
    return 'Valuta $userName';
  }

  @override
  String get selectQualitiesThatApply => 'Seleziona le qualità applicabili';

  @override
  String get submitRating => 'Invia Valutazione';

  @override
  String get safe => 'Sicuro';

  @override
  String get punctual => 'Puntuale';

  @override
  String get clean => 'Pulito';

  @override
  String get polite => 'Educato';

  @override
  String get communicative => 'Comunicativo';

  @override
  String get suggestion => 'Suggestion';

  @override
  String get complaint => 'Complaint';

  @override
  String get question => 'Question';

  @override
  String get delete => 'Delete';

  @override
  String get conversationArchived => 'Conversazione archiviata';

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
      'vuoi pubblicare un passaggio? scegli autista! o vuoi salire? scegli passeggero!';

  @override
  String get hintRoleSelectionLine1 =>
      'do you want to post a ride? choose driver!';

  @override
  String get hintRoleSelectionOr => 'or';

  @override
  String get hintRoleSelectionLine2 =>
      'do you want to get on a ride? choose rider!';

  @override
  String get hintRouteSelection => 'seleziona il percorso che percorrerai';

  @override
  String get hintOriginSelection => 'scegli la tua fermata di partenza';

  @override
  String get hintDestinationSelection => 'scegli la tua fermata di arrivo';

  @override
  String get hintTimeSelection => 'scegli un orario di partenza o arrivo';

  @override
  String get hintSeatSelectionDriver =>
      'tocca i posti per renderli disponibili ai passeggeri';

  @override
  String get hintSeatSelectionRider => 'tocca un posto per prenotare il tuo';

  @override
  String get hintMatchingRides =>
      'questi autisti corrispondono al tuo percorso e orario';

  @override
  String get hintPostRide => 'rivedi e conferma i dettagli del tuo viaggio';

  @override
  String systemNotificationDriverCanceled(String driverName, String routeName) {
    return '$driverName ha annullato il viaggio su $routeName';
  }

  @override
  String systemNotificationRiderCanceled(String riderName) {
    return '$riderName ha annullato la prenotazione';
  }

  @override
  String systemNotificationNewRider(String riderName, String driverName) {
    return '$riderName ha prenotato un posto nel viaggio di $driverName';
  }

  @override
  String systemNotificationRiderBooked(String riderName, String driverName) {
    return '$riderName ha prenotato un posto nel viaggio di $driverName';
  }

  @override
  String get snackbarAdminViewOnly =>
      'Gli amministratori possono solo visualizzare i messaggi, non inviarli';

  @override
  String get snackbarMessagingExpired =>
      'Il periodo di messaggistica è scaduto (3 giorni dopo l\'arrivo)';

  @override
  String get snackbarPleaseLoginToSuggestStop =>
      'Accedi per suggerire una fermata';

  @override
  String get snackbarPleaseLoginToSuggestRoute =>
      'Accedi per suggerire un percorso';

  @override
  String get snackbarCannotBookOwnRideDetail =>
      'Non puoi prenotare un posto nel tuo stesso viaggio. Questo è contro i nostri regolamenti.';

  @override
  String get snackbarAlreadyBookedThisRide =>
      'Hai già prenotato questo viaggio';

  @override
  String snackbarConflictingBooking(String routeName) {
    return 'Hai una prenotazione in conflitto a quest\'ora: $routeName';
  }

  @override
  String snackbarSwitchedToUser(String userName) {
    return 'Passato a $userName';
  }

  @override
  String get snackbarBookingsCleared =>
      'Tutte le prenotazioni sono state cancellate';

  @override
  String get snackbarConversationsCleared =>
      'Tutte le conversazioni sono state cancellate';

  @override
  String get snackbarRatingsCleared =>
      'Tutte le valutazioni sono state cancellate';

  @override
  String snackbarAlreadyRated(String userName) {
    return 'Hai già valutato $userName per questo viaggio';
  }

  @override
  String snackbarRatingSubmitted(String rating, String userName) {
    return 'Valutazione inviata: $rating stelle per $userName';
  }

  @override
  String snackbarCopiedToClipboard(String label) {
    return '$label copiato negli appunti';
  }

  @override
  String get snackbarCannotMessageYourself =>
      'Non puoi inviare un messaggio a te stesso';

  @override
  String snackbarErrorOpeningChat(String error) {
    return 'Errore nell\'apertura della chat di supporto: $error';
  }

  @override
  String get snackbarConversationRestored => 'Conversazione ripristinata';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get Started';

  @override
  String get introWelcomeTitle => 'Welcome to IndiBindi';

  @override
  String get introWelcomeSubtitle => 'Share rides, save money, travel together';

  @override
  String get introDriverTitle => 'Offer Rides';

  @override
  String get introDriverSubtitle =>
      'Post your journey and share costs with fellow travelers';

  @override
  String get introRiderTitle => 'Find Rides';

  @override
  String get introRiderSubtitle =>
      'Discover available rides and travel together';

  @override
  String get walkthroughRoleTitle => 'Choose Your Role';

  @override
  String get walkthroughRoleDescription =>
      'Select Driver to post rides or Rider to find rides. You can switch between roles anytime.';

  @override
  String get walkthroughRouteTitle => 'Select Your Route';

  @override
  String get walkthroughRouteDescription =>
      'Choose your route, then pick your origin and destination stops along the way.';

  @override
  String get walkthroughBookingTitle => 'Set Your Journey';

  @override
  String get walkthroughBookingDescription =>
      'Pick your travel date and time. Drivers can set available seats, riders can book them.';

  @override
  String get walkthroughMyBookingsTitle => 'Manage Bookings';

  @override
  String get walkthroughMyBookingsDescription =>
      'View and manage your upcoming, ongoing, and completed rides all in one place.';

  @override
  String get walkthroughMessagingTitle => 'Stay Connected';

  @override
  String get walkthroughMessagingDescription =>
      'Chat with drivers and riders to coordinate your trip and share updates.';

  @override
  String get tutorialSearchTitle1 => 'Choose Your Role';

  @override
  String get tutorialSearchDesc1 =>
      'Tap Driver to offer rides, or Rider to find and book rides. You can switch anytime!';

  @override
  String get tutorialSearchTitle2 => 'Select Route & Stops';

  @override
  String get tutorialSearchDesc2 =>
      'Pick your travel route, then choose your origin and destination stops.';

  @override
  String get tutorialSearchTitle3 => 'Set Time & Seats';

  @override
  String get tutorialSearchDesc3 =>
      'Choose when you want to travel. Drivers set available seats, riders select their seat.';

  @override
  String get tutorialBookingsTitle1 => 'Your Rides';

  @override
  String get tutorialBookingsDesc1 =>
      'View all your upcoming, ongoing, and completed rides in one place.';

  @override
  String get tutorialBookingsTitle2 => 'Manage Bookings';

  @override
  String get tutorialBookingsDesc2 =>
      'Tap any ride to see details, message participants, or cancel if needed.';

  @override
  String get tutorialInboxTitle1 => 'Your Messages';

  @override
  String get tutorialInboxDesc1 =>
      'Chat with drivers and riders to coordinate pickup details and share updates.';

  @override
  String get tutorialInboxTitle2 => 'Get Support';

  @override
  String get tutorialInboxDesc2 =>
      'Need help? Use the support options to ask questions or share feedback.';
}
