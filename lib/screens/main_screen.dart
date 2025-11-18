import 'package:flutter/material.dart';
import 'search_screen.dart';
import 'my_bookings_screen.dart';
import 'inbox_screen.dart';
import 'account_screen.dart';
import '../l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Start at Search screen (index 0)

  void _switchToBookings() {
    setState(() {
      _currentIndex = 1;
    });
  }

  late final List<Widget> _screens = [
    SearchScreen(onBookingCompleted: _switchToBookings),
    MyBookingsScreen(),
    InboxScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Color(0xFFDD2C00),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_seat),
            label: l10n.myBookings,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            label: l10n.inbox,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: l10n.account,
          ),
        ],
      ),
    );
  }
}
