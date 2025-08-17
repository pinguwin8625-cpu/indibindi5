import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/routes.dart';
import 'route_line_with_stops.dart';
import 'dart:math' show max, min;
import '../utils/date_time_helpers.dart';
import '../utils/constants.dart';
import '../widgets/car_seat_layout.dart';
import '../widgets/booking_progress_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'indibindi',
            style: TextStyle(
              letterSpacing: 1, 
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red,
          iconTheme: IconThemeData(color: Colors.white),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Stack(
                  children: [
                    Icon(Icons.directions_car),
                    Positioned(
                      top: 7,
                      right: 8,
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                text: "Driver",
              ),
              Tab(icon: Icon(Icons.person), text: 'Rider'),
            ],
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: [_buildTabContent('Driver'), _buildTabContent('Rider')],
        ),
      ),
    );
  }

  Widget _buildTabContent(String role) {
    RouteInfo? selectedRoute;
    int? originIndex;
    int? destinationIndex;
    List<int> selectedSeats = [];
    bool hasSelectedDateTime = false;

    return StatefulBuilder(
      builder: (context, setState) {
        // Compute greyed stops
        List<int> greyedStops = [];
        if (selectedRoute != null && originIndex != null && destinationIndex != null) {
          int start = originIndex! < destinationIndex!
              ? originIndex!
              : destinationIndex!;
          int end = originIndex! > destinationIndex!
              ? originIndex!
              : destinationIndex!;
          for (int i = 0; i < selectedRoute!.stops.length; i++) {
            if (i < start || i > end) {
              greyedStops.add(i);
            }
          }
        }
        
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Show booking progress bar always
            BookingProgressBar(
              currentStep: _getCurrentStep(
                selectedRoute,
                originIndex,
                destinationIndex,
                hasSelectedDateTime,
                selectedSeats,
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xFF2E2E2E), // Neutral dark grey background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<RouteInfo>(
                  value: selectedRoute,
                  isExpanded: true,
                  underline: Container(), // Remove the default underline border
                  dropdownColor: Color(0xFF2E2E2E), // Dark grey background for dropdown items
                  icon: Icon(Icons.arrow_drop_down, color: Color(0xFFFFFFFF)), // White icon
                  hint: Text(
                    'Select a route to get started',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFFFFFFF), // White text
                    ),
                  ),
                  items: predefinedRoutes.map((route) {
                    return DropdownMenuItem<RouteInfo>(
                      value: route,
                      child: Row(
                        children: [
                          // Route name with integrated direction
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _getFormattedRouteName(route.name),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFFFFFFFF), // White text
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          // Route details
                          Text(
                            '${route.distance} • ${route.duration}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFFFFFFF), // White text
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedRoute = value;
                        originIndex = null;
                        destinationIndex = null;
                        hasSelectedDateTime = false; // Reset when route changes
                      });
                    }
                  },
                ),
              ),
            ),
            
            // Show route content only when a route is selected
            if (selectedRoute != null)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side: Stop list and seat plan
                    Expanded(
                      child: Column(
                        children: [
                          // Stop list section
                          SizedBox(
                                height: selectedRoute!.stops.length * 28.0,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: RouteLineWithStopsPainter(
                                          stopCount: selectedRoute!.stops.length,
                                          rowHeight: 28,
                                          lineWidth: 2,
                                          lineColor: Colors.blueGrey,
                                          originIndex: originIndex,
                                          destinationIndex: destinationIndex,
                                          greyedStops: greyedStops,
                                        ),
                                      ),
                                    ),
                                    ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: selectedRoute!.stops.length,
                                      itemBuilder: (context, i) {
                                        bool isFirst = i == 0;
                                        bool isLast = i == selectedRoute!.stops.length - 1;
                                        bool disableTap =
                                            (originIndex == null && isLast) ||
                                            (originIndex != null &&
                                                destinationIndex == null &&
                                                isFirst &&
                                                i > originIndex!);
                                        bool isGreyed = greyedStops.contains(i);
                                        return InkWell(
                                          onTap: disableTap
                                              ? null
                                              : () {
                                                  setState(() {
                                                    if (originIndex == null) {
                                                      if (!isLast) {
                                                        originIndex = i;
                                                        destinationIndex = null;
                                                      }
                                                    } else if (destinationIndex == null &&
                                                        i != originIndex &&
                                                        i > originIndex!) {
                                                      if (!isFirst) {
                                                        destinationIndex = i;
                                                      }
                                                    } else if (i == originIndex) {
                                                      originIndex = null;
                                                      destinationIndex = null;
                                                    } else if (i == destinationIndex) {
                                                      destinationIndex = null;
                                                    }
                                                    hasSelectedDateTime = false;
                                                  });
                                                },
                                          child: Container(
                                            height: 28.0,
                                            padding: EdgeInsets.symmetric(vertical: 4),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 28,
                                                  alignment: Alignment.center,
                                                  child: _buildStopCircleOrMarker(
                                                    i,
                                                    originIndex,
                                                    destinationIndex,
                                                    isGreyed,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    selectedRoute!.stops[i].name,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: isGreyed
                                                          ? Colors.grey
                                                          : (i == destinationIndex
                                                                ? Color(0xFFDD2C00)
                                                                : (i == originIndex
                                                                      ? Color(0xFF00C853)
                                                                      : Color(0xFF2E2E2E))),
                                                      fontWeight: (i == originIndex || i == destinationIndex)
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                            ),
                            
                            // Car seat layout section (show below stop list)
                            if (originIndex != null && destinationIndex != null && hasSelectedDateTime)
                              Column(
                                children: [
                                  Container(
                                    key: ValueKey('seat-layout'), // Add key for alignment reference
                                    margin: EdgeInsets.only(top: 20),
                                    height: 250, // Fixed height to match info card
                                    child: CarSeatLayout(
                                      userRole: role,
                                      onSeatsSelected: (seats) {
                                        setState(() {
                                          selectedSeats = seats;
                                        });
                                        if (kDebugMode) {
                                          debugPrint('Selected seats: $seats');
                                        }
                                      },
                                    ),
                                  ),
                                ],
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
                          _TimeBoxesContainer(
                              selectedRoute: selectedRoute!,
                              originIndex: originIndex!,
                              destinationIndex: destinationIndex,
                              onDateTimeSelected: (bool selected) {
                                setState(() {
                                  hasSelectedDateTime = selected;
                                });
                              },
                            ),
                          
                          // Seat availability information card (positioned to match seat layout)
                          if (destinationIndex != null && hasSelectedDateTime)
                            Container(
                              key: ValueKey('info-card'), // Add key for alignment reference
                              margin: EdgeInsets.only(
                                top: 20 + (selectedRoute!.stops.length * 28.0) - (destinationIndex! * 28.0 + 28.0), 
                                // Position card to align with seat layout: margin + stop list height - time picker height
                              ),
                              width: 160, // Match the time picker width
                              height: 250, // Increased to match seat layout height
                              padding: EdgeInsets.all(0), // Remove internal padding to align borders perfectly
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16), // Move padding inside
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Large number at the top
                                    Text(
                                      '${4 - selectedSeats.length}',
                                      style: TextStyle(
                                        fontSize: 56, // 4 times bigger than original (14 * 4)
                                        color: Colors.blue[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    // Descriptive text below
                                    Text(
                                      role == 'Driver' 
                                        ? 'seats\navailable\nfor riders'
                                        : 'seats\navailable',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue[600],
                                        height: 1.3,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // Car seat layout moved to be positioned right after stop list
            
            // Complete Booking button appears with seat layout at same level as dropdown
            if (destinationIndex != null && hasSelectedDateTime)
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: (4 - selectedSeats.length) > 0 ? Color(0xFF2E2E2E) : Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: (4 - selectedSeats.length) > 0 ? () {
                      // Handle final booking submission
                      if (kDebugMode) {
                        debugPrint('Final booking submitted!');
                        debugPrint('Route: ${selectedRoute?.name}');
                        debugPrint('Origin: ${selectedRoute?.stops[originIndex!].name}');
                        debugPrint('Destination: ${selectedRoute?.stops[destinationIndex!].name}');
                        debugPrint('Selected seats: $selectedSeats');
                      }
                      
                      // TODO: Navigate to confirmation screen or process booking
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Booking submitted successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          (4 - selectedSeats.length) > 0 ? 'Complete Booking' : 'No Available Seats',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: (4 - selectedSeats.length) > 0 ? Color(0xFFFFFFFF) : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        );
      },
    );
  }

  // Deprecated local helpers removed; using shared helpers from utils/date_time_helpers.dart

  Widget _buildStopCircleOrMarker(
    int i,
    int? originIndex,
    int? destinationIndex,
    bool isGreyed,
  ) {
    if (i == originIndex) {
      // Google Maps style origin marker (green)
      return Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 2,
                  spreadRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
          // Inner circle - dark grey for origin
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Color(0xFF2E2E2E), // Neutral dark grey color
              shape: BoxShape.circle,
            ),
          ),
        ],
      );
    } else if (i == destinationIndex) {
      // Google Maps style destination marker (red)
      return Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 2,
                  spreadRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
          // Inner circle - dark grey for destination
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Color(0xFF2E2E2E), // Neutral dark grey color
              shape: BoxShape.circle,
            ),
          ),
        ],
      );
    } else {
      // Regular stop marker using neutral dark grey style
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isGreyed
                ? Colors.grey
                : Color(0xFF2E2E2E), // Neutral dark grey color
            width: 2,
          ),
          shape: BoxShape.circle,
        ),
      );
    }
  }

  // Helper method to format route name with a direction icon
  String _getFormattedRouteName(String name) {
    // Find the position of the hyphen that separates origin from destination
    int hyphenPos = name.indexOf(' - ');
    if (hyphenPos != -1) {
      String origin = name.substring(0, hyphenPos);
      String destination = name.substring(hyphenPos + 3);
      // Insert a subtle arrow between the origin and destination
      return '$origin  →  $destination'; // Added extra spaces around the arrow for better visual spacing
    }
    return name; // Return original name if no hyphen is found
  }

  int _getCurrentStep(
    RouteInfo? selectedRoute,
    int? originIndex,
    int? destinationIndex,
    bool hasSelectedDateTime,
    List<int> selectedSeats,
  ) {
    if (selectedRoute == null) return 0;
    if (originIndex == null) return 1;
    if (destinationIndex == null) return 2;
    if (!hasSelectedDateTime) return 3;
    if (selectedSeats.isEmpty) return 4;
    return 4; // All steps completed
  }
}

