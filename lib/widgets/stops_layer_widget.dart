import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../widgets/stops_section_widget.dart';
import '../widgets/time_selection_widget.dart';
import '../utils/booking_logic.dart';

class StopsLayerWidget extends StatefulWidget {
  final String userRole;
  final RouteInfo selectedRoute;
  final int? originIndex;
  final int? destinationIndex;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final bool hasSelectedDateTime;
  final bool isBookingCompleted;
  final Function(int origin, int destination, DateTime? departure, DateTime? arrival) onStopsAndTimeSelected;
  final Function(int?)? onOriginSelected;
  final Function(int?)? onDestinationSelected;
  final Function(DateTime departure, DateTime arrival)? onTimeSelected;
  final VoidCallback onBack;

  const StopsLayerWidget({
    super.key,
    required this.userRole,
    required this.selectedRoute,
    required this.originIndex,
    required this.destinationIndex,
    this.departureTime,
    this.arrivalTime,
    this.hasSelectedDateTime = false,
    required this.isBookingCompleted,
    required this.onStopsAndTimeSelected,
    this.onOriginSelected,
    this.onDestinationSelected,
    this.onTimeSelected,
    required this.onBack,
  });

  @override
  State<StopsLayerWidget> createState() => _StopsLayerWidgetState();
}

class _StopsLayerWidgetState extends State<StopsLayerWidget> {
  int? localOriginIndex;
  int? localDestinationIndex;
  DateTime? localDepartureTime;
  DateTime? localArrivalTime;
  bool localHasSelectedDateTime = false;

  @override
  void initState() {
    super.initState();
    localOriginIndex = widget.originIndex;
    localDestinationIndex = widget.destinationIndex;
    localDepartureTime = widget.departureTime;
    localArrivalTime = widget.arrivalTime;
    localHasSelectedDateTime = widget.hasSelectedDateTime;
  }

  void _checkAndNavigate() {
    // Auto-navigate when both stops and time are selected
    // Only navigate if user has actually interacted with time selection
    if (localOriginIndex != null &&
        localDestinationIndex != null &&
        localHasSelectedDateTime &&
        localDepartureTime != null &&
        localArrivalTime != null &&
        !widget.isBookingCompleted) {
      // Trigger individual callbacks to ensure progress bar sync
      widget.onOriginSelected?.call(localOriginIndex);
      widget.onDestinationSelected?.call(localDestinationIndex);
      widget.onTimeSelected?.call(localDepartureTime!, localArrivalTime!);

      // Then trigger the combined callback for navigation
      widget.onStopsAndTimeSelected(localOriginIndex!, localDestinationIndex!, localDepartureTime, localArrivalTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Compute greyed stops
    List<int> greyedStops = BookingLogic.computeGreyedStops(
      widget.selectedRoute,
      localOriginIndex,
      localDestinationIndex,
    );

    bool canProceed = localOriginIndex != null && localDestinationIndex != null && localHasSelectedDateTime;

    return Column(
      children: [
        // Header with back button
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: Icon(Icons.arrow_back_ios, color: Color(0xFF8E8E8E), size: 20),
                style: IconButton.styleFrom(backgroundColor: Colors.transparent, padding: EdgeInsets.all(8)),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pick Your Stops',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24),

                  // Side-by-side layout for stops and time selection
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stops Selection (Left Side)
                      Expanded(
                        flex: 3,
                        child: StopsSectionWidget(
                          selectedRoute: widget.selectedRoute,
                          originIndex: localOriginIndex,
                          destinationIndex: localDestinationIndex,
                          greyedStops: greyedStops,
                          isDisabled: widget.isBookingCompleted,
                          onOriginChanged: (index) {
                            print('🔥 StopsLayer: onOriginChanged called with $index');
                            setState(() {
                              localOriginIndex = index;
                            });
                            // Always call the callback to update parent state
                            widget.onOriginSelected?.call(index);
                            _checkAndNavigate();
                          },
                          onDestinationChanged: (index) {
                            print('🔥 StopsLayer: onDestinationChanged called with $index');
                            setState(() {
                              localDestinationIndex = index;
                            });
                            // Always call the callback to update parent state
                            widget.onDestinationSelected?.call(index);
                            _checkAndNavigate();
                          },
                          onResetDateTime: () {
                            setState(() {
                              localHasSelectedDateTime = false;
                              localDepartureTime = null;
                              localArrivalTime = null;
                            });
                          },
                        ),
                      ),

                      SizedBox(width: 24),

                      // Time Selection (Right Side) - only show if origin is selected
                      Expanded(
                        flex: 2,
                        child: localOriginIndex != null
                            ? TimeSelectionWidget(
                                selectedRoute: widget.selectedRoute,
                                originIndex: localOriginIndex!,
                                destinationIndex: localDestinationIndex,
                                onDateTimeSelected: (hasSelected) {
                                  // Only set localHasSelectedDateTime if user actually picked time
                                  // Don't set it on automatic time calculations
                                  if (hasSelected) {
                                    setState(() {
                                      localHasSelectedDateTime = hasSelected;
                                    });
                                    // Also notify parent when user actually selects time
                                    widget.onTimeSelected?.call(
                                      localDepartureTime ?? DateTime.now(),
                                      localArrivalTime ?? DateTime.now(),
                                    );
                                    print('🕐 StopsLayer: User selected time, calling onTimeSelected');
                                    _checkAndNavigate();
                                  }
                                },
                                onTimesChanged: (departure, arrival) {
                                  setState(() {
                                    localDepartureTime = departure;
                                    localArrivalTime = arrival;
                                    // Don't set localHasSelectedDateTime here
                                    // Only set it when user actually interacts
                                  });

                                  // Don't call onTimeSelected for automatic time calculations
                                  // This callback should only be triggered by actual user time selection
                                  print(
                                    '🕐 StopsLayer: Time updated but not calling onTimeSelected (automatic calculation)',
                                  );
                                  // Don't auto-navigate on initial time setup
                                },
                              )
                            : Container(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'Select origin stop first',
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Continue Button
        if (canProceed)
          Container(
            padding: EdgeInsets.all(16),
            // Auto-navigation happens via _checkAndNavigate
            // No continue button needed
          ),
      ],
    );
  }
}
