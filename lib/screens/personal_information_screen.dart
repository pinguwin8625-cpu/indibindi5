import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../widgets/scroll_indicator.dart';
import '../models/user.dart';
import '../utils/dialog_helper.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedCountryIso = 'US';
  String? _selectedSex;
  bool _isSaved = false;

  // Original values to detect changes
  String _originalName = '';
  String _originalSurname = '';
  String? _originalSex;
  File? _profileImage;
  final _picker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  void _loadUserData() {
    final user = AuthService.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _surnameController.text = user.surname;
      _phoneController.text = User.formatPhoneNumber(user.phoneNumber, user.countryCode);
      _emailController.text = user.email;

      // Store original values to detect changes
      _originalName = user.name;
      _originalSurname = user.surname;
      _originalSex = user.sex;

      // Load profile photo if exists (skip for asset paths - they're mock data)
      if (user.profilePhotoUrl != null && user.profilePhotoUrl!.isNotEmpty) {
        if (!user.profilePhotoUrl!.startsWith('assets/')) {
          // Only load actual file paths, not assets
          final photoFile = File(user.profilePhotoUrl!);
          if (photoFile.existsSync()) {
            setState(() {
              _profileImage = photoFile;
            });
          }
        }
      }

      // Use user's stored country code or default to US
      if (user.countryCode.isNotEmpty) {
        final countryExists = _countryCodes.any((c) => c['iso'] == user.countryCode);
        if (countryExists) {
          setState(() {
            _selectedCountryIso = user.countryCode;
          });
        }
      }

      // Load sex
      setState(() {
        _selectedSex = user.sex;
      });
    }
  }
  
  final List<Map<String, String>> _countryCodes = [
    {'code': '+93', 'country': 'Afghanistan', 'flag': '🇦🇫', 'iso': 'AF'},
    {'code': '+355', 'country': 'Albania', 'flag': '🇦🇱', 'iso': 'AL'},
    {'code': '+213', 'country': 'Algeria', 'flag': '🇩🇿', 'iso': 'DZ'},
    {'code': '+1', 'country': 'American Samoa', 'flag': '🇦🇸', 'iso': 'AS'},
    {'code': '+376', 'country': 'Andorra', 'flag': '🇦🇩', 'iso': 'AD'},
    {'code': '+244', 'country': 'Angola', 'flag': '🇦🇴', 'iso': 'AO'},
    {'code': '+1', 'country': 'Anguilla', 'flag': '🇦🇮', 'iso': 'AI'},
    {'code': '+1', 'country': 'Antigua and Barbuda', 'flag': '🇦🇬', 'iso': 'AG'},
    {'code': '+54', 'country': 'Argentina', 'flag': '🇦🇷', 'iso': 'AR'},
    {'code': '+374', 'country': 'Armenia', 'flag': '🇦🇲', 'iso': 'AM'},
    {'code': '+297', 'country': 'Aruba', 'flag': '🇦🇼', 'iso': 'AW'},
    {'code': '+61', 'country': 'Australia', 'flag': '🇦🇺', 'iso': 'AU'},
    {'code': '+43', 'country': 'Austria', 'flag': '🇦🇹', 'iso': 'AT'},
    {'code': '+994', 'country': 'Azerbaijan', 'flag': '🇦🇿', 'iso': 'AZ'},
    {'code': '+1', 'country': 'Bahamas', 'flag': '🇧🇸', 'iso': 'BS'},
    {'code': '+973', 'country': 'Bahrain', 'flag': '🇧🇭', 'iso': 'BH'},
    {'code': '+880', 'country': 'Bangladesh', 'flag': '🇧🇩', 'iso': 'BD'},
    {'code': '+1', 'country': 'Barbados', 'flag': '🇧🇧', 'iso': 'BB'},
    {'code': '+375', 'country': 'Belarus', 'flag': '🇧🇾', 'iso': 'BY'},
    {'code': '+32', 'country': 'Belgium', 'flag': '🇧🇪', 'iso': 'BE'},
    {'code': '+501', 'country': 'Belize', 'flag': '🇧🇿', 'iso': 'BZ'},
    {'code': '+229', 'country': 'Benin', 'flag': '🇧🇯', 'iso': 'BJ'},
    {'code': '+1', 'country': 'Bermuda', 'flag': '🇧🇲', 'iso': 'BM'},
    {'code': '+975', 'country': 'Bhutan', 'flag': '🇧🇹', 'iso': 'BT'},
    {'code': '+591', 'country': 'Bolivia', 'flag': '🇧🇴', 'iso': 'BO'},
    {'code': '+387', 'country': 'Bosnia and Herzegovina', 'flag': '🇧🇦', 'iso': 'BA'},
    {'code': '+267', 'country': 'Botswana', 'flag': '🇧🇼', 'iso': 'BW'},
    {'code': '+55', 'country': 'Brazil', 'flag': '🇧🇷', 'iso': 'BR'},
    {'code': '+673', 'country': 'Brunei', 'flag': '🇧🇳', 'iso': 'BN'},
    {'code': '+359', 'country': 'Bulgaria', 'flag': '🇧🇬', 'iso': 'BG'},
    {'code': '+226', 'country': 'Burkina Faso', 'flag': '🇧🇫', 'iso': 'BF'},
    {'code': '+257', 'country': 'Burundi', 'flag': '🇧🇮', 'iso': 'BI'},
    {'code': '+855', 'country': 'Cambodia', 'flag': '🇰🇭', 'iso': 'KH'},
    {'code': '+237', 'country': 'Cameroon', 'flag': '🇨🇲', 'iso': 'CM'},
    {'code': '+1', 'country': 'Canada', 'flag': '🇨🇦', 'iso': 'CA'},
    {'code': '+238', 'country': 'Cape Verde', 'flag': '🇨🇻', 'iso': 'CV'},
    {'code': '+1', 'country': 'Cayman Islands', 'flag': '🇰🇾', 'iso': 'KY'},
    {'code': '+236', 'country': 'Central African Republic', 'flag': '🇨🇫', 'iso': 'CF'},
    {'code': '+235', 'country': 'Chad', 'flag': '🇹🇩', 'iso': 'TD'},
    {'code': '+56', 'country': 'Chile', 'flag': '🇨🇱', 'iso': 'CL'},
    {'code': '+86', 'country': 'China', 'flag': '🇨🇳', 'iso': 'CN'},
    {'code': '+57', 'country': 'Colombia', 'flag': '🇨🇴', 'iso': 'CO'},
    {'code': '+269', 'country': 'Comoros', 'flag': '🇰🇲', 'iso': 'KM'},
    {'code': '+242', 'country': 'Congo', 'flag': '🇨🇬', 'iso': 'CG'},
    {'code': '+243', 'country': 'Congo (DRC)', 'flag': '🇨🇩', 'iso': 'CD'},
    {'code': '+682', 'country': 'Cook Islands', 'flag': '🇨🇰', 'iso': 'CK'},
    {'code': '+506', 'country': 'Costa Rica', 'flag': '🇨🇷', 'iso': 'CR'},
    {'code': '+225', 'country': "Côte d'Ivoire", 'flag': '🇨🇮', 'iso': 'CI'},
    {'code': '+385', 'country': 'Croatia', 'flag': '🇭🇷', 'iso': 'HR'},
    {'code': '+53', 'country': 'Cuba', 'flag': '🇨🇺', 'iso': 'CU'},
    {'code': '+599', 'country': 'Curaçao', 'flag': '🇨🇼', 'iso': 'CW'},
    {'code': '+357', 'country': 'Cyprus', 'flag': '🇨🇾', 'iso': 'CY'},
    {'code': '+420', 'country': 'Czech Republic', 'flag': '🇨🇿', 'iso': 'CZ'},
    {'code': '+45', 'country': 'Denmark', 'flag': '🇩🇰', 'iso': 'DK'},
    {'code': '+253', 'country': 'Djibouti', 'flag': '🇩🇯', 'iso': 'DJ'},
    {'code': '+1', 'country': 'Dominica', 'flag': '🇩🇲', 'iso': 'DM'},
    {'code': '+1', 'country': 'Dominican Republic', 'flag': '🇩🇴', 'iso': 'DO'},
    {'code': '+593', 'country': 'Ecuador', 'flag': '🇪🇨', 'iso': 'EC'},
    {'code': '+20', 'country': 'Egypt', 'flag': '🇪🇬', 'iso': 'EG'},
    {'code': '+503', 'country': 'El Salvador', 'flag': '🇸🇻', 'iso': 'SV'},
    {'code': '+240', 'country': 'Equatorial Guinea', 'flag': '🇬🇶', 'iso': 'GQ'},
    {'code': '+291', 'country': 'Eritrea', 'flag': '🇪🇷', 'iso': 'ER'},
    {'code': '+372', 'country': 'Estonia', 'flag': '🇪🇪', 'iso': 'EE'},
    {'code': '+251', 'country': 'Ethiopia', 'flag': '🇪🇹', 'iso': 'ET'},
    {'code': '+500', 'country': 'Falkland Islands', 'flag': '🇫🇰', 'iso': 'FK'},
    {'code': '+298', 'country': 'Faroe Islands', 'flag': '🇫🇴', 'iso': 'FO'},
    {'code': '+679', 'country': 'Fiji', 'flag': '🇫🇯', 'iso': 'FJ'},
    {'code': '+358', 'country': 'Finland', 'flag': '🇫🇮', 'iso': 'FI'},
    {'code': '+33', 'country': 'France', 'flag': '🇫🇷', 'iso': 'FR'},
    {'code': '+594', 'country': 'French Guiana', 'flag': '🇬🇫', 'iso': 'GF'},
    {'code': '+689', 'country': 'French Polynesia', 'flag': '🇵🇫', 'iso': 'PF'},
    {'code': '+241', 'country': 'Gabon', 'flag': '🇬🇦', 'iso': 'GA'},
    {'code': '+220', 'country': 'Gambia', 'flag': '🇬🇲', 'iso': 'GM'},
    {'code': '+995', 'country': 'Georgia', 'flag': '🇬🇪', 'iso': 'GE'},
    {'code': '+49', 'country': 'Germany', 'flag': '🇩🇪', 'iso': 'DE'},
    {'code': '+233', 'country': 'Ghana', 'flag': '🇬🇭', 'iso': 'GH'},
    {'code': '+350', 'country': 'Gibraltar', 'flag': '🇬🇮', 'iso': 'GI'},
    {'code': '+30', 'country': 'Greece', 'flag': '🇬🇷', 'iso': 'GR'},
    {'code': '+299', 'country': 'Greenland', 'flag': '🇬🇱', 'iso': 'GL'},
    {'code': '+1', 'country': 'Grenada', 'flag': '🇬🇩', 'iso': 'GD'},
    {'code': '+590', 'country': 'Guadeloupe', 'flag': '🇬🇵', 'iso': 'GP'},
    {'code': '+1', 'country': 'Guam', 'flag': '🇬🇺', 'iso': 'GU'},
    {'code': '+502', 'country': 'Guatemala', 'flag': '🇬🇹', 'iso': 'GT'},
    {'code': '+224', 'country': 'Guinea', 'flag': '🇬🇳', 'iso': 'GN'},
    {'code': '+245', 'country': 'Guinea-Bissau', 'flag': '🇬🇼', 'iso': 'GW'},
    {'code': '+592', 'country': 'Guyana', 'flag': '🇬🇾', 'iso': 'GY'},
    {'code': '+509', 'country': 'Haiti', 'flag': '🇭🇹', 'iso': 'HT'},
    {'code': '+504', 'country': 'Honduras', 'flag': '🇭🇳', 'iso': 'HN'},
    {'code': '+852', 'country': 'Hong Kong', 'flag': '🇭🇰', 'iso': 'HK'},
    {'code': '+36', 'country': 'Hungary', 'flag': '🇭🇺', 'iso': 'HU'},
    {'code': '+354', 'country': 'Iceland', 'flag': '🇮🇸', 'iso': 'IS'},
    {'code': '+91', 'country': 'India', 'flag': '🇮🇳', 'iso': 'IN'},
    {'code': '+62', 'country': 'Indonesia', 'flag': '🇮🇩', 'iso': 'ID'},
    {'code': '+98', 'country': 'Iran', 'flag': '🇮🇷', 'iso': 'IR'},
    {'code': '+964', 'country': 'Iraq', 'flag': '🇮🇶', 'iso': 'IQ'},
    {'code': '+353', 'country': 'Ireland', 'flag': '🇮🇪', 'iso': 'IE'},
    {'code': '+972', 'country': 'Israel', 'flag': '🇮🇱', 'iso': 'IL'},
    {'code': '+39', 'country': 'Italy', 'flag': '🇮🇹', 'iso': 'IT'},
    {'code': '+1', 'country': 'Jamaica', 'flag': '🇯🇲', 'iso': 'JM'},
    {'code': '+81', 'country': 'Japan', 'flag': '🇯🇵', 'iso': 'JP'},
    {'code': '+962', 'country': 'Jordan', 'flag': '🇯🇴', 'iso': 'JO'},
    {'code': '+7', 'country': 'Kazakhstan', 'flag': '🇰🇿', 'iso': 'KZ'},
    {'code': '+254', 'country': 'Kenya', 'flag': '🇰🇪', 'iso': 'KE'},
    {'code': '+686', 'country': 'Kiribati', 'flag': '🇰🇮', 'iso': 'KI'},
    {'code': '+383', 'country': 'Kosovo', 'flag': '🇽🇰', 'iso': 'XK'},
    {'code': '+965', 'country': 'Kuwait', 'flag': '🇰🇼', 'iso': 'KW'},
    {'code': '+996', 'country': 'Kyrgyzstan', 'flag': '🇰🇬', 'iso': 'KG'},
    {'code': '+856', 'country': 'Laos', 'flag': '🇱🇦', 'iso': 'LA'},
    {'code': '+371', 'country': 'Latvia', 'flag': '🇱🇻', 'iso': 'LV'},
    {'code': '+961', 'country': 'Lebanon', 'flag': '🇱🇧', 'iso': 'LB'},
    {'code': '+266', 'country': 'Lesotho', 'flag': '🇱🇸', 'iso': 'LS'},
    {'code': '+231', 'country': 'Liberia', 'flag': '🇱🇷', 'iso': 'LR'},
    {'code': '+218', 'country': 'Libya', 'flag': '🇱🇾', 'iso': 'LY'},
    {'code': '+423', 'country': 'Liechtenstein', 'flag': '🇱🇮', 'iso': 'LI'},
    {'code': '+370', 'country': 'Lithuania', 'flag': '🇱🇹', 'iso': 'LT'},
    {'code': '+352', 'country': 'Luxembourg', 'flag': '🇱🇺', 'iso': 'LU'},
    {'code': '+853', 'country': 'Macau', 'flag': '🇲🇴', 'iso': 'MO'},
    {'code': '+389', 'country': 'Macedonia', 'flag': '🇲🇰', 'iso': 'MK'},
    {'code': '+261', 'country': 'Madagascar', 'flag': '🇲🇬', 'iso': 'MG'},
    {'code': '+265', 'country': 'Malawi', 'flag': '🇲🇼', 'iso': 'MW'},
    {'code': '+60', 'country': 'Malaysia', 'flag': '🇲🇾', 'iso': 'MY'},
    {'code': '+960', 'country': 'Maldives', 'flag': '🇲🇻', 'iso': 'MV'},
    {'code': '+223', 'country': 'Mali', 'flag': '🇲🇱', 'iso': 'ML'},
    {'code': '+356', 'country': 'Malta', 'flag': '🇲🇹', 'iso': 'MT'},
    {'code': '+692', 'country': 'Marshall Islands', 'flag': '🇲🇭', 'iso': 'MH'},
    {'code': '+596', 'country': 'Martinique', 'flag': '🇲🇶', 'iso': 'MQ'},
    {'code': '+222', 'country': 'Mauritania', 'flag': '🇲🇷', 'iso': 'MR'},
    {'code': '+230', 'country': 'Mauritius', 'flag': '🇲🇺', 'iso': 'MU'},
    {'code': '+262', 'country': 'Mayotte', 'flag': '🇾🇹', 'iso': 'YT'},
    {'code': '+52', 'country': 'Mexico', 'flag': '🇲🇽', 'iso': 'MX'},
    {'code': '+691', 'country': 'Micronesia', 'flag': '🇫🇲', 'iso': 'FM'},
    {'code': '+373', 'country': 'Moldova', 'flag': '🇲🇩', 'iso': 'MD'},
    {'code': '+377', 'country': 'Monaco', 'flag': '🇲🇨', 'iso': 'MC'},
    {'code': '+976', 'country': 'Mongolia', 'flag': '🇲🇳', 'iso': 'MN'},
    {'code': '+382', 'country': 'Montenegro', 'flag': '🇲🇪', 'iso': 'ME'},
    {'code': '+1', 'country': 'Montserrat', 'flag': '🇲🇸', 'iso': 'MS'},
    {'code': '+212', 'country': 'Morocco', 'flag': '🇲🇦', 'iso': 'MA'},
    {'code': '+258', 'country': 'Mozambique', 'flag': '🇲🇿', 'iso': 'MZ'},
    {'code': '+95', 'country': 'Myanmar', 'flag': '🇲🇲', 'iso': 'MM'},
    {'code': '+264', 'country': 'Namibia', 'flag': '🇳🇦', 'iso': 'NA'},
    {'code': '+674', 'country': 'Nauru', 'flag': '🇳🇷', 'iso': 'NR'},
    {'code': '+977', 'country': 'Nepal', 'flag': '🇳🇵', 'iso': 'NP'},
    {'code': '+31', 'country': 'Netherlands', 'flag': '🇳🇱', 'iso': 'NL'},
    {'code': '+687', 'country': 'New Caledonia', 'flag': '🇳🇨', 'iso': 'NC'},
    {'code': '+64', 'country': 'New Zealand', 'flag': '🇳🇿', 'iso': 'NZ'},
    {'code': '+505', 'country': 'Nicaragua', 'flag': '🇳🇮', 'iso': 'NI'},
    {'code': '+227', 'country': 'Niger', 'flag': '🇳🇪', 'iso': 'NE'},
    {'code': '+234', 'country': 'Nigeria', 'flag': '🇳🇬', 'iso': 'NG'},
    {'code': '+683', 'country': 'Niue', 'flag': '🇳🇺', 'iso': 'NU'},
    {'code': '+850', 'country': 'North Korea', 'flag': '🇰🇵', 'iso': 'KP'},
    {'code': '+47', 'country': 'Norway', 'flag': '🇳🇴', 'iso': 'NO'},
    {'code': '+968', 'country': 'Oman', 'flag': '🇴🇲', 'iso': 'OM'},
    {'code': '+92', 'country': 'Pakistan', 'flag': '🇵🇰', 'iso': 'PK'},
    {'code': '+680', 'country': 'Palau', 'flag': '🇵🇼', 'iso': 'PW'},
    {'code': '+970', 'country': 'Palestine', 'flag': '🇵🇸', 'iso': 'PS'},
    {'code': '+507', 'country': 'Panama', 'flag': '🇵🇦', 'iso': 'PA'},
    {'code': '+675', 'country': 'Papua New Guinea', 'flag': '🇵🇬', 'iso': 'PG'},
    {'code': '+595', 'country': 'Paraguay', 'flag': '🇵🇾', 'iso': 'PY'},
    {'code': '+51', 'country': 'Peru', 'flag': '🇵🇪', 'iso': 'PE'},
    {'code': '+63', 'country': 'Philippines', 'flag': '🇵🇭', 'iso': 'PH'},
    {'code': '+48', 'country': 'Poland', 'flag': '🇵🇱', 'iso': 'PL'},
    {'code': '+351', 'country': 'Portugal', 'flag': '🇵🇹', 'iso': 'PT'},
    {'code': '+1', 'country': 'Puerto Rico', 'flag': '🇵🇷', 'iso': 'PR'},
    {'code': '+974', 'country': 'Qatar', 'flag': '🇶🇦', 'iso': 'QA'},
    {'code': '+262', 'country': 'Réunion', 'flag': '🇷🇪', 'iso': 'RE'},
    {'code': '+40', 'country': 'Romania', 'flag': '🇷🇴', 'iso': 'RO'},
    {'code': '+7', 'country': 'Russia', 'flag': '🇷🇺', 'iso': 'RU'},
    {'code': '+250', 'country': 'Rwanda', 'flag': '🇷🇼', 'iso': 'RW'},
    {'code': '+590', 'country': 'Saint Barthélemy', 'flag': '🇧🇱', 'iso': 'BL'},
    {'code': '+290', 'country': 'Saint Helena', 'flag': '🇸🇭', 'iso': 'SH'},
    {'code': '+1', 'country': 'Saint Kitts and Nevis', 'flag': '🇰🇳', 'iso': 'KN'},
    {'code': '+1', 'country': 'Saint Lucia', 'flag': '🇱🇨', 'iso': 'LC'},
    {'code': '+590', 'country': 'Saint Martin', 'flag': '🇲🇫', 'iso': 'MF'},
    {'code': '+508', 'country': 'Saint Pierre and Miquelon', 'flag': '🇵🇲', 'iso': 'PM'},
    {'code': '+1', 'country': 'Saint Vincent and the Grenadines', 'flag': '🇻🇨', 'iso': 'VC'},
    {'code': '+685', 'country': 'Samoa', 'flag': '🇼🇸', 'iso': 'WS'},
    {'code': '+378', 'country': 'San Marino', 'flag': '🇸🇲', 'iso': 'SM'},
    {'code': '+239', 'country': 'São Tomé and Príncipe', 'flag': '🇸🇹', 'iso': 'ST'},
    {'code': '+966', 'country': 'Saudi Arabia', 'flag': '🇸🇦', 'iso': 'SA'},
    {'code': '+221', 'country': 'Senegal', 'flag': '🇸🇳', 'iso': 'SN'},
    {'code': '+381', 'country': 'Serbia', 'flag': '🇷🇸', 'iso': 'RS'},
    {'code': '+248', 'country': 'Seychelles', 'flag': '🇸🇨', 'iso': 'SC'},
    {'code': '+232', 'country': 'Sierra Leone', 'flag': '🇸🇱', 'iso': 'SL'},
    {'code': '+65', 'country': 'Singapore', 'flag': '🇸🇬', 'iso': 'SG'},
    {'code': '+1', 'country': 'Sint Maarten', 'flag': '🇸🇽', 'iso': 'SX'},
    {'code': '+421', 'country': 'Slovakia', 'flag': '🇸🇰', 'iso': 'SK'},
    {'code': '+386', 'country': 'Slovenia', 'flag': '🇸🇮', 'iso': 'SI'},
    {'code': '+677', 'country': 'Solomon Islands', 'flag': '🇸🇧', 'iso': 'SB'},
    {'code': '+252', 'country': 'Somalia', 'flag': '🇸🇴', 'iso': 'SO'},
    {'code': '+27', 'country': 'South Africa', 'flag': '🇿🇦', 'iso': 'ZA'},
    {'code': '+82', 'country': 'South Korea', 'flag': '🇰🇷', 'iso': 'KR'},
    {'code': '+211', 'country': 'South Sudan', 'flag': '🇸🇸', 'iso': 'SS'},
    {'code': '+34', 'country': 'Spain', 'flag': '🇪🇸', 'iso': 'ES'},
    {'code': '+94', 'country': 'Sri Lanka', 'flag': '🇱🇰', 'iso': 'LK'},
    {'code': '+249', 'country': 'Sudan', 'flag': '🇸🇩', 'iso': 'SD'},
    {'code': '+597', 'country': 'Suriname', 'flag': '🇸🇷', 'iso': 'SR'},
    {'code': '+268', 'country': 'Swaziland', 'flag': '🇸🇿', 'iso': 'SZ'},
    {'code': '+46', 'country': 'Sweden', 'flag': '🇸🇪', 'iso': 'SE'},
    {'code': '+41', 'country': 'Switzerland', 'flag': '🇨🇭', 'iso': 'CH'},
    {'code': '+963', 'country': 'Syria', 'flag': '🇸🇾', 'iso': 'SY'},
    {'code': '+886', 'country': 'Taiwan', 'flag': '🇹🇼', 'iso': 'TW'},
    {'code': '+992', 'country': 'Tajikistan', 'flag': '🇹🇯', 'iso': 'TJ'},
    {'code': '+255', 'country': 'Tanzania', 'flag': '🇹🇿', 'iso': 'TZ'},
    {'code': '+66', 'country': 'Thailand', 'flag': '🇹🇭', 'iso': 'TH'},
    {'code': '+670', 'country': 'Timor-Leste', 'flag': '🇹🇱', 'iso': 'TL'},
    {'code': '+228', 'country': 'Togo', 'flag': '🇹🇬', 'iso': 'TG'},
    {'code': '+690', 'country': 'Tokelau', 'flag': '🇹🇰', 'iso': 'TK'},
    {'code': '+676', 'country': 'Tonga', 'flag': '🇹🇴', 'iso': 'TO'},
    {'code': '+1', 'country': 'Trinidad and Tobago', 'flag': '🇹🇹', 'iso': 'TT'},
    {'code': '+216', 'country': 'Tunisia', 'flag': '🇹🇳', 'iso': 'TN'},
    {'code': '+90', 'country': 'Turkey', 'flag': '🇹🇷', 'iso': 'TR'},
    {'code': '+993', 'country': 'Turkmenistan', 'flag': '🇹🇲', 'iso': 'TM'},
    {'code': '+1', 'country': 'Turks and Caicos Islands', 'flag': '🇹🇨', 'iso': 'TC'},
    {'code': '+688', 'country': 'Tuvalu', 'flag': '🇹🇻', 'iso': 'TV'},
    {'code': '+256', 'country': 'Uganda', 'flag': '🇺🇬', 'iso': 'UG'},
    {'code': '+380', 'country': 'Ukraine', 'flag': '🇺🇦', 'iso': 'UA'},
    {'code': '+971', 'country': 'United Arab Emirates', 'flag': '🇦🇪', 'iso': 'AE'},
    {'code': '+44', 'country': 'United Kingdom', 'flag': '🇬🇧', 'iso': 'GB'},
    {'code': '+1', 'country': 'United States', 'flag': '🇺🇸', 'iso': 'US'},
    {'code': '+598', 'country': 'Uruguay', 'flag': '🇺🇾', 'iso': 'UY'},
    {'code': '+998', 'country': 'Uzbekistan', 'flag': '🇺🇿', 'iso': 'UZ'},
    {'code': '+678', 'country': 'Vanuatu', 'flag': '🇻🇺', 'iso': 'VU'},
    {'code': '+379', 'country': 'Vatican City', 'flag': '🇻🇦', 'iso': 'VA'},
    {'code': '+58', 'country': 'Venezuela', 'flag': '🇻🇪', 'iso': 'VE'},
    {'code': '+84', 'country': 'Vietnam', 'flag': '🇻🇳', 'iso': 'VN'},
    {'code': '+1', 'country': 'British Virgin Islands', 'flag': '🇻🇬', 'iso': 'VG'},
    {'code': '+1', 'country': 'US Virgin Islands', 'flag': '🇻🇮', 'iso': 'VI'},
    {'code': '+681', 'country': 'Wallis and Futuna', 'flag': '🇼🇫', 'iso': 'WF'},
    {'code': '+212', 'country': 'Western Sahara', 'flag': '🇪🇭', 'iso': 'EH'},
    {'code': '+967', 'country': 'Yemen', 'flag': '🇾🇪', 'iso': 'YE'},
    {'code': '+260', 'country': 'Zambia', 'flag': '🇿🇲', 'iso': 'ZM'},
    {'code': '+263', 'country': 'Zimbabwe', 'flag': '🇿🇼', 'iso': 'ZW'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showImageSourceDialog() {
    print('🔵 _showImageSourceDialog called');
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        print('🔵 Building bottom sheet');
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                Text(
                  'Choose Photo Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Camera option
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  title: Text(
                    'Camera',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text('Take a new photo'),
                  onTap: () {
                    print('🔵 Camera option tapped');
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
                
                SizedBox(height: 8),
                
                // Gallery option
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  title: Text(
                    'Gallery',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text('Choose from gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                ),
                
                SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image from camera: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.personalInformation,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ScrollIndicator(
        scrollController: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                
                // Profile photo section
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: _profileImage != null
                                ? Image.file(
                                    _profileImage!,
                                    fit: BoxFit.cover,
                                  )
                                : (AuthService.currentUser?.profilePhotoUrl != null &&
                                    AuthService.currentUser!.profilePhotoUrl!.startsWith('assets/'))
                                    ? Image.asset(
                                        AuthService.currentUser!.profilePhotoUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                                            child: Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                                        child: Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Theme.of(context).primaryColor,
                              ),
                              SizedBox(width: 8),
                              Text(
                                _profileImage != null ? 'Change Photo' : 'Upload Photo',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Name field
                Text(
                  l10n.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  enabled: !(AuthService.currentUser?.hasEditedPersonalInfo ?? false),
                  decoration: InputDecoration(
                    hintText: l10n.enterName,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFFDD2C00), width: 2),
                    ),
                    filled: true,
                    fillColor: (AuthService.currentUser?.hasEditedPersonalInfo ?? false) ? Colors.grey[200] : Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterName;
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 20),
                
                // Surname field
                Text(
                  l10n.surname,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _surnameController,
                  enabled: !(AuthService.currentUser?.hasEditedPersonalInfo ?? false),
                  decoration: InputDecoration(
                    hintText: l10n.enterSurname,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFFDD2C00), width: 2),
                    ),
                    filled: true,
                    fillColor: (AuthService.currentUser?.hasEditedPersonalInfo ?? false) ? Colors.grey[200] : Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterSurname;
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 20),

                // Gender selector
                Text(
                  'Gender',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: (AuthService.currentUser?.hasEditedPersonalInfo ?? false) ? Colors.grey[200] : Colors.grey[50],
                    border: Border.all(color: (AuthService.currentUser?.hasEditedPersonalInfo ?? false) ? Colors.grey[300]! : Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: DropdownButton<String?>(
                    value: _selectedSex,
                    isExpanded: true,
                    underline: SizedBox.shrink(),
                    hint: Text('Select gender'),
                    items: [
                      DropdownMenuItem<String?>(
                        value: 'M',
                        child: Text('Male'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'F',
                        child: Text('Female'),
                      ),
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Prefer not to say'),
                      ),
                    ],
                    onChanged: (AuthService.currentUser?.hasEditedPersonalInfo ?? false) ? null : (value) {
                      setState(() {
                        _selectedSex = value;
                      });
                    },
                  ),
                ),

                SizedBox(height: 20),

                // Phone number field
                Text(
                  l10n.phoneNumber,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    // Country code dropdown
                    Flexible(
                      flex: 2,
                      child: Container(
                        height: 56,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[50],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCountryIso,
                            menuMaxHeight: 400,
                            menuWidth: 300,
                            items: _countryCodes.map((country) {
                              return DropdownMenuItem<String>(
                                value: country['iso'],
                                child: Row(
                                  children: [
                                    Text(
                                      country['flag']!,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      country['code']!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        country['country']!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            selectedItemBuilder: (BuildContext context) {
                              return _countryCodes.map((country) {
                                return Row(
                                  children: [
                                    Text(
                                      country['flag']!,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      country['code']!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList();
                            },
                            onChanged: (value) {
                              setState(() {
                                _selectedCountryIso = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Phone number input
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: l10n.enterPhone,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFFDD2C00), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseEnterPhone;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 20),
                
                // Email address field
                Text(
                  l10n.email,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: l10n.enterEmail,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFFDD2C00), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterValidEmail;
                    }
                    if (!value.contains('@')) {
                      return l10n.pleaseEnterValidEmail;
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 32),
                
                // Save button
                GestureDetector(
                  onTap: _isSaved ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      final currentUser = AuthService.currentUser;
                      if (currentUser != null) {
                        // Check if name, surname, or gender has changed
                        final nameChanged = _nameController.text.trim() != _originalName;
                        final surnameChanged = _surnameController.text.trim() != _originalSurname;
                        final sexChanged = _selectedSex != _originalSex;

                        // If any of these fields changed and this is the FIRST time editing, show warning
                        if (!currentUser.hasEditedPersonalInfo && (nameChanged || surnameChanged || sexChanged)) {
                          final confirmed = await DialogHelper.showConfirmDialog(
                            context: context,
                            title: 'Warning',
                            content: 'Name, surname, and gender can only be changed once. After saving, these fields cannot be modified again. Are you sure you want to proceed?',
                            cancelText: 'Cancel',
                            confirmText: 'Yes, Save',
                            isDangerous: true,
                          );

                          if (!confirmed) {
                            return;
                          }
                        }

                        // Remove formatting from phone number (keep only digits)
                        final phoneDigitsOnly = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');

                        // Mark as edited if name, surname, or gender changed
                        final shouldMarkAsEdited = (nameChanged || surnameChanged || sexChanged) || currentUser.hasEditedPersonalInfo;

                        final updatedUser = currentUser.copyWith(
                          name: _nameController.text.trim(),
                          surname: _surnameController.text.trim(),
                          sex: _selectedSex,
                          phoneNumber: phoneDigitsOnly,
                          countryCode: _selectedCountryIso,
                          profilePhotoUrl: _profileImage?.path,
                          hasEditedPersonalInfo: shouldMarkAsEdited,
                        );
                        AuthService.updateProfile(updatedUser);
                      }

                      setState(() {
                        _isSaved = true;
                      });

                      // Navigate back after a short delay
                      Future.delayed(Duration(milliseconds: 800), () {
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isSaved ? Color(0xFF00C853) : Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SizedBox(
                      height: 42.0,
                      child: Center(
                        child: Text(
                          _isSaved ? l10n.saved : l10n.save,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
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
