import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/routes.dart';
import '../widgets/time_selection_widget.dart';
import '../widgets/seat_planning_section_widget.dart';
import '../widgets/booking_button_widget.dart';
import '../widgets/scroll_indicator.dart';
import '../widgets/ride_details_bar.dart';
import '../l10n/app_localizations.dart';

class BookingLayerWidget extends StatefulWidget {
  final String userRole;
  final RouteInfo selectedRoute;
  final int originIndex;
  final int destinationIndex;
  final List<int> selectedSeats;
  final bool hasSelectedDateTime;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final bool
  isActionCompleted; // Can be either booking completed or ride posted
  final Function(List<int>) onSeatsSelected;
  final Function(DateTime departure, DateTime arrival) onTimeSelected;
  final VoidCallback onBookingCompleted;
  final VoidCallback onBack;

  const BookingLayerWidget({
    super.key,
    required this.userRole,
    required this.selectedRoute,
    required this.originIndex,
    required this.destinationIndex,
    required this.selectedSeats,
    required this.hasSelectedDateTime,
    required this.departureTime,
    required this.arrivalTime,
    required this.isActionCompleted,
    required this.onSeatsSelected,
    required this.onTimeSelected,
    required this.onBookingCompleted,
    required this.onBack,
  });

  @override
  State<BookingLayerWidget> createState() => _BookingLayerWidgetState();
}

