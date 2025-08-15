import 'package:flutter/material.dart';
import '../models/routes.dart';
import 'route_line_with_stops.dart';
import 'dart:math' show max, min;
import '../utils/date_time_helpers.dart';
import '../utils/constants.dart';

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
            style: TextStyle(letterSpacing: 1, color: Colors.white),
          ),
          backgroundColor: Colors.red,
          iconTheme: IconThemeData(color: Colors.white),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.local_taxi), text: 'Driver'),
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
    RouteInfo selectedRoute = predefinedRoutes[0];
    int? originIndex;
    int? destinationIndex;

    return StatefulBuilder(
      builder: (context, setState) {
        // Compute greyed stops
        List<int> greyedStops = [];
        if (originIndex != null && destinationIndex != null) {
          int start = originIndex! < destinationIndex!
              ? originIndex!
              : destinationIndex!;
          int end = originIndex! > destinationIndex!
              ? originIndex!
              : destinationIndex!;
          for (int i = 0; i < selectedRoute.stops.length; i++) {
            if (i < start || i > end) {
              greyedStops.add(i);
            }
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
              child: DropdownButton<RouteInfo>(
                value: selectedRoute,
                isExpanded: true,
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
                                  style: TextStyle(fontSize: 16),
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
                            color: Colors.grey[600],
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
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stop list
                  Expanded(
                    child: SizedBox(
                      height: selectedRoute.stops.length * 28.0,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: RouteLineWithStopsPainter(
                                stopCount: selectedRoute.stops.length,
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
                            itemCount: selectedRoute.stops.length,
                            itemBuilder: (context, i) {
                              bool isFirst = i == 0;
                              bool isLast = i == selectedRoute.stops.length - 1;
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
                                        });
                                      },
                                child: Container(
                                  height: 28.0,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 4,
                                  ), // Add vertical padding
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                          selectedRoute.stops[i].name,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isGreyed
                                                ? Colors.grey
                                                : (i == destinationIndex
                                                      ? Color(
                                                          0xFFDD2C00,
                                                        ) // Google Maps red for destination
                                                      : (i == originIndex
                                                            ? Color(
                                                                0xFF00C853,
                                                              ) // Google Maps green for origin
                                                            : Colors.black)),
                                            fontWeight:
                                                (i == originIndex ||
                                                    i == destinationIndex)
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
                  ),

                  // Right side date picker (positioned near origin)
                  if (originIndex != null && destinationIndex != null)
                    Container(
                      margin: EdgeInsets.only(left: 16),
                      width: 160, // Even narrower box
                      child: _TimeBoxesContainer(
                        selectedRoute: selectedRoute,
                        originIndex: originIndex!,
                        destinationIndex: destinationIndex!,
                      ),
                    ),
                ],
              ),
            ),
          ],
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
          // Inner circle - green for origin
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Color(0xFF00C853), // Google Maps green color
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
          // Inner circle - red for destination
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Color(0xFFDD2C00), // Google Maps red color
              shape: BoxShape.circle,
            ),
          ),
        ],
      );
    } else {
      // Regular stop marker using Google Maps style
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isGreyed
                ? Colors.grey
                : Color(0xFF4285F4), // Google Maps blue color
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
}

// A separate widget to handle both origin and destination time boxes
class _TimeBoxesContainer extends StatefulWidget {
  final RouteInfo selectedRoute;
  final int originIndex;
  final int destinationIndex;

  const _TimeBoxesContainer({
    required this.selectedRoute,
    required this.originIndex,
    required this.destinationIndex,
  });

  @override
  _TimeBoxesContainerState createState() => _TimeBoxesContainerState();
}

