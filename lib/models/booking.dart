import '../models/routes.dart';

// Rider information for a specific seat
class RiderInfo {
  final String userId;  // The actual user ID of the rider
  final String name;
  final double rating;
  final int seatIndex;
  final String? profilePhotoUrl;

  RiderInfo({
    required this.userId,
    required this.name,
    required this.rating,
    required this.seatIndex,
    this.profilePhotoUrl,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'rating': rating,
      'seatIndex': seatIndex,
      'profilePhotoUrl': profilePhotoUrl,
    };
  }

  // Create from JSON
  factory RiderInfo.fromJson(Map<String, dynamic> json) {
    return RiderInfo(
      userId: json['userId'] as String? ?? '', // Handle legacy data without userId
      name: json['name'] as String,
      rating: (json['rating'] as num).toDouble(),
      seatIndex: json['seatIndex'] as int,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );
  }
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
  final String? driverUserId; // Driver's user ID (for rider bookings)
  final double? driverRating; // Driver's rating (0.0 to 5.0)
  final bool? isCanceled; // Whether the booking has been canceled
  final bool? isArchived; // Whether the booking has been archived
  final DateTime? archivedAt; // When the booking was archived (for 7-day unarchive limit)
  final List<RiderInfo>?
  riders; // List of riders who booked seats (for driver bookings)

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
    this.driverUserId,
    this.driverRating,
    this.isCanceled = false,
    this.isArchived = false,
    this.archivedAt,
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
    String? driverUserId,
    double? driverRating,
    bool? isCanceled,
    bool? isArchived,
    DateTime? archivedAt,
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
      driverUserId: driverUserId ?? this.driverUserId,
      driverRating: driverRating ?? this.driverRating,
      isCanceled: isCanceled ?? this.isCanceled,
      isArchived: isArchived ?? this.isArchived,
      archivedAt: archivedAt ?? this.archivedAt,
      riders: riders ?? this.riders,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'routeName': route.name,
      'originIndex': originIndex,
      'destinationIndex': destinationIndex,
      'selectedSeats': selectedSeats,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'bookingDate': bookingDate.toIso8601String(),
      'userRole': userRole,
      'driverName': driverName,
      'driverUserId': driverUserId,
      'driverRating': driverRating,
      'isCanceled': isCanceled,
      'isArchived': isArchived,
      'archivedAt': archivedAt?.toIso8601String(),
      'riders': riders?.map((r) => r.toJson()).toList(),
    };
  }

  // Create from JSON
  factory Booking.fromJson(Map<String, dynamic> json) {
    // Find the route by name
    final routeName = json['routeName'] as String;
    final route = predefinedRoutes.firstWhere(
      (r) => r.name == routeName,
      orElse: () => predefinedRoutes[0], // Default to first route if not found
    );

    return Booking(
      id: json['id'] as String,
      userId: json['userId'] as String,
      route: route,
      originIndex: json['originIndex'] as int,
      destinationIndex: json['destinationIndex'] as int,
      selectedSeats: List<int>.from(json['selectedSeats'] as List),
      departureTime: DateTime.parse(json['departureTime'] as String),
      arrivalTime: DateTime.parse(json['arrivalTime'] as String),
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      userRole: json['userRole'] as String,
      driverName: json['driverName'] as String?,
      driverUserId: json['driverUserId'] as String?,
      driverRating: json['driverRating'] != null
          ? (json['driverRating'] as num).toDouble()
          : null,
      isCanceled: json['isCanceled'] as bool?,
      isArchived: json['isArchived'] as bool?,
      archivedAt: json['archivedAt'] != null
          ? DateTime.parse(json['archivedAt'] as String)
          : null,
      riders: json['riders'] != null
          ? (json['riders'] as List)
                .map((r) => RiderInfo.fromJson(r as Map<String, dynamic>))
                .toList()
          : null,
    );
  }
}
