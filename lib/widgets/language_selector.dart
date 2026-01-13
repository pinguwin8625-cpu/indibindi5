import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/feedback_event.dart';
import '../services/feedback_service.dart';

class LanguageSelector extends StatelessWidget {
  final bool isDarkBackground;
  
  const LanguageSelector({super.key, this.isDarkBackground = false});

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

  static String _getLanguageName(String code) {
    return _languages.entries
        .firstWhere((entry) => entry.value == code,
            orElse: () => const MapEntry('English', 'en'))
        .key;
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale.languageCode;
    final l10n = AppLocalizations.of(context)!;
    
    // Use white colors for dark backgrounds (red app bars), red for light backgrounds
    final textColor = isDarkBackground ? Colors.white : Color(0xFFDD2C00);
    final borderColor = isDarkBackground ? Colors.white : Color(0xFFDD2C00);
    final backgroundColor = isDarkBackground 
        ? Colors.white.withOpacity(0.2) 
        : Color(0xFFDD2C00).withOpacity(0.1);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: PopupMenuButton<String>(
        icon: Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Text(
            currentLocale.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      offset: Offset(0, 50),
      itemBuilder: (BuildContext context) {
        return _languages.entries.map((entry) {
          final languageCode = entry.value;
          final languageName = entry.key;
          final isSelected = languageCode == currentLocale;

          return PopupMenuItem<String>(
            value: languageCode,
            child: Row(
              children: [
                Container(
                  width: 32,
                  alignment: Alignment.center,
                  child: Text(
                    languageCode.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Color(0xFFDD2C00)
                          : Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    languageName,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Color(0xFFDD2C00) : Colors.black,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check, color: Color(0xFFDD2C00), size: 20),
              ],
            ),
          );
        }).toList();
      },
      onSelected: (String languageCode) async {
        await localeProvider.setLocale(Locale(languageCode));
        final languageName = _getLanguageName(languageCode);
        if (context.mounted) {
          FeedbackService.show(
            context,
            FeedbackEvent.success(l10n.languageChanged(languageName)),
          );
        }
      },
      ),
    );
  }
}
