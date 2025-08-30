import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../widgets/booking_progress_bar.dart';
import '../widgets/route_layer_widget.dart';
import '../widgets/stops_layer_widget.dart';
import '../widgets/booking_layer_widget.dart';
import '../utils/booking_logic.dart';

enum BookingLayer {
  routeSelection,
  stopsSelection,
  timeAndSeats,
}

class LayeredBookingWidget extends StatefulWidget {
  final String userRole;

  const LayeredBookingWidget({super.key, required this.userRole});

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
            _navigateToLayer(BookingLayer.stopsSelection);
          },
        );

      case BookingLayer.stopsSelection:
        return StopsLayerWidget(
          key: ValueKey('stops-layer'),
          userRole: widget.userRole,
          selectedRoute: selectedRoute!,
          originIndex: originIndex,
          destinationIndex: destinationIndex,
          isBookingCompleted: isBookingCompleted,
          onStopsSelected: (origin, destination) {
            setState(() {
              originIndex = origin;
              destinationIndex = destination;
            });
            _navigateToLayer(BookingLayer.timeAndSeats);
          },
          onBack: _goBack,
        );

      case BookingLayer.timeAndSeats:
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
          },
          onBack: _goBack,
        );
    }
  }
}
