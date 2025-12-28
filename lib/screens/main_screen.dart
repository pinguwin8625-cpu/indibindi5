import 'package:flutter/material.dart';
import 'search_screen.dart';
import 'my_bookings_screen.dart';
import 'inbox_screen.dart';
import 'account_screen.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/messaging_service.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  int _bookingsTabIndex = 0; // Track which bookings tab to show
  final GlobalKey<MyBookingsScreenState> _myBookingsKey =
      GlobalKey<MyBookingsScreenState>();
  final GlobalKey<SearchScreenState> _searchScreenKey =
      GlobalKey<SearchScreenState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // Start at the specified index
  }

  void _switchToBookings({int tabIndex = 0}) {
    setState(() {
      _currentIndex = 1;
      _bookingsTabIndex = tabIndex;
    });

    // After navigation, switch to the appropriate tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _myBookingsKey.currentState?.switchToTab(tabIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUserId = AuthService.currentUser?.id ?? '';
    final messagingService = MessagingService();

    // Rebuild screens list each build so InboxScreen gets fresh key when user changes
    final screens = [
      SearchScreen(
        key: _searchScreenKey,
        onBookingCompleted: _switchToBookings,
      ),
      MyBookingsScreen(
        key: _myBookingsKey,
        initialTabIndex: _bookingsTabIndex,
      ),
      InboxScreen(
        key: ValueKey('inbox_$currentUserId'),
      ),
      AccountScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Reset search screen when tapping search tab (either from another screen or while already on it)
          if (index == 0) {
            _searchScreenKey.currentState?.resetBookingLayers();
          }

          setState(() {
            _currentIndex = index;
            // Reset bookings tab to driver when manually navigating to bookings
            if (index == 1) {
              _bookingsTabIndex = 0;
            }
          });
        },
        selectedItemColor: Color(0xFFDD2C00),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: l10n.home),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_seat),
            label: l10n.myBookings,
          ),
          BottomNavigationBarItem(
            icon: _buildInboxIcon(messagingService, currentUserId),
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

  Widget _buildInboxIcon(MessagingService messagingService, String userId) {
    return ValueListenableBuilder(
      valueListenable: messagingService.conversations,
      builder: (context, _, __) {
        final unreadCount = messagingService.getTotalUnreadCount(userId);
        
        if (unreadCount == 0) {
          return Icon(Icons.mail_outline);
        }
        
        return Badge(
          label: Text(
            unreadCount > 99 ? '99+' : unreadCount.toString(),
            style: TextStyle(fontSize: 10, color: Colors.white),
          ),
          child: Icon(Icons.mail_outline),
        );
      },
    );
  }
}
