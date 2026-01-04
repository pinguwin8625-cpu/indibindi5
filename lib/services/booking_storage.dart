import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/booking.dart';
import 'mock_users.dart';

// A persistent store for bookings using SharedPreferences.
class BookingStorage {
  static final BookingStorage _instance = BookingStorage._internal();
  factory BookingStorage() {
    return _instance;
  }
  BookingStorage._internal() {
    _loadBookings();
  }

  final ValueNotifier<List<Booking>> bookings = ValueNotifier<List<Booking>>(
    [],
  );
  static const String _storageKey = 'bookings_data';
  bool _isInitialized = false;
  Future<void>? _loadingFuture;

  // Load bookings from persistent storage
  Future<void> _loadBookings() async {
    if (_isInitialized) {
      if (kDebugMode) {
        print(
          '📚 BookingStorage._loadBookings() - Already initialized with ${bookings.value.length} bookings',
        );
      }
      return;
    }

    if (kDebugMode) {
      print('📚 BookingStorage._loadBookings() - Starting to load...');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? bookingsJson = prefs.getString(_storageKey);

      if (bookingsJson != null) {
        if (kDebugMode) {
          print('📚 Found saved bookings in storage');
        }
        final List<dynamic> jsonList = json.decode(bookingsJson);
        bookings.value = jsonList
            .map((json) => Booking.fromJson(json as Map<String, dynamic>))
            .toList();

        if (kDebugMode) {
          print(
            '📚 BookingStorage: Loaded ${bookings.value.length} bookings from storage',
          );
          for (var booking in bookings.value) {
            print(
              '   - ${booking.id}: ${booking.userRole} | ${booking.route.name}',
            );
          }
        }
      } else {
        if (kDebugMode) {
          print('📚 No saved bookings found, starting with empty list');
        }
        // No saved bookings, start with empty list
        bookings.value = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('📚 BookingStorage: Error loading bookings - $e');
      }
      // On error, start with empty list
      bookings.value = [];
    }

    _isInitialized = true;
    if (kDebugMode) {
      print(
        '📚 BookingStorage._loadBookings() - Finished. Total: ${bookings.value.length}',
      );
    }

    // Auto-archive completed rides older than 3 days
    _autoArchiveOldBookings();
    _autoHideOldArchivedBookings();
  }

  // Auto-archive completed and canceled bookings older than 3 days from arrival time
  void _autoArchiveOldBookings() {
    final now = DateTime.now();
    final archiveCutoff = now.subtract(Duration(days: 3));
    bool hasChanges = false;
    
    final updatedBookings = bookings.value.map((booking) {
      // Skip if already archived
      if (booking.isArchived == true) {
        return booking;
      }
      
      // For both completed and canceled rides: auto-archive if arrival time is older than 3 days
      if (booking.arrivalTime.isBefore(archiveCutoff)) {
        hasChanges = true;
        if (kDebugMode) {
          print('📚 Auto-archiving old booking: ${booking.id} (arrived ${booking.arrivalTime}, canceled: ${booking.isCanceled})');
        }
        return booking.copyWith(isArchived: true, archivedAt: now, isAutoArchived: true);
      }
      
      return booking;
    }).toList();
    
    if (hasChanges) {
      bookings.value = updatedBookings;
      _saveBookings();
      if (kDebugMode) {
        print('📚 Auto-archive complete');
      }
    }
  }

  // Auto-hide archived bookings older than 7 days from arrival time
  void _autoHideOldArchivedBookings() {
    final now = DateTime.now();
    final hideCutoff = now.subtract(Duration(days: 7));
    bool hasChanges = false;
    
    final updatedBookings = bookings.value.map((booking) {
      // Skip if already hidden
      if (booking.isHidden == true) {
        return booking;
      }
      
      // Only hide archived bookings whose arrival time is older than 7 days
      if (booking.isArchived == true && booking.arrivalTime.isBefore(hideCutoff)) {
        hasChanges = true;
        if (kDebugMode) {
          print('📚 Auto-hiding old archived booking: ${booking.id} (arrived ${booking.arrivalTime})');
        }
        return booking.copyWith(isHidden: true, hiddenAt: now);
      }
      
      return booking;
    }).toList();
    
    if (hasChanges) {
      bookings.value = updatedBookings;
      _saveBookings();
      if (kDebugMode) {
        print('📚 Auto-hide complete');
      }
    }
  }

  // Ensure bookings are loaded before accessing
  Future<void> ensureLoaded() async {
    if (_loadingFuture != null) {
      await _loadingFuture;
      return;
    }
    if (!_isInitialized) {
      _loadingFuture = _loadBookings();
      await _loadingFuture;
      _loadingFuture = null;
    }
  }

