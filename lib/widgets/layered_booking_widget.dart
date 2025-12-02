import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../widgets/booking_progress_bar.dart';
import '../widgets/route_layer_widget.dart';
import '../widgets/stops_layer_widget.dart';
import '../widgets/booking_layer_widget.dart';
import '../widgets/matching_rides_widget.dart';
import '../utils/booking_logic.dart';
import '../l10n/app_localizations.dart';

enum BookingLayer { routeSelection, stopsSelection, timeAndSeats, matchingRides }

class LayeredBookingWidget extends StatefulWidget {
  final String userRole;
  final VoidCallback? onBookingCompleted;
  final TabController? tabController;
  final bool hasSelectedRole;
  final VoidCallback? onRoleSelected;

  const LayeredBookingWidget({
    super.key,
    required this.userRole,
    this.onBookingCompleted,
    this.tabController,
    this.hasSelectedRole = false,
    this.onRoleSelected,
  });

  @override
  State<LayeredBookingWidget> createState() => _LayeredBookingWidgetState();
}

class _LayeredBookingWidgetState extends State<LayeredBookingWidget> {
  BookingLayer currentLayer = BookingLayer.routeSelection;

  // Shared state across layers
  RouteInfo? selectedRoute;
  int? originIndex;
  int? destinationIndex;
  List<int> selectedSeats = [];
  bool hasSelectedDateTime = false;
  DateTime? departureTime;
  DateTime? arrivalTime;
  String? riderTimeChoice; // 'departure' or 'arrival' for riders
  bool isActionCompleted = false; // Can be either booking completed or ride posted

  void _navigateToLayer(BookingLayer layer) {
    setState(() {
      currentLayer = layer;
    });
  }

