import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/scroll_indicator.dart';
import '../utils/phone_formatter.dart';
import '../utils/dialog_helper.dart';
import 'main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSignUp = false; // Toggle between sign in and sign up
  String _selectedCountryIso = 'TR'; // Default to Turkey for admin login
  String? _selectedSex; // Gender selection for sign up (M, F, or null for prefer not to say)

  @override
  void initState() {
    super.initState();
    // Auto-fill admin credentials for sign in
    _phoneController.text = '555 000 00 00';
    _passwordController.text = AuthService.defaultPassword;
  }

  final List<Map<String, String>> _countryCodes = [
    {'code': '+93', 'country': 'Afghanistan', 'flag': '🇦🇫', 'iso': 'AF'},
    {'code': '+355', 'country': 'Albania', 'flag': '🇦🇱', 'iso': 'AL'},
    {'code': '+213', 'country': 'Algeria', 'flag': '🇩🇿', 'iso': 'DZ'},
    {'code': '+1', 'country': 'American Samoa', 'flag': '🇦🇸', 'iso': 'AS'},
    {'code': '+376', 'country': 'Andorra', 'flag': '🇦🇩', 'iso': 'AD'},
    {'code': '+244', 'country': 'Angola', 'flag': '🇦🇴', 'iso': 'AO'},
    {'code': '+1', 'country': 'Anguilla', 'flag': '🇦🇮', 'iso': 'AI'},
    {
      'code': '+1',
      'country': 'Antigua and Barbuda',
      'flag': '🇦🇬',
      'iso': 'AG',
    },
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
    {
      'code': '+387',
      'country': 'Bosnia and Herzegovina',
      'flag': '🇧🇦',
      'iso': 'BA',
    },
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
    {
      'code': '+236',
      'country': 'Central African Republic',
      'flag': '🇨🇫',
      'iso': 'CF',
    },
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
    {
      'code': '+1',
      'country': 'Dominican Republic',
      'flag': '🇩🇴',
      'iso': 'DO',
    },
    {'code': '+593', 'country': 'Ecuador', 'flag': '🇪🇨', 'iso': 'EC'},
    {'code': '+20', 'country': 'Egypt', 'flag': '🇪🇬', 'iso': 'EG'},
    {'code': '+503', 'country': 'El Salvador', 'flag': '🇸🇻', 'iso': 'SV'},
    {
      'code': '+240',
      'country': 'Equatorial Guinea',
      'flag': '🇬🇶',
      'iso': 'GQ',
    },
    {'code': '+291', 'country': 'Eritrea', 'flag': '🇪🇷', 'iso': 'ER'},
    {'code': '+372', 'country': 'Estonia', 'flag': '🇪🇪', 'iso': 'EE'},
    {'code': '+251', 'country': 'Ethiopia', 'flag': '🇪🇹', 'iso': 'ET'},
    {
      'code': '+500',
      'country': 'Falkland Islands',
      'flag': '🇫🇰',
      'iso': 'FK',
    },
    {'code': '+298', 'country': 'Faroe Islands', 'flag': '🇫🇴', 'iso': 'FO'},
    {'code': '+679', 'country': 'Fiji', 'flag': '🇫🇯', 'iso': 'FJ'},
    {'code': '+358', 'country': 'Finland', 'flag': '🇫🇮', 'iso': 'FI'},
    {'code': '+33', 'country': 'France', 'flag': '🇫🇷', 'iso': 'FR'},
    {'code': '+594', 'country': 'French Guiana', 'flag': '🇬🇫', 'iso': 'GF'},
    {
      'code': '+689',
      'country': 'French Polynesia',
      'flag': '🇵🇫',
      'iso': 'PF',
    },
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
    {
      'code': '+692',
      'country': 'Marshall Islands',
      'flag': '🇲🇭',
      'iso': 'MH',
    },
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
    {
      'code': '+675',
      'country': 'Papua New Guinea',
      'flag': '🇵🇬',
      'iso': 'PG',
    },
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
    {
      'code': '+590',
      'country': 'Saint Barthélemy',
      'flag': '🇧🇱',
      'iso': 'BL',
    },
    {'code': '+290', 'country': 'Saint Helena', 'flag': '🇸🇭', 'iso': 'SH'},
    {
      'code': '+1',
      'country': 'Saint Kitts and Nevis',
      'flag': '🇰🇳',
      'iso': 'KN',
    },
    {'code': '+1', 'country': 'Saint Lucia', 'flag': '🇱🇨', 'iso': 'LC'},
    {'code': '+590', 'country': 'Saint Martin', 'flag': '🇲🇫', 'iso': 'MF'},
    {
      'code': '+508',
      'country': 'Saint Pierre and Miquelon',
      'flag': '🇵🇲',
      'iso': 'PM',
    },
    {
      'code': '+1',
      'country': 'Saint Vincent and the Grenadines',
      'flag': '🇻🇨',
      'iso': 'VC',
    },
    {'code': '+685', 'country': 'Samoa', 'flag': '🇼🇸', 'iso': 'WS'},
    {'code': '+378', 'country': 'San Marino', 'flag': '🇸🇲', 'iso': 'SM'},
    {
      'code': '+239',
      'country': 'São Tomé and Príncipe',
      'flag': '🇸🇹',
      'iso': 'ST',
    },
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
    {
      'code': '+1',
      'country': 'Trinidad and Tobago',
      'flag': '🇹🇹',
      'iso': 'TT',
    },
    {'code': '+216', 'country': 'Tunisia', 'flag': '🇹🇳', 'iso': 'TN'},
    {'code': '+90', 'country': 'Turkey', 'flag': '🇹🇷', 'iso': 'TR'},
    {'code': '+993', 'country': 'Turkmenistan', 'flag': '🇹🇲', 'iso': 'TM'},
    {
      'code': '+1',
      'country': 'Turks and Caicos Islands',
      'flag': '🇹🇨',
      'iso': 'TC',
    },
    {'code': '+688', 'country': 'Tuvalu', 'flag': '🇹🇻', 'iso': 'TV'},
    {'code': '+256', 'country': 'Uganda', 'flag': '🇺🇬', 'iso': 'UG'},
    {'code': '+380', 'country': 'Ukraine', 'flag': '🇺🇦', 'iso': 'UA'},
    {
      'code': '+971',
      'country': 'United Arab Emirates',
      'flag': '🇦🇪',
      'iso': 'AE',
    },
    {'code': '+44', 'country': 'United Kingdom', 'flag': '🇬🇧', 'iso': 'GB'},
    {'code': '+1', 'country': 'United States', 'flag': '🇺🇸', 'iso': 'US'},
    {'code': '+598', 'country': 'Uruguay', 'flag': '🇺🇾', 'iso': 'UY'},
    {'code': '+998', 'country': 'Uzbekistan', 'flag': '🇺🇿', 'iso': 'UZ'},
    {'code': '+678', 'country': 'Vanuatu', 'flag': '🇻🇺', 'iso': 'VU'},
    {'code': '+379', 'country': 'Vatican City', 'flag': '🇻🇦', 'iso': 'VA'},
    {'code': '+58', 'country': 'Venezuela', 'flag': '🇻🇪', 'iso': 'VE'},
    {'code': '+84', 'country': 'Vietnam', 'flag': '🇻🇳', 'iso': 'VN'},
    {
      'code': '+1',
      'country': 'British Virgin Islands',
      'flag': '🇻🇬',
      'iso': 'VG',
    },
    {'code': '+1', 'country': 'US Virgin Islands', 'flag': '🇻🇮', 'iso': 'VI'},
    {
      'code': '+681',
      'country': 'Wallis and Futuna',
      'flag': '🇼🇫',
      'iso': 'WF',
    },
    {'code': '+212', 'country': 'Western Sahara', 'flag': '🇪🇭', 'iso': 'EH'},
    {'code': '+967', 'country': 'Yemen', 'flag': '🇾🇪', 'iso': 'YE'},
    {'code': '+260', 'country': 'Zambia', 'flag': '🇿🇲', 'iso': 'ZM'},
    {'code': '+263', 'country': 'Zimbabwe', 'flag': '🇿🇼', 'iso': 'ZW'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _confirmPasswordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getCountryCode() {
    return _countryCodes.firstWhere(
      (c) => c['iso'] == _selectedCountryIso,
      orElse: () => {'code': '+90', 'country': 'Turkey', 'flag': '🇹🇷', 'iso': 'TR'},
    )['code']!;
  }

  String _getPhoneHint() {
    // Return example phone number based on country (without leading 0)
    switch (_selectedCountryIso) {
      case 'US':
      case 'CA':
        return '(555) 123-4567';
      case 'GB':
        return '7123 456789';
      case 'FR':
        return '6 12 34 56 78';
      case 'DE':
        return '160 1234567';
      case 'IT':
        return '312 345 6789';
      case 'ES':
        return '612 34 56 78';
      case 'BR':
        return '(11) 91234-5678';
      case 'MX':
        return '55 1234 5678';
      case 'JP':
        return '90-1234-5678';
      case 'CN':
        return '138 0013 8000';
      case 'IN':
        return '98765 43210';
      case 'AU':
        return '412 345 678';
      case 'KR':
        return '10-1234-5678';
      case 'TR':
        return '532 123 45 67';
      default:
        return '123 456 7890';
    }
  }

  void _signUp() async {
    // Validate fields
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your name';
      });
      return;
    }

    if (_surnameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your surname';
      });
      return;
    }

    if (_phoneController.text.trim().isEmpty ||
        _phoneController.text.length < 10) {
      setState(() {
        _errorMessage = 'Please enter a valid phone number';
      });
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // TODO: Implement actual sign up logic with backend
    // When implementing, remember to:
    // 1. Strip formatting: phoneDigits = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    // 2. Remove leading zero: if (phoneDigits.startsWith('0')) phoneDigits = phoneDigits.substring(1);
    // 3. Combine with country code: phoneNumber = '${_getCountryCode()}$phoneDigits';
    // For now, just show success message
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _errorMessage = null;
    });

    // Show success dialog
    if (mounted) {
      await DialogHelper.showInfoDialog(
        context: context,
        title: 'Account Created',
        content: 'Your account has been created successfully. Please sign in.',
        okText: 'Sign In',
      );

      setState(() {
        _isSignUp = false;
        _passwordController.text = '';
        _confirmPasswordController.text = '';
      });
    }
  }

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Strip formatting from phone number (keep only digits)
      String phoneDigits = _phoneController.text.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );

      // Remove leading zero if present (common in many countries for domestic dialing)
      if (phoneDigits.startsWith('0')) {
        phoneDigits = phoneDigits.substring(1);
      }

      // Combine country code and phone number
      final phoneNumber = '${_getCountryCode()}$phoneDigits';
      final success = AuthService.login(phoneNumber, _passwordController.text);

      if (success && mounted) {
        // Check if logged in user is admin
        final currentUser = AuthService.currentUser;
        if (currentUser?.isAdmin == true) {
          // Navigate to account tab (index 3) for admin
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => MainScreen(initialIndex: 3)),
          );
        } else {
          // Navigate to main screen for regular users
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => MainScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid email or password';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'User not found';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: ScrollIndicator(
          scrollController: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 60),

                // App Logo/Title
                Icon(Icons.directions_car, size: 80, color: Color(0xFFDD2C00)),
                SizedBox(height: 16),
                Text(
                  'indibindi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Ride Together, Save Together',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),

                SizedBox(height: 24),

                // Sign In / Sign Up Toggle
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSignUp = false;
                              _errorMessage = null;
                              _passwordController.text =
                                  AuthService.defaultPassword;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isSignUp
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: !_isSignUp
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              'Sign In',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: !_isSignUp
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: !_isSignUp
                                    ? Color(0xFFDD2C00)
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSignUp = true;
                              _errorMessage = null;
                              _passwordController.text = '';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isSignUp
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _isSignUp
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              'Sign Up',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: _isSignUp
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _isSignUp
                                    ? Color(0xFFDD2C00)
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Name field (only for sign up)
                if (_isSignUp) ...[
                  TextField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: 'John',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color(0xFFDD2C00),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Surname field (only for sign up)
                  TextField(
                    controller: _surnameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      labelText: 'Surname',
                      hintText: 'Doe',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color(0xFFDD2C00),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Gender selector
                  Text(
                    'Gender',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(12),
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
                      onChanged: (value) {
                        setState(() {
                          _selectedSex = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 16),

                  // Mobile phone instruction
                  Text(
                    'Mobile Phone Number',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 12),
                ],

                // Phone number field
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Country code dropdown
                    Container(
                      height: 56,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[50],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCountryIso,
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
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        country['country']!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        country['code']!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
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
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    country['code']!,
                                    style: TextStyle(
                                      fontSize: 14,
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
                              // Reformat phone number when country changes
                              String digitsOnly = _phoneController.text
                                  .replaceAll(RegExp(r'[^\d]'), '');
                              if (digitsOnly.isNotEmpty) {
                                PhoneNumberFormatter formatter =
                                    PhoneNumberFormatter(value);
                                _phoneController.text = formatter.format(
                                  digitsOnly,
                                );
                                _phoneController.selection =
                                    TextSelection.collapsed(
                                      offset: _phoneController.text.length,
                                    );
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Phone number input
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          PhoneNumberFormatter(_selectedCountryIso),
                        ],
                        decoration: InputDecoration(
                          hintText: _getPhoneHint(),
                          prefixIcon: Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xFFDD2C00),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Password field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: _isSignUp
                        ? 'Enter password'
                        : 'Pre-filled for testing',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color(0xFFDD2C00),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                // Confirm Password field (only for sign up)
                if (_isSignUp) ...[
                  SizedBox(height: 16),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color(0xFFDD2C00),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],

                if (_errorMessage != null) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                SizedBox(height: 24),

                // Login/Sign Up button
                GestureDetector(
                  onTap: _isLoading ? null : (_isSignUp ? _signUp : _login),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _isLoading ? Colors.grey : Color(0xFFDD2C00),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isSignUp ? 'Sign Up' : 'Sign In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
    );
  }
}
