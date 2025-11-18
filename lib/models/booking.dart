import '../models/routes.dart';

// Rider information for a specific seat
class RiderInfo {
  final String name;
  final double rating;
  final int seatIndex;
  final String? profilePhotoUrl;

  RiderInfo({
    required this.name,
    required this.rating,
    required this.seatIndex,
    this.profilePhotoUrl,
  });
}

class Booking {
  final String id;
  final String userId; // User who made the booking
  final RouteInfo route;
  final int originIndex;
  final int destinationIndex;
  final List<int> selectedSeats;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final DateTime bookingDate;
  final String userRole; // 'driver' or 'rider'
  final String? driverName; // Driver's display name (e.g., "Ahmet T.")
  final double? driverRating; // Driver's rating (0.0 to 5.0)
  final bool? isCanceled; // Whether the booking has been canceled
  final bool? isArchived; // Whether the booking has been archived
  final List<RiderInfo>? riders; // List of riders who booked seats (for driver bookings)

  Booking({
    required this.id,
    required this.userId,
    required this.route,
    required this.originIndex,
    required this.destinationIndex,
    required this.selectedSeats,
    required this.departureTime,
    required this.arrivalTime,
    required this.bookingDate,
    required this.userRole,
    this.driverName,
    this.driverRating,
    this.isCanceled = false,
    this.isArchived = false,
    this.riders,
  });

  // Helper getters
  String get originName => route.stops[originIndex].name;
  String get destinationName => route.stops[destinationIndex].name;
  int get numberOfSeats => selectedSeats.length;
  
  // Check if booking is in the past
  bool get isPast => arrivalTime.isBefore(DateTime.now());
  
  // Check if booking is upcoming
  bool get isUpcoming => departureTime.isAfter(DateTime.now());
  
  // Check if booking is active (in progress)
  bool get isActive => 
      departureTime.isBefore(DateTime.now()) && 
      arrivalTime.isAfter(DateTime.now());

  // Create a copy with updated fields
  Booking copyWith({
    String? id,
    String? userId,
    RouteInfo? route,
    int? originIndex,
    int? destinationIndex,
    List<int>? selectedSeats,
    DateTime? departureTime,
    DateTime? arrivalTime,
    DateTime? bookingDate,
    String? userRole,
    String? driverName,
    double? driverRating,
    bool? isCanceled,
    bool? isArchived,
    List<RiderInfo>? riders,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      route: route ?? this.route,
      originIndex: originIndex ?? this.originIndex,
      destinationIndex: destinationIndex ?? this.destinationIndex,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      bookingDate: bookingDate ?? this.bookingDate,
      userRole: userRole ?? this.userRole,
      driverName: driverName ?? this.driverName,
      driverRating: driverRating ?? this.driverRating,
      isCanceled: isCanceled ?? this.isCanceled,
      isArchived: isArchived ?? this.isArchived,
      riders: riders ?? this.riders,
    );
  }
}
