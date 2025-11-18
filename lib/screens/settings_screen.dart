import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/dialog_helper.dart';
import '../widgets/scroll_indicator.dart';
import '../widgets/language_selector.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.settings,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: LanguageSelector(),
          ),
        ],
      ),
      body: ScrollIndicator(
        scrollController: _scrollController,
        child: ListView(
          controller: _scrollController,
          padding: EdgeInsets.all(16),
        children: [
          // Notifications Section
          _buildSwitchTile(
            title: l10n.pushNotifications,
            subtitle: l10n.pushNotificationsDesc,
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          
          SizedBox(height: 16),
          
          // Clear Cache - Android only (iOS manages cache automatically)
          if (Platform.isAndroid) ...[
            _buildSettingTile(
              icon: Icons.delete_outline,
              title: l10n.clearCache,
              onTap: () {
                _showClearCacheDialog();
              },
            ),
            SizedBox(height: 16),
          ],
          
          // App Version
          Center(
            child: Text(
              l10n.version('1.0.0'),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
      ),
    );
  }
  
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: Color(0xFFDD2C00),
        activeTrackColor: Color(0xFFDD2C00).withOpacity(0.5),
      ),
    );
  }
  
  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(icon, color: Color(0xFFDD2C00), size: 24),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
  
  Future<void> _showClearCacheDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await DialogHelper.showConfirmDialog(
      context: context,
      title: l10n.clearCacheTitle,
      content: l10n.clearCacheMessage,
      cancelText: l10n.cancel,
      confirmText: l10n.clearCache,
      isDangerous: true,
    );
    
    if (confirmed) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text(l10n.cacheCleared)),
      );
    }
  }
}
