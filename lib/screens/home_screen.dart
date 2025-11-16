import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/layered_booking_widget.dart';
import '../widgets/language_selector.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onBookingCompleted;

  const HomeScreen({super.key, this.onBookingCompleted});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
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
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabButton(
                  label: l10n.driver,
                  icon: Icons.directions_car,
                  isSelected: _tabController!.index == 0,
                  onTap: () {
                    _tabController!.animateTo(0);
                  },
                ),
                SizedBox(width: 20),
                _buildTabButton(
                  label: l10n.rider,
                  icon: Icons.person,
                  isSelected: _tabController!.index == 1,
                  onTap: () {
                    _tabController!.animateTo(1);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController!,
              children: [
                LayeredBookingWidget(
                  userRole: 'driver',
                  onBookingCompleted: widget.onBookingCompleted,
                ),
                LayeredBookingWidget(
                  userRole: 'rider',
                  onBookingCompleted: widget.onBookingCompleted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFDD2C00) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Color(0xFFDD2C00) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Color(0xFFDD2C00),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Color(0xFFDD2C00),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

