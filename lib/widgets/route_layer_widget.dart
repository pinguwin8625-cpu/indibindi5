import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../widgets/route_selection_widget.dart';
import '../widgets/scroll_indicator.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../screens/personal_information_screen.dart';
import '../utils/dialog_helper.dart';

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

  Future<void> _showIncompleteProfileDialog() async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await DialogHelper.showConfirmDialog(
      context: context,
      title: 'Incomplete Profile',
      content: 'Please complete your personal information (name, surname, email, phone number) before booking a ride.',
      cancelText: l10n.cancel,
      confirmText: 'Complete Profile',
    );
    
    if (confirmed) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PersonalInformationScreen(),
        ),
      );
    }
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
