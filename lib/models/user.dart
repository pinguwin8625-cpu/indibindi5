class User {
  final String id;
  final String name;
  final String surname;
  final String? title; // Mr., Ms., Dr., etc.
  final String email;
  final String phoneNumber;
  final String countryCode;
  final String? profilePhotoUrl;
  final String? vehicleBrand;
  final String? vehicleModel;
  final String? vehicleColor;
  final String? licensePlate;
  final bool isAdmin;
  final double rating;
  final int completedTripsCount; // Number of completed posts/bookings

  User({
    required this.id,
    required this.name,
    required this.surname,
    this.title,
    required this.email,
    required this.phoneNumber,
    required this.countryCode,
    this.profilePhotoUrl,
    this.vehicleBrand,
    this.vehicleModel,
    this.vehicleColor,
    this.licensePlate,
    this.isAdmin = false,
    this.rating = 0.0,
    this.completedTripsCount = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      title: json['title'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      countryCode: json['countryCode'],
      profilePhotoUrl: json['profilePhotoUrl'],
      vehicleBrand: json['vehicleBrand'],
      vehicleModel: json['vehicleModel'],
      vehicleColor: json['vehicleColor'],
      licensePlate: json['licensePlate'],
      isAdmin: json['isAdmin'] ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      completedTripsCount: json['completedTripsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'title': title,
      'email': email,
      'phoneNumber': phoneNumber,
      'countryCode': countryCode,
      'profilePhotoUrl': profilePhotoUrl,
      'vehicleBrand': vehicleBrand,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'licensePlate': licensePlate,
      'isAdmin': isAdmin,
      'rating': rating,
      'completedTripsCount': completedTripsCount,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? surname,
    String? title,
    String? email,
    String? phoneNumber,
    String? countryCode,
    String? profilePhotoUrl,
    String? vehicleBrand,
    String? vehicleModel,
    String? vehicleColor,
    String? licensePlate,
    bool? isAdmin,
    double? rating,
    int? completedTripsCount,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      title: title ?? this.title,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      vehicleBrand: vehicleBrand ?? this.vehicleBrand,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      licensePlate: licensePlate ?? this.licensePlate,
      isAdmin: isAdmin ?? this.isAdmin,
      rating: rating ?? this.rating,
      completedTripsCount: completedTripsCount ?? this.completedTripsCount,
    );
  }

  String get fullName => '$name $surname';

  String get formattedPhone {
    final countryInfo = getCountryInfo(countryCode);
    final formattedNumber = formatPhoneNumber(phoneNumber, countryCode);
    return '${countryInfo['flag']} ${countryInfo['code']} $formattedNumber';
  }

  // Helper method to format phone numbers according to local conventions
  static String formatPhoneNumber(String phoneNumber, String isoCode) {
    // Remove any non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.isEmpty) return phoneNumber;

    // Format based on country
    switch (isoCode) {
      // US, Canada, and other NANP countries: (XXX) XXX-XXXX
      case 'US':
      case 'CA':
      case 'AS':
      case 'AI':
      case 'AG':
      case 'BS':
      case 'BB':
      case 'BM':
      case 'DO':
      case 'GD':
      case 'GU':
      case 'JM':
      case 'KN':
      case 'LC':
      case 'MS':
      case 'PR':
      case 'SX':
      case 'TC':
      case 'TT':
      case 'VC':
      case 'VG':
      case 'VI':
        if (digitsOnly.length >= 10) {
          return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
        }
        return phoneNumber;

      // Turkey: XXX XXX XX XX
      case 'TR':
        if (digitsOnly.length == 10) {
          return '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6, 8)} ${digitsOnly.substring(8)}';
        }
        return phoneNumber;

      // UK: XXXX XXX XXXX or XXXXX XXXXXX
      case 'GB':
        if (digitsOnly.length == 10) {
          return '${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4, 7)} ${digitsOnly.substring(7)}';
        } else if (digitsOnly.length == 11) {
          return '${digitsOnly.substring(0, 5)} ${digitsOnly.substring(5)}';
        }
        return phoneNumber;

      // Germany: XXX XXXXXXXX or XXXX XXXXXXX
      case 'DE':
        if (digitsOnly.length >= 10) {
          if (digitsOnly.length == 10) {
            return '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3)}';
          } else if (digitsOnly.length == 11) {
            return '${digitsOnly.substring(0, 4)} ${digitsOnly.substring(4)}';
          }
        }
        return phoneNumber;

      // France: XX XX XX XX XX
      case 'FR':
        if (digitsOnly.length == 9) {
          return '${digitsOnly.substring(0, 1)} ${digitsOnly.substring(1, 3)} ${digitsOnly.substring(3, 5)} ${digitsOnly.substring(5, 7)} ${digitsOnly.substring(7)}';
        }
        return phoneNumber;

      // Spain: XXX XX XX XX
      case 'ES':
        if (digitsOnly.length == 9) {
          return '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 5)} ${digitsOnly.substring(5, 7)} ${digitsOnly.substring(7)}';
        }
        return phoneNumber;

      // Italy: XXX XXX XXXX
      case 'IT':
        if (digitsOnly.length == 10) {
          return '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6)}';
        }
        return phoneNumber;

      // Russia, Kazakhstan: XXX XXX-XX-XX
      case 'RU':
      case 'KZ':
        if (digitsOnly.length == 10) {
          return '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6, 8)}-${digitsOnly.substring(8)}';
        }
        return phoneNumber;

      // China: XXX XXXX XXXX
      case 'CN':
        if (digitsOnly.length == 11) {
          return '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 7)} ${digitsOnly.substring(7)}';
        }
        return phoneNumber;

      // Japan: XX-XXXX-XXXX
      case 'JP':
        if (digitsOnly.length == 10) {
          return '${digitsOnly.substring(0, 2)}-${digitsOnly.substring(2, 6)}-${digitsOnly.substring(6)}';
        }
        return phoneNumber;

      // Australia: XXX XXX XXX
      case 'AU':
        if (digitsOnly.length == 9) {
          return '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6)}';
        }
        return phoneNumber;

      // Brazil: XX XXXXX-XXXX or XX XXXX-XXXX
      case 'BR':
        if (digitsOnly.length == 11) {
          return '${digitsOnly.substring(0, 2)} ${digitsOnly.substring(2, 7)}-${digitsOnly.substring(7)}';
        } else if (digitsOnly.length == 10) {
          return '${digitsOnly.substring(0, 2)} ${digitsOnly.substring(2, 6)}-${digitsOnly.substring(6)}';
        }
        return phoneNumber;

      // India: XXXXX XXXXX
      case 'IN':
        if (digitsOnly.length == 10) {
          return '${digitsOnly.substring(0, 5)} ${digitsOnly.substring(5)}';
        }
        return phoneNumber;

      // Mexico: XXX XXX XXXX
      case 'MX':
        if (digitsOnly.length == 10) {
          return '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6)}';
        }
        return phoneNumber;

      // South Korea: XX-XXXX-XXXX or XXX-XXXX-XXXX
      case 'KR':
        if (digitsOnly.length == 10) {
          return '${digitsOnly.substring(0, 2)}-${digitsOnly.substring(2, 6)}-${digitsOnly.substring(6)}';
        } else if (digitsOnly.length == 11) {
          return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 7)}-${digitsOnly.substring(7)}';
        }
        return phoneNumber;

      // Netherlands: XX XXXXXXXX
      case 'NL':
        if (digitsOnly.length == 9) {
          return '${digitsOnly.substring(0, 2)} ${digitsOnly.substring(2)}';
        }
        return phoneNumber;

      // Poland: XXX XXX XXX
      case 'PL':
        if (digitsOnly.length == 9) {
          return '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6)}';
        }
        return phoneNumber;

      // Default: add spaces every 3-4 digits for readability
      default:
        if (digitsOnly.length <= 4) {
          return digitsOnly;
        } else if (digitsOnly.length <= 7) {
          return '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3)}';
        } else if (digitsOnly.length <= 10) {
          return '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6)}';
        } else {
          return '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6, 9)} ${digitsOnly.substring(9)}';
        }
    }
  }

  // Helper method to get country info (flag, name, code) from ISO code
  static Map<String, String> getCountryInfo(String isoCode) {
    const Map<String, Map<String, String>> isoToCountryInfo = {
      'AF': {'code': '+93', 'country': 'Afghanistan', 'flag': '🇦🇫'},
      'AL': {'code': '+355', 'country': 'Albania', 'flag': '🇦🇱'},
      'DZ': {'code': '+213', 'country': 'Algeria', 'flag': '🇩🇿'},
      'AS': {'code': '+1', 'country': 'American Samoa', 'flag': '🇦🇸'},
      'AD': {'code': '+376', 'country': 'Andorra', 'flag': '🇦🇩'},
      'AO': {'code': '+244', 'country': 'Angola', 'flag': '🇦🇴'},
      'AI': {'code': '+1', 'country': 'Anguilla', 'flag': '🇦🇮'},
      'AG': {'code': '+1', 'country': 'Antigua and Barbuda', 'flag': '🇦🇬'},
      'AR': {'code': '+54', 'country': 'Argentina', 'flag': '🇦🇷'},
      'AM': {'code': '+374', 'country': 'Armenia', 'flag': '🇦🇲'},
      'AW': {'code': '+297', 'country': 'Aruba', 'flag': '🇦🇼'},
      'AU': {'code': '+61', 'country': 'Australia', 'flag': '🇦🇺'},
      'AT': {'code': '+43', 'country': 'Austria', 'flag': '🇦🇹'},
      'AZ': {'code': '+994', 'country': 'Azerbaijan', 'flag': '🇦🇿'},
      'BS': {'code': '+1', 'country': 'Bahamas', 'flag': '🇧🇸'},
      'BH': {'code': '+973', 'country': 'Bahrain', 'flag': '🇧🇭'},
      'BD': {'code': '+880', 'country': 'Bangladesh', 'flag': '🇧🇩'},
      'BB': {'code': '+1', 'country': 'Barbados', 'flag': '🇧🇧'},
      'BY': {'code': '+375', 'country': 'Belarus', 'flag': '🇧🇾'},
      'BE': {'code': '+32', 'country': 'Belgium', 'flag': '🇧🇪'},
      'BZ': {'code': '+501', 'country': 'Belize', 'flag': '🇧🇿'},
      'BJ': {'code': '+229', 'country': 'Benin', 'flag': '🇧🇯'},
      'BM': {'code': '+1', 'country': 'Bermuda', 'flag': '🇧🇲'},
      'BT': {'code': '+975', 'country': 'Bhutan', 'flag': '🇧🇹'},
      'BO': {'code': '+591', 'country': 'Bolivia', 'flag': '🇧🇴'},
      'BA': {'code': '+387', 'country': 'Bosnia and Herzegovina', 'flag': '🇧🇦'},
      'BW': {'code': '+267', 'country': 'Botswana', 'flag': '🇧🇼'},
      'BR': {'code': '+55', 'country': 'Brazil', 'flag': '🇧🇷'},
      'BN': {'code': '+673', 'country': 'Brunei', 'flag': '🇧🇳'},
      'BG': {'code': '+359', 'country': 'Bulgaria', 'flag': '🇧🇬'},
      'BF': {'code': '+226', 'country': 'Burkina Faso', 'flag': '🇧🇫'},
      'BI': {'code': '+257', 'country': 'Burundi', 'flag': '🇧🇮'},
      'KH': {'code': '+855', 'country': 'Cambodia', 'flag': '🇰🇭'},
      'CM': {'code': '+237', 'country': 'Cameroon', 'flag': '🇨🇲'},
      'CA': {'code': '+1', 'country': 'Canada', 'flag': '🇨🇦'},
      'CV': {'code': '+238', 'country': 'Cape Verde', 'flag': '🇨🇻'},
      'KY': {'code': '+1', 'country': 'Cayman Islands', 'flag': '🇰🇾'},
      'CF': {'code': '+236', 'country': 'Central African Republic', 'flag': '🇨🇫'},
      'TD': {'code': '+235', 'country': 'Chad', 'flag': '🇹🇩'},
      'CL': {'code': '+56', 'country': 'Chile', 'flag': '🇨🇱'},
      'CN': {'code': '+86', 'country': 'China', 'flag': '🇨🇳'},
      'CO': {'code': '+57', 'country': 'Colombia', 'flag': '🇨🇴'},
      'KM': {'code': '+269', 'country': 'Comoros', 'flag': '🇰🇲'},
      'CG': {'code': '+242', 'country': 'Congo', 'flag': '🇨🇬'},
      'CD': {'code': '+243', 'country': 'Congo (DRC)', 'flag': '🇨🇩'},
      'CK': {'code': '+682', 'country': 'Cook Islands', 'flag': '🇨🇰'},
      'CR': {'code': '+506', 'country': 'Costa Rica', 'flag': '🇨🇷'},
      'CI': {'code': '+225', 'country': "Côte d'Ivoire", 'flag': '🇨🇮'},
      'HR': {'code': '+385', 'country': 'Croatia', 'flag': '🇭🇷'},
      'CU': {'code': '+53', 'country': 'Cuba', 'flag': '🇨🇺'},
      'CW': {'code': '+599', 'country': 'Curaçao', 'flag': '🇨🇼'},
      'CY': {'code': '+357', 'country': 'Cyprus', 'flag': '🇨🇾'},
      'CZ': {'code': '+420', 'country': 'Czech Republic', 'flag': '🇨🇿'},
      'DK': {'code': '+45', 'country': 'Denmark', 'flag': '🇩🇰'},
      'DJ': {'code': '+253', 'country': 'Djibouti', 'flag': '🇩🇯'},
      'DM': {'code': '+1', 'country': 'Dominica', 'flag': '🇩🇲'},
      'DO': {'code': '+1', 'country': 'Dominican Republic', 'flag': '🇩🇴'},
      'EC': {'code': '+593', 'country': 'Ecuador', 'flag': '🇪🇨'},
      'EG': {'code': '+20', 'country': 'Egypt', 'flag': '🇪🇬'},
      'SV': {'code': '+503', 'country': 'El Salvador', 'flag': '🇸🇻'},
      'GQ': {'code': '+240', 'country': 'Equatorial Guinea', 'flag': '🇬🇶'},
      'ER': {'code': '+291', 'country': 'Eritrea', 'flag': '🇪🇷'},
      'EE': {'code': '+372', 'country': 'Estonia', 'flag': '🇪🇪'},
      'ET': {'code': '+251', 'country': 'Ethiopia', 'flag': '🇪🇹'},
      'FK': {'code': '+500', 'country': 'Falkland Islands', 'flag': '🇫🇰'},
      'FO': {'code': '+298', 'country': 'Faroe Islands', 'flag': '🇫🇴'},
      'FJ': {'code': '+679', 'country': 'Fiji', 'flag': '🇫🇯'},
      'FI': {'code': '+358', 'country': 'Finland', 'flag': '🇫🇮'},
      'FR': {'code': '+33', 'country': 'France', 'flag': '🇫🇷'},
      'GF': {'code': '+594', 'country': 'French Guiana', 'flag': '🇬🇫'},
      'PF': {'code': '+689', 'country': 'French Polynesia', 'flag': '🇵🇫'},
      'GA': {'code': '+241', 'country': 'Gabon', 'flag': '🇬🇦'},
      'GM': {'code': '+220', 'country': 'Gambia', 'flag': '🇬🇲'},
      'GE': {'code': '+995', 'country': 'Georgia', 'flag': '🇬🇪'},
      'DE': {'code': '+49', 'country': 'Germany', 'flag': '🇩🇪'},
      'GH': {'code': '+233', 'country': 'Ghana', 'flag': '🇬🇭'},
      'GI': {'code': '+350', 'country': 'Gibraltar', 'flag': '🇬🇮'},
      'GR': {'code': '+30', 'country': 'Greece', 'flag': '🇬🇷'},
      'GL': {'code': '+299', 'country': 'Greenland', 'flag': '🇬🇱'},
      'GD': {'code': '+1', 'country': 'Grenada', 'flag': '🇬🇩'},
      'GP': {'code': '+590', 'country': 'Guadeloupe', 'flag': '🇬🇵'},
      'GU': {'code': '+1', 'country': 'Guam', 'flag': '🇬🇺'},
      'GT': {'code': '+502', 'country': 'Guatemala', 'flag': '🇬🇹'},
      'GN': {'code': '+224', 'country': 'Guinea', 'flag': '🇬🇳'},
      'GW': {'code': '+245', 'country': 'Guinea-Bissau', 'flag': '🇬🇼'},
      'GY': {'code': '+592', 'country': 'Guyana', 'flag': '🇬🇾'},
      'HT': {'code': '+509', 'country': 'Haiti', 'flag': '🇭🇹'},
      'HN': {'code': '+504', 'country': 'Honduras', 'flag': '🇭🇳'},
      'HK': {'code': '+852', 'country': 'Hong Kong', 'flag': '🇭🇰'},
      'HU': {'code': '+36', 'country': 'Hungary', 'flag': '🇭🇺'},
      'IS': {'code': '+354', 'country': 'Iceland', 'flag': '🇮🇸'},
      'IN': {'code': '+91', 'country': 'India', 'flag': '🇮🇳'},
      'ID': {'code': '+62', 'country': 'Indonesia', 'flag': '🇮🇩'},
      'IR': {'code': '+98', 'country': 'Iran', 'flag': '🇮🇷'},
      'IQ': {'code': '+964', 'country': 'Iraq', 'flag': '🇮🇶'},
      'IE': {'code': '+353', 'country': 'Ireland', 'flag': '🇮🇪'},
      'IL': {'code': '+972', 'country': 'Israel', 'flag': '🇮🇱'},
      'IT': {'code': '+39', 'country': 'Italy', 'flag': '🇮🇹'},
      'JM': {'code': '+1', 'country': 'Jamaica', 'flag': '🇯🇲'},
      'JP': {'code': '+81', 'country': 'Japan', 'flag': '🇯🇵'},
      'JO': {'code': '+962', 'country': 'Jordan', 'flag': '🇯🇴'},
      'KZ': {'code': '+7', 'country': 'Kazakhstan', 'flag': '🇰🇿'},
      'KE': {'code': '+254', 'country': 'Kenya', 'flag': '🇰🇪'},
      'KI': {'code': '+686', 'country': 'Kiribati', 'flag': '🇰🇮'},
      'KP': {'code': '+850', 'country': 'North Korea', 'flag': '🇰🇵'},
      'KR': {'code': '+82', 'country': 'South Korea', 'flag': '🇰🇷'},
      'KW': {'code': '+965', 'country': 'Kuwait', 'flag': '🇰🇼'},
      'KG': {'code': '+996', 'country': 'Kyrgyzstan', 'flag': '🇰🇬'},
      'LA': {'code': '+856', 'country': 'Laos', 'flag': '🇱🇦'},
      'LV': {'code': '+371', 'country': 'Latvia', 'flag': '🇱🇻'},
      'LB': {'code': '+961', 'country': 'Lebanon', 'flag': '🇱🇧'},
      'LS': {'code': '+266', 'country': 'Lesotho', 'flag': '🇱🇸'},
      'LR': {'code': '+231', 'country': 'Liberia', 'flag': '🇱🇷'},
      'LY': {'code': '+218', 'country': 'Libya', 'flag': '🇱🇾'},
      'LI': {'code': '+423', 'country': 'Liechtenstein', 'flag': '🇱🇮'},
      'LT': {'code': '+370', 'country': 'Lithuania', 'flag': '🇱🇹'},
      'LU': {'code': '+352', 'country': 'Luxembourg', 'flag': '🇱🇺'},
      'MO': {'code': '+853', 'country': 'Macau', 'flag': '🇲🇴'},
      'MK': {'code': '+389', 'country': 'North Macedonia', 'flag': '🇲🇰'},
      'MG': {'code': '+261', 'country': 'Madagascar', 'flag': '🇲🇬'},
      'MW': {'code': '+265', 'country': 'Malawi', 'flag': '🇲🇼'},
      'MY': {'code': '+60', 'country': 'Malaysia', 'flag': '🇲🇾'},
      'MV': {'code': '+960', 'country': 'Maldives', 'flag': '🇲🇻'},
      'ML': {'code': '+223', 'country': 'Mali', 'flag': '🇲🇱'},
      'MT': {'code': '+356', 'country': 'Malta', 'flag': '🇲🇹'},
      'MH': {'code': '+692', 'country': 'Marshall Islands', 'flag': '🇲🇭'},
      'MQ': {'code': '+596', 'country': 'Martinique', 'flag': '🇲🇶'},
      'MR': {'code': '+222', 'country': 'Mauritania', 'flag': '🇲🇷'},
      'MU': {'code': '+230', 'country': 'Mauritius', 'flag': '🇲🇺'},
      'YT': {'code': '+262', 'country': 'Mayotte', 'flag': '🇾🇹'},
      'MX': {'code': '+52', 'country': 'Mexico', 'flag': '🇲🇽'},
      'FM': {'code': '+691', 'country': 'Micronesia', 'flag': '🇫🇲'},
      'MD': {'code': '+373', 'country': 'Moldova', 'flag': '🇲🇩'},
      'MC': {'code': '+377', 'country': 'Monaco', 'flag': '🇲🇨'},
      'MN': {'code': '+976', 'country': 'Mongolia', 'flag': '🇲🇳'},
      'ME': {'code': '+382', 'country': 'Montenegro', 'flag': '🇲🇪'},
      'MS': {'code': '+1', 'country': 'Montserrat', 'flag': '🇲🇸'},
      'MA': {'code': '+212', 'country': 'Morocco', 'flag': '🇲🇦'},
      'MZ': {'code': '+258', 'country': 'Mozambique', 'flag': '🇲🇿'},
      'MM': {'code': '+95', 'country': 'Myanmar', 'flag': '🇲🇲'},
      'NA': {'code': '+264', 'country': 'Namibia', 'flag': '🇳🇦'},
      'NR': {'code': '+674', 'country': 'Nauru', 'flag': '🇳🇷'},
      'NP': {'code': '+977', 'country': 'Nepal', 'flag': '🇳🇵'},
      'NL': {'code': '+31', 'country': 'Netherlands', 'flag': '🇳🇱'},
      'NC': {'code': '+687', 'country': 'New Caledonia', 'flag': '🇳🇨'},
      'NZ': {'code': '+64', 'country': 'New Zealand', 'flag': '🇳🇿'},
      'NI': {'code': '+505', 'country': 'Nicaragua', 'flag': '🇳🇮'},
      'NE': {'code': '+227', 'country': 'Niger', 'flag': '🇳🇪'},
      'NG': {'code': '+234', 'country': 'Nigeria', 'flag': '🇳🇬'},
      'NU': {'code': '+683', 'country': 'Niue', 'flag': '🇳🇺'},
      'NF': {'code': '+672', 'country': 'Norfolk Island', 'flag': '🇳🇫'},
      'MP': {'code': '+1', 'country': 'Northern Mariana Islands', 'flag': '🇲🇵'},
      'NO': {'code': '+47', 'country': 'Norway', 'flag': '🇳🇴'},
      'OM': {'code': '+968', 'country': 'Oman', 'flag': '🇴🇲'},
      'PK': {'code': '+92', 'country': 'Pakistan', 'flag': '🇵🇰'},
      'PW': {'code': '+680', 'country': 'Palau', 'flag': '🇵🇼'},
      'PS': {'code': '+970', 'country': 'Palestine', 'flag': '🇵🇸'},
      'PA': {'code': '+507', 'country': 'Panama', 'flag': '🇵🇦'},
      'PG': {'code': '+675', 'country': 'Papua New Guinea', 'flag': '🇵🇬'},
      'PY': {'code': '+595', 'country': 'Paraguay', 'flag': '🇵🇾'},
      'PE': {'code': '+51', 'country': 'Peru', 'flag': '🇵🇪'},
      'PH': {'code': '+63', 'country': 'Philippines', 'flag': '🇵🇭'},
      'PN': {'code': '+64', 'country': 'Pitcairn', 'flag': '🇵🇳'},
      'PL': {'code': '+48', 'country': 'Poland', 'flag': '🇵🇱'},
      'PT': {'code': '+351', 'country': 'Portugal', 'flag': '🇵🇹'},
      'PR': {'code': '+1', 'country': 'Puerto Rico', 'flag': '🇵🇷'},
      'QA': {'code': '+974', 'country': 'Qatar', 'flag': '🇶🇦'},
      'RE': {'code': '+262', 'country': 'Réunion', 'flag': '🇷🇪'},
      'RO': {'code': '+40', 'country': 'Romania', 'flag': '🇷🇴'},
      'RU': {'code': '+7', 'country': 'Russia', 'flag': '🇷🇺'},
      'RW': {'code': '+250', 'country': 'Rwanda', 'flag': '🇷🇼'},
      'WS': {'code': '+685', 'country': 'Samoa', 'flag': '🇼🇸'},
      'SM': {'code': '+378', 'country': 'San Marino', 'flag': '🇸🇲'},
      'ST': {'code': '+239', 'country': 'São Tomé and Príncipe', 'flag': '🇸🇹'},
      'SA': {'code': '+966', 'country': 'Saudi Arabia', 'flag': '🇸🇦'},
      'SN': {'code': '+221', 'country': 'Senegal', 'flag': '🇸🇳'},
      'RS': {'code': '+381', 'country': 'Serbia', 'flag': '🇷🇸'},
      'SC': {'code': '+248', 'country': 'Seychelles', 'flag': '🇸🇨'},
      'SL': {'code': '+232', 'country': 'Sierra Leone', 'flag': '🇸🇱'},
      'SG': {'code': '+65', 'country': 'Singapore', 'flag': '🇸🇬'},
      'SX': {'code': '+1', 'country': 'Sint Maarten', 'flag': '🇸🇽'},
      'SK': {'code': '+421', 'country': 'Slovakia', 'flag': '🇸🇰'},
      'SI': {'code': '+386', 'country': 'Slovenia', 'flag': '🇸🇮'},
      'SB': {'code': '+677', 'country': 'Solomon Islands', 'flag': '🇸🇧'},
      'SO': {'code': '+252', 'country': 'Somalia', 'flag': '🇸🇴'},
      'ZA': {'code': '+27', 'country': 'South Africa', 'flag': '🇿🇦'},
      'SS': {'code': '+211', 'country': 'South Sudan', 'flag': '🇸🇸'},
      'ES': {'code': '+34', 'country': 'Spain', 'flag': '🇪🇸'},
      'LK': {'code': '+94', 'country': 'Sri Lanka', 'flag': '🇱🇰'},
      'SD': {'code': '+249', 'country': 'Sudan', 'flag': '🇸🇩'},
      'SR': {'code': '+597', 'country': 'Suriname', 'flag': '🇸🇷'},
      'SZ': {'code': '+268', 'country': 'Eswatini', 'flag': '🇸🇿'},
      'SE': {'code': '+46', 'country': 'Sweden', 'flag': '🇸🇪'},
      'CH': {'code': '+41', 'country': 'Switzerland', 'flag': '🇨🇭'},
      'SY': {'code': '+963', 'country': 'Syria', 'flag': '🇸🇾'},
      'TW': {'code': '+886', 'country': 'Taiwan', 'flag': '🇹🇼'},
      'TJ': {'code': '+992', 'country': 'Tajikistan', 'flag': '🇹🇯'},
      'TZ': {'code': '+255', 'country': 'Tanzania', 'flag': '🇹🇿'},
      'TH': {'code': '+66', 'country': 'Thailand', 'flag': '🇹🇭'},
      'TL': {'code': '+670', 'country': 'Timor-Leste', 'flag': '🇹🇱'},
      'TG': {'code': '+228', 'country': 'Togo', 'flag': '🇹🇬'},
      'TK': {'code': '+690', 'country': 'Tokelau', 'flag': '🇹🇰'},
      'TO': {'code': '+676', 'country': 'Tonga', 'flag': '🇹🇴'},
      'TT': {'code': '+1', 'country': 'Trinidad and Tobago', 'flag': '🇹🇹'},
      'TN': {'code': '+216', 'country': 'Tunisia', 'flag': '🇹🇳'},
      'TR': {'code': '+90', 'country': 'Turkey', 'flag': '🇹🇷'},
      'TM': {'code': '+993', 'country': 'Turkmenistan', 'flag': '🇹🇲'},
      'TC': {'code': '+1', 'country': 'Turks and Caicos Islands', 'flag': '🇹🇨'},
      'TV': {'code': '+688', 'country': 'Tuvalu', 'flag': '🇹🇻'},
      'UG': {'code': '+256', 'country': 'Uganda', 'flag': '🇺🇬'},
      'UA': {'code': '+380', 'country': 'Ukraine', 'flag': '🇺🇦'},
      'AE': {'code': '+971', 'country': 'United Arab Emirates', 'flag': '🇦🇪'},
      'GB': {'code': '+44', 'country': 'United Kingdom', 'flag': '🇬🇧'},
      'US': {'code': '+1', 'country': 'United States', 'flag': '🇺🇸'},
      'UY': {'code': '+598', 'country': 'Uruguay', 'flag': '🇺🇾'},
      'UZ': {'code': '+998', 'country': 'Uzbekistan', 'flag': '🇺🇿'},
      'VU': {'code': '+678', 'country': 'Vanuatu', 'flag': '🇻🇺'},
      'VA': {'code': '+379', 'country': 'Vatican City', 'flag': '🇻🇦'},
      'VE': {'code': '+58', 'country': 'Venezuela', 'flag': '🇻🇪'},
      'VN': {'code': '+84', 'country': 'Vietnam', 'flag': '🇻🇳'},
      'VG': {'code': '+1', 'country': 'British Virgin Islands', 'flag': '🇻🇬'},
      'VI': {'code': '+1', 'country': 'U.S. Virgin Islands', 'flag': '🇻🇮'},
      'WF': {'code': '+681', 'country': 'Wallis and Futuna', 'flag': '🇼🇫'},
      'EH': {'code': '+212', 'country': 'Western Sahara', 'flag': '🇪🇭'},
      'YE': {'code': '+967', 'country': 'Yemen', 'flag': '🇾🇪'},
      'ZM': {'code': '+260', 'country': 'Zambia', 'flag': '🇿🇲'},
      'ZW': {'code': '+263', 'country': 'Zimbabwe', 'flag': '🇿🇼'},
    };
    return isoToCountryInfo[isoCode] ?? {'code': '+1', 'country': 'United States', 'flag': '🇺🇸'};
  }

  bool get hasVehicle =>
      vehicleBrand != null &&
      vehicleModel != null &&
      vehicleColor != null &&
      licensePlate != null;

  bool get hasCompletePersonalInfo =>
      name.isNotEmpty &&
      surname.isNotEmpty &&
      email.isNotEmpty &&
      phoneNumber.isNotEmpty &&
      countryCode.isNotEmpty;

  // Show onboarding hints for users with less than 5 completed trips
  bool get shouldShowOnboardingHints => completedTripsCount < 5;
}
