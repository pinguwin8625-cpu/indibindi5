import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../widgets/stops_section_widget.dart';
import '../widgets/time_selection_widget.dart';
import '../widgets/scroll_indicator.dart';
import '../widgets/ride_info_card.dart';
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

class _StopsLayerWidgetState extends State<StopsLayerWidget> with SingleTickerProviderStateMixin {
  int? localOriginIndex;
  int? localDestinationIndex;
  DateTime? localDepartureTime;
  DateTime? localArrivalTime;
  bool localHasSelectedDateTime = false;
  String? riderTimeChoice; // 'departure' or 'arrival' for riders
  int visibleIntermediateCount = 0; // Track visible intermediate stops
  int hiddenIntermediateCount = 0; // Track hidden intermediate stops
  final ScrollController _scrollController = ScrollController();
  late AnimationController _borderAnimationController;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    localOriginIndex = widget.originIndex;
    localDestinationIndex = widget.destinationIndex;
    localDepartureTime = widget.departureTime;
    localArrivalTime = widget.arrivalTime;
    localHasSelectedDateTime = widget.hasSelectedDateTime;

    // Setup blinking border animation
    _borderAnimationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _borderAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _borderAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _borderAnimationController.dispose();
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
        RideInfoCard(
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
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              color: Color(0xFF4CAF50),
                                              size: 28,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              l10n.pickUpAndDropOff,
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF4CAF50), // Green for from
                                                letterSpacing: 0.5,
                                              ),
                                              maxLines: 1,
                                            ),
                                          ],
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
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.flag,
                                              color: Color(0xFFDD2C00),
                                              size: 28,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              l10n.chooseDropOffPoint,
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFDD2C00), // Red for to
                                                letterSpacing: 0.5,
                                              ),
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 24),
                      // Right column - "when?" (flex: 2 to match time picker column)
                      Expanded(
                        flex: 2,
                        child: (localOriginIndex != null && localDestinationIndex != null)
                            ? Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: Color(0xFFFF6D00),
                                        size: 28,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        l10n.setYourTime,
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFFF6D00),
                                          letterSpacing: 0.5,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ),
                    ],
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
                                onIntermediateVisibilityChanged: (visible, hidden) {
                                  setState(() {
                                    visibleIntermediateCount = visible;
                                    hiddenIntermediateCount = hidden;
                                  });
                                },
                              ),
                            ),

                        SizedBox(width: 24),

                        // Time Selection (Right Side) - only show if both stops are selected
                        Expanded(
                          flex: 2,
                          child: localOriginIndex != null && localDestinationIndex != null
                              ? AnimatedBuilder(
                                  animation: _borderAnimation,
                                  builder: (context, child) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFF6D00).withValues(alpha: 0.05),
                                        border: Border.all(
                                          color: Color(0xFFFF6D00).withValues(alpha: _borderAnimation.value),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: child,
                                    );
                                  },
                                  child: TimeSelectionWidget(
                                    userRole: widget.userRole,
                                    selectedRoute: widget.selectedRoute,
                                    originIndex: localOriginIndex!,
                                    destinationIndex: localDestinationIndex,
                                    hideUnusedStops: localOriginIndex != null && localDestinationIndex != null,
                                    visibleIntermediateCount: visibleIntermediateCount,
                                    hiddenIntermediateCount: hiddenIntermediateCount,
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
                                  ),
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
