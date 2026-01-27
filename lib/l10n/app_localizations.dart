import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

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
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('zh'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'IndiBindi'**
  String get appTitle;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get home;

  /// My Bookings tab label
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// Inbox tab label
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inbox;

  /// Account tab label
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Upload profile photo button
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhoto;

  /// Change profile photo button
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// Camera option
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// Gallery option
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// Take photo with camera
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Choose from gallery
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Remove profile photo
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// Prompt to choose a route
  ///
  /// In en, this message translates to:
  /// **'Choose a route to get started'**
  String get selectRoute;

  /// App bar title for route selection screen
  ///
  /// In en, this message translates to:
  /// **'Select Route'**
  String get selectRouteTitle;

  /// App bar title for stops selection screen
  ///
  /// In en, this message translates to:
  /// **'Select Stops'**
  String get selectStops;

  /// App bar title for matching rides screen
  ///
  /// In en, this message translates to:
  /// **'Find Rides'**
  String get findRides;

  /// App bar title for role selection screen
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get screenTitleRole;

  /// App bar title for route selection screen
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get screenTitleRoute;

  /// App bar title for stops and time selection screen
  ///
  /// In en, this message translates to:
  /// **'Stops & Time'**
  String get screenTitleStopsTime;

  /// App bar title for seat selection screen
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get screenTitleSeat;

  /// Helper text for seat selection screen
  ///
  /// In en, this message translates to:
  /// **'Tap seats to mark them available/unavailable for riders. (All available by default!)'**
  String get seatsHelperText;

  /// Driver role label
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// Rider role label
  ///
  /// In en, this message translates to:
  /// **'Rider'**
  String get rider;

  /// Starting point label
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get origin;

  /// Ending point label
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// Prompt to choose origin
  ///
  /// In en, this message translates to:
  /// **'Choose Origin'**
  String get selectOrigin;

  /// Prompt to choose destination
  ///
  /// In en, this message translates to:
  /// **'Choose Destination'**
  String get selectDestination;

  /// Departure time label
  ///
  /// In en, this message translates to:
  /// **'Departure Time'**
  String get departureTime;

  /// Arrival time label
  ///
  /// In en, this message translates to:
  /// **'Arrival Time'**
  String get arrivalTime;

  /// Button to choose time
  ///
  /// In en, this message translates to:
  /// **'Choose Time'**
  String get selectTime;

  /// Seats label
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get seats;

  /// Prompt to choose seats
  ///
  /// In en, this message translates to:
  /// **'Choose Seats'**
  String get selectSeats;

  /// Title for route selection
  ///
  /// In en, this message translates to:
  /// **'which route?'**
  String get chooseYourRoute;

  /// Title for seat selection
  ///
  /// In en, this message translates to:
  /// **'tap seats to edit'**
  String get chooseYourSeats;

  /// Title for driver's available seats
  ///
  /// In en, this message translates to:
  /// **'Available Seats'**
  String get availableSeats;

  /// Title for rider's seat selection
  ///
  /// In en, this message translates to:
  /// **'Choose Your Seat'**
  String get chooseYourSeat;

  /// Instruction for rider to select a seat
  ///
  /// In en, this message translates to:
  /// **'Select Your Seat'**
  String get selectYourSeat;

  /// Word for available (used in brackets)
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// Word for unavailable seats
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// Number of seats available for driver
  ///
  /// In en, this message translates to:
  /// **'{count} seat(s) available'**
  String seatsAvailable(int count);

  /// Number of seats selected by rider
  ///
  /// In en, this message translates to:
  /// **'{count} Seat(s) Selected'**
  String seatsSelected(int count);

  /// Title for stops selection
  ///
  /// In en, this message translates to:
  /// **'Choose Your Stops'**
  String get chooseYourStops;

  /// Start time label
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get pickUpTime;

  /// End time label
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get dropOffTime;

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Tomorrow label
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @jan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get jan;

  /// No description provided for @feb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get feb;

  /// No description provided for @mar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get mar;

  /// No description provided for @apr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get apr;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @jun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get jun;

  /// No description provided for @jul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get jul;

  /// No description provided for @aug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get aug;

  /// No description provided for @sep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get sep;

  /// No description provided for @oct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get oct;

  /// No description provided for @nov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get nov;

  /// No description provided for @dec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get dec;

  /// Confirm booking button
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// Booking confirmation message
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed!'**
  String get bookingConfirmed;

  /// Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Saved status
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// Personal Information screen title
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Surname field label
  ///
  /// In en, this message translates to:
  /// **'Surname'**
  String get surname;

  /// Mobile phone number field label
  ///
  /// In en, this message translates to:
  /// **'Mobile Phone Number'**
  String get phoneNumber;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email;

  /// Name field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterName;

  /// Surname field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your surname'**
  String get enterSurname;

  /// Phone field hint
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhone;

  /// Email field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// Name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// Surname validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your surname'**
  String get pleaseEnterSurname;

  /// Phone validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get pleaseEnterPhone;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// Success message after saving
  ///
  /// In en, this message translates to:
  /// **'Information saved successfully!'**
  String get informationSaved;

  /// Vehicle Information screen title
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get vehicleInformation;

  /// Vehicle brand label
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// Vehicle model label
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// Vehicle color label
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// License plate label
  ///
  /// In en, this message translates to:
  /// **'License Plate'**
  String get licensePlate;

  /// Brand dropdown hint
  ///
  /// In en, this message translates to:
  /// **'Select brand'**
  String get selectBrand;

  /// Model dropdown hint
  ///
  /// In en, this message translates to:
  /// **'Select model'**
  String get selectModel;

  /// Color dropdown hint
  ///
  /// In en, this message translates to:
  /// **'Select color'**
  String get selectColor;

  /// Model dropdown disabled hint
  ///
  /// In en, this message translates to:
  /// **'Select a brand first'**
  String get selectBrandFirst;

  /// License plate field hint
  ///
  /// In en, this message translates to:
  /// **'Enter license plate'**
  String get enterLicensePlate;

  /// License plate example
  ///
  /// In en, this message translates to:
  /// **'Example: {plate}'**
  String examplePlate(String plate);

  /// Brand validation error
  ///
  /// In en, this message translates to:
  /// **'Please select a brand'**
  String get pleaseSelectBrand;

  /// Plate validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter license plate'**
  String get pleaseEnterPlate;

  /// Success message after saving vehicle
  ///
  /// In en, this message translates to:
  /// **'Vehicle information saved successfully!'**
  String get vehicleSaved;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Notifications section header
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Push notifications setting
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// Push notifications description
  ///
  /// In en, this message translates to:
  /// **'Receive notifications about ride updates'**
  String get pushNotificationsDesc;

  /// Location section header
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Location services setting
  ///
  /// In en, this message translates to:
  /// **'Location Services'**
  String get locationServices;

  /// Location services description
  ///
  /// In en, this message translates to:
  /// **'Allow app to access your location'**
  String get locationServicesDesc;

  /// Appearance section header
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Dark mode setting
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Dark mode description
  ///
  /// In en, this message translates to:
  /// **'Use dark theme'**
  String get darkModeDesc;

  /// Language section header and setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language selector title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Language change confirmation
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChanged(String language);

  /// Privacy section header
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// Privacy policy menu item
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Terms of service menu item
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Data section header
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// Download data menu item
  ///
  /// In en, this message translates to:
  /// **'Download My Data'**
  String get downloadMyData;

  /// Clear cache menu item
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// Clear cache dialog title
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCacheTitle;

  /// Clear cache dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all cached data? This action cannot be undone.'**
  String get clearCacheMessage;

  /// Cache cleared confirmation
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheCleared;

  /// Download data message
  ///
  /// In en, this message translates to:
  /// **'Preparing your data for download...'**
  String get preparingData;

  /// App version display
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// Ride history menu item
  ///
  /// In en, this message translates to:
  /// **'Ride History'**
  String get rideHistory;

  /// Help menu item
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Frequently Asked Questions
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// Support menu item
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// Help and support menu item
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// About menu item
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Logout menu item
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Clear my bookings menu item
  ///
  /// In en, this message translates to:
  /// **'Clear My Bookings'**
  String get clearMyBookings;

  /// Delete account menu item
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @white.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get white;

  /// No description provided for @black.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get black;

  /// No description provided for @silver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get silver;

  /// No description provided for @gray.
  ///
  /// In en, this message translates to:
  /// **'Gray'**
  String get gray;

  /// No description provided for @red.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get red;

  /// No description provided for @blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blue;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get green;

  /// No description provided for @yellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get yellow;

  /// No description provided for @orange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get orange;

  /// No description provided for @brown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get brown;

  /// No description provided for @beige.
  ///
  /// In en, this message translates to:
  /// **'Beige'**
  String get beige;

  /// No description provided for @gold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get gold;

  /// No description provided for @purple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get purple;

  /// No description provided for @pink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get pink;

  /// No description provided for @turquoise.
  ///
  /// In en, this message translates to:
  /// **'Turquoise'**
  String get turquoise;

  /// No description provided for @bronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get bronze;

  /// No description provided for @maroon.
  ///
  /// In en, this message translates to:
  /// **'Maroon'**
  String get maroon;

  /// No description provided for @navyBlue.
  ///
  /// In en, this message translates to:
  /// **'Navy Blue'**
  String get navyBlue;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Message shown when user has no bookings
  ///
  /// In en, this message translates to:
  /// **'No bookings yet.'**
  String get noBookingsYet;

  /// Rider label for seat occupants
  ///
  /// In en, this message translates to:
  /// **'Rider'**
  String get passenger;

  /// Button text when booking is completed
  ///
  /// In en, this message translates to:
  /// **'Booking Completed'**
  String get bookingCompleted;

  /// Button text to complete a booking
  ///
  /// In en, this message translates to:
  /// **'Complete Booking'**
  String get completeBooking;

  /// Button text for driver to post a ride
  ///
  /// In en, this message translates to:
  /// **'Post a Ride'**
  String get postRide;

  /// Button text after driver successfully posts a ride
  ///
  /// In en, this message translates to:
  /// **'Ride Posted'**
  String get ridePosted;

  /// Message when no seats are available
  ///
  /// In en, this message translates to:
  /// **'No Available Seats'**
  String get noAvailableSeats;

  /// Question about travel time
  ///
  /// In en, this message translates to:
  /// **'When do you want to travel?'**
  String get whenDoYouWantToTravel;

  /// Title for matching rides list
  ///
  /// In en, this message translates to:
  /// **'Matching Rides'**
  String get matchingRides;

  /// Main title for matching rides screen
  ///
  /// In en, this message translates to:
  /// **'Choose a Seat'**
  String get chooseASeatOnMatchingRides;

  /// Preposition for showing driver name
  ///
  /// In en, this message translates to:
  /// **'With'**
  String get withDriver;

  /// Preposition for showing time
  ///
  /// In en, this message translates to:
  /// **'at'**
  String get atTime;

  /// Upcoming bookings section title
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// Ongoing rides section title
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// Current rides section title (upcoming + ongoing)
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// Archive section title for old bookings
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// Unarchive button text
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchive;

  /// Canceled section title
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get canceledRides;

  /// Completed status label
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Canceled status label
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get canceled;

  /// Link text to suggest a new route
  ///
  /// In en, this message translates to:
  /// **'Suggest a new route'**
  String get suggestRoute;

  /// Link text to suggest a new stop
  ///
  /// In en, this message translates to:
  /// **'Suggest a new stop'**
  String get suggestStop;

  /// Question to choose role
  ///
  /// In en, this message translates to:
  /// **'are you a driver or a rider today?'**
  String get areYouDriverOrRider;

  /// Title for pick up stop selection screen
  ///
  /// In en, this message translates to:
  /// **'from?'**
  String get pickUpAndDropOff;

  /// Hint text for from stop selection
  ///
  /// In en, this message translates to:
  /// **'choose your starting stop'**
  String get hintFromStop;

  /// Title for drop off stop selection screen
  ///
  /// In en, this message translates to:
  /// **'to?'**
  String get chooseDropOffPoint;

  /// Hint text for to stop selection
  ///
  /// In en, this message translates to:
  /// **'choose your ending stop'**
  String get hintToStop;

  /// Hint text for driver seat selection
  ///
  /// In en, this message translates to:
  /// **'tap seats to toggle'**
  String get tapSeatsToChangeAvailability;

  /// Title for time selection
  ///
  /// In en, this message translates to:
  /// **'when?'**
  String get setYourTime;

  /// Hint text for time selection
  ///
  /// In en, this message translates to:
  /// **'choose a starting or ending time'**
  String get hintTime;

  /// Dialog title for incomplete profile
  ///
  /// In en, this message translates to:
  /// **'Incomplete Profile'**
  String get incompleteProfile;

  /// Dialog title for incomplete vehicle info
  ///
  /// In en, this message translates to:
  /// **'Incomplete Vehicle Info'**
  String get incompleteVehicleInfo;

  /// Button to complete profile
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get completeProfile;

  /// Button to add vehicle
  ///
  /// In en, this message translates to:
  /// **'Add Vehicle'**
  String get addVehicle;

  /// Message for incomplete personal info for riders
  ///
  /// In en, this message translates to:
  /// **'Please complete your personal information (name, surname, email, phone number) before booking a ride.'**
  String get completePersonalInfoForBooking;

  /// Message for incomplete personal info for drivers
  ///
  /// In en, this message translates to:
  /// **'Please complete your personal information (name, surname, email, phone number) before posting a ride.'**
  String get completePersonalInfoForPosting;

  /// Message for incomplete vehicle info for drivers
  ///
  /// In en, this message translates to:
  /// **'Please complete your vehicle information (brand, model, color, license plate) before posting a ride.'**
  String get completeVehicleInfoForPosting;

  /// Message when no rides match criteria
  ///
  /// In en, this message translates to:
  /// **'No matching rides found'**
  String get noMatchingRidesFound;

  /// Suggestion when no matching rides
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your time or route'**
  String get tryAdjustingTimeOrRoute;

  /// Error message when trying to book own ride
  ///
  /// In en, this message translates to:
  /// **'You cannot book seats on your own ride'**
  String get cannotBookOwnRide;

  /// Info message shown on user's own ride
  ///
  /// In en, this message translates to:
  /// **'This is your ride - you cannot book it'**
  String get thisIsYourRide;

  /// Error message for time conflict
  ///
  /// In en, this message translates to:
  /// **'You already have a ride scheduled around this time'**
  String get alreadyHaveRideScheduled;

  /// Book button text
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// Booked status text
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get booked;

  /// Pending booking status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Empty inbox message
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// Empty inbox helper text
  ///
  /// In en, this message translates to:
  /// **'Messages will appear when you book a ride'**
  String get messagesWillAppear;

  /// Prompt to start chatting
  ///
  /// In en, this message translates to:
  /// **'Start a conversation!'**
  String get startConversation;

  /// Login prompt for inbox
  ///
  /// In en, this message translates to:
  /// **'Please log in to view messages'**
  String get pleaseLoginToViewMessages;

  /// Title for ride booking screen
  ///
  /// In en, this message translates to:
  /// **'Book a Ride'**
  String get bookARide;

  /// Button to cancel a ride booking
  ///
  /// In en, this message translates to:
  /// **'Cancel Ride'**
  String get cancelRide;

  /// Label for archived messages section
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// Label for automatically archived bookings (after 3 days)
  ///
  /// In en, this message translates to:
  /// **'Auto-archived'**
  String get autoArchived;

  /// Label for manually archived bookings by user
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get userArchived;

  /// Message button text
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// Rate button text
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// Label for user's given rating
  ///
  /// In en, this message translates to:
  /// **'Your Rating:'**
  String get yourRating;

  /// Title for rating dialog
  ///
  /// In en, this message translates to:
  /// **'Rate {userName}'**
  String rateUser(String userName);

  /// Subtitle for rating selection
  ///
  /// In en, this message translates to:
  /// **'Select the qualities that apply'**
  String get selectQualitiesThatApply;

  /// Submit rating button text
  ///
  /// In en, this message translates to:
  /// **'Submit Rating'**
  String get submitRating;

  /// Safe rating category
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get safe;

  /// Punctual rating category
  ///
  /// In en, this message translates to:
  /// **'Punctual'**
  String get punctual;

  /// Clean rating category
  ///
  /// In en, this message translates to:
  /// **'Clean'**
  String get clean;

  /// Polite rating category
  ///
  /// In en, this message translates to:
  /// **'Polite'**
  String get polite;

  /// Communicative rating category
  ///
  /// In en, this message translates to:
  /// **'Communicative'**
  String get communicative;

  /// Support message type - suggestion
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get suggestion;

  /// Support message type - complaint
  ///
  /// In en, this message translates to:
  /// **'Complaint'**
  String get complaint;

  /// Support message type - ask a question
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// Delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Message when conversation is archived
  ///
  /// In en, this message translates to:
  /// **'Conversation archived'**
  String get conversationArchived;

  /// Message when conversation is unarchived
  ///
  /// In en, this message translates to:
  /// **'Conversation unarchived'**
  String get conversationUnarchived;

  /// Message when conversation is deleted
  ///
  /// In en, this message translates to:
  /// **'Conversation deleted'**
  String get conversationDeleted;

  /// Undo action
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Support message type - new route suggestion
  ///
  /// In en, this message translates to:
  /// **'New Route Suggestion'**
  String get newRouteSuggestion;

  /// Support message type - new stop suggestion
  ///
  /// In en, this message translates to:
  /// **'New Stop Suggestion'**
  String get newStopSuggestion;

  /// Hint for role selection screen
  ///
  /// In en, this message translates to:
  /// **'do you want to post a ride? choose driver! or do you want to get on a ride? choose rider!'**
  String get hintRoleSelection;

  /// First line of role selection hint
  ///
  /// In en, this message translates to:
  /// **'do you want to post a ride? choose driver!'**
  String get hintRoleSelectionLine1;

  /// Or text between role selection hints
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get hintRoleSelectionOr;

  /// Second line of role selection hint
  ///
  /// In en, this message translates to:
  /// **'do you want to get on a ride? choose rider!'**
  String get hintRoleSelectionLine2;

  /// Hint for route selection
  ///
  /// In en, this message translates to:
  /// **'select the route you\'ll be traveling on'**
  String get hintRouteSelection;

  /// Hint for origin stop selection
  ///
  /// In en, this message translates to:
  /// **'choose your starting stop'**
  String get hintOriginSelection;

  /// Hint for destination stop selection
  ///
  /// In en, this message translates to:
  /// **'choose your ending stop'**
  String get hintDestinationSelection;

  /// Hint for time selection
  ///
  /// In en, this message translates to:
  /// **'choose a starting or ending time'**
  String get hintTimeSelection;

  /// Hint for driver seat selection
  ///
  /// In en, this message translates to:
  /// **'Tap seats to edit availability'**
  String get hintSeatSelectionDriver;

  /// Hint for rider seat selection
  ///
  /// In en, this message translates to:
  /// **'tap a seat to reserve your spot'**
  String get hintSeatSelectionRider;

  /// Hint for matching rides list
  ///
  /// In en, this message translates to:
  /// **'these drivers match your route and time'**
  String get hintMatchingRides;

  /// Hint for posting a ride
  ///
  /// In en, this message translates to:
  /// **'review and confirm your ride details'**
  String get hintPostRide;

  /// System notification when driver cancels a ride
  ///
  /// In en, this message translates to:
  /// **'{driverName} has canceled the ride on {routeName}'**
  String systemNotificationDriverCanceled(String driverName, String routeName);

  /// System notification when rider cancels their booking
  ///
  /// In en, this message translates to:
  /// **'{riderName} has canceled their booking'**
  String systemNotificationRiderCanceled(String riderName);

  /// System notification when a new rider books a seat (shown to driver)
  ///
  /// In en, this message translates to:
  /// **'{riderName} booked a seat on {driverName}\'s ride'**
  String systemNotificationNewRider(String riderName, String driverName);

  /// System notification shown to rider after booking a seat
  ///
  /// In en, this message translates to:
  /// **'{riderName} booked a seat on {driverName}\'s ride'**
  String systemNotificationRiderBooked(String riderName, String driverName);

  /// System notification shown when rider messages driver before booking
  ///
  /// In en, this message translates to:
  /// **'{riderName} contacted {driverName}'**
  String systemNotificationPreBooking(String riderName, String driverName);

  /// Snackbar shown when admin tries to send message in view mode
  ///
  /// In en, this message translates to:
  /// **'Admins can only view messages, not send them'**
  String get snackbarAdminViewOnly;

  /// Snackbar shown when messaging period has expired
  ///
  /// In en, this message translates to:
  /// **'Messaging period has expired (3 days after arrival)'**
  String get snackbarMessagingExpired;

  /// Snackbar shown when user tries to suggest stop without login
  ///
  /// In en, this message translates to:
  /// **'Please login to suggest a stop'**
  String get snackbarPleaseLoginToSuggestStop;

  /// Snackbar shown when user tries to suggest route without login
  ///
  /// In en, this message translates to:
  /// **'Please login to suggest a route'**
  String get snackbarPleaseLoginToSuggestRoute;

  /// Detailed snackbar when trying to book own ride
  ///
  /// In en, this message translates to:
  /// **'You cannot book a seat on your own ride. This is against our regulations.'**
  String get snackbarCannotBookOwnRideDetail;

  /// Snackbar when user has already booked the same ride
  ///
  /// In en, this message translates to:
  /// **'You have already booked this ride'**
  String get snackbarAlreadyBookedThisRide;

  /// Snackbar when booking conflicts with another
  ///
  /// In en, this message translates to:
  /// **'You have a conflicting booking at this time: {routeName}'**
  String snackbarConflictingBooking(String routeName);

  /// Snackbar when switching test user
  ///
  /// In en, this message translates to:
  /// **'Switched to {userName}'**
  String snackbarSwitchedToUser(String userName);

  /// Snackbar after clearing all bookings
  ///
  /// In en, this message translates to:
  /// **'All bookings have been cleared'**
  String get snackbarBookingsCleared;

  /// Snackbar after clearing all conversations
  ///
  /// In en, this message translates to:
  /// **'All conversations have been cleared'**
  String get snackbarConversationsCleared;

  /// Snackbar after clearing all ratings
  ///
  /// In en, this message translates to:
  /// **'All ratings have been cleared'**
  String get snackbarRatingsCleared;

  /// Snackbar when user already rated someone
  ///
  /// In en, this message translates to:
  /// **'You have already rated {userName} for this trip'**
  String snackbarAlreadyRated(String userName);

  /// Snackbar after submitting rating
  ///
  /// In en, this message translates to:
  /// **'Rating submitted: {rating} stars for {userName}'**
  String snackbarRatingSubmitted(String rating, String userName);

  /// Snackbar when text is copied
  ///
  /// In en, this message translates to:
  /// **'{label} copied to clipboard'**
  String snackbarCopiedToClipboard(String label);

  /// Snackbar when trying to message yourself
  ///
  /// In en, this message translates to:
  /// **'Cannot message yourself'**
  String get snackbarCannotMessageYourself;

  /// Snackbar when chat fails to open
  ///
  /// In en, this message translates to:
  /// **'Error opening support chat: {error}'**
  String snackbarErrorOpeningChat(String error);

  /// Snackbar when conversation is unarchived
  ///
  /// In en, this message translates to:
  /// **'Conversation restored'**
  String get snackbarConversationRestored;

  /// Skip button for onboarding
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Get started button for onboarding
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// App intro slide 1 title
  ///
  /// In en, this message translates to:
  /// **'Welcome to IndiBindi'**
  String get introWelcomeTitle;

  /// App intro slide 1 subtitle
  ///
  /// In en, this message translates to:
  /// **'Share rides, save money, travel together'**
  String get introWelcomeSubtitle;

  /// App intro slide 2 title
  ///
  /// In en, this message translates to:
  /// **'Offer Rides'**
  String get introDriverTitle;

  /// App intro slide 2 subtitle
  ///
  /// In en, this message translates to:
  /// **'Post your journey and share costs with fellow travelers'**
  String get introDriverSubtitle;

  /// App intro slide 3 title
  ///
  /// In en, this message translates to:
  /// **'Find Rides'**
  String get introRiderTitle;

  /// App intro slide 3 subtitle
  ///
  /// In en, this message translates to:
  /// **'Discover available rides and travel together'**
  String get introRiderSubtitle;

  /// Feature walkthrough slide 1 title
  ///
  /// In en, this message translates to:
  /// **'Choose Your Role'**
  String get walkthroughRoleTitle;

  /// Feature walkthrough slide 1 description
  ///
  /// In en, this message translates to:
  /// **'Select Driver to post rides or Rider to find rides. You can switch between roles anytime.'**
  String get walkthroughRoleDescription;

  /// Feature walkthrough slide 2 title
  ///
  /// In en, this message translates to:
  /// **'Select Your Route'**
  String get walkthroughRouteTitle;

  /// Feature walkthrough slide 2 description
  ///
  /// In en, this message translates to:
  /// **'Choose your route, then pick your origin and destination stops along the way.'**
  String get walkthroughRouteDescription;

  /// Feature walkthrough slide 3 title
  ///
  /// In en, this message translates to:
  /// **'Set Your Journey'**
  String get walkthroughBookingTitle;

  /// Feature walkthrough slide 3 description
  ///
  /// In en, this message translates to:
  /// **'Pick your travel date and time. Drivers can set available seats, riders can book them.'**
  String get walkthroughBookingDescription;

  /// Feature walkthrough slide 4 title
  ///
  /// In en, this message translates to:
  /// **'Manage Bookings'**
  String get walkthroughMyBookingsTitle;

  /// Feature walkthrough slide 4 description
  ///
  /// In en, this message translates to:
  /// **'View and manage your upcoming, ongoing, and completed rides all in one place.'**
  String get walkthroughMyBookingsDescription;

  /// Feature walkthrough slide 5 title
  ///
  /// In en, this message translates to:
  /// **'Stay Connected'**
  String get walkthroughMessagingTitle;

  /// Feature walkthrough slide 5 description
  ///
  /// In en, this message translates to:
  /// **'Chat with drivers and riders to coordinate your trip and share updates.'**
  String get walkthroughMessagingDescription;

  /// Search screen tutorial step 1 title
  ///
  /// In en, this message translates to:
  /// **'Choose Your Role'**
  String get tutorialSearchTitle1;

  /// Search screen tutorial step 1 description
  ///
  /// In en, this message translates to:
  /// **'Tap Driver to offer rides, or Rider to find and book rides. You can switch anytime!'**
  String get tutorialSearchDesc1;

  /// Search screen tutorial step 2 title
  ///
  /// In en, this message translates to:
  /// **'Select Route & Stops'**
  String get tutorialSearchTitle2;

  /// Search screen tutorial step 2 description
  ///
  /// In en, this message translates to:
  /// **'Pick your travel route, then choose your origin and destination stops.'**
  String get tutorialSearchDesc2;

  /// Search screen tutorial step 3 title
  ///
  /// In en, this message translates to:
  /// **'Set Time & Seats'**
  String get tutorialSearchTitle3;

  /// Search screen tutorial step 3 description
  ///
  /// In en, this message translates to:
  /// **'Choose when you want to travel. Drivers set available seats, riders select their seat.'**
  String get tutorialSearchDesc3;

  /// Bookings screen tutorial step 1 title
  ///
  /// In en, this message translates to:
  /// **'Your Rides'**
  String get tutorialBookingsTitle1;

  /// Bookings screen tutorial step 1 description
  ///
  /// In en, this message translates to:
  /// **'View all your upcoming, ongoing, and completed rides in one place.'**
  String get tutorialBookingsDesc1;

  /// Bookings screen tutorial step 2 title
  ///
  /// In en, this message translates to:
  /// **'Manage Bookings'**
  String get tutorialBookingsTitle2;

  /// Bookings screen tutorial step 2 description
  ///
  /// In en, this message translates to:
  /// **'Tap any ride to see details, message participants, or cancel if needed.'**
  String get tutorialBookingsDesc2;

  /// Inbox screen tutorial step 1 title
  ///
  /// In en, this message translates to:
  /// **'Your Messages'**
  String get tutorialInboxTitle1;

  /// Inbox screen tutorial step 1 description
  ///
  /// In en, this message translates to:
  /// **'Chat with drivers and riders to coordinate pickup details and share updates.'**
  String get tutorialInboxDesc1;

  /// Inbox screen tutorial step 2 title
  ///
  /// In en, this message translates to:
  /// **'Get Support'**
  String get tutorialInboxTitle2;

  /// Inbox screen tutorial step 2 description
  ///
  /// In en, this message translates to:
  /// **'Need help? Use the support options to ask questions or share feedback.'**
  String get tutorialInboxDesc2;

  /// Button to make a seat available for riders
  ///
  /// In en, this message translates to:
  /// **'Make Available'**
  String get makeAvailable;

  /// Button to make a seat unavailable for riders
  ///
  /// In en, this message translates to:
  /// **'Make Unavailable'**
  String get makeUnavailable;

  /// Button to confirm seat availability changes
  ///
  /// In en, this message translates to:
  /// **'Update Seats'**
  String get updateSeats;

  /// Confirmation message when seats are updated
  ///
  /// In en, this message translates to:
  /// **'Seat availability updated'**
  String get seatsUpdated;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
