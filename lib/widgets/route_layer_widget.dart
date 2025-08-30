import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../widgets/route_selection_widget.dart';

class RouteLayerWidget extends StatelessWidget {
  final String userRole;
  final RouteInfo? selectedRoute;
  final bool isBookingCompleted;
  final Function(RouteInfo) onRouteSelected;

  const RouteLayerWidget({
    super.key,
    required this.userRole,
    required this.selectedRoute,
    required this.isBookingCompleted,
    required this.onRouteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Choose Your Route',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 16),
            
            // Description
            Text(
              'Select which route you\'d like to travel on today.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 32),

            // Route Selection
            RouteSelectionWidget(
              selectedRoute: selectedRoute,
              originIndex: null,
              destinationIndex: null,
              hasSelectedDateTime: false,
              departureTime: null,
              arrivalTime: null,
              isDisabled: isBookingCompleted,
              onRouteChanged: (route) {
                if (route != null && !isBookingCompleted) {
                  onRouteSelected(route);
                }
              },
            ),

            SizedBox(height: 32),

            // Instructions
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF2E2E2E).withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFF2E2E2E), width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.white70,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Once you pick a route, we\'ll help you choose your stops and complete your booking.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                        height: 1.4,
                      ),
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
}
