import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/mock_users.dart';
import 'rating_widgets.dart';

class SeatPlanningSectionWidget extends StatelessWidget {
  final String userRole;
  final List<int> selectedSeats;
  final Function(List<int>) onSeatsSelected;
  final bool isDisabled;

  const SeatPlanningSectionWidget({
    super.key,
    required this.userRole,
    required this.selectedSeats,
    required this.onSeatsSelected,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Format driver name (first name + last initial) and get rating
    String driverDisplayName = l10n.driver;
    String driverRating = '0.0';

    // Get current user info if they are the driver
    final currentUser = AuthService.currentUser;
    if (currentUser != null && userRole.toLowerCase() == 'driver') {
      driverDisplayName = currentUser.name;
      if (currentUser.surname.isNotEmpty) {
        driverDisplayName = '${currentUser.name} ${currentUser.surname[0]}.';
      }
      // Get live rating from RatingService
      driverRating = MockUsers.getLiveRating(currentUser.id).toStringAsFixed(1);
    }

    // Helper function to get rider info for a seat (placeholder for now)
    String getRiderName(int seatIndex) {
      return '${l10n.rider}-${seatIndex + 1}';
    }

    // Return null for unoccupied seats (no rating to show for placeholders)
    String? getRiderRating(int seatIndex) {
      return null;
    }

    // Calculate available seats count
    int availableCount = 0;
    for (int i = 0; i < 4; i++) {
      if (userRole.toLowerCase() == 'driver') {
        // For driver: selectedSeats are available
        if (selectedSeats.contains(i)) {
          availableCount++;
        }
      } else {
        // For rider: selectedSeats are occupied, so available = not in list
        if (!selectedSeats.contains(i)) {
          availableCount++;
        }
      }
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Available seats count at the top - compact display
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFF00C853).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFF00C853).withValues(alpha: 0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event_seat, color: Color(0xFF00C853), size: 20),
                SizedBox(width: 8),
                Text(
                  '${l10n.available}: ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF00C853),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  key: ValueKey('available-$availableCount'),
                  tween: Tween<double>(begin: 2.0, end: 1.0),
                  duration: Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Text(
                        '$availableCount',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00C853),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 28),
          // Seat layout
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Left column - Back seats (1, 2, 3)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        _buildSeatLabel(getRiderName(1), getRiderRating(1)),
                        SizedBox(width: 4),
                        _buildMiniSeat(
                          context: context,
                          seatIndex: 1,
                          isSelected: selectedSeats.contains(1),
                          passengerName: getRiderName(1),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        _buildSeatLabel(getRiderName(3), getRiderRating(3)),
                        SizedBox(width: 4),
                        _buildMiniSeat(
                          context: context,
                          seatIndex: 3,
                          isSelected: selectedSeats.contains(3),
                          passengerName: getRiderName(3),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        _buildSeatLabel(getRiderName(2), getRiderRating(2)),
                        SizedBox(width: 4),
                        _buildMiniSeat(
                          context: context,
                          seatIndex: 2,
                          isSelected: selectedSeats.contains(2),
                          passengerName: getRiderName(2),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(width: 12),
                // Right column - Front seats (Driver and Rider 1)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildMiniSeat(
                          context: context,
                          isDriver: true,
                          passengerName: driverDisplayName,
                        ),
                        SizedBox(width: 4),
                        _buildSeatLabel(driverDisplayName, driverRating),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        _buildMiniSeat(
                          context: context,
                          seatIndex: 0,
                          isSelected: selectedSeats.contains(0),
                          passengerName: getRiderName(0),
                        ),
                        SizedBox(width: 4),
                        _buildSeatLabel(getRiderName(0), getRiderRating(0)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniSeat({
    required BuildContext context,
    int? seatIndex,
    bool isSelected = false,
    bool isDriver = false,
    required String passengerName,
  }) {
    Color backgroundColor;
    Color borderColor;
    bool isAvailable = false;

    if (isDriver) {
      // Driver seat is always red/occupied
      backgroundColor = Colors.red[100]!;
      borderColor = Color(0xFFDD2C00);
    } else {
      // For passenger seats, the meaning of isSelected depends on the booking role
      if (userRole.toLowerCase() == 'driver') {
        // For driver bookings: seats in selectedSeats list are AVAILABLE (driver offering these seats)
        isAvailable = isSelected;
      } else {
        // For rider bookings: seats in selectedSeats list are OCCUPIED (rider booked these seats)
        isAvailable = !isSelected;
      }

      if (isAvailable) {
        // Available seat - green
        backgroundColor = Colors.green[100]!;
        borderColor = Color(0xFF00C853);
      } else {
        // Unavailable seat - red
        backgroundColor = Colors.red[100]!;
        borderColor = Color(0xFFDD2C00);
      }
    }

    // Make driver and all occupied seats clickable
    final isClickable = !isDisabled && !isDriver;

    return GestureDetector(
      onTap: isClickable && seatIndex != null
          ? () => _toggleSeat(seatIndex)
          : null,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: isDriver
                  ? _buildDriverPhoto(context)
                  : Icon(Icons.person, size: 28, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverPhoto(BuildContext context) {
    final currentUser = AuthService.currentUser;

    // Check if current user is the driver and has a profile photo
    if (currentUser != null && userRole.toLowerCase() == 'driver') {
      if (currentUser.profilePhotoUrl != null &&
          currentUser.profilePhotoUrl!.isNotEmpty) {
        // Check if it's an asset or file path
        if (currentUser.profilePhotoUrl!.startsWith('assets/')) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              currentUser.profilePhotoUrl!,
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.person, size: 28, color: Colors.grey[700]),
                );
              },
            ),
          );
        }
        // Note: File-based photos (non-asset paths) are not supported on web
        // On native platforms, photos should be stored as assets or network URLs
      }
    }

    // Default placeholder
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.person, size: 32, color: Colors.grey[600]),
    );
  }

  Widget _buildSeatLabel(String name, String? rating) {
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
            RatingDisplay(
              rating: double.tryParse(rating) ?? 0.0,
              starSize: 10,
              fontSize: 10,
            ),
        ],
      ),
    );
  }

  void _toggleSeat(int seatIndex) {
    if (kDebugMode) {
      debugPrint('Toggling seat: $seatIndex');
    }

    List<int> newSelectedSeats = List.from(selectedSeats);

    // Toggle seat selection
    if (newSelectedSeats.contains(seatIndex)) {
      newSelectedSeats.remove(seatIndex);
    } else {
      newSelectedSeats.add(seatIndex);
    }

    onSeatsSelected(newSelectedSeats);
  }
}
