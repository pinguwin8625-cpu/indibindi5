import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../utils/date_time_helpers.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';

class TimeSelectionWidget extends StatefulWidget {
  final RouteInfo selectedRoute;
  final int originIndex;
  final int? destinationIndex;
  final Function(bool) onDateTimeSelected;
  final Function(DateTime departure, DateTime arrival)? onTimesChanged;
  final Function(String?)? onRiderTimeChoiceChanged; // 'departure' or 'arrival' for riders
  final String userRole; // 'driver' or 'rider'
  final bool hideUnusedStops; // When true, only origin and destination are visible
  final int visibleIntermediateCount; // Number of visible intermediate stops
  final int hiddenIntermediateCount; // Number of hidden intermediate stops (shows expander if > 0)

  const TimeSelectionWidget({
    super.key,
    required this.selectedRoute,
    required this.originIndex,
    this.destinationIndex,
    required this.onDateTimeSelected,
    this.onTimesChanged,
    this.onRiderTimeChoiceChanged,
    required this.userRole,
    this.hideUnusedStops = false,
    this.visibleIntermediateCount = 0,
    this.hiddenIntermediateCount = 0,
  });

  @override
  TimeSelectionWidgetState createState() => TimeSelectionWidgetState();
}

class TimeSelectionWidgetState extends State<TimeSelectionWidget> {
  late DateTime selectedDate; // Used for departure time
  late DateTime arrivalTime; // Store arrival time explicitly
  bool isEditingArrival = false; // Flag to track if we're editing arrival or departure time
  bool hasUserSelectedDateTime = false; // Track if user has explicitly selected date/time
  bool _isAutomaticRecalculation = false; // Track automatic vs user-driven time updates
  String? riderTimeChoice; // For riders: 'departure' or 'arrival' - tracks which time they chose

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
    arrivalTime = calculateArrivalTime(selectedDate, widget.selectedRoute, widget.originIndex, widget.destinationIndex);

    // DON'T notify parent of initial times - only notify when user actually selects a time
    // This prevents overwriting the user's selected date with today's date
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Origin time box - positioned to align with the origin
        // Note: When hideUnusedStops, we're inside a Container with 4px vertical padding
        // so no additional offset needed (container padding handles alignment)
        SizedBox(
          height: widget.hideUnusedStops
              ? 0.0 // Container already has 4px vertical padding
              : widget.originIndex * 42.0,
        ), // Stop positioning only (no title offset)
        // Origin departure time box
        GestureDetector(
          onTap: () => _showDepartureTimePicker(),
          child: _buildTimeBox(
            hasUserSelectedDateTime ? formatRelativeDay(selectedDate, DateTime.now()) : l10n.pickUpTime,
            hasUserSelectedDateTime ? formatTimeHHmm(selectedDate) : null,
            Colors.green, // Green color for pickup
            compact: widget.hideUnusedStops,
            fixedWidth: 115.0, // Fixed width for consistent sizing
          ),
        ),

        // Add space between origin and destination time boxes (only if destination is selected)
        // Space = (visible intermediate stops + expander row if any hidden) * row height
        // When no intermediate stops, add half row height (15px) for proper spacing
        if (widget.destinationIndex != null)
          SizedBox(
            height: widget.hideUnusedStops
                ? (widget.visibleIntermediateCount + (widget.hiddenIntermediateCount > 0 ? 1 : 0)) * 30.0 +
                    (widget.visibleIntermediateCount == 0 && widget.hiddenIntermediateCount == 0 ? 15.0 : 0)
                : (widget.destinationIndex! - widget.originIndex - 1) * 42.0,
          ),

