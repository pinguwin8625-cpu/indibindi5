import 'package:flutter/material.dart';
import '../models/routes.dart';

class RouteSelectionWidget extends StatelessWidget {
  final RouteInfo? selectedRoute;
  final Function(RouteInfo?) onRouteChanged;

  const RouteSelectionWidget({
    super.key,
    required this.selectedRoute,
    required this.onRouteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 8,
            left: 16,
            right: 16,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Color(0xFF2E2E2E), // Keep dark color always
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DropdownButton<RouteInfo>(
                  value: selectedRoute,
                  isExpanded: true,
                  underline: Container(), // Remove the default underline border
                  dropdownColor: Color(0xFF2E2E2E), // Dark grey background for dropdown items
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFFFFFFFF), // Always white icon
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
                          return predefinedRoutes.map<Widget>((RouteInfo route) {
                            return Center(
                              child: Text(
                                _getFormattedRouteName(route.name),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFFFFFFFF), // Always white text
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList();
                        }
                      : null,
                  items: predefinedRoutes.map((route) {
                    return DropdownMenuItem<RouteInfo>(
                      value: route,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Route name with integrated direction
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    _getFormattedRouteName(route.name),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFFFFFFFF), // White text
                                    ),
                                    textAlign: TextAlign.center,
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
                  onChanged: onRouteChanged,
                ),
                if (selectedRoute != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      '${selectedRoute!.distance} • ${selectedRoute!.duration}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFCCCCCC),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
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
}
