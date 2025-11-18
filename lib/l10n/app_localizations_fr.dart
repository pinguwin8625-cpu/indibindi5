// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'IndiBindi';

  @override
  String get home => 'Accueil';

  @override
  String get myBookings => 'Mes Réservations';

  @override
  String get inbox => 'Inbox';

  @override
  String get account => 'Compte';

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
  String get selectRoute => 'Sélectionnez un itinéraire pour commencer';

  @override
  String get driver => 'Conducteur';

  @override
  String get rider => 'Passager';

  @override
  String get origin => 'Origine';

  @override
  String get destination => 'Destination';

  @override
  String get selectOrigin => 'Sélectionner l\'Origine';

  @override
  String get selectDestination => 'Sélectionner la Destination';

  @override
  String get departureTime => 'Heure de Départ';

  @override
  String get arrivalTime => 'Heure d\'Arrivée';

  @override
  String get selectTime => 'Sélectionner l\'Heure';

  @override
  String get seats => 'Sièges';

  @override
  String get selectSeats => 'Choisir des Sièges';

  @override
  String get chooseYourRoute => 'Choisissez Votre Itinéraire';

  @override
  String get chooseYourSeats => 'Choisissez vos sièges';

  @override
  String get availableSeats => 'Available Seats';

  @override
  String get chooseYourSeat => 'Choose Your Seat';

  @override
  String get selectYourSeat => 'Select your seat';

  @override
  String get available => 'available';

  @override
  String seatsAvailable(int count) {
    return '$count seat(s) available';
  }

  @override
  String seatsSelected(int count) {
    return '$count seat(s) selected';
  }

  @override
  String get chooseYourStops => 'Choisissez Vos Arrêts';

  @override
  String get pickUpTime => 'Heure de Prise en Charge';

  @override
  String get dropOffTime => 'Heure de Dépose';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get tomorrow => 'Demain';

  @override
  String get done => 'Terminé';

  @override
  String get cancel => 'Annuler';

  @override
  String get mon => 'Lun';

  @override
  String get tue => 'Mar';

  @override
  String get wed => 'Mer';

  @override
  String get thu => 'Jeu';

  @override
  String get fri => 'Ven';

  @override
  String get sat => 'Sam';

  @override
  String get sun => 'Dim';

  @override
  String get jan => 'Jan';

  @override
  String get feb => 'Fév';

  @override
  String get mar => 'Mar';

  @override
  String get apr => 'Avr';

  @override
  String get may => 'Mai';

  @override
  String get jun => 'Juin';

  @override
  String get jul => 'Juil';

  @override
  String get aug => 'Août';

  @override
  String get sep => 'Sep';

  @override
  String get oct => 'Oct';

  @override
  String get nov => 'Nov';

  @override
  String get dec => 'Déc';

  @override
  String get confirmBooking => 'Confirmer la Réservation';

  @override
  String get bookingConfirmed => 'Réservation Confirmée!';

  @override
  String get back => 'Retour';

  @override
  String get next => 'Suivant';

  @override
  String get save => 'Enregistrer';

  @override
  String get saved => 'Enregistré';

  @override
  String get personalInformation => 'Informations Personnelles';

  @override
  String get name => 'Prénom';

  @override
  String get surname => 'Nom de Famille';

  @override
  String get phoneNumber => 'Numéro de Téléphone';

  @override
  String get email => 'Adresse E-mail';

  @override
  String get enterName => 'Entrez votre prénom';

  @override
  String get enterSurname => 'Entrez votre nom de famille';

  @override
  String get enterPhone => 'Entrez le numéro de téléphone';

  @override
  String get enterEmail => 'Entrez votre e-mail';

  @override
  String get pleaseEnterName => 'Veuillez entrer votre prénom';

  @override
  String get pleaseEnterSurname => 'Veuillez entrer votre nom de famille';

  @override
  String get pleaseEnterPhone => 'Veuillez entrer le numéro de téléphone';

  @override
  String get pleaseEnterValidEmail => 'Veuillez entrer un e-mail valide';

  @override
  String get informationSaved => 'Informations enregistrées avec succès!';

  @override
  String get vehicleInformation => 'Informations sur le Véhicule';

  @override
  String get brand => 'Marque';

  @override
  String get model => 'Modèle';

  @override
  String get color => 'Couleur';

  @override
  String get licensePlate => 'Plaque d\'Immatriculation';

  @override
  String get selectBrand => 'Sélectionner la marque';

  @override
  String get selectModel => 'Sélectionner le modèle';

  @override
  String get selectColor => 'Sélectionner la couleur';

  @override
  String get selectBrandFirst => 'Sélectionnez d\'abord une marque';

  @override
  String get enterLicensePlate => 'Entrez la plaque d\'immatriculation';

  @override
  String examplePlate(String plate) {
    return 'Exemple: $plate';
  }

  @override
  String get pleaseSelectBrand => 'Veuillez sélectionner une marque';

  @override
  String get pleaseEnterPlate => 'Veuillez entrer la plaque d\'immatriculation';

  @override
  String get vehicleSaved =>
      'Informations du véhicule enregistrées avec succès!';

  @override
  String get settings => 'Paramètres';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Notifications Push';

  @override
  String get pushNotificationsDesc =>
      'Recevoir des notifications sur les mises à jour de trajets';

  @override
  String get location => 'Localisation';

  @override
  String get locationServices => 'Services de Localisation';

  @override
  String get locationServicesDesc =>
      'Autoriser l\'application à accéder à votre position';

  @override
  String get appearance => 'Apparence';

  @override
  String get darkMode => 'Mode Sombre';

  @override
  String get darkModeDesc => 'Utiliser le thème sombre';

  @override
  String get language => 'Langue';

  @override
  String get selectLanguage => 'Sélectionner la Langue';

  @override
  String languageChanged(String language) {
    return 'Langue changée en $language';
  }

  @override
  String get privacy => 'Confidentialité';

  @override
  String get privacyPolicy => 'Politique de Confidentialité';

  @override
  String get termsOfService => 'Conditions d\'Utilisation';

  @override
  String get data => 'Données';

  @override
  String get downloadMyData => 'Télécharger Mes Données';

  @override
  String get clearCache => 'Vider le Cache';

  @override
  String get clearCacheTitle => 'Vider le Cache';

  @override
  String get clearCacheMessage =>
      'Êtes-vous sûr de vouloir effacer toutes les données en cache? Cette action ne peut pas être annulée.';

  @override
  String get cacheCleared => 'Cache vidé avec succès';

  @override
  String get preparingData =>
      'Préparation de vos données pour le téléchargement...';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get rideHistory => 'Historique des Trajets';

  @override
  String get help => 'Help';

  @override
  String get faq => 'FAQ';

  @override
  String get support => 'Support';

  @override
  String get helpAndSupport => 'Aide et Support';

  @override
  String get about => 'À Propos';

  @override
  String get logout => 'Se Déconnecter';

  @override
  String get deleteAccount => 'Supprimer le Compte';

  @override
  String get white => 'Blanc';

  @override
  String get black => 'Noir';

  @override
  String get silver => 'Argent';

  @override
  String get gray => 'Gris';

  @override
  String get red => 'Rouge';

  @override
  String get blue => 'Bleu';

  @override
  String get green => 'Vert';

  @override
  String get yellow => 'Jaune';

  @override
  String get orange => 'Orange';

  @override
  String get brown => 'Marron';

  @override
  String get beige => 'Beige';

  @override
  String get gold => 'Or';

  @override
  String get purple => 'Violet';

  @override
  String get pink => 'Rose';

  @override
  String get turquoise => 'Turquoise';

  @override
  String get bronze => 'Bronze';

  @override
  String get maroon => 'Bordeaux';

  @override
  String get navyBlue => 'Bleu Marine';

  @override
  String get other => 'Autre';

  @override
  String get noBookingsYet => 'Aucune réservation pour le moment.';

  @override
  String get passenger => 'Passager';

  @override
  String get bookingCompleted => 'Réservation Terminée';

  @override
  String get completeBooking => 'Terminer la Réservation';

  @override
  String get noAvailableSeats => 'Aucun Siège Disponible';

  @override
  String get whenDoYouWantToTravel => 'Quand voulez-vous voyager?';

  @override
  String get matchingRides => 'Trajets Correspondants';

  @override
  String get withDriver => 'Avec';

  @override
  String get atTime => 'à';

  @override
  String get upcoming => 'À venir';

  @override
  String get ongoing => 'En Cours';

  @override
  String get archive => 'Archives';

  @override
  String get unarchive => 'Désarchiver';

  @override
  String get canceledRides => 'Annulés';

  @override
  String get completed => 'Terminé';

  @override
  String get canceled => 'Annulé';

  @override
  String get suggestRoute => 'Suggérer un nouvel itinéraire';

  @override
  String get suggestStop => 'Suggérer un nouvel arrêt';
}
