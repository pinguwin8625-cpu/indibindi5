import '../models/user.dart';
import '../services/mock_users.dart';
import '../services/rating_service.dart';

class AuthService {
  static User? _currentUser;

  // Default password for all mock users (for testing)
  static const String defaultPassword = 'test123';

  // Get current logged in user with live rating
  static User? get currentUser {
    if (_currentUser == null) return null;
    // Always return user with live rating from RatingService
    final liveRating = RatingService().getUserAverageRating(_currentUser!.id);
    return _currentUser!.copyWith(rating: liveRating);
  }

  // Check if user is logged in
  static bool get isLoggedIn => _currentUser != null;

  // Login with email/phone and password
  static bool login(String emailOrPhone, String password) {
    print('🔐 Login attempt: emailOrPhone="$emailOrPhone", password="$password"');

    // Try to find user by email first, then by phone number
    User? user;

    // Try email first
    user = MockUsers.users.firstWhere(
      (u) => u.email.toLowerCase() == emailOrPhone.toLowerCase(),
      orElse: () {
        print('🔐 Email not found, trying phone number...');

        // If not found by email, try by full phone number (with country code)
        final cleanedInput = emailOrPhone.replaceAll(RegExp(r'[^\d+]'), '');
        print('🔐 Cleaned input: "$cleanedInput"');

        final foundUser = MockUsers.users.firstWhere(
          (u) {
            final cleanedUserPhone = u.formattedPhone.replaceAll(RegExp(r'[^\d+]'), '');
            print('🔐 Checking user ${u.fullName}: formattedPhone="${u.formattedPhone}", cleaned="$cleanedUserPhone"');
            return cleanedUserPhone == cleanedInput;
          },
          orElse: () {
            print('🔐 Phone not found either');
            throw Exception('User not found');
          },
        );

        print('🔐 Found user by phone: ${foundUser.fullName}');
        return foundUser;
      },
    );

    if (user.email.toLowerCase() == emailOrPhone.toLowerCase()) {
      print('🔐 Found user by email: ${user.fullName}');
    }

    // Check password (all mock users use default password)
    if (password == defaultPassword) {
      _currentUser = user;
      MockUsers.currentUser = user;
      print('🔐 Login successful for: ${user.fullName}');
      return true;
    }

    print('🔐 Password incorrect');
    return false;
  }

  // Auto-login with just email (password auto-filled for testing)
  static bool quickLogin(String email) {
    return login(email, defaultPassword);
  }

  // Login with user ID (for quick testing)
  static bool loginWithId(String userId) {
    print('🔐 AuthService.loginWithId called with userId: $userId');
    final user = MockUsers.getUserById(userId);
    print('🔐 Found user: ${user?.fullName ?? "null"}');
    if (user != null) {
      _currentUser = user;
      MockUsers.currentUser = user;
      print('🔐 Login successful for: ${user.fullName}');
      return true;
    }
    print('🔐 Login failed - user not found');
    return false;
  }

  // Logout
  static void logout() {
    _currentUser = null;
  }

  // Get all available test users (for login screen)
  static List<Map<String, String>> getTestUsers() {
    return MockUsers.users.map((user) {
      return {'id': user.id, 'name': user.fullName, 'email': user.email};
    }).toList();
  }

  // Update current user profile
  static void updateProfile(User updatedUser) {
    if (_currentUser?.id == updatedUser.id) {
      _currentUser = updatedUser;
      MockUsers.updateCurrentUser(updatedUser);
    }
  }
}
