import 'package:flutter/material.dart';
import '../models/routes.dart';

class SeatAvailabilityInfoWidget extends StatelessWidget {
  final RouteInfo selectedRoute;
  final int originIndex;
  final int destinationIndex;
  final List<int> selectedSeats;
  final String userRole;

  const SeatAvailabilityInfoWidget({
    super.key,
    required this.selectedRoute,
    required this.originIndex,
    required this.destinationIndex,
    required this.selectedSeats,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('info-card'),
      width: 160,
      height: 120,
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Single line with standard font sizing
            Text(
              userRole == 'Driver'
                  ? '${4 - selectedSeats.length} seats available for riders'
                  : '${4 - selectedSeats.length} seats available',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF2E2E2E),
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
