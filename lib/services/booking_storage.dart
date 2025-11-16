import 'package:flutter/foundation.dart';
import '../models/booking.dart';

// A simple in-memory store for bookings.
// In a real app, this would be replaced by a database or API service.
class BookingStorage {
  static final BookingStorage _instance = BookingStorage._internal();
  factory BookingStorage() {
    return _instance;
  }
  BookingStorage._internal();

  final ValueNotifier<List<Booking>> bookings = ValueNotifier<List<Booking>>([]);

  // Add a new booking
  void addBooking(Booking booking) {
    bookings.value = [...bookings.value, booking];
    if (kDebugMode) {
      print('📚 BookingStorage: Added booking ${booking.id}');
      print('📚 Total bookings: ${bookings.value.length}');
    }
  }

  // Get all bookings
  List<Booking> getAllBookings() {
    return bookings.value;
  }
  
  // Get bookings for a specific user
  List<Booking> getBookingsForUser(String userId) {
    return bookings.value.where((booking) => booking.userId == userId).toList();
  }

  // Get upcoming bookings
  List<Booking> getUpcomingBookings() {
    return bookings.value.where((booking) => booking.isUpcoming).toList();
  }
  
  // Get upcoming bookings for a specific user
  List<Booking> getUpcomingBookingsForUser(String userId) {
    return bookings.value
        .where((booking) => booking.userId == userId && booking.isUpcoming)
        .toList();
  }

  // Get past bookings
  List<Booking> getPastBookings() {
    return bookings.value.where((booking) => booking.isPast).toList();
  }
  
  // Get past bookings for a specific user
  List<Booking> getPastBookingsForUser(String userId) {
    return bookings.value
        .where((booking) => booking.userId == userId && booking.isPast)
        .toList();
  }

  // Get active bookings
  List<Booking> getActiveBookings() {
    return bookings.value.where((booking) => booking.isActive).toList();
  }

  // Update a booking
  void updateBooking(Booking updatedBooking) {
    final index = bookings.value.indexWhere((b) => b.id == updatedBooking.id);
    if (index != -1) {
      final updatedList = List<Booking>.from(bookings.value);
      updatedList[index] = updatedBooking;
      bookings.value = updatedList;
      if (kDebugMode) {
        print('📚 BookingStorage: Updated booking ${updatedBooking.id}');
      }
    }
  }

  // Cancel a booking (mark as canceled instead of removing)
  void cancelBooking(String id) {
    final booking = bookings.value.firstWhere((b) => b.id == id);
    updateBooking(booking.copyWith(isCanceled: true));
    if (kDebugMode) {
      print('📚 BookingStorage: Canceled booking $id');
    }
  }

  // Archive a booking (mark as archived)
  void archiveBooking(String id) {
    final booking = bookings.value.firstWhere((b) => b.id == id);
    updateBooking(booking.copyWith(isArchived: true));
    if (kDebugMode) {
      print('📚 BookingStorage: Archived booking $id');
    }
  }

  // Unarchive a booking (mark as not archived)
  void unarchiveBooking(String id) {
    final booking = bookings.value.firstWhere((b) => b.id == id);
    updateBooking(booking.copyWith(isArchived: false));
    if (kDebugMode) {
      print('📚 BookingStorage: Unarchived booking $id');
    }
  }

  // Get canceled bookings for a specific user
  List<Booking> getCanceledBookingsForUser(String userId) {
    return bookings.value
        .where((booking) => booking.userId == userId && booking.isCanceled == true)
        .toList();
  }

  // Remove a booking by ID
  void removeBooking(String id) {
    bookings.value = bookings.value.where((booking) => booking.id != id).toList();
    if (kDebugMode) {
      print('📚 BookingStorage: Removed booking $id');
    }
  }

  // Clear all bookings
  void clearAllBookings() {
    bookings.value = [];
    if (kDebugMode) {
      print('📚 BookingStorage: Cleared all bookings');
    }
  }
}
