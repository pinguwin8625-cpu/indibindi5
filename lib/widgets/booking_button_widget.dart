import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/routes.dart';

class BookingButtonWidget extends StatelessWidget {
  final RouteInfo? selectedRoute;
  final int? originIndex;
  final int? destinationIndex;
  final List<int> selectedSeats;

  const BookingButtonWidget({
    super.key,
    required this.selectedRoute,
    required this.originIndex,
    required this.destinationIndex,
    required this.selectedSeats,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = (4 - selectedSeats.length) > 0;
    
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        left: 16,
        right: 16,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isEnabled ? Color(0xFF2E2E2E) : Colors.grey[400],
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: isEnabled ? 'Complete Booking' : 'No Available Seats',
            isExpanded: true,
            onChanged: null, // Disabled dropdown functionality
            dropdownColor: Color(0xFF2E2E2E),
            icon: SizedBox(), // Remove arrow icon
            items: [
              DropdownMenuItem<String>(
                value: isEnabled ? 'Complete Booking' : 'No Available Seats',
                child: Center(
                  child: Text(
                    isEnabled ? 'Complete Booking' : 'No Available Seats',
                    style: TextStyle(
                      fontSize: 16,
                      color: isEnabled ? Color(0xFFFFFFFF) : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBookingSubmission(BuildContext context) {
    if (kDebugMode) {
      debugPrint('Final booking submitted!');
      debugPrint('Route: ${selectedRoute?.name}');
      debugPrint('Origin: ${selectedRoute?.stops[originIndex!].name}');
      debugPrint('Destination: ${selectedRoute?.stops[destinationIndex!].name}');
      debugPrint('Selected seats: $selectedSeats');
    }

    // TODO: Navigate to confirmation screen or process booking
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
