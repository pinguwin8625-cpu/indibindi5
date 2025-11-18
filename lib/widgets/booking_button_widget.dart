import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../models/booking.dart';
import '../services/booking_storage.dart';
import '../services/auth_service.dart';
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
  });

  @override
  State<BookingButtonWidget> createState() => _BookingButtonWidgetState();
}

class _BookingButtonWidgetState extends State<BookingButtonWidget> {
  bool isBookingCompleted = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // For drivers: enabled when at least one seat is available (selectedSeats.length > 0)
    // For riders: enabled when at least one seat is selected (selectedSeats.length > 0)
    final isEnabled = widget.selectedSeats.isNotEmpty && !isBookingCompleted;
    
    String buttonText;
    Color buttonColor;
    Color textColor;
    
    if (isBookingCompleted) {
      buttonText = l10n.bookingCompleted;
      buttonColor = Color(0xFF00C853); // Standard green
      textColor = Colors.white;
    } else if (isEnabled) {
      buttonText = l10n.completeBooking;
      buttonColor = Color(0xFF2E2E2E);
      textColor = Color(0xFFFFFFFF);
    } else {
      buttonText = l10n.noAvailableSeats;
      buttonColor = Colors.grey[400]!;
      textColor = Colors.grey[600]!;
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
            onPressed: isEnabled ? _completeBooking : null,
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

  void _completeBooking() {
    if (widget.selectedRoute == null || 
        widget.originIndex == null || 
        widget.destinationIndex == null ||
        widget.departureTime == null ||
        widget.arrivalTime == null) {
      return;
    }

    // Debug: Print the times being saved
    print('🎫 BookingButton: Saving booking with:');
    print('   Departure: ${widget.departureTime}');
    print('   Arrival: ${widget.arrivalTime}');

    // Get current user ID
    final currentUser = AuthService.currentUser;
    final userId = currentUser?.id ?? 'unknown';
    final l10n = AppLocalizations.of(context)!;

    // Prepare driver info if user is driver (compare with localized string)
    String? driverName;
    double? driverRating;
    List<RiderInfo>? riders;
    List<int> finalSelectedSeats = widget.selectedSeats;
    
    if (widget.userRole.toLowerCase() == l10n.driver.toLowerCase() && currentUser != null) {
      driverName = currentUser.name;
      if (currentUser.surname.isNotEmpty) {
        driverName = '${currentUser.name} ${currentUser.surname[0]}.';
      }
      driverRating = currentUser.rating;
      print('🚗 Driver booking - Name: $driverName, Rating: $driverRating');
      
      // Add test riders for driver bookings (for testing purposes)
      // These will be replaced when real riders book seats
      riders = [
        RiderInfo(
          name: 'Elena G.', 
          rating: 4.7, 
          seatIndex: 1,
          profilePhotoUrl: 'assets/images/profile_elena.jpeg',
        ),
        RiderInfo(
          name: 'Yuki T.', 
          rating: 4.5, 
          seatIndex: 2,
          profilePhotoUrl: 'assets/images/profile_yuki.jpeg',
        ),
      ];
      print('👥 Added ${riders.length} test riders');
      for (var rider in riders) {
        print('   - ${rider.name}, photo: ${rider.profilePhotoUrl}');
      }
      
      // Remove occupied seats from selectedSeats
      // Riders occupy seats 1 and 2, so only seats 0 and 3 remain available
      final occupiedSeats = riders.map((r) => r.seatIndex).toList();
      finalSelectedSeats = widget.selectedSeats.where((seat) => !occupiedSeats.contains(seat)).toList();
      print('🎫 Original seats: ${widget.selectedSeats}, Occupied: $occupiedSeats, Available: $finalSelectedSeats');
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

    print('💾 Saving booking - ID: ${booking.id}, userRole: ${booking.userRole}, driverName: ${booking.driverName}, driverRating: ${booking.driverRating}');

    // Save to storage
    BookingStorage().addBooking(booking);

    setState(() {
      isBookingCompleted = true;
    });
    
    // Notify parent widget that booking is completed
    if (widget.onBookingCompleted != null) {
      widget.onBookingCompleted!();
    }
  }
}