  // Save bookings to persistent storage
  Future<void> _saveBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = bookings.value
          .map((booking) => booking.toJson())
          .toList();
      final String bookingsJson = json.encode(jsonList);
      await prefs.setString(_storageKey, bookingsJson);

      if (kDebugMode) {
        print(
          '📚 BookingStorage: Saved ${bookings.value.length} bookings to storage',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('📚 BookingStorage: Error saving bookings - $e');
      }
    }
  }

  /// Check if a user has any active bookings that conflict with the given time range
  /// Returns true if there's a conflict, false if the time slot is available
  bool hasTimeConflict({
    required String userId,
    required DateTime departureTime,
    required DateTime arrivalTime,
    String? excludeBookingId, // Optionally exclude a specific booking (for updates)
  }) {
    final userBookings = bookings.value.where((b) =>
        b.userId == userId &&
        b.isCanceled != true &&
        b.isArchived != true &&
        b.isUpcoming &&
        (excludeBookingId == null || b.id != excludeBookingId));

    for (final booking in userBookings) {
      // Check for time overlap
      // Two time ranges overlap if one starts before the other ends
      // and the other starts before the first one ends
      final existingStart = booking.departureTime;
      final existingEnd = booking.arrivalTime;

      // Add a 30-minute buffer before and after each ride
      final bufferedNewStart = departureTime.subtract(Duration(minutes: 30));
      final bufferedNewEnd = arrivalTime.add(Duration(minutes: 30));
      final bufferedExistingStart = existingStart.subtract(Duration(minutes: 30));
      final bufferedExistingEnd = existingEnd.add(Duration(minutes: 30));

      // Check if ranges overlap (with buffer)
      if (bufferedNewStart.isBefore(bufferedExistingEnd) &&
          bufferedNewEnd.isAfter(bufferedExistingStart)) {
        if (kDebugMode) {
          print('📚 Time conflict detected:');
          print('   Existing: ${booking.id} ($existingStart - $existingEnd)');
          print('   New ride: $departureTime - $arrivalTime');
        }
        return true;
      }
    }

    return false;
  }

  /// Get a booking by its ID
  Booking? getBookingById(String bookingId) {
    try {
      return bookings.value.firstWhere((b) => b.id == bookingId);
    } catch (e) {
      return null;
    }
  }

  /// Get the conflicting booking details for user-friendly error messages
  Booking? getConflictingBooking({
    required String userId,
    required DateTime departureTime,
    required DateTime arrivalTime,
  }) {
    final userBookings = bookings.value.where((b) =>
        b.userId == userId &&
        b.isCanceled != true &&
        b.isArchived != true &&
        b.isUpcoming);

    for (final booking in userBookings) {
      final existingStart = booking.departureTime;
      final existingEnd = booking.arrivalTime;

      // Add a 30-minute buffer
      final bufferedNewStart = departureTime.subtract(Duration(minutes: 30));
      final bufferedNewEnd = arrivalTime.add(Duration(minutes: 30));
      final bufferedExistingStart = existingStart.subtract(Duration(minutes: 30));
      final bufferedExistingEnd = existingEnd.add(Duration(minutes: 30));

      if (bufferedNewStart.isBefore(bufferedExistingEnd) &&
          bufferedNewEnd.isAfter(bufferedExistingStart)) {
        return booking;
      }
    }

    return null;
  }

  // Add a new booking
  void addBooking(Booking booking) {
    bookings.value = [...bookings.value, booking];
    _saveBookings(); // Persist to storage
    if (kDebugMode) {
      print('📚 BookingStorage: Added booking ${booking.id}');
      print('   UserId: ${booking.userId}, Role: ${booking.userRole}');
      print('   Route: ${booking.route.name}');
      print(
        '   Origin: ${booking.originIndex}, Destination: ${booking.destinationIndex}',
      );
      print('   Departure: ${booking.departureTime}');
      print('   Seats: ${booking.selectedSeats}');
      print('   Upcoming: ${booking.isUpcoming}');
      print('📚 Total bookings: ${bookings.value.length}');
    }
  }

  // Get all bookings
  List<Booking> getAllBookings() {
    if (kDebugMode) {
      print(
        '📚 BookingStorage.getAllBookings() called - returning ${bookings.value.length} bookings',
      );
      for (var booking in bookings.value) {
        print(
          '   - ${booking.id}: ${booking.userRole} | ${booking.route.name} | Origin:${booking.originIndex} Dest:${booking.destinationIndex} | ${booking.departureTime}',
        );
      }
    }
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
      _saveBookings(); // Persist to storage
      if (kDebugMode) {
        print('📚 BookingStorage: Updated booking ${updatedBooking.id}');
      }
    }
  }

  // Cancel a booking (mark as canceled instead of removing)
  void cancelBooking(String id) {
    try {
      final index = bookings.value.indexWhere((b) => b.id == id);
      if (index == -1) {
        if (kDebugMode) {
          print('📚 BookingStorage: Cannot cancel - booking not found: $id');
        }
        return;
      }

      final booking = bookings.value[index];

      // If this is a driver booking, cancel for everyone
      if (booking.userRole.toLowerCase() == 'driver') {
        updateBooking(booking.copyWith(isCanceled: true));

        // Also cancel all associated rider bookings
        final riderBookingsToCancel = bookings.value
            .where(
              (b) => b.id.startsWith('${id}_rider_') && b.isCanceled != true,
            )
            .toList();

        for (final riderBooking in riderBookingsToCancel) {
          updateBooking(riderBooking.copyWith(isCanceled: true));
          if (kDebugMode) {
            print(
              '📚 BookingStorage: Auto-canceled rider booking ${riderBooking.id}',
            );
          }
        }
      }
      // If this is a rider booking, only cancel for this rider
      else if (booking.userRole.toLowerCase() == 'rider') {
        if (kDebugMode) {
          print('📚 BookingStorage: Rider canceling - Booking ID: $id');
          print('   Rider User ID: ${booking.userId}');
          print('   Booking isCanceled before: ${booking.isCanceled}');
        }
        
        // Cancel the rider's booking
        updateBooking(booking.copyWith(isCanceled: true));
        
        if (kDebugMode) {
          print('   Rider booking marked as canceled');
        }

        // Remove this rider from the driver's booking and all other rider bookings
        // Extract the driver booking ID from rider booking ID (format: driverBookingId_rider_userId)
        final parts = id.split('_rider_');
        if (parts.length == 2) {
          final driverBookingId = parts[0];
          final riderUserId = booking.userId;
          
          if (kDebugMode) {
            print('   Driver Booking ID: $driverBookingId');
            print('   Rider User ID: $riderUserId');
          }
          
          // Find this rider's seat by matching their user ID to their name
          // Get the current user to find their display name
          final cancelingUser = MockUsers.getUserById(riderUserId);
          if (cancelingUser == null) {
            if (kDebugMode) {
              print('   ❌ Could not find user with ID: $riderUserId');
            }
            return;
          }
          
          final cancelingUserDisplayName = '${cancelingUser.name} ${cancelingUser.surname[0]}.';
          if (kDebugMode) {
            print('   Canceling user display name: $cancelingUserDisplayName');
          }
          
          // Find the driver's booking
          final driverBookingIndex =
              bookings.value.indexWhere((b) => b.id == driverBookingId);
          if (driverBookingIndex != -1) {
            final driverBooking = bookings.value[driverBookingIndex];
            
            if (kDebugMode) {
              print('   Driver booking found');
              print('   Driver booking isCanceled: ${driverBooking.isCanceled}');
              print('   Driver booking userRole: ${driverBooking.userRole}');
              print('   Driver booking riders count: ${driverBooking.riders?.length ?? 0}');
              print('   Riders in driver booking:');
              for (final r in driverBooking.riders ?? []) {
                print('      - ${r.name} at seat ${r.seatIndex}');
              }
            }

            // Find which seat(s) belong to the canceling rider by matching their name
            final canceledRiderSeats = <int>[];
            if (driverBooking.riders != null) {
              for (final rider in driverBooking.riders!) {
                if (rider.name == cancelingUserDisplayName) {
                  canceledRiderSeats.add(rider.seatIndex);
                  if (kDebugMode) {
                    print('   ✓ Found canceling rider at seat: ${rider.seatIndex}');
                  }
                }
              }
            }

            if (kDebugMode) {
              print(
                '📚 BookingStorage: Rider $riderUserId canceling seats: $canceledRiderSeats',
              );
            }

            // Remove this rider from the driver's riders list by matching seat indices
            if (driverBooking.riders != null && canceledRiderSeats.isNotEmpty) {
              final updatedRiders = driverBooking.riders!
                  .where((r) => !canceledRiderSeats.contains(r.seatIndex))
                  .toList();

              updateBooking(driverBooking.copyWith(riders: updatedRiders));

              if (kDebugMode) {
                print(
                  '📚 BookingStorage: Removed rider from seats $canceledRiderSeats from driver booking $driverBookingId',
                );
                print('   Updated riders count: ${updatedRiders.length}');
                // Verify driver booking is still not canceled
                final verifyDriverBooking = bookings.value.firstWhere((b) => b.id == driverBookingId);
                print('   Driver booking isCanceled after update: ${verifyDriverBooking.isCanceled}');
              }

              // Update all other rider bookings to remove the canceled rider
              final otherRiderBookings = bookings.value
                  .where(
                    (b) =>
                        b.id.startsWith('${driverBookingId}_rider_') &&
                        b.id != id &&
                        b.isCanceled != true,
                  )
                  .toList();

              for (final otherRiderBooking in otherRiderBookings) {
                if (otherRiderBooking.riders != null) {
                  final updatedOtherRiders = otherRiderBooking.riders!
                      .where((r) => !canceledRiderSeats.contains(r.seatIndex))
                      .toList();

                  updateBooking(
                    otherRiderBooking.copyWith(riders: updatedOtherRiders),
                  );

                  if (kDebugMode) {
                    print(
                      '📚 BookingStorage: Removed rider from seats $canceledRiderSeats from rider booking ${otherRiderBooking.id}',
                    );
                  }
                }
              }
            }
          }
        }
      }

      if (kDebugMode) {
        print('📚 BookingStorage: Canceled booking $id');
      }
    } catch (e) {
      if (kDebugMode) {
        print('📚 BookingStorage: Error canceling booking $id - $e');
      }
    }
  }

  // Archive a booking (mark as archived)
  void archiveBooking(String id) {
    try {
      final index = bookings.value.indexWhere((b) => b.id == id);
      if (index == -1) {
        if (kDebugMode) {
          print('📚 BookingStorage: Cannot archive - booking not found: $id');
        }
        return;
      }

      final booking = bookings.value[index];
      final archivedBooking = booking.copyWith(isArchived: true, archivedAt: DateTime.now(), isAutoArchived: false);
      updateBooking(archivedBooking);
      if (kDebugMode) {
        print('📚 BookingStorage: Manually archived booking $id');
        print('📚 BookingStorage: isArchived=${archivedBooking.isArchived}, isAutoArchived=${archivedBooking.isAutoArchived}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('📚 BookingStorage: Error archiving booking $id - $e');
      }
    }
  }

  // Unarchive a booking (mark as not archived)
  void unarchiveBooking(String id) {
    try {
      final index = bookings.value.indexWhere((b) => b.id == id);
      if (index == -1) {
        if (kDebugMode) {
          print('📚 BookingStorage: Cannot unarchive - booking not found: $id');
        }
        return;
      }

      final booking = bookings.value[index];
      updateBooking(booking.copyWith(isArchived: false, archivedAt: null, isAutoArchived: null));
      if (kDebugMode) {
        print('📚 BookingStorage: Unarchived booking $id');
      }
    } catch (e) {
      if (kDebugMode) {
        print('📚 BookingStorage: Error unarchiving booking $id - $e');
      }
    }
  }

  // Get canceled bookings for a specific user
  List<Booking> getCanceledBookingsForUser(String userId) {
    return bookings.value
        .where(
          (booking) => booking.userId == userId && booking.isCanceled == true,
        )
        .toList();
  }

  // Remove a booking by ID
  void removeBooking(String id) {
    bookings.value = bookings.value
        .where((booking) => booking.id != id)
        .toList();
    _saveBookings(); // Persist to storage
    if (kDebugMode) {
      print('📚 BookingStorage: Removed booking $id');
    }
  }

  // Clear all bookings
  void clearAllBookings() {
    bookings.value = [];
    _saveBookings(); // Persist to storage
    if (kDebugMode) {
      print('📚 BookingStorage: Cleared all bookings');
    }
  }

  // Clear bookings for a specific user
  // Returns the count of bookings removed
  int clearBookingsForUser(String userId) {
    final userBookings = bookings.value.where((b) => b.userId == userId).toList();
    final count = userBookings.length;

    if (count == 0) return 0;

    // Remove all bookings for this user
    bookings.value = bookings.value.where((b) => b.userId != userId).toList();

    // Also remove this user from other bookings' rider lists
    final updatedBookings = bookings.value.map((booking) {
      if (booking.riders != null && booking.riders!.isNotEmpty) {
        // Find and remove any riders that belong to this user
        final user = MockUsers.getUserById(userId);
        if (user != null) {
          final displayName = '${user.name} ${user.surname[0]}.';
          final updatedRiders = booking.riders!
              .where((r) => r.name != displayName)
              .toList();
          if (updatedRiders.length != booking.riders!.length) {
            return booking.copyWith(riders: updatedRiders);
          }
        }
      }
      return booking;
    }).toList();

    bookings.value = updatedBookings;
    _saveBookings();

    if (kDebugMode) {
      print('📚 BookingStorage: Cleared $count bookings for user $userId');
    }

    return count;
  }

  // Count bookings for a specific user (posts + books)
  Map<String, int> countBookingsForUser(String userId) {
    final userBookings = bookings.value.where((b) => b.userId == userId).toList();
    final posts = userBookings.where((b) => b.userRole.toLowerCase() == 'driver').length;
    final books = userBookings.where((b) => b.userRole.toLowerCase() == 'rider').length;
    return {'posts': posts, 'books': books, 'total': posts + books};
  }
}
