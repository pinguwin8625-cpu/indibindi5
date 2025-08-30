import 'package:flutter/material.dart';
import '../models/routes.dart';

class RouteSelectionWidget extends StatelessWidget {
  final RouteInfo? selectedRoute;
  final Function(RouteInfo?) onRouteChanged;
  final int? originIndex;
  final int? destinationIndex;
  final bool hasSelectedDateTime;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final bool isDisabled;

  const RouteSelectionWidget({
    super.key,
    required this.selectedRoute,
    required this.onRouteChanged,
    this.originIndex,
    this.destinationIndex,
    this.hasSelectedDateTime = false,
    this.departureTime,
    this.arrivalTime,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if selections are complete
    bool selectionsComplete =
        hasSelectedDateTime && originIndex != null && destinationIndex != null;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
          ), // Reduced from 40 to 16 for better balance
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: selectionsComplete
                  ? Theme.of(context)
                        .scaffoldBackgroundColor // Match background when complete (Phase 3)
                  : Color(0xFF2E2E2E), // Dark color for Phase 1 and Phase 2
              borderRadius: BorderRadius.circular(8),
              border: selectionsComplete
                  ? Border.all(
                      color: Color(0xFF2E2E2E),
                      width: 2,
                    ) // Dark border when complete (Phase 3)
                  : null, // No border for Phase 1 and Phase 2
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DropdownButton<RouteInfo>(
                  value: selectedRoute,
                  isExpanded: true,
                  underline: Container(), // Remove the default underline border
                  dropdownColor: Color(
                    0xFF2E2E2E,
                  ), // Dark grey background for dropdown items
                  borderRadius: BorderRadius.circular(
                    12,
                  ), // Curved corners for dropdown menu
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: selectionsComplete
                        ? Color(
                            0xFF2E2E2E,
                          ) // Dark background color when complete
                        : Color(0xFFFFFFFF), // White arrow during selection
                  ),
                  hint: Center(
                    child: Text(
                      'Routes',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFFFFFFF), // White text for hint
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  selectedItemBuilder: selectedRoute != null
                      ? (BuildContext context) {
                          return predefinedRoutes.map<Widget>((
                            RouteInfo route,
                          ) {
                            return Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 300),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: _buildColoredDisplayText(route),
                                ),
                              ),
                            );
                          }).toList();
                        }
                      : null,
                  items: predefinedRoutes.map((route) {
                    return DropdownMenuItem<RouteInfo>(
                      value: route,
                      child: Container(
                        height: 42.0,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Route name
                            Expanded(
                              child: Text(
                                _getFormattedRouteName(route.name),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFFFFFFF), // White text
                                  fontWeight: FontWeight.normal,
                                ),
                                textAlign: TextAlign.left,
                                maxLines: 2,
                                overflow: TextOverflow.visible,
                                softWrap: true,
                              ),
                            ),
                            SizedBox(width: 8),
                            // Route details (distance and duration)
                            Text(
                              _getDropdownRouteDetails(route),
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFCCCCCC), // Slightly dimmed
                                fontWeight: FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: isDisabled ? null : onRouteChanged,
                ),
                if (selectedRoute != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 1.0),
                    child: _buildRouteDetailsLayout(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to build colored display text for selected item
  Widget _buildColoredDisplayText(RouteInfo route) {
    // Determine if we're in Phase 3 (selections complete)
    bool selectionsComplete =
        hasSelectedDateTime && originIndex != null && destinationIndex != null;

    // If stops are selected, show colored stop names
    if (originIndex != null &&
        destinationIndex != null &&
        originIndex! < route.stops.length &&
        destinationIndex! < route.stops.length) {
      String originStop = route.stops[originIndex!].name;
      String destinationStop = route.stops[destinationIndex!].name;

      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: originStop,
              style: TextStyle(
                fontSize: 16,
                color: selectionsComplete
                    ? Color(
                        0xFF2E2E2E,
                      ) // Dark text for Phase 3 (on light background)
                    : Color(
                        0xFFFFFFFF,
                      ), // White text for Phase 2 (on dark background)
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: ' → ',
              style: TextStyle(
                fontSize: 16,
                color: selectionsComplete
                    ? Color(0xFF2E2E2E) // Dark text for Phase 3
                    : Color(0xFFFFFFFF), // White text for Phase 2
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: destinationStop,
              style: TextStyle(
                fontSize: 16,
                color: selectionsComplete
                    ? Color(0xFF2E2E2E) // Dark text for Phase 3
                    : Color(0xFFFFFFFF), // White text for Phase 2
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Otherwise show formatted route name
    return Text(
      _getFormattedRouteName(route.name),
      style: TextStyle(
        fontSize: 16,
        color: selectionsComplete
            ? Color(0xFF2E2E2E) // Dark text for Phase 3 (on light background)
            : Color(0xFFFFFFFF), // White text for Phase 1 (on dark background)
        fontWeight: FontWeight.bold,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
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

  // Helper method to build the route details layout with proper alignment
  Widget _buildRouteDetailsLayout() {
    if (selectedRoute == null) return Container();

    // If stops are selected and times are available, show aligned layout
    if (originIndex != null &&
        destinationIndex != null &&
        hasSelectedDateTime &&
        departureTime != null &&
        arrivalTime != null &&
        originIndex! < selectedRoute!.stops.length &&
        destinationIndex! < selectedRoute!.stops.length) {
      return _buildTimeAlignedLayout();
    }

    // Fallback to simple text for other cases
    return Text(
      _getSimpleRouteDetails(),
      style: TextStyle(fontSize: 12, color: Color(0xFFCCCCCC)),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      textAlign: TextAlign.center,
    );
  }

  // Build layout with departure time aligned to departure stop, arrival time to arrival stop
  Widget _buildTimeAlignedLayout() {
    // Add bounds checking
    if (selectedRoute == null ||
        originIndex == null ||
        destinationIndex == null ||
        originIndex! >= selectedRoute!.stops.length ||
        destinationIndex! >= selectedRoute!.stops.length) {
      return Container();
    }

    String distance = selectedRoute!.calculateDistance(
      originIndex!,
      destinationIndex!,
    );
    String duration = selectedRoute!.calculateDuration(
      originIndex!,
      destinationIndex!,
    );
    String depTime = _formatTime(departureTime!);
    String arrTime = _formatTime(arrivalTime!);

    return Column(
      children: [
        // Times row with distance/duration in center
        Row(
          children: [
            // Departure time (left side)
            Expanded(
              child: Text(
                depTime,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF2E2E2E), // Dark color for departure time
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Distance and duration (center, below arrow)
            Text(
              '$distance • $duration',
              style: TextStyle(
                fontSize: 12,
                color: Color(
                  0xFF666666,
                ), // Darker gray for more prominence when locked
              ),
              textAlign: TextAlign.center,
            ),
            // Arrival time (right side)
            Expanded(
              child: Text(
                arrTime,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF2E2E2E), // Dark color for arrival time
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper method to get simple route details for fallback cases
  String _getSimpleRouteDetails() {
    if (selectedRoute == null) return '';

    // If stops are selected but no times, show calculated distance and duration
    if (originIndex != null &&
        destinationIndex != null &&
        originIndex! < selectedRoute!.stops.length &&
        destinationIndex! < selectedRoute!.stops.length) {
      String distance = selectedRoute!.calculateDistance(
        originIndex!,
        destinationIndex!,
      );
      String duration = selectedRoute!.calculateDuration(
        originIndex!,
        destinationIndex!,
      );
      return '$distance • $duration';
    }

    // Default: show full route distance and duration
    return '${selectedRoute!.distance} • ${selectedRoute!.duration}';
  }

  // Helper method to get route details for dropdown items
  String _getDropdownRouteDetails(RouteInfo route) {
    // Always show full route details in dropdown
    return '${route.distance} • ${route.duration}';
  }

  // Helper method to format time in HH:mm format
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
