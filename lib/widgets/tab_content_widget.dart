import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../widgets/booking_progress_bar.dart';
import '../widgets/route_selection_widget.dart';
import '../widgets/stops_section_widget.dart';
import '../widgets/time_selection_widget.dart';
import '../widgets/seat_planning_section_widget.dart';
import '../widgets/booking_button_widget.dart';
import '../utils/booking_logic.dart';

class TabContentWidget extends StatefulWidget {
  final String userRole;

  const TabContentWidget({super.key, required this.userRole});

  @override
  State<TabContentWidget> createState() => _TabContentWidgetState();
}

class _TabContentWidgetState extends State<TabContentWidget> {
  RouteInfo? selectedRoute;
  int? originIndex;
  int? destinationIndex;
  List<int> selectedSeats = [];
  bool hasSelectedDateTime = false;
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // Compute greyed stops
    List<int> greyedStops = BookingLogic.computeGreyedStops(
      selectedRoute,
      originIndex,
      destinationIndex,
    );

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

        // Scrollable content below
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route selection dropdown
                RouteSelectionWidget(
                  selectedRoute: selectedRoute,
                  onRouteChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedRoute = value;
                        originIndex = null;
                        destinationIndex = null;
                        hasSelectedDateTime = false;
                      });
                    }
                  },
                ),

                // Show route content only when a route is selected
                if (selectedRoute != null) ...[


                  // Main content area with stops and time picker
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left side: Stop list and seat plan
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Stop list section (without title)
                              StopsSectionWidget(
                                selectedRoute: selectedRoute!,
                                originIndex: originIndex,
                                destinationIndex: destinationIndex,
                                greyedStops: greyedStops,
                                hideUnusedStops: hasSelectedDateTime,
                                onOriginChanged: (index) {
                                  setState(() {
                                    originIndex = index;
                                  });
                                },
                                onDestinationChanged: (index) {
                                  setState(() {
                                    destinationIndex = index;
                                  });
                                },
                                onResetDateTime: () {
                                  setState(() {
                                    hasSelectedDateTime = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        // Right side: date picker and seat availability info
                        if (originIndex != null)
                          Container(
                            margin: EdgeInsets.only(left: 16),
                            width: 160,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Time picker section
                                TimeSelectionWidget(
                                  selectedRoute: selectedRoute!,
                                  originIndex: originIndex!,
                                  destinationIndex: destinationIndex,
                                  onDateTimeSelected: (bool selected) {
                                    setState(() {
                                      hasSelectedDateTime = selected;
                                    });
                                    // Auto-scroll to seat layout when time selection is completed
                                    if (selected &&
                                        originIndex != null &&
                                        destinationIndex != null) {
                                      Future.delayed(
                                        Duration(milliseconds: 300),
                                        () {
                                          double scrollPosition =
                                              _calculateScrollToSeatLayout();
                                          scrollController.animateTo(
                                            scrollPosition, // Dynamic scroll position
                                            duration: Duration(
                                              milliseconds: 500,
                                            ),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Standard divider between stops/time section and seat layout


                  // Full-width seat layout section - outside the Row for proper centering
                  if (originIndex != null &&
                      destinationIndex != null &&
                      hasSelectedDateTime)
                    // Centered seat layout - full width centering
                    Container(
                      width: double.infinity,
                      child: Center(
                        child: SeatPlanningSectionWidget(
                          userRole: widget.userRole,
                          selectedSeats: selectedSeats,
                          onSeatsSelected: (seats) {
                            setState(() {
                              selectedSeats = seats;
                            });
                          },
                        ),
                      ),
                    ),
                ],

                // Spacing between seat layout and booking button
                if (destinationIndex != null && hasSelectedDateTime)
                  SizedBox(height: 0),

                // Complete Booking button - moved away from the car
                if (destinationIndex != null && hasSelectedDateTime)
                  Column(
                    children: [
                      BookingButtonWidget(
                        selectedRoute: selectedRoute,
                        originIndex: originIndex,
                        destinationIndex: destinationIndex,
                        selectedSeats: selectedSeats,
                      ),
                      SizedBox(height: 32),
                    ],
                  ),

                // Calculated spacer to ensure divider can align with progress bar
                // Only add enough space to enable the auto-scroll alignment
                (originIndex != null &&
                    destinationIndex != null &&
                    hasSelectedDateTime)
                  ? SizedBox.shrink() // No spacer when seat layout is shown
                  : Container(
                      height: 50,
                    ), // Small spacer when seat layout not shown
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Calculate dynamic scroll position to align seat layout divider with progress bar
  double _calculateScrollToSeatLayout() {
    if (selectedRoute == null) return 400.0;

    // Calculate height of content above the seat layout divider:
    // Updated measurements with consistent divider margins (16px each)
    double routeDropdownHeight = 90.0;
    double firstDividerHeight =
        32.0; // Updated: 16px top + 16px bottom (now consistent)
    double stopsTitleHeight = 50.0;
    double stopsListHeight = selectedRoute!.stops.length * 40.0;
    double timePickerHeight = 180.0;
    double secondDividerHeight = 32.0; // 16px top + 16px bottom
    double progressBarBottomPosition = 85.0; // Progress bar bottom position

    double totalContentAboveSeatDivider =
        routeDropdownHeight +
        firstDividerHeight +
        stopsTitleHeight +
        stopsListHeight +
        timePickerHeight +
        secondDividerHeight;

    // Calculate scroll position to align seat divider with progress bar bottom
    double scrollPosition =
        totalContentAboveSeatDivider - progressBarBottomPosition;

    // Fine-tuning adjustment - adjust this value for perfect alignment
    double alignmentAdjustment =
        -20.0; // Negative to scroll up more, positive to scroll down less
    scrollPosition += alignmentAdjustment;

    // Fine-tuned clamping for better alignment
    return scrollPosition.clamp(150.0, 700.0);
  }
}
