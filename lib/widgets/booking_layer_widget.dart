import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../widgets/time_selection_widget.dart';
import '../widgets/seat_planning_section_widget.dart';
import '../widgets/booking_button_widget.dart';

class BookingLayerWidget extends StatelessWidget {
  final String userRole;
  final RouteInfo selectedRoute;
  final int originIndex;
  final int destinationIndex;
  final List<int> selectedSeats;
  final bool hasSelectedDateTime;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final bool isBookingCompleted;
  final Function(List<int>) onSeatsSelected;
  final Function(DateTime departure, DateTime arrival) onTimeSelected;
  final VoidCallback onBookingCompleted;
  final VoidCallback onBack;

  const BookingLayerWidget({
    super.key,
    required this.userRole,
    required this.selectedRoute,
    required this.originIndex,
    required this.destinationIndex,
    required this.selectedSeats,
    required this.hasSelectedDateTime,
    required this.departureTime,
    required this.arrivalTime,
    required this.isBookingCompleted,
    required this.onSeatsSelected,
    required this.onTimeSelected,
    required this.onBookingCompleted,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    String originStop = selectedRoute.stops[originIndex].name;
    String destinationStop = selectedRoute.stops[destinationIndex].name;

    return Column(
      children: [
        // Header with back button
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: Icon(Icons.arrow_back_ios, color: Color(0xFF8E8E8E), size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.all(8),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose your seats',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E2E2E),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show time picker if time not selected
                  if (!hasSelectedDateTime) ...[
                    Text(
                      'When do you want to travel?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    TimeSelectionWidget(
                      selectedRoute: selectedRoute,
                      originIndex: originIndex,
                      destinationIndex: destinationIndex,
                      onDateTimeSelected: (hasSelected) {
                        // This will be handled by onTimesChanged
                      },
                      onTimesChanged: (departure, arrival) {
                        onTimeSelected(departure, arrival);
                      },
                    ),
                  ],

                  // Show seat selection if time is selected
                  if (hasSelectedDateTime) ...[
                    // Seat layout
                    SeatPlanningSectionWidget(
                      userRole: userRole,
                      selectedSeats: selectedSeats,
                      isDisabled: isBookingCompleted,
                      onSeatsSelected: onSeatsSelected,
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Booking button
                    BookingButtonWidget(
                      selectedRoute: selectedRoute,
                      originIndex: originIndex,
                      destinationIndex: destinationIndex,
                      selectedSeats: selectedSeats,
                      onBookingCompleted: onBookingCompleted,
                    ),
                  ],
                  
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