class _BookingLayerWidgetState extends State<BookingLayerWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Summary bar showing route, stops, and time with back button
        RideDetailsBar(
          selectedRoute: widget.selectedRoute,
          originIndex: widget.originIndex,
          destinationIndex: widget.destinationIndex,
          departureTime: widget.departureTime,
          arrivalTime: widget.arrivalTime,
          userRole: widget.userRole,
          riderTimeChoice: null, // Drivers always show both times
          onBack: widget.isActionCompleted ? null : widget.onBack,
        ),

        // Content area between ride details bar and button
        Expanded(
          child: widget.hasSelectedDateTime && widget.userRole.toLowerCase() == 'driver'
              // Driver seat selection - scrollable on web, centered on mobile
              ? kIsWeb
                  // Web: scrollable content with button inside and scroll indicator
                  ? ScrollIndicator(
                      scrollController: _scrollController,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            // Available seats count badge (swapped from SeatPlanningSectionWidget)
                            if (widget.userRole.toLowerCase() == 'driver')
                              Container(
                                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF00C853).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Color(0xFF00C853).withValues(alpha: 0.3), width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.event_seat, color: Color(0xFF00C853), size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        '${l10n.available}: ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF00C853),
                                        ),
                                      ),
                                      TweenAnimationBuilder<double>(
                                        key: ValueKey('available-${widget.selectedSeats.length}'),
                                        tween: Tween<double>(begin: 2.0, end: 1.0),
                                        duration: Duration(milliseconds: 600),
                                        curve: Curves.elasticOut,
                                        builder: (context, scale, child) {
                                          return Transform.scale(
                                            scale: scale,
                                            child: Text(
                                              '${widget.selectedSeats.length}',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF00C853),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                                child: Text(
                                  l10n.matchingRides,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF5D4037),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            SizedBox(height: 16),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: SeatPlanningSectionWidget(
                                userRole: widget.userRole,
                                selectedSeats: widget.selectedSeats,
                                isDisabled: widget.isActionCompleted,
                                onSeatsSelected: widget.onSeatsSelected,
                              ),
                            ),
                            SizedBox(height: 24),
                            // Inline button for web
                            BookingButtonWidget(
                              selectedRoute: widget.selectedRoute,
                              originIndex: widget.originIndex,
                              destinationIndex: widget.destinationIndex,
                              selectedSeats: widget.selectedSeats,
                              departureTime: widget.departureTime,
                              arrivalTime: widget.arrivalTime,
                              userRole: widget.userRole,
                              onBookingCompleted: widget.onBookingCompleted,
                              isInline: true,
                            ),
                          ],
                        ),
                      ),
                    )
                  // Mobile apps: centered layout with fixed button at bottom
                  : Column(
                      children: [
                        // Available seats count badge (swapped from SeatPlanningSectionWidget)
                        if (widget.userRole.toLowerCase() == 'driver')
                          Container(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Color(0xFF00C853).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Color(0xFF00C853).withValues(alpha: 0.3), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.event_seat, color: Color(0xFF00C853), size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    '${l10n.available}: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF00C853),
                                    ),
                                  ),
                                  TweenAnimationBuilder<double>(
                                    key: ValueKey('available-${widget.selectedSeats.length}'),
                                    tween: Tween<double>(begin: 2.0, end: 1.0),
                                    duration: Duration(milliseconds: 600),
                                    curve: Curves.elasticOut,
                                    builder: (context, scale, child) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: Text(
                                          '${widget.selectedSeats.length}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF00C853),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Text(
                              l10n.matchingRides,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5D4037),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: SeatPlanningSectionWidget(
                                userRole: widget.userRole,
                                selectedSeats: widget.selectedSeats,
                                isDisabled: widget.isActionCompleted,
                                onSeatsSelected: widget.onSeatsSelected,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
              // Other cases (rider or time not selected)
              : widget.hasSelectedDateTime && kIsWeb
                  // Web rider: scrollable content with inline button and scroll indicator
                  ? ScrollIndicator(
                      scrollController: _scrollController,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            // Title for rider (same style as driver)
                            Container(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                              child: Text(
                                widget.selectedSeats.isEmpty
                                    ? l10n.selectYourSeat
                                    : l10n.seatsSelected(widget.selectedSeats.length),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF5D4037), // Same brown as driver
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: SeatPlanningSectionWidget(
                                userRole: widget.userRole,
                                selectedSeats: widget.selectedSeats,
                                isDisabled: widget.isActionCompleted,
                                onSeatsSelected: widget.onSeatsSelected,
                              ),
                            ),
                            SizedBox(height: 24),
                            // Inline button for web rider
                            BookingButtonWidget(
                              selectedRoute: widget.selectedRoute,
                              originIndex: widget.originIndex,
                              destinationIndex: widget.destinationIndex,
                              selectedSeats: widget.selectedSeats,
                              departureTime: widget.departureTime,
                              arrivalTime: widget.arrivalTime,
                              userRole: widget.userRole,
                              onBookingCompleted: widget.onBookingCompleted,
                              isInline: true,
                            ),
                          ],
                        ),
                      ),
                    )
                  // Mobile rider or time not selected - scrollable content with fixed button
                  : Column(
                      children: [
                        // Header with title (for rider)
                        if (widget.hasSelectedDateTime)
                          Container(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Text(
                              widget.selectedSeats.isEmpty
                                  ? l10n.selectYourSeat
                                  : l10n.seatsSelected(widget.selectedSeats.length),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E2E2E),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        Expanded(
                          child: ScrollIndicator(
                            scrollController: _scrollController,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Show time picker if time not selected
                                    if (!widget.hasSelectedDateTime) ...[
                                      Text(
                                        l10n.whenDoYouWantToTravel,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          height: 1.3,
                                        ),
                                      ),
                                      SizedBox(height: 16),

                                      TimeSelectionWidget(
                                        userRole: widget.userRole,
                                        selectedRoute: widget.selectedRoute,
                                        originIndex: widget.originIndex,
                                        destinationIndex: widget.destinationIndex,
                                        onDateTimeSelected: (hasSelected) {
                                          // This will be handled by onTimesChanged
                                        },
                                        onTimesChanged: (departure, arrival) {
                                          widget.onTimeSelected(departure, arrival);
                                        },
                                      ),
                                    ],

                                    // Show seat selection for rider
                                    if (widget.hasSelectedDateTime) ...[
                                      SeatPlanningSectionWidget(
                                        userRole: widget.userRole,
                                        selectedSeats: widget.selectedSeats,
                                        isDisabled: widget.isActionCompleted,
                                        onSeatsSelected: widget.onSeatsSelected,
                                      ),
                                      SizedBox(height: 24),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
        ),

        // Fixed booking button at bottom (not for web - already inline for both driver and rider)
        if (widget.hasSelectedDateTime && !kIsWeb)
          BookingButtonWidget(
            selectedRoute: widget.selectedRoute,
            originIndex: widget.originIndex,
            destinationIndex: widget.destinationIndex,
            selectedSeats: widget.selectedSeats,
            departureTime: widget.departureTime,
            arrivalTime: widget.arrivalTime,
            userRole: widget.userRole,
            onBookingCompleted: widget.onBookingCompleted,
          ),
      ],
    );
  }
}
