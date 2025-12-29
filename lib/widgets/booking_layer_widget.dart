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
                  // Web: scrollable content with button inside
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          // Title for driver
                          Container(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Text(
                              l10n.chooseYourSeats,
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
                          ),
                        ],
                      ),
                    )
                  // Mobile apps: centered layout with fixed button at bottom
                  : Column(
                      children: [
                        // Title for driver
                        Container(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Text(
                            l10n.chooseYourSeats,
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
              // Other cases (rider or time not selected) - scrollable content
              : Column(
                  children: [
                    // Header with title (for rider)
                    if (widget.hasSelectedDateTime)
                      Container(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
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
                            SizedBox(height: 4),
                            Text(
                              l10n.chooseYourSeat,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF8E8E8E),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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

        // Fixed booking button at bottom (not for web driver - already inline)
        if (widget.hasSelectedDateTime && !(kIsWeb && widget.userRole.toLowerCase() == 'driver'))
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
