import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return Column(
      children: [
        // Routes List - in separate transparent boxes
        Column(
          children: predefinedRoutes.asMap().entries.map((entry) {
            RouteInfo route = entry.value;
            bool isSelected = selectedRoute == route;

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: isDisabled ? null : () {
                  // Toggle: unselect if already selected, select if not
                  if (isSelected) {
                    onRouteChanged(null);
                  } else {
                    onRouteChanged(route);
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: isSelected ? Colors.green : Color(0xFFE0E0E0), width: isSelected ? 2 : 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Route name
                      Text(
                        _getFormattedRouteName(route.name),
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? Colors.green : Color(0xFF2E2E2E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Duration and Distance
                      Row(
                        children: [
                          // Duration
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 16, color: Color(0xFF8E8E8E)),
                              SizedBox(width: 4),
                              Text(
                                route.duration,
                                style: TextStyle(fontSize: 14, color: Color(0xFF8E8E8E), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          SizedBox(width: 16),
                          // Distance
                          Row(
                            children: [
                              Icon(Icons.straighten, size: 16, color: Color(0xFF8E8E8E)),
                              SizedBox(width: 4),
                              Text(
                                route.distance,
                                style: TextStyle(fontSize: 14, color: Color(0xFF8E8E8E), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // Suggestion link for new route
        Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _launchURL('https://forms.gle/yourformlink'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.add_circle_outline, size: 16, color: Colors.blue[700]),
                SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.suggestRoute,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[700],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Show selected route details if needed
        if (selectedRoute != null && hasSelectedDateTime)
          Padding(padding: const EdgeInsets.only(top: 16.0), child: _buildRouteDetailsLayout()),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
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

  Widget _buildRouteDetailsLayout() {
    if (selectedRoute == null) return Container();

    // Determine if selections are complete
    bool selectionsComplete = hasSelectedDateTime && originIndex != null && destinationIndex != null;

    // Show departure and arrival times if they exist
    if (departureTime != null && arrivalTime != null) {
      String departureTimeStr = _formatTime(departureTime!);
      String arrivalTimeStr = _formatTime(arrivalTime!);

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selectionsComplete ? Color(0xFF2E2E2E).withOpacity(0.1) : Colors.white.withOpacity(0.1),
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
                    color: (selectionsComplete ? Color(0xFF2E2E2E) : Colors.white).withOpacity(0.7),
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
              color: (selectionsComplete ? Color(0xFF2E2E2E) : Colors.white).withOpacity(0.7),
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
                    color: (selectionsComplete ? Color(0xFF2E2E2E) : Colors.white).withOpacity(0.7),
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
}
