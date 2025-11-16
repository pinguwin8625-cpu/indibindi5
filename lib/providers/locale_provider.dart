import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  
  Locale get locale => _locale;
  
  LocaleProvider() {
    _loadLocale();
  }
  
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }
  
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    print('🌍 LocaleProvider: Changing locale from ${_locale.languageCode} to ${locale.languageCode}');
    
    _locale = locale;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    
    print('🌍 LocaleProvider: Saved to SharedPreferences and notifying listeners');
    notifyListeners();
  }
  
  void clearLocale() {
    _locale = const Locale('en');
    notifyListeners();
  }
}