class _TimeBoxesContainerState extends State<_TimeBoxesContainer> {
  late DateTime selectedDate; // Used for departure time
  late DateTime arrivalTime; // Store arrival time explicitly
  bool isEditingArrival =
      false; // Flag to track if we're editing arrival or departure time

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
                DateTime tempPickedDate = selectedDate;

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
                              color: Colors.grey[200],
                              border: Border(
                                bottom: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                ),
                                Text(
                                  'Select Date & Time',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
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
                                    Navigator.pop(context);
                                  },
                                  child: Text('Done'),
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
                                    itemExtent: 40,
                                    diameterRatio: 1.5,
                                    controller: FixedExtentScrollController(
                                      initialItem: 1, // Default to tomorrow
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

                                      return Center(child: Text(label));
                                    }),
                                  ),
                                ),

                                // Hour wheel
                                Expanded(
                                  flex: 1,
                                  child: ListWheelScrollView(
                                    itemExtent: 40,
                                    diameterRatio: 1.5,
                                    controller: FixedExtentScrollController(
                                      initialItem: max(
                                        selectedDate.hour,
                                        isTodayDate(selectedDate)
                                            ? DateTime.now().hour
                                            : 0,
                                      ),
                                    ),
                                    onSelectedItemChanged: (index) {
                                      // Get minimum valid hour for today
                                      int minHour = 0;
                                      if (isTodayDate(tempPickedDate)) {
                                        minHour = DateTime.now().hour;
                                      }

                                      // Prevent selecting hours in the past for today
                                      if (isTodayDate(tempPickedDate) &&
                                          index < minHour) {
                                        // If user tries to select a past hour, reset to current hour
                                        setModalState(() {
                                          // Wait a moment then scroll back to valid time
                                          // Reset to current hour (no animation needed)
                                        });
                                        return;
                                      }

                                      setModalState(() {
                                        tempPickedDate = DateTime(
                                          tempPickedDate.year,
                                          tempPickedDate.month,
                                          tempPickedDate.day,
                                          index,
                                          isTodayDate(tempPickedDate) &&
                                                  index == DateTime.now().hour
                                              ? max(
                                                  tempPickedDate.minute,
                                                  DateTime.now().minute,
                                                )
                                              : tempPickedDate.minute,
                                        );
                                      });
                                    },
                                    children: List.generate(24, (index) {
                                      // Gray out past hours for today
                                      bool isPastHour =
                                          isTodayDate(tempPickedDate) &&
                                          index < DateTime.now().hour;

                                      return Center(
                                        child: Text(
                                          index.toString().padLeft(2, '0'),
                                          style: TextStyle(
                                            color: isPastHour
                                                ? Colors.grey[400]
                                                : null,
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
                                    itemExtent: 40,
                                    diameterRatio: 1.5,
                                    controller: FixedExtentScrollController(
                                      // Use the formerly unused _getNearestFiveMinuteIndex method
                                      initialItem: nearestFiveMinuteIndex(
                                        max(
                                          selectedDate.minute,
                                          isTodayDate(selectedDate) &&
                                                  selectedDate.hour ==
                                                      DateTime.now().hour
                                              ? DateTime.now().minute
                                              : 0,
                                        ),
                                      ),
                                    ),
                                    onSelectedItemChanged: (index) {
                                      // Convert index to actual minute (multiply by 5)
                                      final minuteValue = index * 5;

                                      // For current hour of today, prevent selecting past minutes
                                      final now = DateTime.now();
                                      if (isTodayDate(tempPickedDate) &&
                                          tempPickedDate.hour == now.hour &&
                                          minuteValue < now.minute) {
                                        setModalState(() {
                                          // Reset to current 5-minute interval (no animation needed)
                                        });
                                        return;
                                      }

                                      setModalState(() {
                                        tempPickedDate = DateTime(
                                          tempPickedDate.year,
                                          tempPickedDate.month,
                                          tempPickedDate.day,
                                          tempPickedDate.hour,
                                          minuteValue, // Use actual minute value (0, 5, 10, etc.)
                                        );
                                      });
                                    },
                                    children: List.generate(12, (index) {
                                      // Only 12 items (0, 5, 10, ... 55)
                                      // Convert index to actual minute
                                      final minuteValue = index * 5;

                                      // Gray out past minutes for current hour of today
                                      final now = DateTime.now();
                                      bool isPastMinute =
                                          isTodayDate(tempPickedDate) &&
                                          tempPickedDate.hour == now.hour &&
                                          minuteValue < now.minute;

                                      return Center(
                                        child: Text(
                                          minuteValue.toString().padLeft(
                                            2,
                                            '0',
                                          ),
                                          style: TextStyle(
                                            color: isPastMinute
                                                ? Colors.grey[400]
                                                : null,
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
                color: Color(0xFF00C853),
                width: 1,
              ), // Google Maps green for origin
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Add space between origin and destination time boxes
        SizedBox(
          height: (widget.destinationIndex - widget.originIndex) * 28.0 - 28.0,
        ),

        // Destination arrival time box - can be clicked to set arrival time
        GestureDetector(
          onTap: () async {
            // Show bottom sheet with wheel pickers for arrival time
            isEditingArrival = true;
            await showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                DateTime tempPickedDate = arrivalTime;

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
                              color: Colors.grey[200],
                              border: Border(
                                bottom: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                ),
                                Text(
                                  'Set Arrival Time',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      arrivalTime = tempPickedDate;
                                      selectedDate = _calculateDepartureTime();
                                      _validateAndAdjustTime(); // Validate the calculated departure time
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text('Done'),
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
                                    itemExtent: 40,
                                    diameterRatio: 1.5,
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

                                      return Center(child: Text(label));
                                    }),
                                  ),
                                ),

                                // Hour and minute wheels are identical to the departure time picker
                                // but use arrivalTime for initial values
                                Expanded(
                                  flex: 1,
                                  child: ListWheelScrollView(
                                    itemExtent: 40,
                                    diameterRatio: 1.5,
                                    controller: FixedExtentScrollController(
                                      initialItem: tempPickedDate.hour,
                                    ),
                                    onSelectedItemChanged: (index) {
                                      setModalState(() {
                                        tempPickedDate = DateTime(
                                          tempPickedDate.year,
                                          tempPickedDate.month,
                                          tempPickedDate.day,
                                          index,
                                          tempPickedDate.minute,
                                        );
                                      });
                                    },
                                    children: List.generate(24, (index) {
                                      return Center(
                                        child: Text(
                                          index.toString().padLeft(2, '0'),
                                        ),
                                      );
                                    }),
                                  ),
                                ),

                                // Minute wheel
                                Expanded(
                                  flex: 1,
                                  child: ListWheelScrollView(
                                    itemExtent: 40,
                                    diameterRatio: 1.5,
                                    controller: FixedExtentScrollController(
                                      initialItem: nearestFiveMinuteIndex(
                                        tempPickedDate.minute,
                                      ),
                                    ),
                                    onSelectedItemChanged: (index) {
                                      final minuteValue = index * 5;
                                      setModalState(() {
                                        tempPickedDate = DateTime(
                                          tempPickedDate.year,
                                          tempPickedDate.month,
                                          tempPickedDate.day,
                                          tempPickedDate.hour,
                                          minuteValue,
                                        );
                                      });
                                    },
                                    children: List.generate(12, (index) {
                                      final minuteValue = index * 5;
                                      return Center(
                                        child: Text(
                                          minuteValue.toString().padLeft(
                                            2,
                                            '0',
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
                color: Color(0xFFDD2C00),
                width: 1,
              ), // Google Maps red for destination
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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

  // Departure time from current arrival using shared utils
  DateTime _calculateDepartureTime() => calculateDepartureTime(
    arrivalTime,
    widget.selectedRoute,
    widget.originIndex,
    widget.destinationIndex,
  );
}
