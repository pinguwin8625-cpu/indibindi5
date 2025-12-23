import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'providers/locale_provider.dart';
import 'services/auth_service.dart';
import 'services/booking_storage.dart';
import 'services/messaging_service.dart';
import 'services/rating_service.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure bookings and messages are loaded before app starts
  await BookingStorage().ensureLoaded();
  await MessagingService().ensureLoaded();
  await RatingService().ensureLoaded();

  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const IndibindiApp(),
    ),
  );
}

class IndibindiApp extends StatelessWidget {
  const IndibindiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    print(
      '🌍 MaterialApp rebuilding with locale: ${localeProvider.locale.languageCode}',
    );

    return MaterialApp(
      title: 'indibindi',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.red,
        primaryColor: Color(0xFFDD2C00), // Use custom red as primary color
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFDD2C00), width: 2),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        primaryColor: Color(0xFFDD2C00),
        scaffoldBackgroundColor: Color(0xFF121212),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardColor: Color(0xFF1E1E1E),
        dividerColor: Colors.grey[800],
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFDD2C00), width: 2),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      themeMode: ThemeMode.system, // Follow system theme
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('tr'), // Turkish
        Locale('es'), // Spanish
        Locale('fr'), // French
        Locale('de'), // German
        Locale('it'), // Italian
        Locale('pt'), // Portuguese
        Locale('ru'), // Russian
        Locale('zh'), // Chinese
        Locale('ja'), // Japanese
        Locale('ko'), // Korean
        Locale('ar'), // Arabic
      ],
      home: AuthService.isLoggedIn
          ? (AuthService.currentUser?.isAdmin == true
              ? const MainScreen(initialIndex: 3)
              : const MainScreen())
          : const AuthScreen(),
    );
  }
}
