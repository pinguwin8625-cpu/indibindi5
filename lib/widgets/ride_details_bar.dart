import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../utils/date_time_helpers.dart';
import 'package:intl/intl.dart';

class RideDetailsBar extends StatelessWidget {
  final RouteInfo? selectedRoute;
  final int? originIndex;
  final int? destinationIndex;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final List<int>? selectedSeats;
  final String? userRole;
  final String? riderTimeChoice; // 'departure' or 'arrival' for riders
  final VoidCallback? onBack;
  
  // Alternative string-based parameters (for when RouteInfo is not available)
  final String? routeName;
  final String? originName;
  final String? destinationName;

  const RideDetailsBar({
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
    this.routeName,
    this.originName,
    this.destinationName,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show if no data is selected (check both RouteInfo and string-based params)
    final hasRouteData = selectedRoute != null || routeName != null;
    if (!hasRouteData &&
        departureTime == null &&
        selectedSeats == null) {
      return SizedBox.shrink();
    }
    
    // Get route name from either source
    final displayRouteName = selectedRoute?.name ?? routeName ?? '';
    
    // Get origin name from either source
    final displayOriginName = (selectedRoute != null && originIndex != null)
        ? selectedRoute!.stops[originIndex!].name
        : originName;
    
    // Get destination name from either source
    final displayDestinationName = (selectedRoute != null && destinationIndex != null)
        ? selectedRoute!.stops[destinationIndex!].name
        : destinationName;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        color: Colors.grey[50],
      ),
      child: Row(
        children: [
          // Back button - more prominent (or spacer if no back button)
          if (onBack != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBack,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Color(0xFFDD2C00).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFFDD2C00),
                  size: 16,
                ),
              ),
            )
          else
            SizedBox(width: 28), // Same width as back button for centering
          
          SizedBox(width: 8),
          
          // Route and stops info - centered
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Role icon, route name and date on same row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Role icon
                    if (userRole != null) ...[
                      Icon(
                        userRole!.toLowerCase() == 'driver'
                            ? Icons.directions_car
                            : Icons.person,
                        color: Color(0xFFDD2C00),
                        size: 14,
                      ),
                      SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        displayRouteName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF42A5F5),
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (departureTime != null) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _formatDate(departureTime!),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                
                // Origin only (when pick up is selected but not drop off)
                if (displayOriginName != null && displayDestinationName == null)
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Origin - location pin icon (same as progress bar)
                        Icon(Icons.location_on, color: Colors.green, size: 14),
                        SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            _shortenStopName(displayOriginName),
                            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Origin → Destination with times (compact single row)
                if (displayOriginName != null && displayDestinationName != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Origin - location pin icon (same as progress bar)
                        Icon(Icons.location_on, color: Colors.green, size: 14),
                        SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            _shortenStopName(displayOriginName),
                            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (departureTime != null)
                          Text(
                            ' ${formatTimeHHmm(departureTime!)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                        
                        // Arrow
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(Icons.arrow_forward, size: 12, color: Colors.grey[400]),
                        ),
                        
                        // Destination - flag icon (same as progress bar)
                        Icon(Icons.flag, color: Colors.red, size: 14),
                        SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            _shortenStopName(displayDestinationName),
                            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (arrivalTime != null)
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Text(
                                ' ${formatTimeHHmm(arrivalTime!)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[700],
                                ),
                              ),
                              // Show +1 at top right corner if arrival is on a different day than departure
                              if (departureTime != null &&
                                  (arrivalTime!.day != departureTime!.day ||
                                   arrivalTime!.month != departureTime!.month ||
                                   arrivalTime!.year != departureTime!.year))
                                Positioned(
                                  top: -1,
                                  right: -10,
                                  child: Text(
                                    '+1',
                                    style: TextStyle(
                                      fontSize: 7,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          SizedBox(width: 8),
          
          // Spacer to balance the back button
          SizedBox(width: 28),
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

  // Shorten stop names for compact display
  String _shortenStopName(String name) {
    // If name is short enough, return as is
    if (name.length <= 15) return name;
    
    // Try to get first meaningful part
    if (name.contains(' - ')) {
      return name.split(' - ').first;
    }
    if (name.contains(', ')) {
      return name.split(', ').first;
    }
    
    // Just truncate
    return '${name.substring(0, 12)}...';
  }
}
