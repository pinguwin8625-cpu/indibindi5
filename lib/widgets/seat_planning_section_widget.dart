import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';

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
      driverRating = currentUser.rating.toStringAsFixed(1);
    }

    // Helper function to get rider info for a seat (placeholder for now)
    String getRiderName(int seatIndex) {
      return '${l10n.passenger}-${seatIndex + 1}';
    }

    String getRiderRating(int seatIndex) {
      return '0.0';
    }

    return Center(
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
        backgroundColor = Colors.green[100]!;
        borderColor = Color(0xFF00C853);
      } else {
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
            // Show +/- icon for clickable seats
            if (isClickable && seatIndex != null)
              Positioned(
                left: -9,
                top: -9,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.red : Color(0xFF00C853),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isAvailable
                        ? Container(
                            // Minus sign
                            width: 9,
                            height: 2,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )
                        : Icon(
                            // Plus sign
                            Icons.add,
                            color: Colors.white,
                            size: 12,
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverPhoto(BuildContext context) {
    final currentUser = AuthService.currentUser;

    // Check if current user is the driver and has a profile photo
    if (currentUser != null &&
        userRole.toLowerCase() == 'driver') {
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
        } else {
          final photoFile = File(currentUser.profilePhotoUrl!);
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

  Widget _buildSeatLabel(String name, String rating) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          name,
          style: TextStyle(
            color: Color(0xFF2E2E2E),
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.amber, size: 10),
            SizedBox(width: 1),
            Text(
              rating,
              style: TextStyle(
                color: Color(0xFF2E2E2E),
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
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
