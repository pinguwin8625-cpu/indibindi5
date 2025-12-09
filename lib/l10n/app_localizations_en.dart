// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'IndiBindi';

  @override
  String get home => 'Search';

  @override
  String get myBookings => 'My Bookings';

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
  String get selectRoute => 'Choose a route to get started';

  @override
  String get driver => 'Driver';

  @override
  String get rider => 'Rider';

  @override
  String get origin => 'Origin';

  @override
  String get destination => 'Destination';

  @override
  String get selectOrigin => 'Choose Origin';

  @override
  String get selectDestination => 'Choose Destination';

  @override
  String get departureTime => 'Departure Time';

  @override
  String get arrivalTime => 'Arrival Time';

  @override
  String get selectTime => 'Choose Time';

  @override
  String get seats => 'Seats';

  @override
  String get selectSeats => 'Choose Seats';

  @override
  String get chooseYourRoute => 'which route?';

  @override
  String get chooseYourSeats => 'Choose your seats';

  @override
  String get availableSeats => 'Available Seats';

  @override
  String get chooseYourSeat => 'Choose Your Seat';

  @override
  String get selectYourSeat => 'Select Your Seat';

  @override
  String get available => 'Available';

  @override
  String get unavailable => 'Unavailable';

  @override
  String seatsAvailable(int count) {
    return '$count seat(s) available';
  }

  @override
  String seatsSelected(int count) {
    return '$count Seat(s) Selected';
  }

  @override
  String get chooseYourStops => 'Choose Your Stops';

  @override
  String get pickUpTime => 'Pick-up';

  @override
  String get dropOffTime => 'Drop-off';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get done => 'Done';

  @override
  String get cancel => 'Cancel';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get jan => 'Jan';

  @override
  String get feb => 'Feb';

  @override
  String get mar => 'Mar';

  @override
  String get apr => 'Apr';

  @override
  String get may => 'May';

  @override
  String get jun => 'Jun';

  @override
  String get jul => 'Jul';

  @override
  String get aug => 'Aug';

  @override
  String get sep => 'Sep';

  @override
  String get oct => 'Oct';

  @override
  String get nov => 'Nov';

  @override
  String get dec => 'Dec';

  @override
  String get confirmBooking => 'Confirm Booking';

  @override
  String get bookingConfirmed => 'Booking Confirmed!';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get name => 'Name';

  @override
  String get surname => 'Surname';

  @override
  String get phoneNumber => 'Mobile Phone Number';

  @override
  String get email => 'Email Address';

  @override
  String get enterName => 'Enter your name';

  @override
  String get enterSurname => 'Enter your surname';

  @override
  String get enterPhone => 'Enter phone number';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get pleaseEnterSurname => 'Please enter your surname';

  @override
  String get pleaseEnterPhone => 'Please enter phone number';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get informationSaved => 'Information saved successfully!';

  @override
  String get vehicleInformation => 'Vehicle Information';

  @override
  String get brand => 'Brand';

  @override
  String get model => 'Model';

  @override
  String get color => 'Color';

  @override
  String get licensePlate => 'License Plate';

  @override
  String get selectBrand => 'Select brand';

  @override
  String get selectModel => 'Select model';

  @override
  String get selectColor => 'Select color';

  @override
  String get selectBrandFirst => 'Select a brand first';

  @override
  String get enterLicensePlate => 'Enter license plate';

  @override
  String examplePlate(String plate) {
    return 'Example: $plate';
  }

  @override
  String get pleaseSelectBrand => 'Please select a brand';

  @override
  String get pleaseEnterPlate => 'Please enter license plate';

  @override
  String get vehicleSaved => 'Vehicle information saved successfully!';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushNotificationsDesc =>
      'Receive notifications about ride updates';

  @override
  String get location => 'Location';

  @override
  String get locationServices => 'Location Services';

  @override
  String get locationServicesDesc => 'Allow app to access your location';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeDesc => 'Use dark theme';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String languageChanged(String language) {
    return 'Language changed to $language';
  }

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get data => 'Data';

  @override
  String get downloadMyData => 'Download My Data';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get clearCacheTitle => 'Clear Cache';

  @override
  String get clearCacheMessage =>
      'Are you sure you want to clear all cached data? This action cannot be undone.';

  @override
  String get cacheCleared => 'Cache cleared successfully';

  @override
  String get preparingData => 'Preparing your data for download...';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get rideHistory => 'Ride History';

  @override
  String get help => 'Help';

  @override
  String get faq => 'FAQ';

  @override
  String get support => 'Support';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get about => 'About';

  @override
  String get logout => 'Logout';

  @override
  String get clearMyBookings => 'Clear My Bookings';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get white => 'White';

  @override
  String get black => 'Black';

  @override
  String get silver => 'Silver';

  @override
  String get gray => 'Gray';

  @override
  String get red => 'Red';

  @override
  String get blue => 'Blue';

  @override
  String get green => 'Green';

  @override
  String get yellow => 'Yellow';

  @override
  String get orange => 'Orange';

  @override
  String get brown => 'Brown';

  @override
  String get beige => 'Beige';

  @override
  String get gold => 'Gold';

  @override
  String get purple => 'Purple';

  @override
  String get pink => 'Pink';

  @override
  String get turquoise => 'Turquoise';

  @override
  String get bronze => 'Bronze';

  @override
  String get maroon => 'Maroon';

  @override
  String get navyBlue => 'Navy Blue';

  @override
  String get other => 'Other';

  @override
  String get noBookingsYet => 'No bookings yet.';

  @override
  String get passenger => 'Rider';

  @override
  String get bookingCompleted => 'Booking Completed';

  @override
  String get completeBooking => 'Complete Booking';

  @override
  String get postRide => 'Post a Ride';

  @override
  String get ridePosted => 'Ride Posted';

  @override
  String get noAvailableSeats => 'No Available Seats';

  @override
  String get whenDoYouWantToTravel => 'When do you want to travel?';

  @override
  String get matchingRides => 'Matching Rides';

  @override
  String get withDriver => 'With';

  @override
  String get atTime => 'at';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get ongoing => 'Ongoing';

  @override
  String get archive => 'Archive';

  @override
  String get unarchive => 'Unarchive';

  @override
  String get canceledRides => 'Canceled';

  @override
  String get completed => 'Completed';

  @override
  String get canceled => 'Canceled';

  @override
  String get suggestRoute => 'Suggest a new route';

  @override
  String get suggestStop => 'Suggest a new stop';

  @override
  String get areYouDriverOrRider => 'are you a driver or a rider today?';

  @override
  String get pickUpAndDropOff => 'from?';

  @override
  String get chooseDropOffPoint => 'to?';

  @override
  String get tapSeatsToChangeAvailability => 'tap seats to toggle';

  @override
  String get setYourTime => 'time?';

  @override
  String get incompleteProfile => 'Incomplete Profile';

  @override
  String get incompleteVehicleInfo => 'Incomplete Vehicle Info';

  @override
  String get completeProfile => 'Complete Profile';

  @override
  String get addVehicle => 'Add Vehicle';

  @override
  String get completePersonalInfoForBooking =>
      'Please complete your personal information (name, surname, email, phone number) before booking a ride.';

  @override
  String get completePersonalInfoForPosting =>
      'Please complete your personal information (name, surname, email, phone number) before posting a ride.';

  @override
  String get completeVehicleInfoForPosting =>
      'Please complete your vehicle information (brand, model, color, license plate) before posting a ride.';

  @override
  String get noMatchingRidesFound => 'No matching rides found';

  @override
  String get tryAdjustingTimeOrRoute => 'Try adjusting your time or route';

  @override
  String get cannotBookOwnRide => 'You cannot book seats on your own ride';

  @override
  String get thisIsYourRide => 'This is your ride - you cannot book it';

  @override
  String get alreadyHaveRideScheduled =>
      'You already have a ride scheduled around this time';

  @override
  String get book => 'Book';

  @override
  String get booked => 'Booked';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get messagesWillAppear => 'Messages will appear when you book a ride';

  @override
  String get startConversation => 'Start a conversation!';

  @override
  String get pleaseLoginToViewMessages => 'Please log in to view messages';

  @override
  String get bookARide => 'Book a Ride';

  @override
  String get cancelRide => 'Cancel Ride';
}
