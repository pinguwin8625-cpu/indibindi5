import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/booking.dart';
import '../providers/app_settings_provider.dart';
import '../services/mock_users.dart';
import '../l10n/app_localizations.dart';
import 'rating_widgets.dart';

/// Widget for drivers to manage seat availability after posting a ride
/// Allows toggling seats between available and unavailable (if not occupied)
class DriverSeatManagementWidget extends StatefulWidget {
  final Booking booking;
  final Function(List<int> updatedSeats)? onSeatsChanged;
  final VoidCallback? onUpdateComplete;

  const DriverSeatManagementWidget({
    super.key,
    required this.booking,
    this.onSeatsChanged,
    this.onUpdateComplete,
  });

  @override
  State<DriverSeatManagementWidget> createState() => _DriverSeatManagementWidgetState();
}

class _DriverSeatManagementWidgetState extends State<DriverSeatManagementWidget>
    with SingleTickerProviderStateMixin {
  late Set<int> _availableSeats; // Seats currently offered by driver
  int? _tappedSeat; // Currently tapped seat for action
  Offset? _buttonPosition; // Position for the floating button
  final GlobalKey _layoutKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _availableSeats = Set<int>.from(widget.booking.selectedSeats);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper methods for responsive design
  bool _isMobileWeb(BuildContext context) {
    if (!kIsWeb) return false;
    final width = MediaQuery.of(context).size.width;
    return width < 600;
  }

  bool _isMobileApp() {
    return !kIsWeb;
  }

  /// Check if a seat is occupied by a rider
  bool _isSeatOccupied(int seatIndex) {
    if (widget.booking.riders != null) {
      for (var rider in widget.booking.riders!) {
        if (rider.seatIndex == seatIndex) {
          return true;
        }
      }
    }
    return false;
  }

  /// Toggle seat availability
  void _onSeatTap(int seatIndex, Offset globalPosition) {
    // Can't change occupied seats
    if (_isSeatOccupied(seatIndex)) {
      return;
    }

    setState(() {
      // If tapping the same seat, deselect it
      if (_tappedSeat == seatIndex) {
        _tappedSeat = null;
        _buttonPosition = null;
      } else {
        _tappedSeat = seatIndex;
        // Convert global position to local position relative to the widget
        final RenderBox? layoutBox =
            _layoutKey.currentContext?.findRenderObject() as RenderBox?;
        if (layoutBox != null) {
          _buttonPosition = layoutBox.globalToLocal(globalPosition);
        }
      }
    });

    // Trigger animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  /// Confirm the seat toggle action
  void _confirmToggle() {
    if (_tappedSeat == null) return;

    setState(() {
      if (_availableSeats.contains(_tappedSeat)) {
        // Make unavailable
        _availableSeats.remove(_tappedSeat);
      } else {
        // Make available
        _availableSeats.add(_tappedSeat!);
      }
      _hasChanges = true;
      _tappedSeat = null;
      _buttonPosition = null;
    });

    // Notify parent of changes
    widget.onSeatsChanged?.call(_availableSeats.toList());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appSettings = AppSettingsProvider();

    // Check if seat management is allowed
    return ListenableBuilder(
      listenable: appSettings,
      builder: (context, child) {
        final isDisabled = !appSettings.allowDriverSeatChange;

        return Stack(
          key: _layoutKey,
          clipBehavior: Clip.none,
          children: [
            // Seat layout
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: kIsWeb ? 350 : double.infinity,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Left column - Back seats (1, 2, 3)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildSeatRow(1, isDisabled: isDisabled),
                        SizedBox(height: 4),
                        _buildSeatRow(3, isDisabled: isDisabled),
                        SizedBox(height: 4),
                        _buildSeatRow(2, isDisabled: isDisabled),
                      ],
                    ),

                    SizedBox(width: 12),

                    // Right column - Driver and front passenger
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDriverRow(),
                        SizedBox(height: 12),
                        _buildSeatRow(0, isRightSide: true, isDisabled: isDisabled),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Floating toggle button (only show if not disabled)
            if (_tappedSeat != null && _buttonPosition != null && !isDisabled)
              Positioned(
                left: _buttonPosition!.dx - 90, // Center the button horizontally
                top: _buttonPosition!.dy - 60, // Position above the pointer
                child: Builder(
                  builder: (context) {
                    final isCurrentlyAvailable = _availableSeats.contains(_tappedSeat);

                    // Responsive sizing based on platform
                    final isMobileApp = _isMobileApp();
                    final isMobileWeb = _isMobileWeb(context);
                    final fontSize = isMobileApp ? 12.0 : (isMobileWeb ? 13.0 : 14.0);

                    return FloatingActionButton.extended(
                      onPressed: _confirmToggle,
                      backgroundColor: isCurrentlyAvailable
                          ? Colors.red[600] // Will make unavailable
                          : Color(0xFF00C853), // Will make available
                      label: Text(
                        isCurrentlyAvailable
                            ? l10n.makeUnavailable
                            : l10n.makeAvailable,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                        ),
                      ),
                      icon: Icon(
                        isCurrentlyAvailable
                            ? Icons.block
                            : Icons.check_circle,
                        color: Colors.white,
                        size: 18,
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSeatRow(int seatIndex, {bool isRightSide = false, bool isDisabled = false}) {
    final riderName = _getRiderName(seatIndex);
    final riderRating = _getRiderRating(seatIndex);
    final label = _buildSeatLabel(riderName, riderRating);
    final seat = _buildSeat(seatIndex, isDisabled: isDisabled);

    if (isRightSide) {
      return Row(children: [seat, SizedBox(width: 4), label]);
    } else {
      return Row(children: [label, SizedBox(width: 4), seat]);
    }
  }

  Widget _buildDriverRow() {
    // Always look up driver name from MockUsers first for accuracy
    final driverId = widget.booking.driverUserId ?? widget.booking.userId;
    final driver = MockUsers.getUserById(driverId);
    String driverDisplayName;
    if (driver != null) {
      driverDisplayName = driver.name;
      if (driver.surname.isNotEmpty) {
        driverDisplayName = '${driver.name} ${driver.surname[0]}.';
      }
    } else {
      driverDisplayName = widget.booking.driverName ?? 'Driver';
    }

    final label = _buildSeatLabel(
      driverDisplayName,
      widget.booking.driverRating?.toStringAsFixed(1) ?? '0.0',
    );
    final seat = _buildDriverSeat();

    return Row(children: [seat, SizedBox(width: 4), label]);
  }

  Widget _buildSeat(int seatIndex, {bool isDisabled = false}) {
    final bool isOccupied = _isSeatOccupied(seatIndex);
    final bool isAvailable = _availableSeats.contains(seatIndex);
    final bool isTapped = _tappedSeat == seatIndex;

    // Determine colors
    Color backgroundColor;
    Color borderColor;

    if (isOccupied) {
      // Occupied by a rider - red, not changeable
      backgroundColor = Colors.red[100]!;
      borderColor = Color(0xFFDD2C00);
    } else if (isTapped && !isDisabled) {
      // Currently tapped for action - blue highlight (only if not disabled)
      backgroundColor = Colors.blue[100]!;
      borderColor = Colors.blue[700]!;
    } else if (isAvailable) {
      // Available seat - green
      backgroundColor = Colors.green[100]!;
      borderColor = Color(0xFF00C853);
    } else {
      // Not offered (unavailable) - red
      backgroundColor = Colors.red[100]!;
      borderColor = Color(0xFFDD2C00);
    }

    // Determine content
    Widget seatContent;
    if (isOccupied) {
      seatContent = _buildRiderPhoto(seatIndex);
    } else {
      seatContent = Icon(Icons.person, size: 28, color: Colors.grey[700]);
    }

    final shouldAnimate = isTapped && !isDisabled;

    // Only allow tapping if not occupied AND not disabled
    Widget seatWidget = GestureDetector(
      onTapDown: (!isOccupied && !isDisabled)
          ? (details) => _onSeatTap(seatIndex, details.globalPosition)
          : null,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Center(child: seatContent),
      ),
    );

    // Add animation if this seat was just tapped
    if (shouldAnimate) {
      return ScaleTransition(scale: _scaleAnimation, child: seatWidget);
    }

    return seatWidget;
  }

  Widget _buildDriverSeat() {
    // Get driver photo
    final driverId = widget.booking.driverUserId ?? widget.booking.userId;
    final driver = MockUsers.getUserById(driverId);

    Widget photoWidget;
    if (driver?.profilePhotoUrl != null && driver!.profilePhotoUrl!.isNotEmpty) {
      photoWidget = _buildPhotoWidget(driver.profilePhotoUrl!);
    } else {
      photoWidget = Icon(Icons.person, size: 32, color: Colors.grey[600]);
    }

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.red[100]!,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Color(0xFFDD2C00), width: 2),
      ),
      child: Center(child: photoWidget),
    );
  }

  Widget _buildSeatLabel(String name, String? rating) {
    return Container(
      width: 85,
      height: 38,
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          if (rating != null)
            RatingDisplay(
              rating: double.tryParse(rating) ?? 0.0,
              starSize: 10,
              fontSize: 10,
            ),
        ],
      ),
    );
  }

  // Helper methods
  String _getRiderName(int seatIndex) {
    if (widget.booking.riders != null) {
      for (var rider in widget.booking.riders!) {
        if (rider.seatIndex == seatIndex) {
          return rider.name;
        }
      }
    }
    return 'Rider-${seatIndex + 1}';
  }

  String? _getRiderRating(int seatIndex) {
    if (widget.booking.riders != null) {
      for (var rider in widget.booking.riders!) {
        if (rider.seatIndex == seatIndex) {
          if (rider.userId.isNotEmpty) {
            return MockUsers.getLiveRating(rider.userId).toStringAsFixed(1);
          }
          return rider.rating.toStringAsFixed(1);
        }
      }
    }
    return null;
  }

  Widget _buildRiderPhoto(int seatIndex) {
    if (widget.booking.riders != null) {
      for (var rider in widget.booking.riders!) {
        if (rider.seatIndex == seatIndex && rider.profilePhotoUrl != null) {
          return _buildPhotoWidget(rider.profilePhotoUrl!);
        }
      }
    }
    return Icon(Icons.person, size: 28, color: Colors.grey[700]);
  }

  Widget _buildPhotoWidget(String photoUrl) {
    if (photoUrl.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          photoUrl,
          width: 54,
          height: 54,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.person, size: 32, color: Colors.grey[600]);
          },
        ),
      );
    } else {
      final photoFile = File(photoUrl);
      if (photoFile.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            photoFile,
            width: 54,
            height: 54,
            fit: BoxFit.cover,
          ),
        );
      }
    }
    return Icon(Icons.person, size: 28, color: Colors.grey[700]);
  }

  /// Check if there are pending changes
  bool get hasChanges => _hasChanges;

  /// Get current available seats
  List<int> get currentSeats => _availableSeats.toList();
}