  void _goBack() {
    print('🔙 LayeredBooking: _goBack called, currentLayer: $currentLayer');
    print('🔙 LayeredBooking: Stack trace: ${StackTrace.current}');
    setState(() {
      switch (currentLayer) {
        case BookingLayer.stopsSelection:
          print('🔙 LayeredBooking: Was on stopsSelection, going to routeSelection');
          // Clear stops data
          originIndex = null;
          destinationIndex = null;
          departureTime = null;
          arrivalTime = null;
          selectedSeats = [];
          hasSelectedDateTime = false;
          currentLayer = BookingLayer.routeSelection;
          break;
        case BookingLayer.timeAndSeats:
          print('🔙 LayeredBooking: Was on timeAndSeats, going to stopsSelection');
          // Clear time and seats data
          departureTime = null;
          arrivalTime = null;
          selectedSeats = [];
          hasSelectedDateTime = false;
          currentLayer = BookingLayer.stopsSelection;
          break;
        case BookingLayer.matchingRides:
          print('🔙 LayeredBooking: Was on matchingRides, going to stopsSelection');
          // Clear time data (but keep stops)
          departureTime = null;
          arrivalTime = null;
          riderTimeChoice = null;
          hasSelectedDateTime = false;
          currentLayer = BookingLayer.stopsSelection;
          break;
        case BookingLayer.routeSelection:
          print('🔙 LayeredBooking: Already at routeSelection (first layer)');
          // Already at first layer
          break;
      }
    });
    print('🔙 LayeredBooking: After _goBack, new currentLayer: $currentLayer');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Fixed progress bar at the top
        BookingProgressBar(
          currentStep: BookingLogic.getCurrentStep(
            selectedRoute,
            originIndex,
            destinationIndex,
            hasSelectedDateTime,
            selectedSeats,
          ),
          totalSteps: 4,
        ),

        // Slim toggle button - only show after role is selected
        if (widget.tabController != null && widget.hasSelectedRole)
          Container(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSlimToggle(
                  label: l10n.driver,
                  icon: Icons.directions_car,
                  isSelected: widget.tabController!.index == 0,
                  onTap: () => widget.tabController!.animateTo(0),
                ),
                SizedBox(width: 4),
                _buildSlimToggle(
                  label: l10n.rider,
                  icon: Icons.person,
                  isSelected: widget.tabController!.index == 1,
                  onTap: () => widget.tabController!.animateTo(1),
                ),
              ],
            ),
          ),

        // Layer navigation
        Expanded(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero).animate(animation),
                child: child,
              );
            },
            child: _buildCurrentLayer(),
          ),
        ),
      ],
    );
  }

  Widget _buildSlimToggle({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFDD2C00) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey[500], size: 14),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[500],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLayer() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero).animate(animation),
          child: child,
        );
      },
      child: () {
        switch (currentLayer) {
          case BookingLayer.routeSelection:
            return RouteLayerWidget(
              key: ValueKey('route-layer'),
              userRole: widget.userRole,
              selectedRoute: selectedRoute,
              isActionCompleted: isActionCompleted,
              tabController: widget.tabController,
              hasSelectedRole: widget.hasSelectedRole,
              onRoleSelected: (role) {
                widget.onRoleSelected?.call();
              },
              onRouteSelected: (route) {
                setState(() {
                  selectedRoute = route;
                  originIndex = null;
                  destinationIndex = null;
                  hasSelectedDateTime = false;
                });
                // Only navigate if a route was selected (not deselected)
                if (route != null) {
                  // Show green selection for 250ms before navigating
                  Future.delayed(Duration(milliseconds: 250), () {
                    _navigateToLayer(BookingLayer.stopsSelection);
                  });
                }
              },
            );

          case BookingLayer.stopsSelection:
            return StopsLayerWidget(
              key: ValueKey('stops-layer'),
              userRole: widget.userRole,
              selectedRoute: selectedRoute!,
              originIndex: originIndex,
              destinationIndex: destinationIndex,
              departureTime: departureTime,
              arrivalTime: arrivalTime,
              hasSelectedDateTime: hasSelectedDateTime,
              isActionCompleted: isActionCompleted,
              onStopsAndTimeSelected: (origin, destination, departure, arrival) {
                print('🔥 LayeredBooking: onStopsAndTimeSelected called with:');
                print('   Departure: $departure');
                print('   Arrival: $arrival');
                print('🔥 Role check: widget.userRole="${widget.userRole}", comparing to "driver"');

                setState(() {
                  originIndex = origin;
                  destinationIndex = destination;
                  departureTime = departure;
                  arrivalTime = arrival;
                  hasSelectedDateTime = true;

                  // For drivers, initialize all 4 seats as available
                  if (widget.userRole.toLowerCase() == 'driver') {
                    selectedSeats = [0, 1, 2, 3];
                    print('🚗 LayeredBooking: Initialized driver seats: $selectedSeats');
                  } else {
                    print('❌ Not a driver, userRole is: ${widget.userRole}');
                  }
                });
                print(
                  '🔥 LayeredBooking: After setState, selectedSeats=$selectedSeats (length: ${selectedSeats.length}), departureTime=$departureTime, arrivalTime=$arrivalTime',
                );

                // Check user role to determine next layer
                if (widget.userRole.toLowerCase() == 'rider') {
                  // Riders see matching rides
                  _navigateToLayer(BookingLayer.matchingRides);
                } else {
                  // Drivers go to booking/seats layer
                  _navigateToLayer(BookingLayer.timeAndSeats);
                }
              },
              onOriginSelected: (origin) {
                setState(() {
                  originIndex = origin;
                  // Reset time selection when origin changes
                  hasSelectedDateTime = false;
                });
              },
              onDestinationSelected: (destination) {
                setState(() {
                  destinationIndex = destination;
                  // Reset time selection when destination changes
                  hasSelectedDateTime = false;
                });
              },
              onTimeSelected: (departure, arrival) {
                print('🕐 LayeredBooking: onTimeSelected called with:');
                print('   Departure: $departure');
                print('   Arrival: $arrival');
                setState(() {
                  departureTime = departure;
                  arrivalTime = arrival;
                  hasSelectedDateTime = true;
                });
                print('🕐 LayeredBooking: State updated, departureTime=$departureTime, arrivalTime=$arrivalTime');
              },
              onRiderTimeChoiceChanged: (choice) {
                setState(() {
                  riderTimeChoice = choice;
                });
                print('🧑 LayeredBooking: Rider time choice changed to: $choice');
              },
              onBack: _goBack,
            );

          case BookingLayer.matchingRides:
            return MatchingRidesWidget(
              key: ValueKey('matching-rides-layer'),
              selectedRoute: selectedRoute!,
              originIndex: originIndex!,
              destinationIndex: destinationIndex!,
              departureTime: departureTime!,
              arrivalTime: arrivalTime,
              riderTimeChoice: riderTimeChoice,
              onBack: _goBack,
              onBookingCompleted: widget.onBookingCompleted,
            );

          case BookingLayer.timeAndSeats:
            print('📦 LayeredBooking: Building BookingLayerWidget with:');
            print('   departureTime: $departureTime');
            print('   arrivalTime: $arrivalTime');
            print('   selectedSeats: $selectedSeats (length: ${selectedSeats.length})');
            return BookingLayerWidget(
              key: ValueKey('booking-layer'),
              userRole: widget.userRole,
              selectedRoute: selectedRoute!,
              originIndex: originIndex!,
              destinationIndex: destinationIndex!,
              selectedSeats: selectedSeats,
              hasSelectedDateTime: hasSelectedDateTime,
              departureTime: departureTime,
              arrivalTime: arrivalTime,
              isActionCompleted: isActionCompleted,
              onSeatsSelected: (seats) {
                setState(() {
                  selectedSeats = seats;
                });
              },
              onTimeSelected: (departure, arrival) {
                setState(() {
                  hasSelectedDateTime = true;
                  departureTime = departure;
                  arrivalTime = arrival;
                });
              },
              onBookingCompleted: () {
                setState(() {
                  isActionCompleted = true;
                });
                // Switch to My Bookings tab after a short delay
                Future.delayed(Duration(milliseconds: 500), () {
                  if (mounted && widget.onBookingCompleted != null) {
                    widget.onBookingCompleted!();
                  }
                });
              },
              onBack: _goBack,
            );
        }
      }(),
    );
  }
}