// A separate widget to handle both origin and destination time boxes
class _TimeBoxesContainer extends StatefulWidget {
  final RouteInfo selectedRoute;
  final int originIndex;
  final int? destinationIndex;
  final Function(bool) onDateTimeSelected;

  const _TimeBoxesContainer({
    required this.selectedRoute,
    required this.originIndex,
    this.destinationIndex,
    required this.onDateTimeSelected,
  });

  @override
  _TimeBoxesContainerState createState() => _TimeBoxesContainerState();
}

class _TimeBoxesContainerState extends State<_TimeBoxesContainer> {
  late DateTime selectedDate; // Used for departure time
  late DateTime arrivalTime; // Store arrival time explicitly
  bool isEditingArrival =
      false; // Flag to track if we're editing arrival or departure time
  bool hasUserSelectedDateTime = false; // Track if user has explicitly selected date/time

  @override
  void initState() {
    super.initState();

    // Default to today at the next hour (or tomorrow if it's late)
    final now = DateTime.now();
    if (now.hour < 23) {
      // If it's before 11 PM, use today at next hour
      selectedDate = DateTime(now.year, now.month, now.day, now.hour + 1, 0);
    } else {
      // If it's after 11 PM, use tomorrow at 9 AM
      selectedDate = DateTime(now.year, now.month, now.day + 1, 9, 0);
    }

    // Initialize arrival time based on departure time
    arrivalTime = calculateArrivalTime(
      selectedDate,
      widget.selectedRoute,
      widget.originIndex,
      widget.destinationIndex,
    );
  }

