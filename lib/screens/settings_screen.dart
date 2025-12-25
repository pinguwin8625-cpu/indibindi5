import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../utils/dialog_helper.dart';
import '../widgets/scroll_indicator.dart';
import '../services/auth_service.dart';
import '../services/mock_users.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  final ScrollController _scrollController = ScrollController();

  static final Map<String, String> _languages = {
    'English': 'en',
    'Türkçe': 'tr',
    'Español': 'es',
    'Français': 'fr',
    'Deutsch': 'de',
    'Italiano': 'it',
    'Português': 'pt',
    'Русский': 'ru',
    '中文': 'zh',
    '日本語': 'ja',
    '한국어': 'ko',
    'العربية': 'ar',
  };

  String _getLanguageName(String code) {
    return _languages.entries
        .firstWhere((entry) => entry.value == code,
            orElse: () => const MapEntry('English', 'en'))
        .key;
  }

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
      ),
      body: ScrollIndicator(
        scrollController: _scrollController,
        child: ListView(
          controller: _scrollController,
          padding: EdgeInsets.all(16),
          children: [
            // Language Selection
            _buildLanguageTile(context, l10n),

            SizedBox(height: 16),

            // Notifications Section
            _buildSwitchTile(
              title: l10n.pushNotifications,
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),

            SizedBox(height: 16),

            // Clear Cache - Android only (iOS manages cache automatically)
            if (!kIsWeb && Platform.isAndroid) ...[
              _buildSettingTile(
                icon: Icons.delete_outline,
                title: l10n.clearCache,
                onTap: () {
                  _showClearCacheDialog();
                },
              ),
              SizedBox(height: 16),
            ],

            // User Selection (for testing)
            _buildUserSelectionTile(context, l10n),
            SizedBox(height: 16),

            // App Version
            Center(
              child: Text(
                l10n.version('1.0.0'),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, AppLocalizations l10n) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale.languageCode;
    final currentLanguageName = _getLanguageName(currentLocale);

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(Icons.language, color: Color(0xFFDD2C00), size: 24),
        title: Text(
          l10n.language,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentLanguageName,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
        onTap: () => _showLanguageDialog(context, l10n, localeProvider),
      ),
    );
  }

  Widget _buildUserSelectionTile(BuildContext context, AppLocalizations l10n) {
    final currentUser = AuthService.currentUser;
    final displayName = currentUser != null
        ? '${currentUser.name} ${currentUser.surname}'
        : 'Not logged in';

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(Icons.person_outline, color: Color(0xFFDD2C00), size: 24),
        title: Text(
          'Switch User',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayName,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
        onTap: () => _showUserSelectionDialog(context),
      ),
    );
  }

  void _showUserSelectionDialog(BuildContext context) {
    final allUsers = MockUsers.users;
    final currentUser = AuthService.currentUser;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Select User'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: allUsers.length,
              itemBuilder: (context, index) {
                final user = allUsers[index];
                final isSelected = currentUser?.id == user.id;
                final hasVehicle = user.hasVehicle;

                final photoUrl = user.profilePhotoUrl;
                final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

                return ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundImage: hasPhoto
                        ? AssetImage(photoUrl)
                        : null,
                    backgroundColor: Colors.grey[300],
                    child: !hasPhoto
                        ? Icon(Icons.person, color: Colors.grey[600])
                        : null,
                  ),
                  title: Text(
                    '${user.name} ${user.surname}',
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Color(0xFFDD2C00) : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    hasVehicle
                        ? '${user.vehicleBrand} ${user.vehicleModel}'
                        : 'No vehicle',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: Color(0xFFDD2C00), size: 20)
                      : null,
                  onTap: () {
                    AuthService.loginWithId(user.id);
                    Navigator.pop(dialogContext);
                    setState(() {}); // Refresh to show new user
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(color: Color(0xFFDD2C00)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations l10n, LocaleProvider localeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentLocale = localeProvider.locale.languageCode;

            return AlertDialog(
              title: Text(l10n.selectLanguage),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    final entry = _languages.entries.elementAt(index);
                    final languageCode = entry.value;
                    final languageName = entry.key;
                    final isSelected = languageCode == currentLocale;

                    return ListTile(
                      leading: Container(
                        width: 32,
                        alignment: Alignment.center,
                        child: Text(
                          languageCode.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Color(0xFFDD2C00) : Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        languageName,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? Color(0xFFDD2C00) : Colors.black,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: Color(0xFFDD2C00), size: 20)
                          : null,
                      onTap: () async {
                        await localeProvider.setLocale(Locale(languageCode));
                        setDialogState(() {}); // Refresh dialog to show new selection
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    l10n.done,
                    style: TextStyle(color: Color(0xFFDD2C00)),
                  ),
                ),
              ],
            );
          },
        );
      },
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.cacheCleared)));
    }
  }
}
