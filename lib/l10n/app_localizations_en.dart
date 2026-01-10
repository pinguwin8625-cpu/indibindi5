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
  String get chooseYourSeats => 'tap seats to edit';

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
  String get pickUpTime => 'Start';

  @override
  String get dropOffTime => 'End';

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
  String get chooseASeatOnMatchingRides => 'Choose a Seat';

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
  String get hintFromStop => 'choose your starting stop';

  @override
  String get chooseDropOffPoint => 'to?';

  @override
  String get hintToStop => 'choose your ending stop';

  @override
  String get tapSeatsToChangeAvailability => 'tap seats to toggle';

  @override
  String get setYourTime => 'when?';

  @override
  String get hintTime => 'choose a starting or ending time';

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

  @override
  String get archived => 'Archived';

  @override
  String get autoArchived => 'Auto-archived';

  @override
  String get userArchived => 'Archived';

  @override
  String get message => 'Message';

  @override
  String get rate => 'Rate';

  @override
  String get yourRating => 'Your Rating:';

  @override
  String rateUser(String userName) {
    return 'Rate $userName';
  }

  @override
  String get selectQualitiesThatApply => 'Select the qualities that apply';

  @override
  String get submitRating => 'Submit Rating';

  @override
  String get safe => 'Safe';

  @override
  String get punctual => 'Punctual';

  @override
  String get clean => 'Clean';

  @override
  String get polite => 'Polite';

  @override
  String get communicative => 'Communicative';

  @override
  String get suggestion => 'Suggestion';

  @override
  String get complaint => 'Complaint';

  @override
  String get question => 'Question';

  @override
  String get delete => 'Delete';

  @override
  String get conversationArchived => 'Conversation archived';

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
      'do you want to post a ride? choose driver! or do you want to get on a ride? choose rider!';

  @override
  String get hintRoleSelectionLine1 =>
      'do you want to post a ride? choose driver!';

  @override
  String get hintRoleSelectionOr => 'or';

  @override
  String get hintRoleSelectionLine2 =>
      'do you want to get on a ride? choose rider!';

  @override
  String get hintRouteSelection => 'select the route you\'ll be traveling on';

  @override
  String get hintOriginSelection => 'choose your starting stop';

  @override
  String get hintDestinationSelection => 'choose your ending stop';

  @override
  String get hintTimeSelection => 'choose a starting or ending time';

  @override
  String get hintSeatSelectionDriver => 'Tap seats to edit availability';

  @override
  String get hintSeatSelectionRider => 'tap a seat to reserve your spot';

  @override
  String get hintMatchingRides => 'these drivers match your route and time';

  @override
  String get hintPostRide => 'review and confirm your ride details';

  @override
  String systemNotificationDriverCanceled(String driverName, String routeName) {
    return '$driverName has canceled the ride on $routeName';
  }

  @override
  String systemNotificationRiderCanceled(String riderName) {
    return '$riderName has canceled their booking';
  }

  @override
  String systemNotificationNewRider(String riderName, String driverName) {
    return '$riderName booked a seat on $driverName\'s ride';
  }

  @override
  String systemNotificationRiderBooked(String riderName, String driverName) {
    return '$riderName booked a seat on $driverName\'s ride';
  }

  @override
  String get snackbarAdminViewOnly =>
      'Admins can only view messages, not send them';

  @override
  String get snackbarMessagingExpired =>
      'Messaging period has expired (3 days after arrival)';

  @override
  String get snackbarPleaseLoginToSuggestStop =>
      'Please login to suggest a stop';

  @override
  String get snackbarPleaseLoginToSuggestRoute =>
      'Please login to suggest a route';

  @override
  String get snackbarCannotBookOwnRideDetail =>
      'You cannot book a seat on your own ride. This is against our regulations.';

  @override
  String get snackbarAlreadyBookedThisRide =>
      'You have already booked this ride';

  @override
  String snackbarConflictingBooking(String routeName) {
    return 'You have a conflicting booking at this time: $routeName';
  }

  @override
  String snackbarSwitchedToUser(String userName) {
    return 'Switched to $userName';
  }

  @override
  String get snackbarBookingsCleared => 'All bookings have been cleared';

  @override
  String get snackbarConversationsCleared =>
      'All conversations have been cleared';

  @override
  String get snackbarRatingsCleared => 'All ratings have been cleared';

  @override
  String snackbarAlreadyRated(String userName) {
    return 'You have already rated $userName for this trip';
  }

  @override
  String snackbarRatingSubmitted(String rating, String userName) {
    return 'Rating submitted: $rating stars for $userName';
  }

  @override
  String snackbarCopiedToClipboard(String label) {
    return '$label copied to clipboard';
  }

  @override
  String get snackbarCannotMessageYourself => 'Cannot message yourself';

  @override
  String snackbarErrorOpeningChat(String error) {
    return 'Error opening support chat: $error';
  }

  @override
  String get snackbarConversationRestored => 'Conversation restored';

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
