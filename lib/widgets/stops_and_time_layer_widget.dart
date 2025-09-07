import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../widgets/stops_section_widget.dart';
import '../widgets/time_selection_widget.dart';

class StopsAndTimeLayerWidget extends StatefulWidget {
  final String userRole;
  final RouteInfo selectedRoute;
  final int? originIndex;
  final int? destinationIndex;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final bool hasSelectedDateTime;
  final bool isBookingCompleted;
  final Function() onBack;
  final Function(int, int, DateTime?, DateTime?) onSelectionComplete;

  const StopsAndTimeLayerWidget({
    super.key,
    required this.userRole,
    required this.selectedRoute,
    required this.originIndex,
    required this.destinationIndex,
    required this.departureTime,
    required this.arrivalTime,
    required this.hasSelectedDateTime,
    required this.isBookingCompleted,
    required this.onBack,
    required this.onSelectionComplete,
  });

  @override
  State<StopsAndTimeLayerWidget> createState() => _StopsAndTimeLayerWidgetState();
}

class _StopsAndTimeLayerWidgetState extends State<StopsAndTimeLayerWidget> {
  int? _currentOriginIndex;
  int? _currentDestinationIndex;
  DateTime? _currentDepartureTime;
  DateTime? _currentArrivalTime;
  bool _currentHasSelectedDateTime = false;

  @override
  void initState() {
    super.initState();
    _currentOriginIndex = widget.originIndex;
    _currentDestinationIndex = widget.destinationIndex;
    _currentDepartureTime = widget.departureTime;
    _currentArrivalTime = widget.arrivalTime;
    _currentHasSelectedDateTime = widget.hasSelectedDateTime;
  }

  bool get _canContinue {
    return _currentOriginIndex != null && 
           _currentDestinationIndex != null && 
           _currentHasSelectedDateTime;
  }

  @override
  Widget build(BuildContext context) {
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
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.all(8),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Stops & Time',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E2E2E),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      widget.selectedRoute.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2E2E2E).withOpacity(0.7),
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
                  // Step indicator
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        // Step 1: Route (completed)
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        // Step 2: Stops & Time (current)
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Color(0xFF2E2E2E),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '2',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Stops & Time',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E2E2E),
                          ),
                        ),
                        Spacer(),
                        // Step 3: Seats (future)
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '3',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Stops selection
                  Text(
                    'Select Your Stops',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E2E2E),
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 16),

                  StopsSectionWidget(
                    selectedRoute: widget.selectedRoute,
                    originIndex: _currentOriginIndex,
                    destinationIndex: _currentDestinationIndex,
                    greyedStops: [],
                    isDisabled: widget.isBookingCompleted,
                    onOriginChanged: (origin) {
                      setState(() {
                        _currentOriginIndex = origin;
                      });
                    },
                    onDestinationChanged: (destination) {
                      setState(() {
                        _currentDestinationIndex = destination;
                      });
                    },
                    onResetDateTime: () {
                      setState(() {
                        _currentHasSelectedDateTime = false;
                        _currentDepartureTime = null;
                        _currentArrivalTime = null;
                      });
                    },
                  ),

                  SizedBox(height: 32),

                  // Time selection
                  Text(
                    'Select Travel Time',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E2E2E),
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 16),

                  TimeSelectionWidget(
                    selectedRoute: widget.selectedRoute,
                    originIndex: _currentOriginIndex ?? 0,
                    destinationIndex: _currentDestinationIndex ?? 0,
                    onDateTimeSelected: (hasSelected) {
                      setState(() {
                        _currentHasSelectedDateTime = hasSelected;
                      });
                    },
                    onTimesChanged: (departure, arrival) {
                      setState(() {
                        _currentDepartureTime = departure;
                        _currentArrivalTime = arrival;
                        // Don't set _currentHasSelectedDateTime here - only when user actually selects time
                      });
                    },
                  ),

                  SizedBox(height: 32),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _canContinue ? () {
                        widget.onSelectionComplete(
                          _currentOriginIndex!,
                          _currentDestinationIndex!,
                          _currentDepartureTime,
                          _currentArrivalTime,
                        );
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canContinue ? Color(0xFF2E2E2E) : Colors.grey,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Continue to Seat Selection',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
