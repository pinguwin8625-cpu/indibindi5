import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for app-wide settings that can be toggled by admin.
class AppSettingsProvider extends ChangeNotifier {
  static final AppSettingsProvider _instance = AppSettingsProvider._internal();
  factory AppSettingsProvider() => _instance;
  AppSettingsProvider._internal() {
    _loadSettings();
  }

  // Settings keys
  static const String _keyAllowMessagingBeforeBooking = 'allow_messaging_before_booking';

  // Settings values with defaults
  bool _allowMessagingBeforeBooking = true;

  /// Whether riders can message drivers before making a booking.
  /// When false, chevron on driver avatar in matching rides is hidden.
  bool get allowMessagingBeforeBooking => _allowMessagingBeforeBooking;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _allowMessagingBeforeBooking = prefs.getBool(_keyAllowMessagingBeforeBooking) ?? true;

    if (kDebugMode) {
      print('⚙️ AppSettings: Loaded - allowMessagingBeforeBooking=$_allowMessagingBeforeBooking');
    }
    notifyListeners();
  }

  Future<void> setAllowMessagingBeforeBooking(bool value) async {
    if (_allowMessagingBeforeBooking == value) return;

    _allowMessagingBeforeBooking = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAllowMessagingBeforeBooking, value);

    if (kDebugMode) {
      print('⚙️ AppSettings: Set allowMessagingBeforeBooking=$value');
    }
    notifyListeners();
  }
}
