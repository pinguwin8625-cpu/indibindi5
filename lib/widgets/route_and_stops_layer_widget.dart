import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../widgets/route_selection_widget.dart';
import '../widgets/stops_section_widget.dart';
import '../widgets/time_selection_widget.dart';
import '../utils/booking_logic.dart';

class RouteAndStopsLayerWidget extends StatefulWidget {
  final String userRole;
  final RouteInfo? selectedRoute;
  final int? originIndex;
  final int? destinationIndex;
  final bool hasSelectedDateTime;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final bool isBookingCompleted;
  final Function(RouteInfo route, int origin, int destination, DateTime departure, DateTime arrival) onSelectionComplete;

  const RouteAndStopsLayerWidget({
    super.key,
    required this.userRole,
    required this.selectedRoute,
    required this.originIndex,
    required this.destinationIndex,
    required this.hasSelectedDateTime,
    required this.departureTime,
    required this.arrivalTime,
    required this.isBookingCompleted,
    required this.onSelectionComplete,
  });

  @override
  State<RouteAndStopsLayerWidget> createState() => _RouteAndStopsLayerWidgetState();
}

class _RouteAndStopsLayerWidgetState extends State<RouteAndStopsLayerWidget> {
  RouteInfo? localSelectedRoute;
  int? localOriginIndex;
  int? localDestinationIndex;
  bool localHasSelectedDateTime = false;
  DateTime? localDepartureTime;
  DateTime? localArrivalTime;

  @override
  void initState() {
    super.initState();
    localSelectedRoute = widget.selectedRoute;
    localOriginIndex = widget.originIndex;
    localDestinationIndex = widget.destinationIndex;
    localHasSelectedDateTime = widget.hasSelectedDateTime;
    localDepartureTime = widget.departureTime;
    localArrivalTime = widget.arrivalTime;
  }

  @override
  Widget build(BuildContext context) {
    // Compute greyed stops
    List<int> greyedStops = BookingLogic.computeGreyedStops(
      localSelectedRoute,
      localOriginIndex,
      localDestinationIndex,
    );

    bool canProceed = localSelectedRoute != null && 
                     localOriginIndex != null && 
                     localDestinationIndex != null &&
                     localHasSelectedDateTime;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Plan Your Journey',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E2E2E),
              ),
            ),
            SizedBox(height: 16),
            
            // Description
            Text(
              'Select your route, pickup/drop-off stops, and travel times.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF2E2E2E).withOpacity(0.7),
              ),
            ),
            SizedBox(height: 32),

            // Step 1: Route Selection
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: localSelectedRoute != null ? Color(0xFF00C853) : Color(0xFF2E2E2E),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Choose Route',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Route Selection Widget
            RouteSelectionWidget(
              selectedRoute: localSelectedRoute,
              originIndex: localOriginIndex,
              destinationIndex: localDestinationIndex,
              hasSelectedDateTime: false,
              departureTime: null,
              arrivalTime: null,
              isDisabled: widget.isBookingCompleted,
              onRouteChanged: (route) {
                if (route != null && !widget.isBookingCompleted) {
                  setState(() {
                    localSelectedRoute = route;
                    localOriginIndex = null;
                    localDestinationIndex = null;
                  });
                }
              },
            ),

            SizedBox(height: 32),

            // Step 2: Stops Selection (only show if route is selected)
            if (localSelectedRoute != null) ...[
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: (localOriginIndex != null && localDestinationIndex != null) 
                          ? Color(0xFF00C853) 
                          : Color(0xFF2E2E2E),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Select Stops',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Stops Selection Widget
              StopsSectionWidget(
                selectedRoute: localSelectedRoute!,
                originIndex: localOriginIndex,
                destinationIndex: localDestinationIndex,
                greyedStops: greyedStops,
                isDisabled: widget.isBookingCompleted,
                onOriginChanged: (index) {
                  setState(() {
                    localOriginIndex = index;
                  });
                },
                onDestinationChanged: (index) {
                  setState(() {
                    localDestinationIndex = index;
                  });
                },
                onResetDateTime: () {
                  // Not needed in this layer
                },
              ),

              SizedBox(height: 32),

              // Step 3: Time Selection (only show if route and stops are selected)
              if (localSelectedRoute != null && localOriginIndex != null && localDestinationIndex != null) ...[
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: localHasSelectedDateTime 
                            ? Color(0xFF00C853) 
                            : Color(0xFF2E2E2E),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Select Times',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Time Selection Widget
                TimeSelectionWidget(
                  selectedRoute: localSelectedRoute!,
                  originIndex: localOriginIndex!,
                  destinationIndex: localDestinationIndex,
                  onDateTimeSelected: (hasSelected) {
                    setState(() {
                      localHasSelectedDateTime = hasSelected;
                    });
                  },
                  onTimesChanged: (departure, arrival) {
                    setState(() {
                      localDepartureTime = departure;
                      localArrivalTime = arrival;
                      // Don't set localHasSelectedDateTime here - only when user actually selects time
                    });
                  },
                ),

                SizedBox(height: 32),
              ],

              // Continue Button
              if (canProceed)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.isBookingCompleted ? null : () {
                      widget.onSelectionComplete(
                        localSelectedRoute!,
                        localOriginIndex!,
                        localDestinationIndex!,
                        localDepartureTime!,
                        localArrivalTime!,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2E2E2E),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Continue to Seats',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
