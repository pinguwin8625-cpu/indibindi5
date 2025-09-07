import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../widgets/route_selection_widget.dart';

class RouteSelectionLayerWidget extends StatefulWidget {
  final String userRole;
  final RouteInfo? selectedRoute;
  final bool isBookingCompleted;
  final Function(RouteInfo?) onRouteSelected;

  const RouteSelectionLayerWidget({
    super.key,
    required this.userRole,
    required this.selectedRoute,
    required this.isBookingCompleted,
    required this.onRouteSelected,
  });

  @override
  State<RouteSelectionLayerWidget> createState() => _RouteSelectionLayerWidgetState();
}

class _RouteSelectionLayerWidgetState extends State<RouteSelectionLayerWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Your Route',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E2E2E),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Choose from available routes',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2E2E2E).withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step indicator
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        // Step 1: Route (current)
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Color(0xFF2E2E2E),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '1',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Select Route',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E2E2E),
                          ),
                        ),
                        Spacer(),
                        // Future steps
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '2',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '3',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Route selection
                  RouteSelectionWidget(
                    selectedRoute: widget.selectedRoute,
                    onRouteChanged: widget.onRouteSelected,
                    isDisabled: widget.isBookingCompleted,
                  ),

                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
