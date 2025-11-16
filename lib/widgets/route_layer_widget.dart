import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../widgets/route_selection_widget.dart';
import '../widgets/scroll_indicator.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../screens/personal_information_screen.dart';

class RouteLayerWidget extends StatefulWidget {
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
  State<RouteLayerWidget> createState() => _RouteLayerWidgetState();
}

class _RouteLayerWidgetState extends State<RouteLayerWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleRouteSelection(RouteInfo route) {
    final currentUser = AuthService.currentUser;
    
    if (currentUser == null) {
      return;
    }

    // Check if personal information is complete
    if (!currentUser.hasCompletePersonalInfo) {
      _showIncompleteProfileDialog();
      return;
    }

    // If complete, proceed with route selection
    if (!widget.isBookingCompleted) {
      widget.onRouteSelected(route);
    }
  }

  void _showIncompleteProfileDialog() {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Incomplete Profile'),
          content: Text('Please complete your personal information (name, surname, email, phone number) before booking a ride.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonalInformationScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFDD2C00),
              ),
              child: Text('Complete Profile', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ScrollIndicator(
      scrollController: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              l10n.chooseYourRoute,
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
              selectedRoute: widget.selectedRoute,
              originIndex: null,
              destinationIndex: null,
              hasSelectedDateTime: false,
              departureTime: null,
              arrivalTime: null,
              isDisabled: widget.isBookingCompleted,
              onRouteChanged: (route) {
                if (route != null) {
                  _handleRouteSelection(route);
                }
              },
            ),

          ],
        ),
      ),
      ),
    );
  }
}
