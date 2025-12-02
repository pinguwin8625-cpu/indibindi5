import 'package:flutter/material.dart';
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
  final bool isActionCompleted; // Can be either booking completed or ride posted
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

        // Header with title and seat count
        Container(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.userRole.toLowerCase() == 'driver'
                        ? Row(
                            children: [
                              Text(
                                l10n.availableSeats,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E2E2E),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '[${widget.selectedSeats.length} ${l10n.available}]',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFDD2C00),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            l10n.chooseYourSeat,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E2E2E),
                              letterSpacing: 0.5,
                            ),
                          ),
                    if (widget.hasSelectedDateTime && widget.userRole.toLowerCase() != 'driver') SizedBox(height: 4),
                    if (widget.hasSelectedDateTime && widget.userRole.toLowerCase() != 'driver')
                      Text(
                        widget.selectedSeats.isEmpty
                            ? l10n.selectYourSeat
                            : l10n.seatsSelected(widget.selectedSeats.length),
                        style: TextStyle(fontSize: 16, color: Color(0xFF8E8E8E), fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: Column(
            children: [
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

                          // Show seat selection if time is selected
                          if (widget.hasSelectedDateTime) ...[
                            // Seat layout
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

              // Fixed booking button at bottom - same as rider's
              if (widget.hasSelectedDateTime)
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
        ),
      ],
    );
  }
}
