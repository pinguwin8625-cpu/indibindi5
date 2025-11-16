import '../models/user.dart';
import '../services/mock_users.dart';

class AuthService {
  static User? _currentUser;
  
  // Default password for all mock users (for testing)
  static const String defaultPassword = 'test123';
  
  // Get current logged in user
  static User? get currentUser => _currentUser;
  
  // Check if user is logged in
  static bool get isLoggedIn => _currentUser != null;
  
  // Login with email and password
  static bool login(String email, String password) {
    // Find user by email
    final user = MockUsers.users.firstWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
      orElse: () => throw Exception('User not found'),
    );
    
    // Check password (all mock users use default password)
    if (password == defaultPassword) {
      _currentUser = user;
      MockUsers.currentUser = user;
      return true;
    }
    
    return false;
  }
  
  // Auto-login with just email (password auto-filled for testing)
  static bool quickLogin(String email) {
    return login(email, defaultPassword);
  }
  
  // Login with user ID (for quick testing)
  static bool loginWithId(String userId) {
    final user = MockUsers.getUserById(userId);
    if (user != null) {
      _currentUser = user;
      MockUsers.currentUser = user;
      return true;
    }
    return false;
  }
  
  // Logout
  static void logout() {
    _currentUser = null;
  }
  
  // Get all available test users (for login screen)
  static List<Map<String, String>> getTestUsers() {
    return MockUsers.users.map((user) {
      return {
        'id': user.id,
        'name': user.fullName,
        'email': user.email,
      };
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
