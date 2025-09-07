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
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: selectionsComplete
                  ? Theme.of(context).scaffoldBackgroundColor
                  : Color(0xFF2E2E2E),
              borderRadius: BorderRadius.circular(8),
              border: selectionsComplete
                  ? Border.all(
                      color: Color(0xFF2E2E2E),
                      width: 2,
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Routes List
                Column(
                  children: predefinedRoutes.asMap().entries.map((entry) {
                    int index = entry.key;
                    RouteInfo route = entry.value;
                    bool isSelected = selectedRoute == route;
                    
                    return Container(
                      margin: EdgeInsets.only(bottom: index < predefinedRoutes.length - 1 ? 8 : 0),
                      child: GestureDetector(
                        onTap: isDisabled ? null : () => onRouteChanged(route),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? (selectionsComplete ? Color(0xFF2E2E2E).withOpacity(0.1) : Colors.white.withOpacity(0.1))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected 
                                  ? (selectionsComplete ? Color(0xFF2E2E2E) : Colors.white)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Selection indicator
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected 
                                      ? (selectionsComplete ? Color(0xFF2E2E2E) : Colors.white) 
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: selectionsComplete ? Color(0xFF2E2E2E) : Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected 
                                    ? Icon(
                                        Icons.check, 
                                        color: selectionsComplete ? Colors.white : Color(0xFF2E2E2E), 
                                        size: 12
                                      )
                                    : null,
                              ),
                              SizedBox(width: 12),
                              // Route info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getFormattedRouteName(route.name),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        color: selectionsComplete ? Color(0xFF2E2E2E) : Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          route.distance,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: (selectionsComplete ? Color(0xFF2E2E2E) : Colors.white).withOpacity(0.7),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          '•',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: (selectionsComplete ? Color(0xFF2E2E2E) : Colors.white).withOpacity(0.7),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          route.duration,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: (selectionsComplete ? Color(0xFF2E2E2E) : Colors.white).withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Color indicator
                              Container(
                                width: 4,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getRouteColor(route.name),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (selectedRoute != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
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
        textAlign: TextAlign.center,
      );
    }

    // If only route is selected, show route name
    return Text(
      _getFormattedRouteName(route.name),
      style: TextStyle(
        fontSize: 16,
        color: selectionsComplete
            ? Color(0xFF2E2E2E) // Dark text for Phase 3
            : Color(0xFFFFFFFF), // White text for Phase 1 & 2
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRouteDetailsLayout() {
    if (selectedRoute == null) return Container();

    // Determine if selections are complete
    bool selectionsComplete =
        hasSelectedDateTime && originIndex != null && destinationIndex != null;

    // Show departure and arrival times if they exist
    if (departureTime != null && arrivalTime != null) {
      String departureTimeStr = _formatTime(departureTime!);
      String arrivalTimeStr = _formatTime(arrivalTime!);

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selectionsComplete
              ? Color(0xFF2E2E2E).withOpacity(0.1)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Departure info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Departure',
                  style: TextStyle(
                    fontSize: 10,
                    color: (selectionsComplete ? Color(0xFF2E2E2E) : Colors.white)
                        .withOpacity(0.7),
                  ),
                ),
                Text(
                  departureTimeStr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: selectionsComplete ? Color(0xFF2E2E2E) : Colors.white,
                  ),
                ),
              ],
            ),
            // Arrow
            Icon(
              Icons.arrow_forward,
              color: (selectionsComplete ? Color(0xFF2E2E2E) : Colors.white)
                  .withOpacity(0.7),
              size: 16,
            ),
            // Arrival info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Arrival',
                  style: TextStyle(
                    fontSize: 10,
                    color: (selectionsComplete ? Color(0xFF2E2E2E) : Colors.white)
                        .withOpacity(0.7),
                  ),
                ),
                Text(
                  arrivalTimeStr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: selectionsComplete ? Color(0xFF2E2E2E) : Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container();
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getFormattedRouteName(String routeName) {
    // Handle different naming patterns
    if (routeName.contains(' - ')) {
      // For names like "New York - Philadelphia"
      List<String> parts = routeName.split(' - ');
      if (parts.length == 2) {
        return '${parts[0]} → ${parts[1]}';
      }
    }
    
    return routeName;
  }

  String _getDropdownRouteDetails(RouteInfo route) {
    return '${route.distance} • ${route.duration}';
  }

  Color _getRouteColor(String routeName) {
    // Define colors for different routes
    switch (routeName) {
      case 'New York - Philadelphia':
        return Color(0xFF4CAF50); // Green
      case 'Boston - New York':
        return Color(0xFF2196F3); // Blue
      case 'Washington DC - New York':
        return Color(0xFFFF9800); // Orange
      case 'Chicago - Detroit':
        return Color(0xFF9C27B0); // Purple
      case 'Los Angeles - San Francisco':
        return Color(0xFFF44336); // Red
      default:
        return Color(0xFF757575); // Grey
    }
  }
}
