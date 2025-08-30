import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../widgets/stops_section_widget.dart';
import '../utils/booking_logic.dart';

class StopsLayerWidget extends StatefulWidget {
  final String userRole;
  final RouteInfo selectedRoute;
  final int? originIndex;
  final int? destinationIndex;
  final bool isBookingCompleted;
  final Function(int origin, int destination) onStopsSelected;
  final VoidCallback onBack;

  const StopsLayerWidget({
    super.key,
    required this.userRole,
    required this.selectedRoute,
    required this.originIndex,
    required this.destinationIndex,
    required this.isBookingCompleted,
    required this.onStopsSelected,
    required this.onBack,
  });

  @override
  State<StopsLayerWidget> createState() => _StopsLayerWidgetState();
}

class _StopsLayerWidgetState extends State<StopsLayerWidget> {
  int? localOriginIndex;
  int? localDestinationIndex;

  @override
  void initState() {
    super.initState();
    localOriginIndex = widget.originIndex;
    localDestinationIndex = widget.destinationIndex;
  }

  @override
  Widget build(BuildContext context) {
    // Compute greyed stops
    List<int> greyedStops = BookingLogic.computeGreyedStops(
      widget.selectedRoute,
      localOriginIndex,
      localDestinationIndex,
    );

    bool canProceed = localOriginIndex != null && localDestinationIndex != null;

    return Column(
      children: [
        // Header with back button
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: Icon(Icons.arrow_back, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Color(0xFF2E2E2E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Route: ${widget.selectedRoute.name}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
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
                  // Description
                  Text(
                    'Choose where you\'ll get on and off the bus.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Stops Selection
                  StopsSectionWidget(
                    selectedRoute: widget.selectedRoute,
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

                  // Instructions
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF2E2E2E).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFF2E2E2E), width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.white70,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pick both your pickup and drop-off stops to continue.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
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
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.isBookingCompleted ? null : () {
                  if (localOriginIndex != null && localDestinationIndex != null) {
                    widget.onStopsSelected(localOriginIndex!, localDestinationIndex!);
                  }
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
                  'Continue to Booking',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
