import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  final String countryIso;
  
  PhoneNumberFormatter(this.countryIso);
  
  // Public method to format a phone number
  String format(String phoneNumber) {
    final text = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (text.isEmpty) return '';
    return _formatByCountry(text);
  }
  
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), ''); // Remove non-digits
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    String formatted = _formatByCountry(text);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
  
  String _formatByCountry(String digits) {
    // Format based on country ISO code
    switch (countryIso) {
      case 'US': // United States: (123) 456-7890
      case 'CA': // Canada: (123) 456-7890
        return _formatNANP(digits);
      
      case 'GB': // UK: 07123 456789 or 0161 123 4567
        return _formatUK(digits);
      
      case 'FR': // France: 01 23 45 67 89
        return _formatFrance(digits);
      
      case 'DE': // Germany: 0123 456789
        return _formatGermany(digits);
      
      case 'IT': // Italy: 012 345 6789
        return _formatItaly(digits);
      
      case 'ES': // Spain: 612 34 56 78
        return _formatSpain(digits);
      
      case 'BR': // Brazil: (11) 91234-5678
        return _formatBrazil(digits);
      
      case 'MX': // Mexico: 55 1234 5678
        return _formatMexico(digits);
      
      case 'JP': // Japan: 090-1234-5678
        return _formatJapan(digits);
      
      case 'CN': // China: 138 0013 8000
        return _formatChina(digits);
      
      case 'IN': // India: 98765 43210
        return _formatIndia(digits);
      
      case 'AU': // Australia: 0412 345 678
        return _formatAustralia(digits);
      
      case 'KR': // South Korea: 010-1234-5678
        return _formatKorea(digits);
      
      case 'TR': // Turkey: 0532 123 45 67
        return _formatTurkey(digits);
      
      default:
        // Default formatting: groups of 3-4 digits
        return _formatDefault(digits);
    }
  }
  
  // US/Canada: (123) 456-7890
  String _formatNANP(String digits) {
    if (digits.length <= 3) return digits;
    if (digits.length <= 6) return '(${digits.substring(0, 3)}) ${digits.substring(3)}';
    if (digits.length <= 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6, 10)}';
  }
  
  // UK: 07123 456789
  String _formatUK(String digits) {
    if (digits.length <= 5) return digits;
    if (digits.length <= 11) {
      return '${digits.substring(0, 5)} ${digits.substring(5)}';
    }
    return '${digits.substring(0, 5)} ${digits.substring(5, 11)}';
  }
  
  // France: 01 23 45 67 89
  String _formatFrance(String digits) {
    String result = '';
    for (int i = 0; i < digits.length && i < 10; i++) {
      if (i > 0 && i % 2 == 0) result += ' ';
      result += digits[i];
    }
    return result;
  }
  
  // Germany: 0123 456789
  String _formatGermany(String digits) {
    if (digits.length <= 4) return digits;
    if (digits.length <= 11) {
      return '${digits.substring(0, 4)} ${digits.substring(4)}';
    }
    return '${digits.substring(0, 4)} ${digits.substring(4, 11)}';
  }
  
  // Italy: 012 345 6789
  String _formatItaly(String digits) {
    if (digits.length <= 3) return digits;
    if (digits.length <= 6) return '${digits.substring(0, 3)} ${digits.substring(3)}';
    if (digits.length <= 10) {
      return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
    }
    return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6, 10)}';
  }
  
  // Spain: 612 34 56 78
  String _formatSpain(String digits) {
    if (digits.length <= 3) return digits;
    if (digits.length <= 5) return '${digits.substring(0, 3)} ${digits.substring(3)}';
    if (digits.length <= 7) {
      return '${digits.substring(0, 3)} ${digits.substring(3, 5)} ${digits.substring(5)}';
    }
    if (digits.length <= 9) {
      return '${digits.substring(0, 3)} ${digits.substring(3, 5)} ${digits.substring(5, 7)} ${digits.substring(7)}';
    }
    return '${digits.substring(0, 3)} ${digits.substring(3, 5)} ${digits.substring(5, 7)} ${digits.substring(7, 9)}';
  }
  
  // Brazil: (11) 91234-5678
  String _formatBrazil(String digits) {
    if (digits.length <= 2) return digits;
    if (digits.length <= 7) return '(${digits.substring(0, 2)}) ${digits.substring(2)}';
    if (digits.length <= 11) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}';
    }
    return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7, 11)}';
  }
  
  // Mexico: 55 1234 5678
  String _formatMexico(String digits) {
    if (digits.length <= 2) return digits;
    if (digits.length <= 6) return '${digits.substring(0, 2)} ${digits.substring(2)}';
    if (digits.length <= 10) {
      return '${digits.substring(0, 2)} ${digits.substring(2, 6)} ${digits.substring(6)}';
    }
    return '${digits.substring(0, 2)} ${digits.substring(2, 6)} ${digits.substring(6, 10)}';
  }
  
  // Japan: 090-1234-5678
  String _formatJapan(String digits) {
    if (digits.length <= 3) return digits;
    if (digits.length <= 7) return '${digits.substring(0, 3)}-${digits.substring(3)}';
    if (digits.length <= 11) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    }
    return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7, 11)}';
  }
  
  // China: 138 0013 8000
  String _formatChina(String digits) {
    if (digits.length <= 3) return digits;
    if (digits.length <= 7) return '${digits.substring(0, 3)} ${digits.substring(3)}';
    if (digits.length <= 11) {
      return '${digits.substring(0, 3)} ${digits.substring(3, 7)} ${digits.substring(7)}';
    }
    return '${digits.substring(0, 3)} ${digits.substring(3, 7)} ${digits.substring(7, 11)}';
  }
  
  // India: 98765 43210
  String _formatIndia(String digits) {
    if (digits.length <= 5) return digits;
    if (digits.length <= 10) {
      return '${digits.substring(0, 5)} ${digits.substring(5)}';
    }
    return '${digits.substring(0, 5)} ${digits.substring(5, 10)}';
  }
  
  // Australia: 0412 345 678
  String _formatAustralia(String digits) {
    if (digits.length <= 4) return digits;
    if (digits.length <= 7) return '${digits.substring(0, 4)} ${digits.substring(4)}';
    if (digits.length <= 10) {
      return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7)}';
    }
    return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7, 10)}';
  }
  
  // South Korea: 010-1234-5678
  String _formatKorea(String digits) {
    if (digits.length <= 3) return digits;
    if (digits.length <= 7) return '${digits.substring(0, 3)}-${digits.substring(3)}';
    if (digits.length <= 11) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    }
    return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7, 11)}';
  }
  
  // Turkey: 0532 123 45 67
  String _formatTurkey(String digits) {
    if (digits.length <= 4) return digits;
    if (digits.length <= 7) return '${digits.substring(0, 4)} ${digits.substring(4)}';
    if (digits.length <= 9) {
      return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7)}';
    }
    if (digits.length <= 10) {
      return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7, 9)} ${digits.substring(9)}';
    }
    return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7, 9)} ${digits.substring(9, 10)}';
  }
  
  // Default: XXX XXX XXXX
  String _formatDefault(String digits) {
    if (digits.length <= 3) return digits;
    if (digits.length <= 6) return '${digits.substring(0, 3)} ${digits.substring(3)}';
    if (digits.length <= 10) {
      return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
    }
    return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6, 10)}';
  }
}
