import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../utils/date_time_helpers.dart';
import 'package:intl/intl.dart';

class BookingSummaryBar extends StatelessWidget {
  final RouteInfo? selectedRoute;
  final int? originIndex;
  final int? destinationIndex;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final List<int>? selectedSeats;
  final String? userRole;
  final String? riderTimeChoice; // 'departure' or 'arrival' for riders
  final VoidCallback? onBack;

  const BookingSummaryBar({
    super.key,
    this.selectedRoute,
    this.originIndex,
    this.destinationIndex,
    this.departureTime,
    this.arrivalTime,
    this.selectedSeats,
    this.userRole,
    this.riderTimeChoice,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    print('🏗️ BookingSummaryBar: Building with onBack=${onBack != null ? "NOT NULL" : "NULL"}');
    // Don't show if no data is selected
    if (selectedRoute == null && departureTime == null && selectedSeats == null) {
      return SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and route name with date
          if (selectedRoute != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                if (onBack != null) ...[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      print('🔙 BookingSummaryBar: GestureDetector tapped!');
                      onBack!();
                      print('🔙 BookingSummaryBar: onBack callback executed');
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.arrow_back_ios, color: Colors.red, size: 20),
                    ),
                  ),
                  SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    selectedRoute!.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E2E),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (departureTime != null) ...[
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _formatDate(departureTime!),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],

          // Origin and destination with times
          if (selectedRoute != null && originIndex != null && destinationIndex != null) ...[
            SizedBox(height: 12),
            
            // Origin with departure time
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedRoute!.stops[originIndex!].name,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                // Show departure time for drivers, or for riders who chose departure
                if (departureTime != null && 
                    (userRole?.toLowerCase() == 'driver' || riderTimeChoice == 'departure'))
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      formatTimeHHmm(departureTime!),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: 8),
            
            // Destination with arrival time
            Row(
              children: [
                Icon(Icons.flag, color: Colors.red, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedRoute!.stops[destinationIndex!].name,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                // Show arrival time for drivers, or for riders who chose arrival
                if (arrivalTime != null && 
                    (userRole?.toLowerCase() == 'driver' || riderTimeChoice == 'arrival'))
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      formatTimeHHmm(arrivalTime!),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    if (isTodayDate(date)) {
      return 'Today';
    } else if (isTomorrowDate(date)) {
      return 'Tomorrow';
    } else {
      final dateFormat = DateFormat('MMM d');
      return dateFormat.format(date);
    }
  }
}
