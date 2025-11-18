import 'package:flutter/material.dart';
import 'dart:io';
import 'personal_information_screen.dart';
import 'vehicle_screen.dart';
import 'settings_screen.dart';
import 'help_screen.dart';
import 'login_screen.dart';
import 'admin_panel_screen.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../utils/dialog_helper.dart';
import '../models/user.dart';
import '../widgets/scroll_indicator.dart';
import '../widgets/language_selector.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  Widget _buildProfilePhoto(User? user) {
    // Check if user has a profile photo
    if (user?.profilePhotoUrl != null && user!.profilePhotoUrl!.isNotEmpty) {
      // Check if it's an asset path or file path
      if (user.profilePhotoUrl!.startsWith('assets/')) {
        // Asset image - use error builder in case asset doesn't exist
        return Image.asset(
          user.profilePhotoUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to placeholder if asset not found
            return Container(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 50,
                color: Theme.of(context).primaryColor,
              ),
            );
          },
        );
      } else {
        // Local file
        final photoFile = File(user.profilePhotoUrl!);
        if (photoFile.existsSync()) {
          return Image.file(
            photoFile,
            fit: BoxFit.cover,
          );
        }
      }
    }
    
    // Default placeholder
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Icon(
        Icons.person,
        size: 50,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = AuthService.currentUser;
    
    // If no user logged in, show placeholder
    final userName = user?.fullName ?? 'John Doe';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.account,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: LanguageSelector(isDarkBackground: true),
          ),
        ],
      ),
      body: ScrollIndicator(
        scrollController: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: Column(
                children: [
                  // Profile photo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).primaryColor, width: 3),
                    ),
                    child: ClipOval(
                      child: _buildProfilePhoto(user),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Name
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      SizedBox(width: 4),
                      Text(
                        '4.8',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E2E2E),
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '(127 rides)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Profile options
            // Show admin panel option for admin users
            if (user?.isAdmin == true)
              _buildProfileOption(
                icon: Icons.admin_panel_settings,
                title: 'Admin Panel',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminPanelScreen(),
                    ),
                  );
                },
              ),
            _buildProfileOption(
              icon: Icons.person_outline,
              title: l10n.personalInformation,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonalInformationScreen(),
                  ),
                );
                // Rebuild the screen when returning
                setState(() {});
              },
            ),
            _buildProfileOption(
              icon: Icons.directions_car_outlined,
              title: l10n.vehicleInformation,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VehicleScreen(),
                  ),
                );
                // Rebuild the screen when returning
                setState(() {});
              },
            ),
            _buildProfileOption(
              icon: Icons.settings,
              title: l10n.settings,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(),
                  ),
                );
              },
            ),
            _buildProfileOption(
              icon: Icons.help_outline,
              title: l10n.help,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HelpScreen(),
                  ),
                );
              },
            ),
            _buildProfileOption(
              icon: Icons.logout,
              title: l10n.logout,
              titleColor: Colors.red,
              onTap: () async {
                final l10n = AppLocalizations.of(context)!;
                // Show confirmation dialog
                final confirmed = await DialogHelper.showConfirmDialog(
                  context: context,
                  title: l10n.logout,
                  content: 'Are you sure you want to logout?',
                  cancelText: l10n.cancel,
                  confirmText: l10n.logout,
                  isDangerous: true,
                );
                
                if (confirmed) {
                  AuthService.logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            _buildProfileOption(
              icon: Icons.delete_forever,
              title: l10n.deleteAccount,
              titleColor: Colors.red[700],
              onTap: () {},
            ),

            SizedBox(height: 24),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: titleColor ?? Color(0xFF2E2E2E),
                    size: 24,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: titleColor ?? Color(0xFF2E2E2E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
