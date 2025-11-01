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
                color: Colors.black,
                letterSpacing: 0.5,
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

          ],
        ),
      ),
    );
  }
}
