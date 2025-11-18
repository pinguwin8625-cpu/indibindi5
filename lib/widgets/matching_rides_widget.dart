import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../services/booking_storage.dart';
import '../widgets/booking_summary_bar.dart';
import '../widgets/matching_rides_card.dart';
import '../l10n/app_localizations.dart';

class MatchingRidesWidget extends StatelessWidget {
  final RouteInfo selectedRoute;
  final int originIndex;
  final int destinationIndex;
  final DateTime departureTime;
  final DateTime? arrivalTime; // For riders who chose arrival
  final String? riderTimeChoice; // 'departure' or 'arrival'
  final VoidCallback onBack;

  const MatchingRidesWidget({
    super.key,
    required this.selectedRoute,
    required this.originIndex,
    required this.destinationIndex,
    required this.departureTime,
    this.arrivalTime,
    this.riderTimeChoice,
    required this.onBack,
  });

  List<RideInfo> _getMatchingRides(BuildContext context) {
    try {
      final bookingStorage = BookingStorage();
      final allBookings = bookingStorage.getAllBookings();
      final l10n = AppLocalizations.of(context)!;
      
      print('🔍 Total bookings: ${allBookings.length}');
      print('🔍 Looking for route: ${selectedRoute.name}');
      print('🔍 Origin index: $originIndex, Destination index: $destinationIndex');
      print('🔍 Departure time: $departureTime');
      print('🔍 Rider time choice: $riderTimeChoice');
      print('🔍 Arrival time: $arrivalTime');
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
      
      // Must be a driver booking
      // userRole is stored as 'driver' or 'rider' in English (not localized)
      if (booking.userRole.toLowerCase() != 'driver') {
        print('    ❌ Not a driver booking (role: ${booking.userRole})');
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
      
      // Time filtering based on rider's choice - calculate times at RIDER'S stops
      if (riderTimeChoice == 'departure') {
        // Rider chose departure time - match rides departing at or after rider's departure time
        // Calculate when the driver arrives at the rider's ORIGIN stop
        int minutesToRiderOrigin = 0;
        for (int i = booking.originIndex + 1; i <= originIndex; i++) {
          minutesToRiderOrigin += booking.route.stops[i].durationFromPrevious;
        }
        final driverArrivalAtRiderOrigin = booking.departureTime.add(Duration(minutes: minutesToRiderOrigin));
        
        if (driverArrivalAtRiderOrigin.isBefore(departureTime)) {
          print('    ❌ Driver arrives at rider\'s origin (stop $originIndex) before rider\'s preferred departure time');
          print('       Driver time at stop $originIndex: $driverArrivalAtRiderOrigin, Rider wants: $departureTime');
          return false;
        }
      } else if (riderTimeChoice == 'arrival' && arrivalTime != null) {
        // Rider chose arrival time - match rides arriving at or before rider's arrival time
        // Calculate when the driver arrives at the rider's DESTINATION stop
        int minutesToRiderDestination = 0;
        for (int i = booking.originIndex + 1; i <= destinationIndex; i++) {
          minutesToRiderDestination += booking.route.stops[i].durationFromPrevious;
        }
        final driverArrivalAtRiderDestination = booking.departureTime.add(Duration(minutes: minutesToRiderDestination));
        
        if (driverArrivalAtRiderDestination.isAfter(arrivalTime!)) {
          print('    ❌ Driver arrives at rider\'s destination (stop $destinationIndex) after rider\'s preferred arrival time');
          print('       Driver time at stop $destinationIndex: $driverArrivalAtRiderDestination, Rider wants: $arrivalTime');
          return false;
        }
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
        arrivalTime: booking.arrivalTime,
        route: booking.route,
        originIndex: originIndex,
        destinationIndex: destinationIndex,
        availableSeats: availableSeats,
      );
    }).toList();
    } catch (e, stackTrace) {
      print('❌ Error in _getMatchingRides: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }
  Widget build(BuildContext context) {
    print('🏗️ MatchingRides: Starting build');
    final l10n = AppLocalizations.of(context)!;
    
    print('🔍 MatchingRides: Calling _getMatchingRides');
    final matchingRides = _getMatchingRides(context);
    print('🔍 MatchingRides: Got ${matchingRides.length} matching rides');
    
    // Determine which times to display based on rider's choice
    DateTime displayDepartureTime;
    DateTime displayArrivalTime;
    
    print('🕐 MatchingRides: Calculating display times, riderTimeChoice=$riderTimeChoice');
    if (riderTimeChoice == 'arrival' && arrivalTime != null) {
      // Rider chose arrival time - use it directly and calculate departure
      displayArrivalTime = arrivalTime!;
      // Calculate departure time by subtracting route duration
      int totalMinutes = 0;
      for (int i = originIndex + 1; i <= destinationIndex; i++) {
        totalMinutes += selectedRoute.stops[i].durationFromPrevious;
      }
      displayDepartureTime = arrivalTime!.subtract(Duration(minutes: totalMinutes));
    } else {
      // Rider chose departure time (or default) - use it and calculate arrival
      displayDepartureTime = departureTime;
      int totalMinutes = 0;
      for (int i = originIndex + 1; i <= destinationIndex; i++) {
        totalMinutes += selectedRoute.stops[i].durationFromPrevious;
      }
      displayArrivalTime = departureTime.add(Duration(minutes: totalMinutes));
    }

    print('🕐 MatchingRides: Display times calculated - departure: $displayDepartureTime, arrival: $displayArrivalTime');
    print('🏗️ MatchingRides: Building UI');

    return SafeArea(
      child: Column(
        children: [
          // Summary bar showing route, stops, and time with back button
          BookingSummaryBar(
            selectedRoute: selectedRoute,
            originIndex: originIndex,
            destinationIndex: destinationIndex,
            departureTime: displayDepartureTime,
            arrivalTime: displayArrivalTime,
            userRole: 'rider',
            riderTimeChoice: riderTimeChoice,
            onBack: () {
              print('🔙 MatchingRides: Back button pressed in BookingSummaryBar');
              print('🔙 MatchingRides: Calling onBack()');
              onBack();
              print('🔙 MatchingRides: onBack() returned');
            },
          ),
          
          // Header
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
          
          // Scrollable content area
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
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: matchingRides.length,
                  itemBuilder: (context, index) {
                    final ride = matchingRides[index];
                    return MatchingRideCard(ride: ride);
                  },
                ),
        ),
      ],
    ),
    );
  }
}