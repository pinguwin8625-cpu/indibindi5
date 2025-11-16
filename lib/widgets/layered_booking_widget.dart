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

  const LayeredBookingWidget({
    super.key,
    required this.userRole,
    this.onBookingCompleted,
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
  bool isBookingCompleted = false;

  void _navigateToLayer(BookingLayer layer) {
    setState(() {
      currentLayer = layer;
    });
  }

  void _goBack() {
    setState(() {
      switch (currentLayer) {
        case BookingLayer.stopsSelection:
          currentLayer = BookingLayer.routeSelection;
          break;
        case BookingLayer.timeAndSeats:
          currentLayer = BookingLayer.stopsSelection;
          break;
        case BookingLayer.matchingRides:
          currentLayer = BookingLayer.stopsSelection;
          break;
        case BookingLayer.routeSelection:
          // Already at first layer
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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

        // Layer navigation
        Expanded(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            child: _buildCurrentLayer(),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentLayer() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
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
          isBookingCompleted: isBookingCompleted,
          onRouteSelected: (route) {
            setState(() {
              selectedRoute = route;
              originIndex = null;
              destinationIndex = null;
              hasSelectedDateTime = false;
            });
            // Show green selection for 250ms before navigating
            Future.delayed(Duration(milliseconds: 250), () {
              _navigateToLayer(BookingLayer.stopsSelection);
            });
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
          isBookingCompleted: isBookingCompleted,
          onStopsAndTimeSelected: (origin, destination, departure, arrival) {
            print('🔥 LayeredBooking: onStopsAndTimeSelected called with:');
            print('   Departure: $departure');
            print('   Arrival: $arrival');
            setState(() {
              originIndex = origin;
              destinationIndex = destination;
              departureTime = departure;
              arrivalTime = arrival;
              hasSelectedDateTime = true;
              
              // For drivers, initialize all 4 seats as available
              final l10n = AppLocalizations.of(context)!;
              if (widget.userRole == l10n.driver) {
                selectedSeats = [0, 1, 2, 3];
              }
            });
            print('🔥 LayeredBooking: After setState, departureTime=$departureTime, arrivalTime=$arrivalTime');
            
            // Check user role to determine next layer
            final l10n = AppLocalizations.of(context)!;
            if (widget.userRole == l10n.rider) {
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
          onBack: _goBack,
        );
        
          case BookingLayer.matchingRides:
            return MatchingRidesWidget(
              key: ValueKey('matching-rides-layer'),
              selectedRoute: selectedRoute!,
              originIndex: originIndex!,
              destinationIndex: destinationIndex!,
              departureTime: departureTime!,
              onBack: _goBack,
            );

          case BookingLayer.timeAndSeats:
            print('📦 LayeredBooking: Building BookingLayerWidget with:');
            print('   departureTime: $departureTime');
            print('   arrivalTime: $arrivalTime');
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
          isBookingCompleted: isBookingCompleted,
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
              isBookingCompleted = true;
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
