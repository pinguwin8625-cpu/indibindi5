import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/routes.dart';
import '../models/booking.dart';
import '../services/booking_storage.dart';
import '../services/auth_service.dart';
import '../services/mock_users.dart';
import '../l10n/app_localizations.dart';

class BookingButtonWidget extends StatefulWidget {
  final RouteInfo? selectedRoute;
  final int? originIndex;
  final int? destinationIndex;
  final List<int> selectedSeats;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final String userRole;
  final VoidCallback? onBookingCompleted;
  final bool isFloating;

  const BookingButtonWidget({
    super.key,
    required this.selectedRoute,
    required this.originIndex,
    required this.destinationIndex,
    required this.selectedSeats,
    required this.departureTime,
    required this.arrivalTime,
    required this.userRole,
    this.onBookingCompleted,
    this.isFloating = false,
  });

  @override
  State<BookingButtonWidget> createState() => _BookingButtonWidgetState();
}

class _BookingButtonWidgetState extends State<BookingButtonWidget> {
  bool isActionCompleted =
      false; // Can be either booking completed or ride posted

  // Helper method for responsive design
  bool _isMobileWeb(BuildContext context) {
    if (!kIsWeb) return false;
    final width = MediaQuery.of(context).size.width;
    return width < 600;
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // For drivers: enabled when at least one seat is available (selectedSeats.length > 0)
    // For riders: enabled when at least one seat is selected (selectedSeats.length > 0)
    final isEnabled = widget.selectedSeats.isNotEmpty && !isActionCompleted;

    String buttonText;
    Color buttonColor;
    Color textColor;

    if (isActionCompleted) {
      // Different text for driver vs rider when completed
      buttonText = widget.userRole.toLowerCase() == 'driver'
          ? l10n.ridePosted
          : l10n.bookingCompleted;
      buttonColor = Color(0xFF00C853); // Standard green
      textColor = Colors.white;
    } else if (isEnabled) {
      // Different text for driver vs rider
      buttonText = widget.userRole.toLowerCase() == 'driver'
          ? l10n.postRide
          : l10n.completeBooking;
      buttonColor = Color(0xFF2E2E2E);
      textColor = Color(0xFFFFFFFF);
    } else {
      buttonText = l10n.noAvailableSeats;
      buttonColor = Colors.grey[400]!;
      textColor = Colors.grey[600]!;
    }

    // Use floating FAB style when isFloating is true or on web
    if (widget.isFloating) {
      return _buildFloatingButton(buttonText, buttonColor, textColor, isEnabled);
    }

    if (kIsWeb) {
      return _buildWebFAB(buttonText, buttonColor, textColor, isEnabled);
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isEnabled ? _performAction : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              buttonText,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebFAB(String buttonText, Color buttonColor, Color textColor, bool isEnabled) {
    final isMobileWeb = _isMobileWeb(context);
    final fontSize = isMobileWeb ? 15.0 : 16.0;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
          top: false,
          child: Center(
            child: FloatingActionButton.extended(
              onPressed: isEnabled ? _performAction : null,
              backgroundColor: isEnabled ? buttonColor : Colors.grey[400],
              disabledElevation: 0,
              elevation: 4,
              label: Text(
                buttonText,
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildFloatingButton(String buttonText, Color buttonColor, Color textColor, bool isEnabled) {
    return FloatingActionButton.extended(
      onPressed: isEnabled ? _performAction : null,
      backgroundColor: isEnabled ? buttonColor : Colors.grey[400],
      disabledElevation: 0,
      elevation: 6,
      label: Text(
        buttonText,
        style: TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _performAction() {
    if (widget.selectedRoute == null ||
        widget.originIndex == null ||
        widget.destinationIndex == null ||
        widget.departureTime == null ||
        widget.arrivalTime == null) {
      return;
    }

    // Debug: Print the times being saved
    print('🎫 BookingButton: Saving ${widget.userRole} action with:');
    print('   Departure: ${widget.departureTime}');
    print('   Arrival: ${widget.arrivalTime}');

    // Get current user ID
    final currentUser = AuthService.currentUser;
    final userId = currentUser?.id ?? 'unknown';

    // Check for time conflicts with existing bookings
    final bookingStorage = BookingStorage();
    if (bookingStorage.hasTimeConflict(
      userId: userId,
      departureTime: widget.departureTime!,
      arrivalTime: widget.arrivalTime!,
    )) {
      final conflictingBooking = bookingStorage.getConflictingBooking(
        userId: userId,
        departureTime: widget.departureTime!,
        arrivalTime: widget.arrivalTime!,
      );
      
      // Show error message
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            conflictingBooking != null
                ? l10n.snackbarConflictingBooking('${_formatTime(conflictingBooking.departureTime)} - ${_formatTime(conflictingBooking.arrivalTime)}')
                : l10n.snackbarAlreadyBookedThisRide,
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Prepare driver info if user is driver (compare with localized string)
    String? driverName;
    double? driverRating;
    List<RiderInfo>? riders;
    List<int> finalSelectedSeats = widget.selectedSeats;

    if (widget.userRole.toLowerCase() == 'driver' &&
        currentUser != null) {
      driverName = currentUser.name;
      if (currentUser.surname.isNotEmpty) {
        driverName = '${currentUser.name} ${currentUser.surname[0]}.';
      }
      // Get live rating from RatingService
      driverRating = MockUsers.getLiveRating(currentUser.id);
      print('🚗 Driver booking - Name: $driverName, Rating: $driverRating');

      // Start with no riders - riders will be added when they book seats
      riders = [];
      finalSelectedSeats = widget.selectedSeats;
    } else {
      print('🚗 Rider booking - userRole: ${widget.userRole}');
      riders = [];
    }

    // Create and save the booking
    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      route: widget.selectedRoute!,
      originIndex: widget.originIndex!,
      destinationIndex: widget.destinationIndex!,
      selectedSeats: finalSelectedSeats,
      departureTime: widget.departureTime!,
      arrivalTime: widget.arrivalTime!,
      bookingDate: DateTime.now(),
      userRole: widget.userRole,
      driverName: driverName,
      driverRating: driverRating,
      riders: riders,
    );

    print('\n💾 ========== CREATING BOOKING ==========');
    print('💾 Booking ID: ${booking.id}');
    print('💾 User: $userId (${currentUser?.name})');
    print('💾 Role: ${booking.userRole}');
    print('💾 Route: ${booking.route.name}');
    print(
      '💾 Origin: ${booking.route.stops[booking.originIndex].name} (${booking.originIndex})',
    );
    print(
      '💾 Destination: ${booking.route.stops[booking.destinationIndex].name} (${booking.destinationIndex})',
    );
    print('💾 Departure: ${booking.departureTime}');
    print('💾 Arrival: ${booking.arrivalTime}');
    print('💾 Now: ${DateTime.now()}');
    print('💾 Is Upcoming: ${booking.isUpcoming}');
    print('💾 Selected Seats: ${booking.selectedSeats}');
    print(
      '💾 Driver Name: ${booking.driverName}, Rating: ${booking.driverRating}',
    );
    print('=========================================\n');

    // Save to storage
    BookingStorage().addBooking(booking);

    setState(() {
      isActionCompleted = true;
    });

    // Notify parent widget that action is completed after frame is complete
    if (widget.onBookingCompleted != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onBookingCompleted!();
        }
      });
    }
  }
}
