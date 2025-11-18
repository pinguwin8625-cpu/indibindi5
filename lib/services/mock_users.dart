import '../models/user.dart';

class MockUsers {
  static final List<User> users = [
    // Admin User
    User(
      id: 'admin',
      name: 'Admin',
      surname: 'User',
      email: 'admin@indibindi.com',
      phoneNumber: '5550000000',
      countryCode: '+90',
      profilePhotoUrl: 'assets/images/profile_admin.jpeg',
      vehicleBrand: null,
      vehicleModel: null,
      vehicleColor: null,
      licensePlate: null,
      isAdmin: true,
      rating: 5.0,
    ),

    // User 1: Complete profile with vehicle (Driver)
    User(
      id: '1',
      name: 'Ahmet',
      surname: 'Yılmaz',
      email: 'ahmet.yilmaz@example.com',
      phoneNumber: '5551234567',
      countryCode: '+90',
      profilePhotoUrl: 'assets/images/profile_ahmet.jpeg',
      vehicleBrand: 'Volkswagen',
      vehicleModel: 'Golf',
      vehicleColor: 'White',
      licensePlate: '34ABC123',
      rating: 4.8,
    ),

    // User 2: Complete profile with vehicle (Driver)
    User(
      id: '2',
      name: 'Sarah',
      surname: 'Johnson',
      email: 'sarah.johnson@example.com',
      phoneNumber: '5559876543',
      countryCode: '+1',
      profilePhotoUrl: 'assets/images/profile_sarah.jpeg',
      vehicleBrand: 'Toyota',
      vehicleModel: 'Corolla',
      vehicleColor: 'Silver',
      licensePlate: '06DEF456',
      rating: 4.9,
    ),

    // User 3: Complete profile without vehicle (Rider)
    User(
      id: '3',
      name: 'Elena',
      surname: 'García',
      email: 'elena.garcia@example.com',
      phoneNumber: '612345678',
      countryCode: '+34',
      profilePhotoUrl: 'assets/images/profile_elena.jpeg',
      vehicleBrand: null,
      vehicleModel: null,
      vehicleColor: null,
      licensePlate: null,
      rating: 4.7,
    ),

    // User 4: Complete profile with vehicle (Driver)
    User(
      id: '4',
      name: 'Mohammed',
      surname: 'Al-Rahman',
      email: 'mohammed.rahman@example.com',
      phoneNumber: '501234567',
      countryCode: '+971',
      profilePhotoUrl: 'assets/images/profile_mohammed.jpeg',
      vehicleBrand: 'BMW',
      vehicleModel: '3 Series',
      vehicleColor: 'Black',
      licensePlate: '35XYZ789',
      rating: 4.6,
    ),

    // User 5: Complete profile without vehicle (Rider)
    User(
      id: '5',
      name: 'Yuki',
      surname: 'Tanaka',
      email: 'yuki.tanaka@example.com',
      phoneNumber: '9012345678',
      countryCode: '+81',
      profilePhotoUrl: 'assets/images/profile_yuki.jpeg',
      vehicleBrand: null,
      vehicleModel: null,
      vehicleColor: null,
      licensePlate: null,
      rating: 4.5,
    ),
  ];

  // Get user by ID
  static User? getUserById(String id) {
    try {
      return users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
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
