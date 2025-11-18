import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../screens/rider_seat_selection_screen.dart';
import '../l10n/app_localizations.dart';

/// A card that displays a matching ride with the same style as booking cards
class MatchingRideCard extends StatelessWidget {
  final RideInfo ride;

  const MatchingRideCard({
    super.key,
    required this.ride,
  });

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diffDays = target.difference(today).inDays;

    if (diffDays == 0) return l10n.today;
    if (diffDays == 1) return l10n.tomorrow;

    final monthAbbr = [
      l10n.jan, l10n.feb, l10n.mar, l10n.apr, l10n.may, l10n.jun,
      l10n.jul, l10n.aug, l10n.sep, l10n.oct, l10n.nov, l10n.dec,
    ];

    return '${date.day} ${monthAbbr[date.month - 1]}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RiderSeatSelectionScreen(ride: ride),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route name and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      ride.route.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _formatDate(context, ride.departureTime),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Origin with departure time
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ride.route.stops[ride.originIndex].name,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _formatTime(ride.departureTime),
                      style: TextStyle(
                        fontSize: 14,
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
                  Icon(Icons.flag, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ride.route.stops[ride.destinationIndex].name,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _formatTime(ride.arrivalTime),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Miniature seat layout showing available seats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Seat layout
                  Expanded(
                    child: _buildMiniatureSeatLayout(),
                  ),
                  
                  // Price badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFFDD2C00),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ride.price,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniatureSeatLayout() {
    // For matching rides, availableSeats tells us how many seats are free
    // We'll show driver (always occupied) and passenger seats (available/occupied)
    final totalSeats = 4; // 3 passenger seats + driver
    final occupiedPassengerSeats = totalSeats - 1 - ride.availableSeats; // -1 for driver seat
    
    // Create a list showing which passenger seats are available (indices 0-3)
    // Seat 0-2 are back seats, seat 3 is front passenger
    // For simplicity, mark first N seats as occupied, rest as available
    final List<bool> seatOccupied = List.generate(4, (index) => index < occupiedPassengerSeats);

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Left column - Back seats (1, 2, 3)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildMiniSeat(1, seatOccupied[1]),
              SizedBox(height: 4),
              _buildMiniSeat(2, seatOccupied[2]),
              SizedBox(height: 4),
              _buildMiniSeat(3, seatOccupied[3]),
            ],
          ),

          SizedBox(width: 12),

          // Right column - Front seats (Driver and seat 0)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMiniSeat(null, true, isDriver: true), // Driver always occupied
              SizedBox(height: 12),
              _buildMiniSeat(0, seatOccupied[0]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniSeat(int? seatIndex, bool isOccupied, {bool isDriver = false}) {
    Color backgroundColor;
    Color borderColor;

    if (isDriver) {
      // Driver seat is always red/occupied
      backgroundColor = Colors.red[100]!;
      borderColor = Color(0xFFDD2C00);
    } else if (isOccupied) {
      // Occupied passenger seat
      backgroundColor = Colors.red[100]!;
      borderColor = Color(0xFFDD2C00);
    } else {
      // Available passenger seat
      backgroundColor = Colors.green[100]!;
      borderColor = Color(0xFF00C853);
    }

    Widget seatContent;
    if (isDriver) {
      // Show driver initial
      seatContent = CircleAvatar(
        radius: 16,
        backgroundColor: Color(0xFFDD2C00),
        child: Text(
          ride.driverName.isNotEmpty ? ride.driverName[0].toUpperCase() : 'D',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    } else {
      // Show generic person icon
      seatContent = Icon(
        Icons.person,
        size: 24,
        color: isOccupied ? Colors.grey[700] : Colors.green[700],
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Center(
        child: seatContent,
      ),
    );
  }
}
