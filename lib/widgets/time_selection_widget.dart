import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../utils/date_time_helpers.dart';
import '../utils/constants.dart';

class TimeSelectionWidget extends StatefulWidget {
  final RouteInfo selectedRoute;
  final int originIndex;
  final int? destinationIndex;
  final Function(bool) onDateTimeSelected;
  final Function(DateTime departure, DateTime arrival)? onTimesChanged;

  const TimeSelectionWidget({
    super.key,
    required this.selectedRoute,
    required this.originIndex,
    this.destinationIndex,
    required this.onDateTimeSelected,
    this.onTimesChanged,
  });

  @override
  TimeSelectionWidgetState createState() => TimeSelectionWidgetState();
}

class TimeSelectionWidgetState extends State<TimeSelectionWidget> {
  late DateTime selectedDate; // Used for departure time
  late DateTime arrivalTime; // Store arrival time explicitly
  bool isEditingArrival =
      false; // Flag to track if we're editing arrival or departure time
  bool hasUserSelectedDateTime =
      false; // Track if user has explicitly selected date/time

  @override
  void initState() {
    super.initState();

    // Default to today at the next hour (or tomorrow if it's late)
    final now = DateTime.now();
    if (now.hour < 23) {
      selectedDate = DateTime(now.year, now.month, now.day, now.hour + 1, 0);
    } else {
      selectedDate = DateTime(now.year, now.month, now.day + 1, 9, 0);
    }

    // Initialize arrival time based on departure time
    arrivalTime = calculateArrivalTime(
      selectedDate,
      widget.selectedRoute,
      widget.originIndex,
      widget.destinationIndex,
    );
    
    // Notify parent of initial times
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyTimesChanged();
    });
  }

  @override
  void didUpdateWidget(TimeSelectionWidget oldWidget) {
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
        SizedBox(
          height: widget.originIndex * 42.0,
        ), // Stop positioning only (no title offset)
        // Origin departure time box
        GestureDetector(
          onTap: () => _showDepartureTimePicker(),
          child: _buildTimeBox(
            hasUserSelectedDateTime
                ? formatRelativeDay(selectedDate, DateTime.now())
                : 'Pick up time',
            hasUserSelectedDateTime ? formatTimeHHmm(selectedDate) : null,
            Color(0xFF00C853), // Green for pickup
          ),
        ),

        // Add space between origin and destination time boxes (only if destination is selected)
        if (widget.destinationIndex != null)
          SizedBox(
            height: (widget.destinationIndex! - widget.originIndex - 1) * 42.0,
          ),

        // Destination arrival time box - only show when destination is selected
        if (widget.destinationIndex != null)
          GestureDetector(
            onTap: () => _showArrivalTimePicker(),
            child: _buildTimeBox(
              (widget.destinationIndex != null && hasUserSelectedDateTime)
                  ? formatRelativeDay(arrivalTime, DateTime.now())
                  : 'Drop off time',
              (widget.destinationIndex != null && hasUserSelectedDateTime)
                  ? formatTimeHHmm(arrivalTime)
                  : null,
              Color(0xFFDD2C00), // Red for drop-off
            ),
          ),
      ],
    );
  }

  Widget _buildTimeBox(String mainText, String? timeText, Color color) {
    return Container(
      height: 42.0, // Match stop item height
      padding: EdgeInsets.all(4.2), // 1/10 padding to center the reduced button
      child: Container(
        height: 33.6, // 42 * 0.8 = reduced by 1/10 from all sides
        padding: EdgeInsets.symmetric(horizontal: 6.4, vertical: 3.2), // 80% of original padding
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8), // More button-like rounded corners
          border: Border.all(color: color, width: 2), // Thicker border for button style
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ], // Subtle shadow for button effect
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (timeText != null) ...[
                    Text(
                      mainText,
                      style: TextStyle(
                        fontSize: 11.7, // 13 * 0.9 = slightly smaller for button style
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 5.4), // 6 * 0.9
                    // Small dot separator
                    Container(
                      width: 2.7, // 3 * 0.9
                      height: 2.7, // 3 * 0.9
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 5.4), // 6 * 0.9
                    Text(
                      timeText,
                      style: TextStyle(
                        fontSize: 11.7, // 13 * 0.9 = slightly smaller for button style
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else
                    Text(
                      mainText,
                      style: TextStyle(
                        fontSize: 11.7, // 13 * 0.9 = slightly smaller for button style
                        color: color,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDepartureTimePicker() async {
    isEditingArrival = false;
    await showModalBottomSheet(
      context: context,
      builder: (context) => _buildTimePicker(
        'Pick-up Time',
        Color(0xFF00C853),
        Icons.location_on,
        _findEarliestValidDepartureTime(selectedDate),
        (tempPickedDate) {
          setState(() {
            hasUserSelectedDateTime = true;
            selectedDate = tempPickedDate;
            _validateAndAdjustTime();
            arrivalTime = calculateArrivalTime(
              selectedDate,
              widget.selectedRoute,
              widget.originIndex,
              widget.destinationIndex,
            );
          });
          // Schedule callback after build is complete
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _notifyTimesChanged();
          });
          widget.onDateTimeSelected(true);
        },
      ),
    );
  }

  Future<void> _showArrivalTimePicker() async {
    isEditingArrival = true;
    await showModalBottomSheet(
      context: context,
      builder: (context) => _buildTimePicker(
        'Drop-off Time',
        Color(0xFFDD2C00),
        Icons.flag,
        _findEarliestValidArrivalTime(arrivalTime),
        (tempPickedDate) {
          if (kDebugMode) {
            debugPrint(
              'Arrival time Done pressed: setting arrivalTime=$tempPickedDate',
            );
          }
          setState(() {
            hasUserSelectedDateTime = true;
            arrivalTime = tempPickedDate;
            selectedDate = calculateDepartureTime(
              tempPickedDate,
              widget.selectedRoute,
              widget.originIndex,
              widget.destinationIndex,
            );
            if (kDebugMode) {
              debugPrint('Calculated departure time: $selectedDate');
            }
            _validateAndAdjustTime();
          });
          // Schedule callback after build is complete
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _notifyTimesChanged();
          });
          widget.onDateTimeSelected(true);
        },
      ),
    );
    isEditingArrival = false;
  }

  Widget _buildTimePicker(
    String title,
    Color color,
    IconData icon,
    DateTime initialTime,
    Function(DateTime) onDone,
  ) {
    DateTime tempPickedDate = initialTime;

    final hourController = FixedExtentScrollController(
      initialItem: tempPickedDate.hour,
    );
    final minuteController = FixedExtentScrollController(
      initialItem: (tempPickedDate.minute / 5).round(),
    );

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              // Header
              Container(
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  border: Border(bottom: BorderSide(color: color, width: 2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: TextStyle(color: color)),
                    ),
                    Row(
                      children: [
                        Icon(icon, color: color, size: 20),
                        SizedBox(width: 8),
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        onDone(tempPickedDate);
                        Navigator.pop(context);
                      },
                      child: Text('Done', style: TextStyle(color: color)),
                    ),
                  ],
                ),
              ),

              // Time picker wheels
              Expanded(
                child: Row(
                  children: [
                    // Day wheel
                    Expanded(
                      flex: 2,
                      child: _buildDayWheel(color, (index) {
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
                      }),
                    ),

                    // Hour wheel
                    Expanded(
                      flex: 1,
                      child: _buildHourWheel(
                        color,
                        tempPickedDate,
                        hourController,
                        minuteController,
                        (validTime) {
                          setModalState(() {
                            tempPickedDate = validTime;
                          });
                        },
                      ),
                    ),

                    // Minute wheel
                    Expanded(
                      flex: 1,
                      child: _buildMinuteWheel(
                        color,
                        tempPickedDate,
                        hourController,
                        minuteController,
                        (validTime) {
                          setModalState(() {
                            tempPickedDate = validTime;
                          });
                        },
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
  }

  Widget _buildDayWheel(Color color, Function(int) onChanged) {
    return ListWheelScrollView(
      itemExtent: 50,
      diameterRatio: 1.2,
      magnification: 1.3,
      useMagnifier: true,
      squeeze: 0.8,
      physics: FixedExtentScrollPhysics(),
      controller: FixedExtentScrollController(initialItem: 0),
      onSelectedItemChanged: onChanged,
      children: List.generate(5, (index) {
        final date = DateTime.now().add(Duration(days: index));
        String label;
        final day = date.day.toString().padLeft(2, '0');
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
              color: color,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHourWheel(
    Color color,
    DateTime tempPickedDate,
    FixedExtentScrollController hourController,
    FixedExtentScrollController minuteController,
    Function(DateTime) onValidTimeChanged,
  ) {
    return ListWheelScrollView(
      itemExtent: 50,
      diameterRatio: 1.2,
      magnification: 1.3,
      useMagnifier: true,
      squeeze: 0.8,
      physics: FixedExtentScrollPhysics(),
      controller: hourController,
      onSelectedItemChanged: (index) {
        final testTime = DateTime(
          tempPickedDate.year,
          tempPickedDate.month,
          tempPickedDate.day,
          index,
          tempPickedDate.minute,
        );

        DateTime validTime;
        if (isEditingArrival
            ? _isValidArrivalTime(testTime)
            : _isValidDepartureTime(testTime)) {
          validTime = testTime;
        } else {
          validTime = isEditingArrival
              ? _findEarliestValidArrivalTime(
                  DateTime(
                    tempPickedDate.year,
                    tempPickedDate.month,
                    tempPickedDate.day,
                  ),
                )
              : _findEarliestValidDepartureTime(
                  DateTime(
                    tempPickedDate.year,
                    tempPickedDate.month,
                    tempPickedDate.day,
                  ),
                );

          Future.delayed(Duration(milliseconds: 100), () {
            hourController.animateToItem(
              validTime.hour,
              duration: Duration(milliseconds: 400),
              curve: Curves.elasticOut,
            );
          });
        }

        onValidTimeChanged(validTime);
      },
      children: List.generate(24, (index) {
        final testTime = DateTime(
          tempPickedDate.year,
          tempPickedDate.month,
          tempPickedDate.day,
          index,
          tempPickedDate.minute,
        );

        final isValid = isEditingArrival
            ? _isValidArrivalTime(testTime)
            : _isValidDepartureTime(testTime);

        return Center(
          child: Text(
            index.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isValid ? color : Colors.grey[300],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMinuteWheel(
    Color color,
    DateTime tempPickedDate,
    FixedExtentScrollController hourController,
    FixedExtentScrollController minuteController,
    Function(DateTime) onValidTimeChanged,
  ) {
    return ListWheelScrollView(
      itemExtent: 50,
      diameterRatio: 1.2,
      magnification: 1.3,
      useMagnifier: true,
      squeeze: 0.8,
      physics: FixedExtentScrollPhysics(),
      controller: minuteController,
      onSelectedItemChanged: (index) {
        final minuteValue = index * 5;
        final testTime = DateTime(
          tempPickedDate.year,
          tempPickedDate.month,
          tempPickedDate.day,
          tempPickedDate.hour,
          minuteValue,
        );

        DateTime validTime;
        if (isEditingArrival
            ? _isValidArrivalTime(testTime)
            : _isValidDepartureTime(testTime)) {
          validTime = testTime;
        } else {
          validTime = isEditingArrival
              ? _findEarliestValidArrivalTime(
                  DateTime(
                    tempPickedDate.year,
                    tempPickedDate.month,
                    tempPickedDate.day,
                    tempPickedDate.hour,
                  ),
                )
              : _findEarliestValidDepartureTime(
                  DateTime(
                    tempPickedDate.year,
                    tempPickedDate.month,
                    tempPickedDate.day,
                    tempPickedDate.hour,
                  ),
                );

          Future.delayed(Duration(milliseconds: 150), () {
            minuteController.animateToItem(
              (validTime.minute / 5).round(),
              duration: Duration(milliseconds: 400),
              curve: Curves.elasticOut,
            );
          });

          if (validTime.hour != tempPickedDate.hour) {
            Future.delayed(Duration(milliseconds: 100), () {
              hourController.animateToItem(
                validTime.hour,
                duration: Duration(milliseconds: 400),
                curve: Curves.elasticOut,
              );
            });
          }
        }

        onValidTimeChanged(validTime);
      },
      children: List.generate(12, (index) {
        final minuteValue = index * 5;
        final testTime = DateTime(
          tempPickedDate.year,
          tempPickedDate.month,
          tempPickedDate.day,
          tempPickedDate.hour,
          minuteValue,
        );

        final isValid = isEditingArrival
            ? _isValidArrivalTime(testTime)
            : _isValidDepartureTime(testTime);

        return Center(
          child: Text(
            minuteValue.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isValid ? color : Colors.grey[300],
            ),
          ),
        );
      }),
    );
  }

  // Validation and helper methods
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

  void _recalculateArrivalTime() {
    if (widget.destinationIndex != null) {
      if (kDebugMode) {
        debugPrint(
          'Recalculating arrival time: origin=${widget.originIndex}, dest=${widget.destinationIndex}',
        );
      }
      setState(() {
        arrivalTime = calculateArrivalTime(
          selectedDate,
          widget.selectedRoute,
          widget.originIndex,
          widget.destinationIndex,
        );
      });
      // Schedule callback after build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _notifyTimesChanged();
      });
    }
  }

  void _notifyTimesChanged() {
    if (widget.onTimesChanged != null) {
      widget.onTimesChanged!(selectedDate, arrivalTime);
    }
  }

  bool _isValidDepartureTime(DateTime departureTime) {
    final earliestValidTime = DateTime.now().add(Duration(minutes: 5));
    if (departureTime.isBefore(earliestValidTime)) {
      return false;
    }

    if (widget.destinationIndex != null) {
      final calculatedArrivalTime = calculateArrivalTime(
        departureTime,
        widget.selectedRoute,
        widget.originIndex,
        widget.destinationIndex,
      );
      return calculatedArrivalTime.isAfter(departureTime);
    }

    return true;
  }

  DateTime _findEarliestValidDepartureTime(DateTime date) {
    final now = DateTime.now();
    int startHour = 0;
    int startMinute = 0;

    if (isTodayDate(date)) {
      startHour = now.hour;
      startMinute = ((now.minute / 5).ceil() * 5);
      if (startMinute >= 60) {
        startHour += 1;
        startMinute = 0;
      }
    }

    for (int hour = startHour; hour < 24; hour++) {
      int minuteStart = (hour == startHour) ? startMinute : 0;
      for (int minute = minuteStart; minute < 60; minute += 5) {
        final testTime = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );
        if (_isValidDepartureTime(testTime)) {
          return testTime;
        }
      }
    }

    final tomorrow = date.add(Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 0, 0);
  }

  bool _isValidArrivalTime(DateTime arrivalTime) {
    if (widget.destinationIndex == null) return true;

    final calculatedDepartureTime = calculateDepartureTime(
      arrivalTime,
      widget.selectedRoute,
      widget.originIndex,
      widget.destinationIndex,
    );

    final earliestValidTime = DateTime.now().add(Duration(minutes: 5));
    return calculatedDepartureTime.isAfter(earliestValidTime);
  }

  DateTime _findEarliestValidArrivalTime(DateTime date) {
    if (widget.destinationIndex == null) return date;

    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 5) {
        final testTime = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );
        if (_isValidArrivalTime(testTime)) {
          return testTime;
        }
      }
    }

    final tomorrow = date.add(Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 0, 0);
  }
}
