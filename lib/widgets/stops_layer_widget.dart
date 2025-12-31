import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../widgets/stops_section_widget.dart';
import '../widgets/time_selection_widget.dart';
import '../widgets/scroll_indicator.dart';
import '../widgets/ride_details_bar.dart';
import '../utils/booking_logic.dart';
import '../l10n/app_localizations.dart';

class StopsLayerWidget extends StatefulWidget {
  final String userRole;
  final RouteInfo selectedRoute;
  final int? originIndex;
  final int? destinationIndex;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final bool hasSelectedDateTime;
  final bool
  isActionCompleted; // Can be either booking completed or ride posted
  final Function(
    int origin,
    int destination,
    DateTime? departure,
    DateTime? arrival,
  )
  onStopsAndTimeSelected;
  final Function(int?)? onOriginSelected;
  final Function(int?)? onDestinationSelected;
  final Function(DateTime departure, DateTime arrival)? onTimeSelected;
  final Function(String?)? onRiderTimeChoiceChanged;
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
    required this.isActionCompleted,
    required this.onStopsAndTimeSelected,
    this.onOriginSelected,
    this.onDestinationSelected,
    this.onTimeSelected,
    this.onRiderTimeChoiceChanged,
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
  String? riderTimeChoice; // 'departure' or 'arrival' for riders
  bool isIntermediateExpanded = false; // Track if intermediate stops are expanded
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    localOriginIndex = widget.originIndex;
    localDestinationIndex = widget.destinationIndex;
    localDepartureTime = widget.departureTime;
    localArrivalTime = widget.arrivalTime;
    localHasSelectedDateTime = widget.hasSelectedDateTime;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _checkAndNavigate() {
    // Auto-navigate when both stops and time are selected
    // Only navigate if user has actually interacted with time selection
    if (localOriginIndex != null &&
        localDestinationIndex != null &&
        localHasSelectedDateTime &&
        localDepartureTime != null &&
        localArrivalTime != null &&
        !widget.isActionCompleted) {
      print('✅ StopsLayer: _checkAndNavigate - calling callbacks with:');
      print('   localDepartureTime: $localDepartureTime');
      print('   localArrivalTime: $localArrivalTime');

      // Trigger individual callbacks to ensure progress bar sync
      widget.onOriginSelected?.call(localOriginIndex);
      widget.onDestinationSelected?.call(localDestinationIndex);
      widget.onTimeSelected?.call(localDepartureTime!, localArrivalTime!);

      // Then trigger the combined callback for navigation
      widget.onStopsAndTimeSelected(
        localOriginIndex!,
        localDestinationIndex!,
        localDepartureTime,
        localArrivalTime,
      );
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

    bool canProceed =
        localOriginIndex != null &&
        localDestinationIndex != null &&
        localHasSelectedDateTime;

    return Column(
      children: [
        // Summary bar showing selected route with back button
        RideDetailsBar(
          selectedRoute: widget.selectedRoute,
          userRole: widget.userRole,
          originIndex: localOriginIndex,
          destinationIndex: localDestinationIndex,
          onBack: widget.isActionCompleted ? null : widget.onBack,
        ),

        // Header with title(s)
        Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;

            // Determine which hint to show based on current state
            String? hintText;
            Color? hintColor;
            if (localOriginIndex == null) {
              hintText = l10n.hintOriginSelection;
              hintColor = Color(0xFF4CAF50).withOpacity(0.6);
            } else if (localDestinationIndex == null) {
              hintText = l10n.hintDestinationSelection;
              hintColor = Color(0xFFDD2C00).withOpacity(0.5);
            } else {
              hintText = l10n.hintTimeSelection;
              hintColor = Color(0xFFFF6D00).withOpacity(0.6);
            }

            return Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                children: [
                  // Titles row
                  Row(
                    children: [
                      // Left column - "from?" (flex: 3 to match stops column)
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            // "from?" on the left side
                            Expanded(
                              child: localOriginIndex == null
                                  ? Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          l10n.pickUpAndDropOff,
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF4CAF50), // Green for from
                                            letterSpacing: 0.5,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ),
                            // "to?" in the middle
                            Expanded(
                              child: (localOriginIndex != null && localDestinationIndex == null)
                                  ? Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          l10n.chooseDropOffPoint,
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFDD2C00), // Red for to
                                            letterSpacing: 0.5,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 24),
                      // Right column - "time?" (flex: 2 to match time picker column)
                      Expanded(
                        flex: 2,
                        child: (localOriginIndex != null && localDestinationIndex != null)
                            ? Center(
                                child: Text(
                                  l10n.setYourTime,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFF6D00), // Orange for time
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ),
                    ],
                  ),
                  // Hint row - full width
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      hintText,
                      style: TextStyle(
                        fontSize: 14,
                        color: hintColor,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Content
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Available height for the content area
              final availableHeight = constraints.maxHeight;

              return ScrollIndicator(
                scrollController: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                hideUnusedStops: localOriginIndex != null && localDestinationIndex != null,
                                isDisabled: widget.isActionCompleted,
                                availableHeight: availableHeight,
                                onOriginChanged: (index) {
                                  print(
                                    '🔥 StopsLayer: onOriginChanged called with $index',
                                  );
                                  setState(() {
                                    localOriginIndex = index;
                                  });
                                  // Always call the callback to update parent state
                                  widget.onOriginSelected?.call(index);
                                  _checkAndNavigate();
                                },
                                onDestinationChanged: (index) {
                                  print(
                                    '🔥 StopsLayer: onDestinationChanged called with $index',
                                  );
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
                                onIntermediateExpandedChanged: (expanded) {
                                  setState(() {
                                    isIntermediateExpanded = expanded;
                                  });
                                },
                              ),
                            ),

                        SizedBox(width: 24),

                        // Time Selection (Right Side) - only show if both stops are selected
                        Expanded(
                          flex: 2,
                          child: localOriginIndex != null && localDestinationIndex != null
                              ? TimeSelectionWidget(
                                      userRole: widget.userRole,
                                      selectedRoute: widget.selectedRoute,
                                      originIndex: localOriginIndex!,
                                      destinationIndex: localDestinationIndex,
                                      hideUnusedStops: localOriginIndex != null && localDestinationIndex != null,
                                      isIntermediateExpanded: isIntermediateExpanded,
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
                                      print(
                                        '🕐 StopsLayer: User selected time, calling onTimeSelected',
                                      );
                                      _checkAndNavigate();
                                    }
                                  },
                                  onRiderTimeChoiceChanged: (choice) {
                                    setState(() {
                                      riderTimeChoice = choice;
                                    });
                                    print(
                                      '🧑 StopsLayer: Rider time choice changed to: $choice',
                                    );
                                    // Notify parent
                                    widget.onRiderTimeChoiceChanged?.call(
                                      choice,
                                    );
                                  },
                                  onTimesChanged: (departure, arrival) {
                                    print(
                                      '🕐 StopsLayer: onTimesChanged called with:',
                                    );
                                    print('   departure: $departure');
                                    print('   arrival: $arrival');
                                    setState(() {
                                      localDepartureTime = departure;
                                      localArrivalTime = arrival;
                                      // Don't set localHasSelectedDateTime here
                                      // Only set it when user actually interacts
                                    });
                                    print(
                                      '🕐 StopsLayer: After setState, localDepartureTime=$localDepartureTime, localArrivalTime=$localArrivalTime',
                                    );

                                    // Don't call onTimeSelected for automatic time calculations
                                    // This callback should only be triggered by actual user time selection
                                    print(
                                      '🕐 StopsLayer: Time updated but not calling onTimeSelected (automatic calculation)',
                                    );
                                    // Don't auto-navigate on initial time setup
                                  },
                                )
                              : Container(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
            },
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
