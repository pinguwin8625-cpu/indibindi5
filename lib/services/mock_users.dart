import '../models/user.dart';
import 'rating_service.dart';

class MockUsers {
  static final List<User> users = [
    // Admin User
    User(
      id: 'admin',
      name: 'Admin',
      surname: 'User',
      title: 'Admin',
      email: 'admin@indibindi.com',
      phoneNumber: '5550000000',
      countryCode: 'TR',
      profilePhotoUrl: 'assets/images/profile_admin.jpeg',
      vehicleBrand: null,
      vehicleModel: null,
      vehicleColor: null,
      licensePlate: null,
      isAdmin: true,
      rating: 0.0,
    ),

    // User 1: Complete profile with vehicle (Driver)
    User(
      id: '1',
      name: 'Ahmet',
      surname: 'Yılmaz',
      title: 'Mr.',
      email: 'ahmet.yilmaz@example.com',
      phoneNumber: '5551234567',
      countryCode: 'TR',
      profilePhotoUrl: 'assets/images/profile_ahmet.jpeg',
      vehicleBrand: 'Volkswagen',
      vehicleModel: 'Golf',
      vehicleColor: 'White',
      licensePlate: '34ABC123',
      rating: 0.0,
    ),

    // User 2: Complete profile with vehicle (Driver)
    User(
      id: '2',
      name: 'Sarah',
      surname: 'Johnson',
      title: 'Ms.',
      email: 'sarah.johnson@example.com',
      phoneNumber: '5559876543',
      countryCode: 'US',
      profilePhotoUrl: 'assets/images/profile_sarah.jpeg',
      vehicleBrand: 'Toyota',
      vehicleModel: 'Corolla',
      vehicleColor: 'Silver',
      licensePlate: '06DEF456',
      rating: 0.0,
    ),

    // User 3: Complete profile with vehicle (Driver)
    User(
      id: '3',
      name: 'Elena',
      surname: 'García',
      title: 'Dr.',
      email: 'elena.garcia@example.com',
      phoneNumber: '612345678',
      countryCode: 'ES',
      profilePhotoUrl: 'assets/images/profile_elena.jpeg',
      vehicleBrand: 'Honda',
      vehicleModel: 'Civic',
      vehicleColor: 'Red',
      licensePlate: '34GHI789',
      rating: 0.0,
    ),

    // User 4: Complete profile with vehicle (Driver)
    User(
      id: '4',
      name: 'Mohammed',
      surname: 'Al-Rahman',
      title: 'Mr.',
      email: 'mohammed.rahman@example.com',
      phoneNumber: '501234567',
      countryCode: 'AE',
      profilePhotoUrl: 'assets/images/profile_mohammed.jpeg',
      vehicleBrand: 'BMW',
      vehicleModel: '3 Series',
      vehicleColor: 'Black',
      licensePlate: '35XYZ789',
      rating: 0.0,
    ),

    // User 5: Profile without vehicle (for testing vehicle warning)
    User(
      id: '5',
      name: 'Yuki',
      surname: 'Tanaka',
      title: 'Ms.',
      email: 'yuki.tanaka@example.com',
      phoneNumber: '9012345678',
      countryCode: 'JP',
      profilePhotoUrl: 'assets/images/profile_yuki.jpeg',
      vehicleBrand: null,
      vehicleModel: null,
      vehicleColor: null,
      licensePlate: null,
      rating: 0.0,
    ),
  ];

  // Get user by ID with live rating from RatingService
  static User? getUserById(String id) {
    try {
      final user = users.firstWhere(
        (user) => user.id == id,
        orElse: () => throw Exception('User not found'),
      );
      // Get live rating from RatingService
      final liveRating = RatingService().getUserAverageRating(id);
      return user.copyWith(rating: liveRating);
    } catch (e) {
      return null;
    }
  }

  // Get live rating for a user
  static double getLiveRating(String userId) {
    return RatingService().getUserAverageRating(userId);
  }

  // Get all drivers (users with vehicles)
  static List<User> getDrivers() {
    return users.where((user) => user.hasVehicle).toList();
  }

  // Get all riders (users without vehicles)
  static List<User> getRiders() {
    return users.where((user) => !user.hasVehicle).toList();
  }

  // Get random user
  static User getRandomUser() {
    return users[DateTime.now().millisecond % users.length];
  }

  // Current logged in user (for testing, defaults to first user)
  static User currentUser = users[0];

  // Update current user
  static void updateCurrentUser(User updatedUser) {
    final index = users.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      users[index] = updatedUser;
      if (currentUser.id == updatedUser.id) {
        currentUser = updatedUser;
      }
    }
  }

  // Switch current user (for testing different user scenarios)
  static void switchToUser(String userId) {
    final user = getUserById(userId);
    if (user != null) {
      currentUser = user;
    }
  }
}
