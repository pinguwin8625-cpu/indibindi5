import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/layered_booking_widget.dart';
import '../widgets/language_selector.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback? onBookingCompleted;

  const SearchScreen({super.key, this.onBookingCompleted});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _isLoading = true;

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
      _tabController = TabController(length: 2, vsync: this, initialIndex: initialTab);
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
          l10n.home,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFDD2C00), // Use custom red instead of Colors.red
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
        children: [
          LayeredBookingWidget(
            userRole: 'driver',
            onBookingCompleted: widget.onBookingCompleted,
            tabController: _tabController!,
          ),
          LayeredBookingWidget(
            userRole: 'rider',
            onBookingCompleted: widget.onBookingCompleted,
            tabController: _tabController!,
          ),
        ],
      ),
    );
  }
}
