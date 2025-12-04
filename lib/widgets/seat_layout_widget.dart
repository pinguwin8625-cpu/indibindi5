import 'dart:io';
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/auth_service.dart';
import '../services/mock_users.dart';

/// Centralized seat layout widget for consistent display across the app
/// Used in: Driver bookings, Rider search, My Bookings
class SeatLayoutWidget extends StatelessWidget {
  final Booking booking;
  final bool isInteractive; // Can seats be tapped?
  final Function(int seatIndex)? onSeatTap;
  final Set<int> selectedSeats; // For interactive mode
  final String? currentUserId; // To highlight current user's seat
  final Function()? onDriverPhotoTap; // Callback for driver photo tap
  final Function(int seatIndex)? onRiderPhotoTap; // Callback for rider photo tap

  const SeatLayoutWidget({
    super.key,
    required this.booking,
    this.isInteractive = false,
    this.onSeatTap,
    this.selectedSeats = const {},
    this.currentUserId,
    this.onDriverPhotoTap,
    this.onRiderPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Left column - Back seats (1, 2, 3)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildSeatRow(context, 1),
              SizedBox(height: 4),
              _buildSeatRow(context, 3),
              SizedBox(height: 4),
              _buildSeatRow(context, 2),
            ],
          ),

          SizedBox(width: 12),

          // Right column - Driver and front passenger
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDriverRow(context),
              SizedBox(height: 12),
              _buildSeatRow(context, 0, isRightSide: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeatRow(
    BuildContext context,
    int seatIndex, {
    bool isRightSide = false,
  }) {
    final riderName = _getRiderName(seatIndex);
    final riderRating = _getRiderRating(seatIndex);
    final label = _buildSeatLabel(context, riderName, riderRating);
    final seat = _buildSeat(context, seatIndex);

    if (isRightSide) {
      return Row(children: [seat, SizedBox(width: 4), label]);
    } else {
      return Row(children: [label, SizedBox(width: 4), seat]);
    }
  }

  Widget _buildDriverRow(BuildContext context) {
    final label = _buildSeatLabel(
      context,
      booking.driverName ?? 'Driver',
      booking.driverRating?.toStringAsFixed(1) ?? '0.0',
    );
    final seat = _buildSeat(context, null, isDriver: true);

    return Row(children: [seat, SizedBox(width: 4), label]);
  }

  Widget _buildSeat(
    BuildContext context,
    int? seatIndex, {
    bool isDriver = false,
  }) {
    // Determine seat state
    final bool isOffered =
        seatIndex != null && booking.selectedSeats.contains(seatIndex);
    final bool isOccupied = seatIndex != null && _isSeatOccupied(seatIndex);
    final bool isSelected =
        seatIndex != null && selectedSeats.contains(seatIndex);
    final bool isCurrentUser =
        seatIndex != null && _isCurrentUserSeat(seatIndex);

    // Determine colors
    Color backgroundColor;
    Color borderColor;

    if (isDriver) {
      backgroundColor = Colors.red[100]!;
      borderColor = Color(0xFFDD2C00);
    } else if (!isOffered) {
      // Seat not offered by driver
      backgroundColor = Colors.red[100]!;
      borderColor = Color(0xFFDD2C00);
    } else if (isOccupied) {
      // Seat occupied by a rider
      backgroundColor = Colors.red[100]!;
      borderColor = Color(0xFFDD2C00);
    } else if (isSelected) {
      // Seat selected by current user (interactive mode)
      backgroundColor = Colors.blue[100]!;
      borderColor = Colors.blue[700]!;
    } else {
      // Available seat
      backgroundColor = Colors.green[100]!;
      borderColor = Color(0xFF00C853);
    }

    // Determine content
    Widget seatContent;
    if (isDriver) {
      seatContent = _buildDriverPhoto();
    } else if (isOccupied) {
      seatContent = _buildRiderPhoto(seatIndex);
    } else if (isCurrentUser) {
      seatContent = _buildCurrentUserPhoto();
    } else {
      seatContent = Icon(Icons.person, size: 28, color: Colors.grey[700]);
    }

    final seatWidget = Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Center(child: seatContent),
    );

    // Make interactive if needed
    if (isInteractive &&
        !isDriver &&
        isOffered &&
        !isOccupied &&
        onSeatTap != null) {
      return GestureDetector(
        onTap: () => onSeatTap!(seatIndex),
        child: seatWidget,
      );
    }

    return seatWidget;
  }