        // Destination arrival time box - only show when destination is selected
        if (widget.destinationIndex != null)
          GestureDetector(
            onTap: () => _showArrivalTimePicker(),
            child: _buildTimeBox(
              (widget.destinationIndex != null && hasUserSelectedDateTime)
                  ? formatRelativeDay(arrivalTime, DateTime.now())
                  : l10n.dropOffTime,
              (widget.destinationIndex != null && hasUserSelectedDateTime) ? formatTimeHHmm(arrivalTime) : null,
              Colors.red, // Red color for drop-off
              compact: widget.hideUnusedStops,
              fixedWidth: 115.0, // Fixed width for consistent sizing
            ),
          ),
      ],
    );
  }

  Widget _buildTimeBox(
    String mainText,
    String? timeText,
    Color color, {
    bool compact = false,
    double? fixedWidth,
  }) {
    final double boxHeight = compact ? 30.0 : 42.0;
    final double fontSize = 12.0; // Same size for both compact and normal
    final double iconSize = 20.0; // Same size for both compact and normal

    return Container(
      height: boxHeight,
      width: fixedWidth,
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: compact ? 2.0 : 4.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(6.0),
        color: color.withValues(alpha: 0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: fixedWidth != null ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.schedule, color: color, size: iconSize),
          SizedBox(width: compact ? 4.0 : 8.0),
          timeText != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mainText,
                      style: TextStyle(fontSize: fontSize, color: color, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: compact ? 3.0 : 5.0),
                    Text(
                      timeText,
                      style: TextStyle(fontSize: fontSize, color: color, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              : Text(
                  mainText,
                  style: TextStyle(fontSize: fontSize, color: color, fontWeight: FontWeight.normal),
                ),
        ],
      ),
    );
  }

  Future<void> _showDepartureTimePicker() async {
    isEditingArrival = false;
    print('🚀 Opening departure time picker...');
    print('   Current selectedDate: $selectedDate');
    print('   User role: ${widget.userRole}');
    final earliestTime = _findEarliestValidDepartureTime(selectedDate);
    print('   Earliest valid time: $earliestTime');
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet(
      context: context,
      builder: (context) =>
          _buildTimePicker(l10n.pickUpTime, Colors.green, Icons.location_on, earliestTime, (tempPickedDate) {
            setState(() {
              hasUserSelectedDateTime = true;
              selectedDate = tempPickedDate;
              _validateAndAdjustTime();

              // Auto-calculate arrival time ONLY for drivers
              if (widget.userRole.toLowerCase() == 'driver') {
                arrivalTime = calculateArrivalTime(
                  selectedDate,
                  widget.selectedRoute,
                  widget.originIndex,
                  widget.destinationIndex,
                );
                print('🚗 Driver: Auto-calculated arrival time: $arrivalTime');
              } else {
                // For riders: mark that they chose departure time
                riderTimeChoice = 'departure';
                arrivalTime = selectedDate; // Set to same as departure to avoid null issues
                print('🧑 Rider: Chose DEPARTURE time, riderTimeChoice=$riderTimeChoice');
                widget.onRiderTimeChoiceChanged?.call(riderTimeChoice);
              }
            });

            // IMPORTANT: Notify parent of new times FIRST before calling onDateTimeSelected
            // This ensures the parent has the correct times before triggering navigation
            _notifyTimesChanged();

            // Only call onDateTimeSelected when user actually picks time AND both stops are selected
            // AND we're not in the middle of automatic recalculation
            if (widget.destinationIndex != null && !_isAutomaticRecalculation) {
              // User actually picked departure time
              widget.onDateTimeSelected(true);
              print('🕐 Time picker: User selected departure time, calling onDateTimeSelected(true)');
            } else if (_isAutomaticRecalculation) {
              print('🕐 Time picker: Automatic recalculation, NOT calling onDateTimeSelected');
            }
          }, l10n),
    );
  }

  Future<void> _showArrivalTimePicker() async {
    isEditingArrival = true;
    print('🚀 Opening arrival time picker...');
    print('   User role: ${widget.userRole}');
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet(
      context: context,
      builder: (context) => _buildTimePicker(
        l10n.dropOffTime,
        Colors.red,
        Icons.flag,
        _findEarliestValidArrivalTime(arrivalTime),
        (tempPickedDate) {
          if (kDebugMode) {
            debugPrint('Arrival time Done pressed: setting arrivalTime=$tempPickedDate');
          }
          setState(() {
            hasUserSelectedDateTime = true;
            arrivalTime = tempPickedDate;

            // Auto-calculate departure time ONLY for drivers
            if (widget.userRole.toLowerCase() == 'driver') {
              selectedDate = calculateDepartureTime(
                tempPickedDate,
                widget.selectedRoute,
                widget.originIndex,
                widget.destinationIndex,
              );
              if (kDebugMode) {
                debugPrint('🚗 Driver: Calculated departure time: $selectedDate');
              }
            } else {
              // For riders: mark that they chose arrival time
              riderTimeChoice = 'arrival';
              selectedDate = tempPickedDate; // Set to same as arrival to avoid null issues
              print('🧑 Rider: Chose ARRIVAL time, riderTimeChoice=$riderTimeChoice');
              widget.onRiderTimeChoiceChanged?.call(riderTimeChoice);
            }
            _validateAndAdjustTime();
          });

          // IMPORTANT: Notify parent of new times FIRST before calling onDateTimeSelected
          // This ensures the parent has the correct times before triggering navigation
          _notifyTimesChanged();

          // Only call onDateTimeSelected when user actually picks time AND both stops are selected
          // AND we're not in the middle of automatic recalculation
          if (widget.destinationIndex != null && !_isAutomaticRecalculation) {
            // User actually picked arrival time
            widget.onDateTimeSelected(true);
            print('🕐 Time picker: User selected arrival time, calling onDateTimeSelected(true)');
          } else if (_isAutomaticRecalculation) {
            print('🕐 Time picker: Automatic recalculation, NOT calling onDateTimeSelected');
          }
        },
        l10n,
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
    AppLocalizations l10n,
  ) {
    print('🎯 TimePicker: _buildTimePicker called with initialTime: $initialTime');
    print('   initialTime date: ${initialTime.day}/${initialTime.month}/${initialTime.year}');

    DateTime tempPickedDate = initialTime;

    // Calculate the day index (0 = today, 1 = tomorrow, etc.)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(initialTime.year, initialTime.month, initialTime.day);
    final dayIndex = targetDay.difference(today).inDays;

    print('   Calculated dayIndex: $dayIndex');

    final dayController = FixedExtentScrollController(initialItem: dayIndex >= 0 && dayIndex < 5 ? dayIndex : 0);
    final hourController = FixedExtentScrollController(initialItem: tempPickedDate.hour);
    final minuteController = FixedExtentScrollController(initialItem: (tempPickedDate.minute / 5).round());

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
                      child: Text(l10n.cancel, style: TextStyle(color: color)),
                    ),
                    Row(
                      children: [
                        Icon(icon, color: color, size: 20),
                        SizedBox(width: 8),
                        Text(
                          title,
                          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        print('⏰ TimePicker: Done pressed with tempPickedDate: $tempPickedDate');
                        print('   Date: ${tempPickedDate.day}/${tempPickedDate.month}/${tempPickedDate.year}');
                        print('   Time: ${tempPickedDate.hour}:${tempPickedDate.minute}');
                        onDone(tempPickedDate);
                        Navigator.pop(context);
                      },
                      child: Text(l10n.done, style: TextStyle(color: color)),
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
                      child: _buildDayWheel(color, dayController, (index) {
                        print('📅 TimePicker: Day wheel changed to index $index');
                        setModalState(() {
                          final date = DateTime.now().add(Duration(days: index));
                          print('   Calculated date: ${date.day}/${date.month}/${date.year}');
                          tempPickedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            tempPickedDate.hour,
                            tempPickedDate.minute,
                          );
                          print('   Updated tempPickedDate: $tempPickedDate');
                        });
                      }, l10n),
                    ),

                    // Hour wheel
                    Expanded(
                      flex: 1,
                      child: _buildHourWheel(color, tempPickedDate, hourController, minuteController, (validTime) {
                        setModalState(() {
                          tempPickedDate = validTime;
                        });
                      }),
                    ),

                    // Minute wheel
                    Expanded(
                      flex: 1,
                      child: _buildMinuteWheel(color, tempPickedDate, hourController, minuteController, (validTime) {
                        setModalState(() {
                          tempPickedDate = validTime;
                        });
                      }),
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

  Widget _buildDayWheel(
    Color color,
    FixedExtentScrollController controller,
    Function(int) onChanged,
    AppLocalizations l10n,
  ) {
    return ListWheelScrollView(
      itemExtent: 50,
      diameterRatio: 1.2,
      magnification: 1.3,
      useMagnifier: true,
      squeeze: 0.8,
      physics: FixedExtentScrollPhysics(),
      controller: controller,
      onSelectedItemChanged: onChanged,
      children: List.generate(5, (index) {
        final date = DateTime.now().add(Duration(days: index));
        String label;
        final day = date.day.toString().padLeft(2, '0');
        final month = [
          l10n.jan,
          l10n.feb,
          l10n.mar,
          l10n.apr,
          l10n.may,
          l10n.jun,
          l10n.jul,
          l10n.aug,
          l10n.sep,
          l10n.oct,
          l10n.nov,
          l10n.dec,
        ][date.month - 1];
        final weekday = [l10n.mon, l10n.tue, l10n.wed, l10n.thu, l10n.fri, l10n.sat, l10n.sun][date.weekday - 1];

        if (index == 0) {
          label = l10n.today;
        } else if (index == 1) {
          label = l10n.tomorrow;
        } else {
          label = '$day $month $weekday';
        }

        return Center(
          child: Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color),
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
    // Pre-calculate validity for all hours to avoid expensive recalculations during scroll
    final validHours = <int, bool>{};

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
        if (isEditingArrival ? _isValidArrivalTime(testTime) : _isValidDepartureTime(testTime)) {
          validTime = testTime;
        } else {
          validTime = isEditingArrival
              ? _findEarliestValidArrivalTime(DateTime(tempPickedDate.year, tempPickedDate.month, tempPickedDate.day))
              : _findEarliestValidDepartureTime(
                  DateTime(tempPickedDate.year, tempPickedDate.month, tempPickedDate.day),
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
        // Only validate if not already cached
        if (!validHours.containsKey(index)) {
          final testTime = DateTime(
            tempPickedDate.year,
            tempPickedDate.month,
            tempPickedDate.day,
            index,
            tempPickedDate.minute,
          );
          validHours[index] = isEditingArrival ? _isValidArrivalTime(testTime) : _isValidDepartureTime(testTime);
        }

        return Center(
          child: Text(
            index.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: validHours[index]! ? color : Colors.grey[300],
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
    // Pre-calculate validity for all minutes to avoid expensive recalculations during scroll
    final validMinutes = <int, bool>{};

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
        if (isEditingArrival ? _isValidArrivalTime(testTime) : _isValidDepartureTime(testTime)) {
          validTime = testTime;
        } else {
          validTime = isEditingArrival
              ? _findEarliestValidArrivalTime(
                  DateTime(tempPickedDate.year, tempPickedDate.month, tempPickedDate.day, tempPickedDate.hour),
                )
              : _findEarliestValidDepartureTime(
                  DateTime(tempPickedDate.year, tempPickedDate.month, tempPickedDate.day, tempPickedDate.hour),
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

        // Only validate if not already cached
        if (!validMinutes.containsKey(index)) {
          final testTime = DateTime(
            tempPickedDate.year,
            tempPickedDate.month,
            tempPickedDate.day,
            tempPickedDate.hour,
            minuteValue,
          );
          validMinutes[index] = isEditingArrival ? _isValidArrivalTime(testTime) : _isValidDepartureTime(testTime);
        }

        return Center(
          child: Text(
            minuteValue.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: validMinutes[index]! ? color : Colors.grey[300],
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
    // Only auto-recalculate for drivers
    if (widget.userRole.toLowerCase() != 'driver') {
      print('🧑 Rider: Skipping auto-recalculation of arrival time');
      return;
    }

    if (widget.destinationIndex != null) {
      if (kDebugMode) {
        debugPrint('Recalculating arrival time: origin=${widget.originIndex}, dest=${widget.destinationIndex}');
      }
      _isAutomaticRecalculation = true; // Mark that this is automatic
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
        _isAutomaticRecalculation = false; // Done with automatic update

        // If user had already selected time before destination was set, notify parent
        if (hasUserSelectedDateTime) {
          widget.onDateTimeSelected(true);
          print('🕐 Time picker: Destination set after time selection, calling onDateTimeSelected(true)');
        }
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
        final testTime = DateTime(date.year, date.month, date.day, hour, minute);
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
        final testTime = DateTime(date.year, date.month, date.day, hour, minute);
        if (_isValidArrivalTime(testTime)) {
          return testTime;
        }
      }
    }

    final tomorrow = date.add(Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 0, 0);
  }
}
