import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/layered_booking_widget.dart';
import '../widgets/language_selector.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';

class SearchScreen extends StatefulWidget {
  final void Function({int tabIndex})? onBookingCompleted;

  const SearchScreen({super.key, this.onBookingCompleted});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _isLoading = true;
  bool _hasSelectedRole = false; // Shared role selection state
  Key _driverBookingKey = UniqueKey();
  Key _riderBookingKey = UniqueKey();
  BookingLayer _currentLayer = BookingLayer.routeSelection;

  void resetBookingLayers() {
    setState(() {
      _hasSelectedRole = false; // Reset role selection to show question first
      _driverBookingKey = UniqueKey();
      _riderBookingKey = UniqueKey();
      _currentLayer = BookingLayer.routeSelection;
    });
  }

  String _getScreenTitle(AppLocalizations l10n) {
    if (!_hasSelectedRole) {
      return l10n.screenTitleRole;
    }
    switch (_currentLayer) {
      case BookingLayer.routeSelection:
        return l10n.screenTitleRoute;
      case BookingLayer.stopsSelection:
        return l10n.screenTitleStopsTime;
      case BookingLayer.timeAndSeats:
      case BookingLayer.matchingRides:
        return l10n.screenTitleSeat;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadLastTab();
  }

  Future<void> _loadLastTab() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = AuthService.currentUser;

    int initialTab = 0;
    if (currentUser != null) {
      final key = 'last_tab_${currentUser.id}';
      initialTab = prefs.getInt(key) ?? 0;
    }

    setState(() {
      _tabController = TabController(
        length: 2,
        vsync: this,
        initialIndex: initialTab,
      );
      _tabController!.addListener(_saveTabIndex);
      _tabController!.addListener(() {
        setState(() {}); // Rebuild to update button states
      });
      _isLoading = false;
    });
  }

  Future<void> _saveTabIndex() async {
    if (_tabController != null && !_tabController!.indexIsChanging) {
      final prefs = await SharedPreferences.getInstance();
      final currentUser = AuthService.currentUser;
      if (currentUser != null) {
        final key = 'last_tab_${currentUser.id}';
        await prefs.setInt(key, _tabController!.index);
      }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading || _tabController == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.home,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color(0xFFDD2C00),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getScreenTitle(l10n),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(
          0xFFDD2C00,
        ), // Use custom red instead of Colors.red
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: LanguageSelector(isDarkBackground: true),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController!,
        physics: NeverScrollableScrollPhysics(), // Disable swipe to change mode
        children: [
          LayeredBookingWidget(
            key: _driverBookingKey,
            userRole: 'driver',
            hasSelectedRole: _hasSelectedRole,
            onRoleSelected: () {
              setState(() {
                _hasSelectedRole = true;
              });
            },
            onBackToRoleSelection: () {
              setState(() {
                _hasSelectedRole = false;
                _currentLayer = BookingLayer.routeSelection;
              });
            },
            onLayerChanged: (layer) {
              setState(() {
                _currentLayer = layer;
              });
            },
            onBookingCompleted: () =>
                widget.onBookingCompleted?.call(tabIndex: 0),
            tabController: _tabController!,
          ),
          LayeredBookingWidget(
            key: _riderBookingKey,
            userRole: 'rider',
            hasSelectedRole: _hasSelectedRole,
            onRoleSelected: () {
              setState(() {
                _hasSelectedRole = true;
              });
            },
            onBackToRoleSelection: () {
              setState(() {
                _hasSelectedRole = false;
                _currentLayer = BookingLayer.routeSelection;
              });
            },
            onLayerChanged: (layer) {
              setState(() {
                _currentLayer = layer;
              });
            },
            onBookingCompleted: () =>
                widget.onBookingCompleted?.call(tabIndex: 1),
            tabController: _tabController!,
          ),
        ],
      ),
    );
  }
}