  Widget _buildSeatLabel(BuildContext context, String name, String? rating) {
    return Container(
      width: 85, // Fixed width
      height: 38, // Fixed height regardless of rating
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          if (rating != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 10, color: Colors.amber[700]),
                SizedBox(width: 2),
                Text(
                  rating,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Helper methods
  String _getRiderName(int seatIndex) {
    if (booking.riders != null) {
      for (var rider in booking.riders!) {
        if (rider.seatIndex == seatIndex) {
          return rider.name;
        }
      }
    }
    return 'Rider-${seatIndex + 1}';
  }

  String? _getRiderRating(int seatIndex) {
    if (booking.riders != null) {
      for (var rider in booking.riders!) {
        if (rider.seatIndex == seatIndex) {
          // Get live rating from RatingService if userId is available
          if (rider.userId.isNotEmpty) {
            return MockUsers.getLiveRating(rider.userId).toStringAsFixed(1);
          }
          return rider.rating.toStringAsFixed(1);
        }
      }
    }
    // Return null for unoccupied seats (no rating to show)
    return null;
  }

  bool _isSeatOccupied(int seatIndex) {
    if (booking.riders != null) {
      for (var rider in booking.riders!) {
        if (rider.seatIndex == seatIndex) {
          return true;
        }
      }
    }
    return false;
  }

  bool _isCurrentUserSeat(int seatIndex) {
    if (currentUserId == null || booking.riders == null) return false;

    // For driver bookings, the driver is at the driver's seat (not in riders list)
    final isDriver = booking.userRole.toLowerCase() == 'driver';
    if (isDriver && booking.userId == currentUserId) {
      // Driver's seat is not indexed, so return false for passenger seats
      return false;
    }

    // For rider bookings, find the current user's seat by matching user ID
    // Since RiderInfo doesn't have userId, we need to get the current user and match by name
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return false;
    
    final currentUserDisplayName = '${currentUser.name} ${currentUser.surname[0]}.';
    
    for (var rider in booking.riders!) {
      if (rider.seatIndex == seatIndex && rider.name == currentUserDisplayName) {
        return true;
      }
    }
    return false;
  }

  // Wrap photo with chevron indicator to show it's tappable
  Widget _wrapWithChevron(Widget photo, {bool isLarge = false}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        photo,
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            padding: EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              Icons.chevron_right,
              size: isLarge ? 12 : 10,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDriverPhoto() {
    // Get driver photo from booking
    // For rider bookings, use driverUserId; for driver bookings, use userId
    final driverId = booking.driverUserId ?? booking.userId;
    final driver = MockUsers.getUserById(driverId);
    
    Widget photoWidget;
    if (driver?.profilePhotoUrl != null) {
      photoWidget = _buildPhotoWidget(driver!.profilePhotoUrl!);
    } else {
      photoWidget = Icon(Icons.person, size: 32, color: Colors.grey[600]);
    }

    // Make driver photo clickable if callback is provided
    if (onDriverPhotoTap != null) {
      return GestureDetector(
        onTap: onDriverPhotoTap,
        child: _wrapWithChevron(photoWidget, isLarge: true),
      );
    }
    
    return photoWidget;
  }

  Widget _buildRiderPhoto(int seatIndex) {
    Widget photoWidget;
    if (booking.riders != null) {
      for (var rider in booking.riders!) {
        if (rider.seatIndex == seatIndex && rider.profilePhotoUrl != null) {
          photoWidget = _buildPhotoWidget(rider.profilePhotoUrl!);
          
          // Make rider photo clickable if callback is provided
          if (onRiderPhotoTap != null) {
            return GestureDetector(
              onTap: () => onRiderPhotoTap!(seatIndex),
              child: _wrapWithChevron(photoWidget),
            );
          }
          
          return photoWidget;
        }
      }
    }
    
    photoWidget = Icon(Icons.person, size: 28, color: Colors.grey[700]);
    return photoWidget;
  }

  Widget _buildCurrentUserPhoto() {
    final currentUser = AuthService.currentUser;
    if (currentUser?.profilePhotoUrl != null) {
      return _buildPhotoWidget(currentUser!.profilePhotoUrl!);
    }
    return Icon(Icons.person, size: 28, color: Colors.grey[700]);
  }

  Widget _buildPhotoWidget(String photoUrl) {
    if (photoUrl.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          photoUrl,
          width: 54,
          height: 54,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.person, size: 32, color: Colors.grey[600]);
          },
        ),
      );
    } else {
      final photoFile = File(photoUrl);
      if (photoFile.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            photoFile,
            width: 54,
            height: 54,
            fit: BoxFit.cover,
          ),
        );
      }
    }
    return Icon(Icons.person, size: 28, color: Colors.grey[700]);
  }
}
