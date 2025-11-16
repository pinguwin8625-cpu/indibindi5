import '../models/booking.dart';

class MockBookings {
  // Get mock bookings for a specific user
  static List<Booking> getMockBookingsForUser(String userId) {
    // All users start with no bookings
    return [];
  }
  
  // Get all mock bookings (for initialization)
  static List<Booking> getAllMockBookings() {
    // No mock bookings - users start with empty booking history
    return [];
  }
}