  @override
  void didUpdateWidget(_TimeBoxesContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recalculate arrival time if destination has changed
    if (oldWidget.destinationIndex != widget.destinationIndex) {
      _recalculateArrivalTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Origin time box - positioned to align with the origin
        SizedBox(height: widget.originIndex * 28.0),

        // Origin departure time box
        GestureDetector(
          onTap: () async {
            // Show bottom sheet with wheel pickers for departure time
            isEditingArrival = false; // We're editing departure time
            await showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                // Initialize with the earliest valid departure time
                DateTime tempPickedDate = _findEarliestValidDepartureTime(selectedDate);
                
                // Create controllers for both wheels to enable snapping animation
                final FixedExtentScrollController hourController = FixedExtentScrollController(
                  initialItem: tempPickedDate.hour,
                );
                final FixedExtentScrollController minuteController = FixedExtentScrollController(
                  initialItem: (tempPickedDate.minute / 5).round(),
                );

                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setModalState) {
                    return Container(
                      height: 300,
                      color: Colors.white,
                      child: Column(
                        children: [
                          // Header with buttons
                          Container(
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Color(0xFF00C853).withValues(alpha: 0.1), // Light green background
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF00C853), width: 2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel', style: TextStyle(color: Color(0xFF00C853))),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, color: Color(0xFF00C853), size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Pick-up Time',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF00C853),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      hasUserSelectedDateTime = true; // User has explicitly selected date/time
                                      if (isEditingArrival) {
                                        // If editing arrival time, set arrival time and calculate departure time
                                        arrivalTime = tempPickedDate;
                                        selectedDate =
                                            _calculateDepartureTime();
                                      } else {
                                        // If editing departure time, set departure time and calculate arrival time
                                        selectedDate = tempPickedDate;
                                        _validateAndAdjustTime(); // Call validation method when done
                                        arrivalTime = calculateArrivalTime(
                                          selectedDate,
                                          widget.selectedRoute,
                                          widget.originIndex,
                                          widget.destinationIndex,
                                        );
                                      }
                                    });
                                    widget.onDateTimeSelected(true); // Notify parent
                                    Navigator.pop(context);
                                  },
                                  child: Text('Done', style: TextStyle(color: Color(0xFF00C853))),
                                ),
                              ],
                            ),
                          ),

                          // Wheels for day, hour, minute
                          Expanded(
                            child: Row(
                              children: [
                                // Day wheel
                                Expanded(
                                  flex: 2,
                                  child: ListWheelScrollView(
                                    itemExtent: 50,
                                    diameterRatio: 1.2,
                                    magnification: 1.3,
                                    useMagnifier: true,
                                    squeeze: 0.8,
                                    physics: FixedExtentScrollPhysics(),
                                    controller: FixedExtentScrollController(
                                      initialItem: 0,
                                    ),
                                    onSelectedItemChanged: (index) {
                                      setModalState(() {
                                        final date = DateTime.now().add(
                                          Duration(days: index),
                                        );
                                        tempPickedDate = DateTime(
                                          date.year,
                                          date.month,
                                          date.day,
                                          tempPickedDate.hour,
                                          tempPickedDate.minute,
                                        );
                                      });
                                    },
                                    children: List.generate(5, (index) {
                                      final date = DateTime.now().add(
                                        Duration(days: index),
                                      );
                                      String label;
                                      final day = date.day.toString().padLeft(
                                        2,
                                        '0',
                                      );
                                      final month = [
                                        'Jan',
                                        'Feb',
                                        'Mar',
                                        'Apr',
                                        'May',
                                        'Jun',
                                        'Jul',
                                        'Aug',
                                        'Sep',
                                        'Oct',
                                        'Nov',
                                        'Dec',
                                      ][date.month - 1];
                                      final weekday = [
                                        'Mon',
                                        'Tue',
                                        'Wed',
                                        'Thu',
                                        'Fri',
                                        'Sat',
                                        'Sun',
                                      ][date.weekday - 1];

                                      if (index == 0) {
                                        label = "Today";
                                      } else if (index == 1) {
                                        label = "Tomorrow";
                                      } else {
                                        label = '$day $month $weekday';
                                      }

                                      return Center(
                                        child: Text(
                                          label,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF00C853),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),

                                // Hour wheel
                                Expanded(
                                  flex: 1,
                                  child: ListWheelScrollView(
                                    itemExtent: 50,
                                    diameterRatio: 1.2,
                                    magnification: 1.3,
                                    useMagnifier: true,
                                    squeeze: 0.8,
                                    physics: FixedExtentScrollPhysics(),
                                    controller: hourController,
                                    onSelectedItemChanged: (index) {
                                      // Test if this hour creates a valid departure time
                                      final testDepartureTime = DateTime(
                                        tempPickedDate.year,
                                        tempPickedDate.month,
                                        tempPickedDate.day,
                                        index,
                                        tempPickedDate.minute,
                                      );
                                      
                                      DateTime validTime;
                                      if (_isValidDepartureTime(testDepartureTime)) {
                                        validTime = testDepartureTime;
                                      } else {
                                        // Find the next valid departure time for this day
                                        validTime = _findEarliestValidDepartureTime(
                                          DateTime(tempPickedDate.year, tempPickedDate.month, tempPickedDate.day)
                                        );
                                        
                                        // Animate to the correct hour with snapping effect
                                        Future.delayed(Duration(milliseconds: 100), () {
                                          hourController.animateToItem(
                                            validTime.hour,
                                            duration: Duration(milliseconds: 400),
                                            curve: Curves.elasticOut,
                                          );
                                        });
                                      }

                                      setModalState(() {
                                        tempPickedDate = validTime;
                                      });
                                    },
                                    children: List.generate(24, (index) {
                                      // Check if this hour would result in a valid departure time
                                      final testDepartureTime = DateTime(
                                        tempPickedDate.year,
                                        tempPickedDate.month,
                                        tempPickedDate.day,
                                        index,
                                        tempPickedDate.minute,
                                      );
                                      
                                      final isValid = _isValidDepartureTime(testDepartureTime);

                                      return Center(
                                        child: Text(
                                          index.toString().padLeft(2, '0'),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: isValid
                                                ? Color(0xFF00C853)
                                                : Colors.grey[300], // Grayed out for invalid times
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),

                                // Minute wheel
                                Expanded(
                                  flex: 1,
                                  child: ListWheelScrollView(
                                    itemExtent: 50,
                                    diameterRatio: 1.2,
                                    magnification: 1.3,
                                    useMagnifier: true,
                                    squeeze: 0.8,
                                    physics: FixedExtentScrollPhysics(),
                                    controller: minuteController,
                                    onSelectedItemChanged: (index) {
                                      // Convert index to actual minute (multiply by 5)
                                      final minuteValue = index * 5;

                                      // Test if this minute creates a valid departure time
                                      final testDepartureTime = DateTime(
                                        tempPickedDate.year,
                                        tempPickedDate.month,
                                        tempPickedDate.day,
                                        tempPickedDate.hour,
                                        minuteValue,
                                      );
                                      
                                      DateTime validTime;
                                      if (_isValidDepartureTime(testDepartureTime)) {
                                        validTime = testDepartureTime;
                                      } else {
                                        // Find the next valid departure time starting from this hour
                                        validTime = _findEarliestValidDepartureTime(
                                          DateTime(tempPickedDate.year, tempPickedDate.month, tempPickedDate.day, tempPickedDate.hour)
                                        );
                                        // If no valid time found in this hour, get the earliest for the day
                                        if (validTime.hour != tempPickedDate.hour) {
                                          validTime = _findEarliestValidDepartureTime(
                                            DateTime(tempPickedDate.year, tempPickedDate.month, tempPickedDate.day)
                                          );
                                          
                                          // Animate hour wheel to the correct hour
                                          Future.delayed(Duration(milliseconds: 100), () {
                                            hourController.animateToItem(
                                              validTime.hour,
                                              duration: Duration(milliseconds: 400),
                                              curve: Curves.elasticOut,
                                            );
                                          });
                                        }
                                        
                                        // Animate minute wheel to the correct minute
                                        Future.delayed(Duration(milliseconds: 150), () {
                                          minuteController.animateToItem(
                                            (validTime.minute / 5).round(),
                                            duration: Duration(milliseconds: 400),
                                            curve: Curves.elasticOut,
                                          );
                                        });
                                      }

                                      setModalState(() {
                                        tempPickedDate = validTime;
                                      });
                                    },
                                    children: List.generate(12, (index) {
                                      // Only 12 items (0, 5, 10, ... 55)
                                      // Convert index to actual minute
                                      final minuteValue = index * 5;

                                      // Check if this minute would result in a valid departure time
                                      final testDepartureTime = DateTime(
                                        tempPickedDate.year,
                                        tempPickedDate.month,
                                        tempPickedDate.day,
                                        tempPickedDate.hour,
                                        minuteValue,
                                      );
                                      
                                      final isValid = _isValidDepartureTime(testDepartureTime);

                                      return Center(
                                        child: Text(
                                          minuteValue.toString().padLeft(
                                            2,
                                            '0',
                                          ),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: isValid
                                                ? Color(0xFF00C853)
                                                : Colors.grey[300], // Grayed out for invalid times
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
          child: Container(
            height: 28.0, // Match stop item height
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Color(0xFF00C853), // Green border for pickup
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Show "Pick up time" or actual date/time based on user selection
                      if (hasUserSelectedDateTime) ...[
                        // Format date as: "Today", "Tomorrow", or "16 Aug Sat" (year removed)
                        Text(
                          formatRelativeDay(selectedDate, DateTime.now()),
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF00C853),
                            fontWeight: FontWeight.bold,
                          ), // Google Maps green
                        ),
                        SizedBox(width: 6),
                        // Small dot separator
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Color(0xFF00C853), // Google Maps green
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6),
                        // Format time as: "14:30"
                        Text(
                          formatTimeHHmm(selectedDate),
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF00C853),
                            fontWeight: FontWeight.bold,
                          ), // Google Maps green
                        ),
                      ] else
                        Text(
                          'Pick up time',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF00C853),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Add space between origin and destination time boxes (only if destination is selected)
        if (widget.destinationIndex != null)
          SizedBox(
            height: (widget.destinationIndex! - widget.originIndex - 1) * 28.0,
          ),

        // Destination arrival time box - only show when destination is selected
        if (widget.destinationIndex != null)
          GestureDetector(
          onTap: () async {
            // Show bottom sheet with wheel pickers for arrival time
            isEditingArrival = true;
            await showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                // Initialize with the earliest valid arrival time
                DateTime tempPickedDate = _findEarliestValidArrivalTime(arrivalTime);
                
                // Create controllers for both wheels to enable snapping animation
                final FixedExtentScrollController hourController = FixedExtentScrollController(
                  initialItem: tempPickedDate.hour,
                );
                final FixedExtentScrollController minuteController = FixedExtentScrollController(
                  initialItem: (tempPickedDate.minute / 5).round(),
                );

                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setModalState) {
                    return Container(
                      height: 300,
                      color: Colors.white,
                      child: Column(
                        children: [
                          // Header with buttons
                          Container(
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Color(0xFFDD2C00).withValues(alpha: 0.1), // Light red background
                              border: Border(
                                bottom: BorderSide(color: Color(0xFFDD2C00), width: 2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel', style: TextStyle(color: Color(0xFFDD2C00))),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.flag, color: Color(0xFFDD2C00), size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Drop-off Time',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFDD2C00),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    debugPrint('Arrival time Done pressed: setting arrivalTime=$tempPickedDate');
                                    setState(() {
                                      hasUserSelectedDateTime = true; // User has explicitly selected date/time
                                      arrivalTime = tempPickedDate;
                                      // Calculate departure time using the new arrival time
                                      selectedDate = calculateDepartureTime(
                                        tempPickedDate, // Use the selected time directly
                                        widget.selectedRoute,
                                        widget.originIndex,
                                        widget.destinationIndex,
                                      );
                                      debugPrint('Calculated departure time: $selectedDate');
                                      _validateAndAdjustTime(); // Validate the calculated departure time
                                    });
                                    widget.onDateTimeSelected(true); // Notify parent
                                    Navigator.pop(context);
                                  },
                                  child: Text('Done', style: TextStyle(color: Color(0xFFDD2C00))),
                                ),
                              ],
                            ),
                          ),

                          // Same wheels as for departure time
                          Expanded(
                            child: Row(
                              children: [
                                // Day wheel
                                Expanded(
                                  flex: 2,
                                  child: ListWheelScrollView(
                                    itemExtent: 50,
                                    diameterRatio: 1.2,
                                    magnification: 1.3,
                                    useMagnifier: true,
                                    squeeze: 0.8,
                                    physics: FixedExtentScrollPhysics(),
                                    controller: FixedExtentScrollController(
                                      initialItem: min(
                                        4,
                                        max(
                                          0,
                                          arrivalTime
                                              .difference(DateTime.now())
                                              .inDays,
                                        ),
                                      ),
                                    ),
                                    onSelectedItemChanged: (index) {
                                      setModalState(() {
                                        final date = DateTime.now().add(
                                          Duration(days: index),
                                        );
                                        tempPickedDate = DateTime(
                                          date.year,
                                          date.month,
                                          date.day,
                                          tempPickedDate.hour,
                                          tempPickedDate.minute,
                                        );
                                      });
                                    },
                                    children: List.generate(5, (index) {
                                      final date = DateTime.now().add(
                                        Duration(days: index),
                                      );
                                      String label;
                                      final day = date.day.toString().padLeft(
                                        2,
                                        '0',
                                      );
                                      final month = [
                                        'Jan',
                                        'Feb',
                                        'Mar',
                                        'Apr',
                                        'May',
                                        'Jun',
                                        'Jul',
                                        'Aug',
                                        'Sep',
                                        'Oct',
                                        'Nov',
                                        'Dec',
                                      ][date.month - 1];
                                      final weekday = [
                                        'Mon',
                                        'Tue',
                                        'Wed',
                                        'Thu',
                                        'Fri',
                                        'Sat',
                                        'Sun',
                                      ][date.weekday - 1];

                                      if (index == 0) {
                                        label = "Today";
                                      } else if (index == 1) {
                                        label = "Tomorrow";
                                      } else {
                                        label = '$day $month $weekday';
                                      }

                                      return Center(
                                        child: Text(
                                          label,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFFDD2C00),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),

                                // Hour and minute wheels are identical to the departure time picker
                                // but use arrivalTime for initial values
                                Expanded(
                                  flex: 1,
                                  child: ListWheelScrollView(
                                    itemExtent: 50,
                                    diameterRatio: 1.2,
                                    magnification: 1.3,
                                    useMagnifier: true,
                                    squeeze: 0.8,
                                    physics: FixedExtentScrollPhysics(),
                                    controller: hourController,
                                    onSelectedItemChanged: (index) {
                                      // Always update to a valid time
                                      final testArrivalTime = DateTime(
                                        tempPickedDate.year,
                                        tempPickedDate.month,
                                        tempPickedDate.day,
                                        index,
                                        tempPickedDate.minute,
                                      );
                                      
                                      DateTime validTime;
                                      if (_isValidArrivalTime(testArrivalTime)) {
                                        validTime = testArrivalTime;
                                      } else {
                                        // Find the next valid hour for this day
                                        validTime = _findEarliestValidArrivalTime(
                                          DateTime(tempPickedDate.year, tempPickedDate.month, tempPickedDate.day)
                                        );
                                        
                                        // Animate to the correct hour with snapping effect
                                        Future.delayed(Duration(milliseconds: 100), () {
                                          hourController.animateToItem(
                                            validTime.hour,
                                            duration: Duration(milliseconds: 400),
                                            curve: Curves.elasticOut,
                                          );
                                        });
                                        
                                        // Also update the minute wheel if needed
                                        if (validTime.minute != tempPickedDate.minute) {
                                          Future.delayed(Duration(milliseconds: 150), () {
                                            minuteController.animateToItem(
                                              (validTime.minute / 5).round(),
                                              duration: Duration(milliseconds: 400),
                                              curve: Curves.elasticOut,
                                            );
                                          });
                                        }
                                      }
                                      
                                      setModalState(() {
                                        tempPickedDate = validTime;
                                      });
                                    },
                                    children: List.generate(24, (index) {
                                      // Check if this hour would result in a valid arrival time
                                      final testArrivalTime = DateTime(
                                        tempPickedDate.year,
                                        tempPickedDate.month,
                                        tempPickedDate.day,
                                        index,
                                        tempPickedDate.minute,
                                      );
                                      
                                      final isValid = _isValidArrivalTime(testArrivalTime);
                                      
                                      return Center(
                                        child: Text(
                                          index.toString().padLeft(2, '0'),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: isValid 
                                              ? Color(0xFFDD2C00) 
                                              : Colors.grey[300], // Grayed out for invalid times
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),

                                // Minute wheel
                                Expanded(
                                  flex: 1,
                                  child: ListWheelScrollView(
                                    itemExtent: 50,
                                    diameterRatio: 1.2,
                                    magnification: 1.3,
                                    useMagnifier: true,
                                    squeeze: 0.8,
                                    physics: FixedExtentScrollPhysics(),
                                    controller: minuteController,
                                    onSelectedItemChanged: (index) {
                                      final minuteValue = index * 5;
                                      
                                      // Always update to a valid time
                                      final testArrivalTime = DateTime(
                                        tempPickedDate.year,
                                        tempPickedDate.month,
                                        tempPickedDate.day,
                                        tempPickedDate.hour,
                                        minuteValue,
                                      );
                                      
                                      DateTime validTime;
                                      if (_isValidArrivalTime(testArrivalTime)) {
                                        validTime = testArrivalTime;
                                      } else {
                                        // Find the next valid time starting from this hour
                                        validTime = _findEarliestValidArrivalTime(
                                          DateTime(tempPickedDate.year, tempPickedDate.month, tempPickedDate.day, tempPickedDate.hour)
                                        );
                                        // If no valid time found in this hour, get the earliest for the day
                                        if (validTime.hour != tempPickedDate.hour) {
                                          validTime = _findEarliestValidArrivalTime(
                                            DateTime(tempPickedDate.year, tempPickedDate.month, tempPickedDate.day)
                                          );
                                        }
                                        
                                        // Animate minute wheel to the correct position with snapping effect
                                        Future.delayed(Duration(milliseconds: 100), () {
                                          minuteController.animateToItem(
                                            (validTime.minute / 5).round(),
                                            duration: Duration(milliseconds: 400),
                                            curve: Curves.elasticOut,
                                          );
                                        });
                                        
                                        // Also animate hour wheel if it changed
                                        if (validTime.hour != tempPickedDate.hour) {
                                          Future.delayed(Duration(milliseconds: 50), () {
                                            hourController.animateToItem(
                                              validTime.hour,
                                              duration: Duration(milliseconds: 400),
                                              curve: Curves.elasticOut,
                                            );
                                          });
                                        }
                                      }
                                      
                                      setModalState(() {
                                        tempPickedDate = validTime;
                                      });
                                    },
                                    children: List.generate(12, (index) {
                                      final minuteValue = index * 5;
                                      
                                      // Check if this minute would result in a valid arrival time
                                      final testArrivalTime = DateTime(
                                        tempPickedDate.year,
                                        tempPickedDate.month,
                                        tempPickedDate.day,
                                        tempPickedDate.hour,
                                        minuteValue,
                                      );
                                      
                                      final isValid = _isValidArrivalTime(testArrivalTime);
                                      
                                      return Center(
                                        child: Text(
                                          minuteValue.toString().padLeft(
                                            2,
                                            '0',
                                          ),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: isValid 
                                              ? Color(0xFFDD2C00)
                                              : Colors.grey[300], // Grayed out for invalid times
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
            isEditingArrival = false; // Reset flag after modal is closed
          },
          child: Container(
            height: 28.0, // Match stop item height
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Color(0xFFDD2C00), // Red border for drop-off
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Show calculated arrival time when both destination is selected AND pickup time is set
                      if (widget.destinationIndex != null && hasUserSelectedDateTime) ...[
                        // Format date as: "Today", "Tomorrow", or "16 Aug Sat" (year removed)
                        Text(
                          formatRelativeDay(arrivalTime, DateTime.now()),
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFDD2C00),
                            fontWeight: FontWeight.bold,
                          ), // Google Maps red
                        ),
                        SizedBox(width: 6),
                        // Small dot separator
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Color(0xFFDD2C00), // Google Maps red
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6),
                        // Format time as: "14:30"
                        Text(
                          formatTimeHHmm(arrivalTime),
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFDD2C00),
                            fontWeight: FontWeight.bold,
                          ), // Google Maps red
                        ),
                      ] else
                        Text(
                          'Drop off time',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFDD2C00),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // End GestureDetector for arrival time box
      ],
    );
  }

  // Validate departure time (adjust forward if now in past when editing arrival)
  void _validateAndAdjustTime() {
    if (isTodayDate(selectedDate)) {
      final now = DateTime.now();
      if (selectedDate.isBefore(now)) {
        final roundedMinute = ((now.minute + 5) ~/ 5) * 5;
        selectedDate = DateTime(
          now.year,
          now.month,
          now.day,
          roundedMinute == 60 ? now.hour + 1 : now.hour,
          roundedMinute == 60 ? 0 : roundedMinute,
        );
      }
    }
  }

  // Recalculate arrival time based on current departure time
  void _recalculateArrivalTime() {
    if (widget.destinationIndex != null) {
      debugPrint('Recalculating arrival time: origin=${widget.originIndex}, dest=${widget.destinationIndex}');
      setState(() {
        arrivalTime = calculateArrivalTime(
          selectedDate,
          widget.selectedRoute,
          widget.originIndex,
          widget.destinationIndex,
        );
      });
    }
  }

  // Check if a departure time is valid (not in the past and results in valid arrival)
  bool _isValidDepartureTime(DateTime departureTime) {
    // Don't allow past times (with 5 minute buffer)
    final earliestValidTime = DateTime.now().add(Duration(minutes: 5));
    if (departureTime.isBefore(earliestValidTime)) {
      return false;
    }
    
    // If destination is selected, check if arrival time would be reasonable
    if (widget.destinationIndex != null) {
      final calculatedArrivalTime = calculateArrivalTime(
        departureTime,
        widget.selectedRoute,
        widget.originIndex,
        widget.destinationIndex,
      );
      // Just make sure arrival is after departure (basic sanity check)
      return calculatedArrivalTime.isAfter(departureTime);
    }
    
    return true;
  }

  // Find the earliest valid departure time for a given date
  DateTime _findEarliestValidDepartureTime(DateTime date) {
    // Start from current time if it's today, otherwise from beginning of day
    final now = DateTime.now();
    int startHour = 0;
    int startMinute = 0;
    
    if (isTodayDate(date)) {
      startHour = now.hour;
      startMinute = ((now.minute / 5).ceil() * 5); // Round up to next 5-minute interval
      if (startMinute >= 60) {
        startHour += 1;
        startMinute = 0;
      }
    }
    
    // Find the first valid time starting from the calculated start time
    for (int hour = startHour; hour < 24; hour++) {
      int minuteStart = (hour == startHour) ? startMinute : 0;
      for (int minute = minuteStart; minute < 60; minute += 5) { // 5-minute increments
        final testTime = DateTime(date.year, date.month, date.day, hour, minute);
        if (_isValidDepartureTime(testTime)) {
          return testTime;
        }
      }
    }
    
    // If no valid time found today, try tomorrow
    final tomorrow = date.add(Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 0, 0);
  }

  // Check if an arrival time would result in a valid (not past) departure time
  bool _isValidArrivalTime(DateTime arrivalTime) {
    if (widget.destinationIndex == null) return true;
    
    final calculatedDepartureTime = calculateDepartureTime(
      arrivalTime,
      widget.selectedRoute,
      widget.originIndex,
      widget.destinationIndex,
    );
    
    // Allow some buffer (5 minutes) from current time
    final earliestValidTime = DateTime.now().add(Duration(minutes: 5));
    return calculatedDepartureTime.isAfter(earliestValidTime);
  }

  // Find the earliest valid arrival time for a given date
  DateTime _findEarliestValidArrivalTime(DateTime date) {
    if (widget.destinationIndex == null) return date;
    
    // Start from the beginning of the day and find the first valid time
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 5) { // 5-minute increments
        final testTime = DateTime(date.year, date.month, date.day, hour, minute);
        if (_isValidArrivalTime(testTime)) {
          return testTime;
        }
      }
    }
    
    // If no valid time found today, try tomorrow
    final tomorrow = date.add(Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 0, 0);
  }

  // Departure time from current arrival using shared utils
  DateTime _calculateDepartureTime() => calculateDepartureTime(
    arrivalTime,
    widget.selectedRoute,
    widget.originIndex,
    widget.destinationIndex,
  );
}
