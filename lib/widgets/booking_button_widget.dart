import 'package:flutter/material.dart';
import '../models/routes.dart';

class BookingButtonWidget extends StatefulWidget {
  final RouteInfo? selectedRoute;
  final int? originIndex;
  final int? destinationIndex;
  final List<int> selectedSeats;
  final VoidCallback? onBookingCompleted;

  const BookingButtonWidget({
    super.key,
    required this.selectedRoute,
    required this.originIndex,
    required this.destinationIndex,
    required this.selectedSeats,
    this.onBookingCompleted,
  });

  @override
  State<BookingButtonWidget> createState() => _BookingButtonWidgetState();
}

class _BookingButtonWidgetState extends State<BookingButtonWidget> {
  bool isBookingCompleted = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = (4 - widget.selectedSeats.length) > 0 && !isBookingCompleted;
    
    String buttonText;
    Color buttonColor;
    Color textColor;
    
    if (isBookingCompleted) {
      buttonText = 'Booking Completed';
      buttonColor = Color(0xFF00C853); // Standard green
      textColor = Colors.white;
    } else if (isEnabled) {
      buttonText = 'Complete Booking';
      buttonColor = Color(0xFF2E2E2E);
      textColor = Color(0xFFFFFFFF);
    } else {
      buttonText = 'No Available Seats';
      buttonColor = Colors.grey[400]!;
      textColor = Colors.grey[600]!;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
      child: GestureDetector(
        onTap: isEnabled ? _completeBooking : null,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            height: 42.0,
            child: Center(
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _completeBooking() {
    setState(() {
      isBookingCompleted = true;
    });
    
    // Notify parent widget that booking is completed
    if (widget.onBookingCompleted != null) {
      widget.onBookingCompleted!();
    }
  }
}
