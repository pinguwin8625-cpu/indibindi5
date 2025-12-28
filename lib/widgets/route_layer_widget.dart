import 'package:flutter/material.dart';
import '../models/routes.dart';
import '../widgets/route_selection_widget.dart';
import '../widgets/scroll_indicator.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../screens/personal_information_screen.dart';
import '../screens/vehicle_screen.dart';
import '../utils/dialog_helper.dart';

class RouteLayerWidget extends StatefulWidget {
  final String userRole;
  final RouteInfo? selectedRoute;
  final bool
  isActionCompleted; // Can be either booking completed or ride posted
  final Function(RouteInfo?) onRouteSelected;
  final Function(String)? onRoleSelected;
  final VoidCallback? onBackToRoleSelection;
  final TabController? tabController;
  final bool hasSelectedRole;

  const RouteLayerWidget({
    super.key,
    required this.userRole,
    required this.selectedRoute,
    required this.isActionCompleted,
    required this.onRouteSelected,
    this.onRoleSelected,
    this.onBackToRoleSelection,
    this.tabController,
    this.hasSelectedRole = false,
  });

  @override
  State<RouteLayerWidget> createState() => _RouteLayerWidgetState();
}

class _RouteLayerWidgetState extends State<RouteLayerWidget> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedRole;

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

    // Check requirements based on user role
    if (widget.userRole == 'driver') {
      // Drivers need both personal info AND vehicle info
      if (!currentUser.hasCompletePersonalInfo) {
        _showIncompletePersonalInfoDialog(isDriver: true);
        return;
      }
      if (!currentUser.hasVehicle) {
        _showIncompleteVehicleInfoDialog();
        return;
      }
    } else {
      // Riders only need personal info
      if (!currentUser.hasCompletePersonalInfo) {
        _showIncompletePersonalInfoDialog(isDriver: false);
        return;
      }
    }

    // If complete, proceed with route selection
    if (!widget.isActionCompleted) {
      widget.onRouteSelected(route);
    }
  }

  Future<void> _showIncompletePersonalInfoDialog({required bool isDriver}) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await DialogHelper.showConfirmDialog(
      context: context,
      title: l10n.incompleteProfile,
      content: isDriver
          ? l10n.completePersonalInfoForPosting
          : l10n.completePersonalInfoForBooking,
      cancelText: l10n.cancel,
      confirmText: l10n.completeProfile,
      isCancelDangerous: true,
    );

    if (confirmed) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PersonalInformationScreen()),
      );
    }
  }

  Future<void> _showIncompleteVehicleInfoDialog() async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await DialogHelper.showConfirmDialog(
      context: context,
      title: l10n.incompleteVehicleInfo,
      content: l10n.completeVehicleInfoForPosting,
      cancelText: l10n.cancel,
      confirmText: l10n.addVehicle,
      isCancelDangerous: true,
    );

    if (confirmed) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VehicleScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Role selection screen - no scroll indicator needed
    if (!widget.hasSelectedRole) {
      return Visibility(
        visible: widget.tabController != null && 
                 widget.userRole == (widget.tabController!.index == 0 ? 'driver' : 'rider'),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Question
                Text(
                  l10n.areYouDriverOrRider,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                // Hint below title - three lines
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Column(
                    children: [
                      Text(
                        l10n.hintRoleSelectionLine1,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8E8E8E),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        l10n.hintRoleSelectionOr,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8E8E8E),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        l10n.hintRoleSelectionLine2,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8E8E8E),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 48),
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Driver Button
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          _selectedRole = 'driver';
                        });
                        widget.tabController?.animateTo(0); // Switch to driver tab
                        widget.onRoleSelected?.call('driver');

                        // Check vehicle info after selecting driver role
                        final currentUser = AuthService.currentUser;
                        if (currentUser != null && !currentUser.hasVehicle) {
                          // Small delay to let the UI update first
                          await Future.delayed(Duration(milliseconds: 100));
                          _showIncompleteVehicleInfoDialog();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedRole == 'driver' ? Color(0xFF2E2E2E) : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: _selectedRole == 'driver' ? Color(0xFF2E2E2E) : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Driver icon
                            Icon(
                              Icons.directions_car,
                              color: _selectedRole == 'driver' ? Colors.white : Color(0xFF2E2E2E),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              l10n.driver,
                              style: TextStyle(
                                color: _selectedRole == 'driver' ? Colors.white : Color(0xFF2E2E2E),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    // Rider Button
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          _selectedRole = 'rider';
                        });
                        widget.tabController?.animateTo(1); // Switch to rider tab
                        widget.onRoleSelected?.call('rider');

                        // Check personal info after selecting rider role
                        final currentUser = AuthService.currentUser;
                        if (currentUser != null && !currentUser.hasCompletePersonalInfo) {
                          // Small delay to let the UI update first
                          await Future.delayed(Duration(milliseconds: 100));
                          _showIncompletePersonalInfoDialog(isDriver: false);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedRole == 'rider' ? Color(0xFF2E2E2E) : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: _selectedRole == 'rider' ? Color(0xFF2E2E2E) : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person,
                              color: _selectedRole == 'rider' ? Colors.white : Color(0xFF2E2E2E),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              l10n.rider,
                              style: TextStyle(
                                color: _selectedRole == 'rider' ? Colors.white : Color(0xFF2E2E2E),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              ),
            ),
          ),
        );
    }

    // Route selection screen - with scroll indicator
    return ScrollIndicator(
      scrollController: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary bar with back button (similar to RideDetailsBar)
              Container(
                margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                  color: Colors.grey[50],
                ),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        // Clear the selected route when going back to role selection
                        widget.onRouteSelected(null);
                        widget.onBackToRoleSelection?.call();
                      },
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Color(0xFFDD2C00).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFFDD2C00),
                          size: 16,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    // Role display - centered
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.userRole.toLowerCase() == 'driver'
                                ? Icons.directions_car
                                : Icons.person,
                            color: Color(0xFFDD2C00),
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            widget.userRole.toLowerCase() == 'driver'
                                ? l10n.driver
                                : l10n.rider,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E2E2E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Spacer for symmetry
                    SizedBox(width: 28),
                  ],
                ),
              ),
              // Title with hint
              Padding(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 16),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        l10n.chooseYourRoute,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF42A5F5),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          l10n.hintRouteSelection,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF42A5F5).withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Route Selection
              RouteSelectionWidget(
                selectedRoute: widget.selectedRoute,
                originIndex: null,
                destinationIndex: null,
                hasSelectedDateTime: false,
                departureTime: null,
                arrivalTime: null,
                isDisabled: widget.isActionCompleted,
                onRouteChanged: (route) {
                  // Handle both selection and deselection
                  if (route != null) {
                    _handleRouteSelection(route);
                  } else {
                    // Deselect route
                    widget.onRouteSelected(null);
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
