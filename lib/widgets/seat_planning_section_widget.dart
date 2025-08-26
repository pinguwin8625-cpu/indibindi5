import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../widgets/car_seat_layout.dart';

class SeatPlanningSectionWidget extends StatelessWidget {
  final String userRole;
  final List<int> selectedSeats;
  final Function(List<int>) onSeatsSelected;

  const SeatPlanningSectionWidget({
    super.key,
    required this.userRole,
    required this.selectedSeats,
    required this.onSeatsSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          key: ValueKey('seat-layout'),
          height:
              434, // Reduced to give only 10px extra space (5px top + 5px bottom)
          decoration: BoxDecoration(),
          child: CarSeatLayout(
            userRole: userRole,
            onSeatsSelected: (seats) {
              onSeatsSelected(seats);
              if (kDebugMode) {
                debugPrint('Selected seats: $seats');
              }
            },
          ),
        ),
      ],
    );
  }
}
