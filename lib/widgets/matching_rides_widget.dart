import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../services/booking_storage.dart';
import '../screens/rider_seat_selection_screen.dart';
import '../widgets/booking_summary_bar.dart';
import '../l10n/app_localizations.dart';

class MatchingRidesWidget extends StatelessWidget {
  final RouteInfo selectedRoute;
  final int originIndex;
  final int destinationIndex;
  final DateTime departureTime;
  final VoidCallback onBack;

  const MatchingRidesWidget({
    super.key,
    required this.selectedRoute,
    required this.originIndex,
    required this.destinationIndex,
    required this.departureTime,
    required this.onBack,
  });

  List<RideInfo> _getMatchingRides(BuildContext context) {
    final bookingStorage = BookingStorage();
    final allBookings = bookingStorage.getAllBookings();
    final l10n = AppLocalizations.of(context)!;
    
    print('🔍 Total bookings: ${allBookings.length}');
    print('🔍 Looking for route: ${selectedRoute.name}');
    print('🔍 Origin index: $originIndex, Destination index: $destinationIndex');
    print('🔍 Departure time: $departureTime');
    print('🔍 Driver role string: ${l10n.driver}');
    
    // Filter for driver bookings that match rider's criteria
    // Riders can see listings that COVER their trip even if driver goes further
    final matchingBookings = allBookings.where((booking) {
      print('  Checking booking ${booking.id}:');
      print('    - Role: ${booking.userRole}');
      print('    - Route: ${booking.route.name}');
      print('    - Origin: ${booking.originIndex}, Destination: ${booking.destinationIndex}');
      print('    - Canceled: ${booking.isCanceled}, Archived: ${booking.isArchived}');
      print('    - Upcoming: ${booking.isUpcoming}');
      
      // Must be a driver booking (compare with localized string)
      if (booking.userRole != l10n.driver) {
        print('    ❌ Not a driver (expected: ${l10n.driver}, got: ${booking.userRole})');
        return false;
      }
      
      // Must not be canceled or archived
      if (booking.isCanceled == true || booking.isArchived == true) {
        print('    ❌ Canceled or archived');
        return false;
      }
      
      // Must be upcoming
      if (!booking.isUpcoming) {
        print('    ❌ Not upcoming');
        return false;
      }
      
      // Must match the same route
      if (booking.route.name != selectedRoute.name) {
        print('    ❌ Different route');
        return false;
      }
      
      // Driver's origin must be AT or BEFORE rider's origin
      // Example: If rider wants to join at stop 2, driver can start at stop 0, 1, or 2
      if (booking.originIndex > originIndex) {
        print('    ❌ Driver starts after rider origin');
        return false;
      }
      
      // Driver's destination must be AT or AFTER rider's destination
      // Example: If rider wants to get off at stop 4, driver can go to stop 4, 5, 6, etc.
      if (booking.destinationIndex < destinationIndex) {
        print('    ❌ Driver ends before rider destination');
        return false;
      }
      
      print('    ✅ MATCH!');
      return true;
    }).toList()
    ..sort((a, b) {
      // Sort by departure time - closest to rider's preferred time first
      final aDiff = a.departureTime.difference(departureTime).inMinutes.abs();
      final bDiff = b.departureTime.difference(departureTime).inMinutes.abs();
      return aDiff.compareTo(bDiff);
    });
    
    print('🔍 Found ${matchingBookings.length} matching rides');
    
    // Convert bookings to RideInfo
    return matchingBookings.map((booking) {
      // Calculate available seats (assuming 4 total seats minus selected)
      final availableSeats = 4 - booking.selectedSeats.length;
      
      return RideInfo(
        id: booking.id,
        driverName: booking.driverName ?? 'Driver',
        driverPhoto: 'https://randomuser.me/api/portraits/lego/1.jpg',
        driverRating: booking.driverRating ?? 4.5,
        price: '\$${(10 + (destinationIndex - originIndex) * 5)}.00',
        departureTime: booking.departureTime,
        route: booking.route,
        originIndex: originIndex,
        destinationIndex: destinationIndex,
        availableSeats: availableSeats,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final matchingRides = _getMatchingRides(context);

    return Column(
      children: [
        // Summary bar showing route, stops, and time with back button
        BookingSummaryBar(
          selectedRoute: selectedRoute,
          originIndex: originIndex,
          destinationIndex: destinationIndex,
          departureTime: departureTime,
          onBack: onBack,
        ),
        
        Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Text(
                l10n.matchingRides,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black),
              ),
            ],
          ),
        ),
        Expanded(
          child: matchingRides.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No matching rides found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Try adjusting your time or route',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: matchingRides.length,
                  itemBuilder: (context, index) {
                    final ride = matchingRides[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(ride.driverPhoto),
                        ),
                        title: Text('${ride.route.stops[ride.originIndex].name} → ${ride.route.stops[ride.destinationIndex].name}'),
                        subtitle: Text('${l10n.withDriver} ${ride.driverName} ${l10n.atTime} ${_formatTime(ride.departureTime)}'),
                        trailing: Text(
                          ride.price,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RiderSeatSelectionScreen(ride: ride),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    String hour = time.hour > 12 ? '${time.hour - 12}' : '${time.hour}';
    if (time.hour == 0) hour = '12';
    String minute = time.minute.toString().padLeft(2, '0');
    String period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}