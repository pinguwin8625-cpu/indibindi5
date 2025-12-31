import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/routes.dart';
import '../models/booking.dart';
import '../services/booking_storage.dart';
import '../services/auth_service.dart';
import '../services/mock_users.dart';
import '../widgets/ride_details_bar.dart';
import '../widgets/matching_rides_card.dart';
import '../widgets/scroll_indicator.dart';
import '../l10n/app_localizations.dart';

class MatchingRidesWidget extends StatefulWidget {
  final RouteInfo selectedRoute;
  final int originIndex;
  final int destinationIndex;
  final DateTime departureTime;
  final DateTime? arrivalTime; // For riders who chose arrival
  final String? riderTimeChoice; // 'departure' or 'arrival'
  final VoidCallback onBack;
  final VoidCallback? onBookingCompleted;

  const MatchingRidesWidget({
    super.key,
    required this.selectedRoute,
    required this.originIndex,
    required this.destinationIndex,
    required this.departureTime,
    this.arrivalTime,
    this.riderTimeChoice,
    required this.onBack,
    this.onBookingCompleted,
  });

  @override
  State<MatchingRidesWidget> createState() => _MatchingRidesWidgetState();
}

class _MatchingRidesWidgetState extends State<MatchingRidesWidget> {
  bool _hasPendingSeats = false;
  VoidCallback? _confirmAction;
  String? _activeRideId; // Track which ride has pending seats
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<RideInfo> _getMatchingRides(BuildContext context) {
    try {
      final bookingStorage = BookingStorage();
      final allBookings = bookingStorage.getAllBookings();
      final currentUser = AuthService.currentUser;

      print(
        '🔍 MATCHING DEBUG: Total bookings in storage: ${allBookings.length}',
      );
      print('🔍 Rider searching for:');
      print('   Route: ${widget.selectedRoute.name}');
      print(
        '   Origin: ${widget.originIndex} (${widget.selectedRoute.stops[widget.originIndex].name})',
      );
      print(
        '   Destination: ${widget.destinationIndex} (${widget.selectedRoute.stops[widget.destinationIndex].name})',
      );
      print('   Time choice: ${widget.riderTimeChoice}');
      print('   Departure time: ${widget.departureTime}');
      print('   Arrival time: ${widget.arrivalTime}');

      // Filter for driver bookings that match rider's criteria
      // Riders can see listings that COVER their trip even if driver goes further
      final matchingBookings =
          allBookings.where((booking) {
            print('\n📋 Checking booking ${booking.id}:');
            print('   User: ${booking.userId} (${booking.userRole})');
            print('   Route: ${booking.route.name}');
            print(
              '   Driver Origin: ${booking.originIndex} (${booking.route.stops[booking.originIndex].name})',
            );
            print(
              '   Driver Dest: ${booking.destinationIndex} (${booking.route.stops[booking.destinationIndex].name})',
            );
            print('   Departure: ${booking.departureTime}');
            print(
              '   Canceled: ${booking.isCanceled}, Archived: ${booking.isArchived}',
            );
            print('   IsUpcoming: ${booking.isUpcoming}');
            print(
              '   Selected seats: ${booking.selectedSeats} (length: ${booking.selectedSeats.length})',
            );
            print('   Riders: ${booking.riders?.length ?? 0}');
            print(
              '   Available seats: ${booking.selectedSeats.length - (booking.riders?.length ?? 0)}',
            );

            // Must be a driver booking
            // userRole is stored as 'driver' or 'rider' in English (not localized)
            if (booking.userRole.toLowerCase() != 'driver') {
              print('   ❌ Not a driver booking');
              return false;
            }

            // Cannot book a seat on your own driver booking (against regulations)
            if (currentUser != null && booking.userId == currentUser.id) {
              print('   ❌ Cannot book seat on your own ride');
              return false;
            }

            // Skip corrupted bookings (more riders than offered seats)
            if ((booking.riders?.length ?? 0) > booking.selectedSeats.length) {
              print(
                '   ⚠️ CORRUPTED BOOKING: ${booking.riders?.length ?? 0} riders but only ${booking.selectedSeats.length} seats offered',
              );
              return false;
            }

            // Must not be canceled or archived
            if (booking.isCanceled == true || booking.isArchived == true) {
              print('   ❌ Canceled or archived');
              return false;
            }

            // Must be upcoming
            if (!booking.isUpcoming) {
              print('   ❌ Not upcoming (past booking)');
              return false;
            }

            // Must match the same route
            if (booking.route.name != widget.selectedRoute.name) {
              print('   ❌ Different route');
              return false;
            }

            // Driver's origin must be AT or BEFORE rider's origin
            // Example: If rider wants to join at stop 2, driver can start at stop 0, 1, or 2
            if (booking.originIndex > widget.originIndex) {
              print('   ❌ Driver starts after rider origin');
              return false;
            }

            // Driver's destination must be AT or AFTER rider's destination
            // Example: If rider wants to get off at stop 4, driver can go to stop 4, 5, 6, etc.
            if (booking.destinationIndex < widget.destinationIndex) {
              print('   ❌ Driver ends before rider destination');
              return false;
            }

            // Time filtering based on rider's choice - calculate times at RIDER'S stops
            if (widget.riderTimeChoice == 'departure') {
              // Rider chose departure time - match rides departing at or after rider's departure time
              // Calculate when the driver arrives at the rider's ORIGIN stop
              int minutesToRiderOrigin = 0;
              for (int i = booking.originIndex + 1; i <= widget.originIndex; i++) {
                minutesToRiderOrigin +=
                    booking.route.stops[i].durationFromPrevious;
              }
              final driverArrivalAtRiderOrigin = booking.departureTime.add(
                Duration(minutes: minutesToRiderOrigin),
              );

              // Show all rides where driver arrives at or after rider's desired departure time
              // (no upper limit - rider can choose any ride in the future)
              if (driverArrivalAtRiderOrigin.isBefore(widget.departureTime)) {
                print(
                  '   ❌ Driver arrives at rider origin BEFORE rider wants to depart',
                );
                print(
                  '      Driver at stop ${widget.originIndex}: $driverArrivalAtRiderOrigin, Rider wants: ${widget.departureTime}',
                );
                return false;
              }
            } else if (widget.riderTimeChoice == 'arrival' && widget.arrivalTime != null) {
              // Rider chose arrival time - match rides arriving at or before rider's arrival time
              // Calculate when the driver arrives at the rider's DESTINATION stop
              int minutesToRiderDestination = 0;
              for (
                int i = booking.originIndex + 1;
                i <= widget.destinationIndex;
                i++
              ) {
                minutesToRiderDestination +=
                    booking.route.stops[i].durationFromPrevious;
              }
              final driverArrivalAtRiderDestination = booking.departureTime.add(
                Duration(minutes: minutesToRiderDestination),
              );

              if (driverArrivalAtRiderDestination.isAfter(widget.arrivalTime!)) {
                print(
                  '   ❌ Driver arrives at rider destination AFTER rider wants to arrive',
                );
                print(
                  '      Driver at stop ${widget.destinationIndex}: $driverArrivalAtRiderDestination, Rider wants: ${widget.arrivalTime}',
                );
                return false;
              }
            }

            // Calculate available seats (for display purposes)
            final totalOfferedSeats = booking.selectedSeats.length;
            final bookedSeats = booking.riders?.length ?? 0;
            final availableSeats = totalOfferedSeats - bookedSeats;

            print('   ✅ MATCH! Available seats: $availableSeats');
            return true;
          }).toList()..sort((a, b) {
            // Sort by departure time - closest to rider's preferred time first
            final aDiff = a.departureTime
                .difference(widget.departureTime)
                .inMinutes
                .abs();
            final bDiff = b.departureTime
                .difference(widget.departureTime)
                .inMinutes
                .abs();
            return aDiff.compareTo(bDiff);
          });

      print('\n✅ Found ${matchingBookings.length} matching rides\n');

      // Convert bookings to RideInfo
      return matchingBookings.map((booking) {
        // Calculate available seats: total offered seats minus already booked riders
        final totalOfferedSeats = booking.selectedSeats.length;
        final bookedSeats = booking.riders?.length ?? 0;
        final availableSeats = totalOfferedSeats - bookedSeats;

        // Get driver's photo and name from user data
        // Always look up driver name from MockUsers first for accuracy
        final driver = MockUsers.getUserById(booking.userId);
        final driverPhoto = driver?.profilePhotoUrl ?? '';
        String driverDisplayName;
        if (driver != null) {
          driverDisplayName = driver.name;
          if (driver.surname.isNotEmpty) {
            driverDisplayName = '${driver.name} ${driver.surname[0]}.';
          }
        } else {
          // Fall back to stored name or default
          driverDisplayName = booking.driverName ?? 'Driver';
        }

        return RideInfo(
          id: booking.id,
          driverId: booking.userId,
          driverName: driverDisplayName,
          driverPhoto: driverPhoto,
          driverRating: booking.driverRating ?? 4.5,
          price: '\$${(10 + (widget.destinationIndex - widget.originIndex) * 5)}.00',
          departureTime: booking.departureTime,
          arrivalTime: booking.arrivalTime,
          route: booking.route,
          originIndex: widget.originIndex,
          destinationIndex: widget.destinationIndex,
          availableSeats: availableSeats,
          riders: booking.riders, // Pass riders from booking
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  void _onPendingChanged(String rideId, bool hasPending, VoidCallback? confirmAction) {
    print('🔔 _onPendingChanged called: rideId=$rideId, hasPending=$hasPending, confirmAction=${confirmAction != null}');
    setState(() {
      if (hasPending) {
        _hasPendingSeats = true;
        _confirmAction = confirmAction;
        _activeRideId = rideId;
      } else if (_activeRideId == rideId) {
        // Only clear if this is the active ride
        _hasPendingSeats = false;
        _confirmAction = null;
        _activeRideId = null;
      }
    });
    print('🔔 State updated: _hasPendingSeats=$_hasPendingSeats, _activeRideId=$_activeRideId');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bookingStorage = BookingStorage();

    // Determine which times to display based on rider's choice
    DateTime displayDepartureTime;
    DateTime displayArrivalTime;

    if (widget.riderTimeChoice == 'arrival' && widget.arrivalTime != null) {
      // Rider chose arrival time - use it directly and calculate departure
      displayArrivalTime = widget.arrivalTime!;
      // Calculate departure time by subtracting route duration
      int totalMinutes = 0;
      for (int i = widget.originIndex + 1; i <= widget.destinationIndex; i++) {
        totalMinutes += widget.selectedRoute.stops[i].durationFromPrevious;
      }
      displayDepartureTime = widget.arrivalTime!.subtract(
        Duration(minutes: totalMinutes),
      );
    } else {
      // Rider chose departure time (or default) - use it and calculate arrival
      displayDepartureTime = widget.departureTime;
      int totalMinutes = 0;
      for (int i = widget.originIndex + 1; i <= widget.destinationIndex; i++) {
        totalMinutes += widget.selectedRoute.stops[i].durationFromPrevious;
      }
      displayArrivalTime = widget.departureTime.add(Duration(minutes: totalMinutes));
    }

    return ValueListenableBuilder<List<Booking>>(
      valueListenable: bookingStorage.bookings,
      builder: (context, bookings, child) {
        final matchingRides = _getMatchingRides(context);
        
        return SafeArea(
          child: Column(
            children: [
              // Summary bar showing route, stops, and time with back button
              RideDetailsBar(
                selectedRoute: widget.selectedRoute,
                originIndex: widget.originIndex,
                destinationIndex: widget.destinationIndex,
                departureTime: displayDepartureTime,
                arrivalTime: displayArrivalTime,
                userRole: 'rider',
                riderTimeChoice: widget.riderTimeChoice,
                onBack: widget.onBack,
              ),

              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        l10n.matchingRides,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5D4037),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          l10n.hintMatchingRides,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF5D4037).withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
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
                              l10n.noMatchingRidesFound,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              l10n.tryAdjustingTimeOrRoute,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : kIsWeb
                        // Web: SingleChildScrollView with inline FAB button and scroll indicator
                        ? ScrollIndicator(
                            scrollController: _scrollController,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  ...matchingRides.map((ride) => MatchingRideCard(
                                    key: ValueKey('ride-${ride.id}'),
                                    ride: ride,
                                    onBookingCompleted: widget.onBookingCompleted,
                                    onPendingChanged: _onPendingChanged,
                                    activeRideId: _activeRideId,
                                  )),
                                  // Inline FAB button for web (inside scrollable content)
                                  if (_hasPendingSeats && _confirmAction != null)
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 24),
                                      child: Center(
                                        child: FloatingActionButton.extended(
                                          onPressed: _confirmAction,
                                          backgroundColor: Color(0xFF2E2E2E),
                                          elevation: 4,
                                          label: Text(
                                            l10n.completeBooking,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          )
                        // Mobile: ListView with fixed button at bottom
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: matchingRides.length,
                            itemBuilder: (context, index) {
                              final ride = matchingRides[index];
                              return MatchingRideCard(
                                key: ValueKey('ride-${ride.id}'),
                                ride: ride,
                                onBookingCompleted: widget.onBookingCompleted,
                                onPendingChanged: _onPendingChanged,
                                activeRideId: _activeRideId,
                              );
                            },
                          ),
              ),

              // Fixed confirm button at bottom (mobile only)
              if (!kIsWeb && _hasPendingSeats && _confirmAction != null)
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2E2E2E),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        l10n.completeBooking,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
