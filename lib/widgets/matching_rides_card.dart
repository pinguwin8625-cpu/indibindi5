import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import '../models/routes.dart';
import '../models/booking.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/booking_storage.dart';
import '../services/mock_users.dart';

/// A card that displays a matching ride with the same style as booking cards
class MatchingRideCard extends StatefulWidget {
  final RideInfo ride;
  final VoidCallback? onBookingCompleted;
  final Function(bool hasPending, VoidCallback? confirmAction)? onPendingChanged;

  const MatchingRideCard({
    super.key,
    required this.ride,
    this.onBookingCompleted,
    this.onPendingChanged,
  });

  @override
  State<MatchingRideCard> createState() => _MatchingRideCardState();
}

class _MatchingRideCardState extends State<MatchingRideCard>
    with SingleTickerProviderStateMixin {
  final Set<int> selectedSeats = {};
  final Set<int> bookedSeats = {};
  final Set<int> pendingSeats = {}; // Seats awaiting confirmation
  int? lastTappedSeat;
  Offset? buttonPosition;
  final GlobalKey _cardKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
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

  // Check if this is the current user's own ride
  bool get _isOwnRide {
    final currentUser = AuthService.currentUser;
    return currentUser != null && widget.ride.driverId == currentUser.id;
  }

  // Format time for conflict error messages
  String _formatTimeForConflict(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  void _toggleSeat(int seatIndex, Offset tapPosition) {
    // Cannot select seats on own ride
    if (_isOwnRide) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cannotBookOwnRide),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check if seat is already occupied by a rider or booked
    bool isOccupied = false;
    if (widget.ride.riders != null && widget.ride.riders!.isNotEmpty) {
      for (var r in widget.ride.riders!) {
        if (r.seatIndex == seatIndex) {
          isOccupied = true;
          break;
        }
      }
    }

    // Only toggle if seat is not occupied or booked
    if (!isOccupied && !bookedSeats.contains(seatIndex)) {
      setState(() {
        if (selectedSeats.contains(seatIndex)) {
          // Deselecting the seat
          selectedSeats.remove(seatIndex);
          buttonPosition = null; // Hide button when deselecting
        } else {
          // ONE SEAT PER USER RESTRICTION:
          // Clear any previously selected seats before selecting a new one
          selectedSeats.clear();
          
          // Select the new seat
          selectedSeats.add(seatIndex);
          lastTappedSeat = seatIndex;

          // Convert global position to local position relative to the card
          final RenderBox? cardBox =
              _cardKey.currentContext?.findRenderObject() as RenderBox?;
          if (cardBox != null) {
            final localPosition = cardBox.globalToLocal(tapPosition);
            buttonPosition = localPosition;
          }

          // Trigger animation
          _animationController.forward().then((_) {
            _animationController.reverse();
          });
        }
      });
    }
  }

  void _confirmBooking() async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null || pendingSeats.isEmpty) return;

    final bookingStorage = BookingStorage();

    // Get driver's booking to update it
    Booking? driverBooking;
    try {
      driverBooking = bookingStorage.getAllBookings().firstWhere(
        (b) => b.id == widget.ride.id,
        orElse: () =>
            throw StateError('Driver booking not found: ${widget.ride.id}'),
      );
    } catch (e) {
      print('❌ Driver booking not found: ${widget.ride.id}');
      if (kDebugMode) {
        print('   Error: $e');
      }
      return;
    }

    // Check for time conflicts with the rider's existing bookings
    if (bookingStorage.hasTimeConflict(
      userId: currentUser.id,
      departureTime: widget.ride.departureTime,
      arrivalTime: widget.ride.arrivalTime,
    )) {
      final conflictingBooking = bookingStorage.getConflictingBooking(
        userId: currentUser.id,
        departureTime: widget.ride.departureTime,
        arrivalTime: widget.ride.arrivalTime,
      );
      
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              conflictingBooking != null
                  ? '${l10n.alreadyHaveRideScheduled} (${_formatTimeForConflict(conflictingBooking.departureTime)} - ${_formatTimeForConflict(conflictingBooking.arrivalTime)})'
                  : l10n.alreadyHaveRideScheduled,
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
      // Clear pending seats since there's a conflict
      setState(() {
        pendingSeats.clear();
      });
      // Notify parent that pending state is cleared
      widget.onPendingChanged?.call(false, null);
      return;
    }

    // Create rider's display name
    String riderName = currentUser.surname.isNotEmpty
        ? '${currentUser.name} ${currentUser.surname[0]}.'
        : currentUser.name;

    if (kDebugMode) {
      print('🎫 Creating rider booking:');
      print('   Rider: $riderName (userId: ${currentUser.id})');
      print('   Pending seats: $pendingSeats');
    }

    // Update driver's booking with rider info first
    final updatedRiders = List<RiderInfo>.from(driverBooking.riders ?? []);
    for (final seatIndex in pendingSeats) {
      if (kDebugMode) {
        print('   Adding rider to seat index: $seatIndex');
      }
      updatedRiders.add(
        RiderInfo(
          userId: currentUser.id,
          name: riderName,
          rating: currentUser.rating,
          seatIndex: seatIndex,
          profilePhotoUrl: currentUser.profilePhotoUrl,
        ),
      );
    }

    // Create rider's own booking with the complete riders list (including themselves and all previous riders)
    // For rider bookings, selectedSeats should contain the driver's offered seats,
    // and the riders array should contain ALL riders (so they can see each other)
    final riderBooking = Booking(
      id: '${widget.ride.id}_rider_${currentUser.id}',
      userId: currentUser.id,
      route: widget.ride.route,
      originIndex: widget.ride.originIndex,
      destinationIndex: widget.ride.destinationIndex,
      selectedSeats: driverBooking.selectedSeats, // Use driver's offered seats
      departureTime: widget.ride.departureTime,
      arrivalTime: widget.ride.arrivalTime,
      bookingDate: DateTime.now(),
      userRole: 'rider', // Always use English for consistency
      driverName: widget.ride.driverName,
      driverUserId: driverBooking.userId, // Store driver's user ID
      driverRating: widget.ride.driverRating,
      riders: updatedRiders, // Include all riders (current + previous)
    );

    // Add rider's booking
    bookingStorage.addBooking(riderBooking);

    // Keep the original selectedSeats (total offered) - don't remove booked ones
    // Available seats = selectedSeats.length - riders.length
    final updatedDriverBooking = driverBooking.copyWith(riders: updatedRiders);

    bookingStorage.updateBooking(updatedDriverBooking);

    // IMPORTANT: Update all existing rider bookings for this ride with the complete riders list
    // This ensures all riders can see each other
    final allBookings = bookingStorage.getAllBookings();
    for (final booking in allBookings) {
      // Check if this is a rider booking for the same ride
      if (booking.id.startsWith('${widget.ride.id}_rider_') &&
          booking.id != riderBooking.id) {
        // Update this rider's booking with the complete riders list
        final updatedRiderBooking = booking.copyWith(riders: updatedRiders);
        bookingStorage.updateBooking(updatedRiderBooking);
      }
    }

    print('✅ Rider booking created and driver booking updated');
    print('   Rider: $riderName, Seats: $pendingSeats');
    print('   Driver offered seats: ${driverBooking.selectedSeats}');
    print('   Total riders: ${updatedRiders.length}');
    print(
      '   Available seats: ${driverBooking.selectedSeats.length - updatedRiders.length}',
    );

    setState(() {
      // Move pending seats to booked seats
      bookedSeats.addAll(pendingSeats);
      pendingSeats.clear();
      lastTappedSeat = null;
    });

    // Notify parent that pending state is cleared
    widget.onPendingChanged?.call(false, null);

    // Navigate to My Bookings screen after frame is complete
    if (widget.onBookingCompleted != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onBookingCompleted!();
        }
      });
    }
  }

  bool _isSeatSelected(int seatIndex) {
    return selectedSeats.contains(seatIndex);
  }

  bool _isSeatBooked(int seatIndex) {
    return bookedSeats.contains(seatIndex);
  }

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diffDays = target.difference(today).inDays;

    if (diffDays == 0) return l10n.today;
    if (diffDays == 1) return l10n.tomorrow;

    final monthAbbr = [
      l10n.jan,
      l10n.feb,
      l10n.mar,
      l10n.apr,
      l10n.may,
      l10n.jun,
      l10n.jul,
      l10n.aug,
      l10n.sep,
      l10n.oct,
      l10n.nov,
      l10n.dec,
    ];

    return '${date.day} ${monthAbbr[date.month - 1]}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: kIsWeb ? 500 : double.infinity,
        ),
        child: Stack(
          key: _cardKey,
          children: [
            Card(
              margin: EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "Your Ride" badge if this is the user's own ride
                    if (_isOwnRide) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[300]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700], size: 18),
                            SizedBox(width: 8),
                            Text(
                              l10n.thisIsYourRide,
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Route summary card with border
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[300]!, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Route name and date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.ride.route.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E2E2E),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _formatDate(context, widget.ride.departureTime),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16),

                          // Origin with departure time
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.green, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.ride.route.stops[widget.ride.originIndex].name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _formatTime(widget.ride.departureTime),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 8),

                          // Destination with arrival time
                          Row(
                            children: [
                              Icon(Icons.flag, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget
                                      .ride
                                      .route
                                      .stops[widget.ride.destinationIndex]
                                      .name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Text(
                                      _formatTime(widget.ride.arrivalTime),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red[700],
                                      ),
                                    ),
                                    // Show +1 at top right corner if arrival is on a different day than departure
                                    if (widget.ride.arrivalTime.day != widget.ride.departureTime.day ||
                                        widget.ride.arrivalTime.month != widget.ride.departureTime.month ||
                                        widget.ride.arrivalTime.year != widget.ride.departureTime.year)
                                      Positioned(
                                        top: -2,
                                        right: -14,
                                        child: Text(
                                          '+1',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red[700],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12),

                    // Miniature seat layout showing available seats
                    _buildMiniatureSeatLayout(),
                  ],
                ),
              ),
            ),
            // Floating book button at pointer position
            if (selectedSeats.isNotEmpty && buttonPosition != null && pendingSeats.isEmpty)
              Positioned(
                left: buttonPosition!.dx - 80, // Center the button horizontally
                top: buttonPosition!.dy - 60, // Position above the pointer
                child: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    
                    // Responsive sizing based on platform
                    final isMobileApp = _isMobileApp();
                    final isMobileWeb = _isMobileWeb(context);
                    
                    // Different font sizes for each platform
                    // Mobile App: compact, Mobile Web: medium, Desktop Web: larger
                    final fontSize = isMobileApp ? 14.0 : (isMobileWeb ? 15.0 : 16.0);

                    return FloatingActionButton.extended(
                      onPressed: bookedSeats.isNotEmpty ? null : _moveToPending,
                      backgroundColor: bookedSeats.isNotEmpty
                          ? Color(0xFF00C853) // Standard green
                          : Color(0xFF2E2E2E), // Same as post ride button
                      disabledElevation: 0,
                      label: Text(
                        bookedSeats.isNotEmpty ? l10n.booked : l10n.book,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _moveToPending() {
    setState(() {
      // Move selected seats to pending
      pendingSeats.addAll(selectedSeats);
      selectedSeats.clear();
      buttonPosition = null;
      lastTappedSeat = null;
    });
    
    // Notify parent about pending state change
    print('🔔 _moveToPending called, notifying parent with pendingSeats: $pendingSeats');
    print('🔔 onPendingChanged is null: ${widget.onPendingChanged == null}');
    widget.onPendingChanged?.call(true, _confirmBooking);
  }

  Widget _buildMiniatureSeatLayout() {
    // Helper function to get rider info for a seat
    String getRiderName(int seatIndex) {
      if (widget.ride.riders != null && widget.ride.riders!.isNotEmpty) {
        try {
          for (var r in widget.ride.riders!) {
            if (r.seatIndex == seatIndex) {
              return r.name;
            }
          }
        } catch (e) {
          // Handle case where rider is not found
        }
      }
      return 'Rider-${seatIndex + 1}';
    }

    String? getRiderRating(int seatIndex) {
      // Check if this is a pending seat for the current user
      if (pendingSeats.contains(seatIndex)) {
        final currentUser = AuthService.currentUser;
        if (currentUser != null) {
          return currentUser.rating.toStringAsFixed(1);
        }
      }
      
      if (widget.ride.riders != null && widget.ride.riders!.isNotEmpty) {
        try {
          for (var r in widget.ride.riders!) {
            if (r.seatIndex == seatIndex) {
              // Get live rating from RatingService if userId is available
              if (r.userId.isNotEmpty) {
                return MockUsers.getLiveRating(r.userId).toStringAsFixed(1);
              }
              return r.rating.toStringAsFixed(1);
            }
          }
        } catch (e) {
          // Handle case where rider is not found
        }
      }
      // Return null for unoccupied seats (no rating to show)
      return null;
    }

    // Get the display name for a seat (checks pending seats first)
    String getDisplayName(int seatIndex) {
      // Check if this is a pending seat for the current user
      if (pendingSeats.contains(seatIndex)) {
        final currentUser = AuthService.currentUser;
        if (currentUser != null) {
          if (currentUser.surname.isNotEmpty) {
            return '${currentUser.name} ${currentUser.surname[0]}.';
          }
          return currentUser.name;
        }
      }
      return getRiderName(seatIndex);
    }

    // Check if a seat is occupied by a rider
    bool isSeatOccupied(int seatIndex) {
      if (widget.ride.riders != null && widget.ride.riders!.isNotEmpty) {
        try {
          for (var r in widget.ride.riders!) {
            if (r.seatIndex == seatIndex) {
              return true;
            }
          }
        } catch (e) {
          // Handle error
        }
      }
      return false;
    }

    // Check if a seat is offered by the driver
    bool isSeatOffered(int seatIndex) {
      // Need to get the actual booking to check selectedSeats
      final bookingStorage = BookingStorage();
      try {
        final driverBooking = bookingStorage.getAllBookings().firstWhere(
          (b) => b.id == widget.ride.id,
        );
        return driverBooking.selectedSeats.contains(seatIndex);
      } catch (e) {
        return false;
      }
    }

    return Center(
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
                Row(
                  children: [
                    _buildSeatLabel(getDisplayName(1), getRiderRating(1)),
                    SizedBox(width: 4),
                    _buildMiniSeat(
                      seatIndex: 1,
                      isOccupied: isSeatOccupied(1),
                      isNotOffered: !isSeatOffered(1),
                      passengerName: getDisplayName(1),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    _buildSeatLabel(getDisplayName(3), getRiderRating(3)),
                    SizedBox(width: 4),
                    _buildMiniSeat(
                      seatIndex: 3,
                      isOccupied: isSeatOccupied(3),
                      isNotOffered: !isSeatOffered(3),
                      passengerName: getDisplayName(3),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    _buildSeatLabel(getDisplayName(2), getRiderRating(2)),
                    SizedBox(width: 4),
                    _buildMiniSeat(
                      seatIndex: 2,
                      isOccupied: isSeatOccupied(2),
                      isNotOffered: !isSeatOffered(2),
                      passengerName: getDisplayName(2),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(width: 12),

            // Right column - Front seats (Driver and Rider 1)
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildMiniSeat(
                      isDriver: true,
                      passengerName: widget.ride.driverName,
                    ),
                    SizedBox(width: 4),
                    _buildSeatLabel(
                      widget.ride.driverName,
                      widget.ride.driverRating.toStringAsFixed(1),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    _buildMiniSeat(
                      seatIndex: 0,
                      isOccupied: isSeatOccupied(0),
                      isNotOffered: !isSeatOffered(0),
                      passengerName: getDisplayName(0),
                    ),
                    SizedBox(width: 4),
                    _buildSeatLabel(getDisplayName(0), getRiderRating(0)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniSeat({
    int? seatIndex,
    bool isOccupied = false,
    bool isDriver = false,
    bool isNotOffered = false,
    required String passengerName,
  }) {
    bool isSelected = seatIndex != null && _isSeatSelected(seatIndex);
    bool isBooked = seatIndex != null && _isSeatBooked(seatIndex);
    bool isPending = seatIndex != null && pendingSeats.contains(seatIndex);
    bool shouldAnimate = seatIndex == lastTappedSeat && isSelected;

    Color backgroundColor;
    Color borderColor;

    if (isDriver) {
      // Driver seat is always red/occupied
      backgroundColor = Colors.red[100]!;
      borderColor = Color(0xFFDD2C00);
    } else if (isNotOffered) {
      // Seat not offered by driver - show as unavailable (red like occupied)
      backgroundColor = Colors.red[100]!;
      borderColor = Color(0xFFDD2C00);
    } else if (isOccupied || isBooked) {
      // Occupied passenger seat OR booked seat - both show red frame like other riders
      backgroundColor = Colors.red[100]!;
      borderColor = Color(0xFFDD2C00);
    } else if (isPending) {
      // Pending seat - show with blue/purple to indicate awaiting confirmation
      backgroundColor = Colors.blue[100]!;
      borderColor = Colors.blue[700]!;
    } else if (isSelected) {
      // Selected seat - use blue color
      backgroundColor = Colors.blue[100]!;
      borderColor = Colors.blue[700]!;
    } else {
      // Available passenger seat
      backgroundColor = Colors.green[100]!;
      borderColor = Color(0xFF00C853);
    }

    Widget seatContent;
    if (isDriver) {
      // Show driver photo or placeholder
      seatContent = _buildDriverPhoto();
    } else if (isOccupied && seatIndex != null) {
      // Show rider photo if this seat is occupied
      seatContent = _buildRiderPhoto(seatIndex);
    } else if (isBooked || isPending) {
      // Show current user's photo for booked or pending seat
      seatContent = _buildCurrentUserPhoto();
    } else {
      // Show generic person icon for available seats
      seatContent = Icon(Icons.person, size: 28, color: Colors.grey[700]);
    }

    Widget seatWidget = GestureDetector(
      onTapDown:
          (!isDriver &&
              !isOccupied &&
              !isBooked &&
              !isPending &&
              !isNotOffered &&
              seatIndex != null)
          ? (details) => _toggleSeat(seatIndex, details.globalPosition)
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

  Widget _buildDriverPhoto() {
    if (widget.ride.driverPhoto.isNotEmpty) {
      // Check if it's an asset or file path
      if (widget.ride.driverPhoto.startsWith('assets/')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            widget.ride.driverPhoto,
            width: 54,
            height: 54,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.person, size: 32, color: Colors.grey[600]);
            },
          ),
        );
      } else {
        final photoFile = File(widget.ride.driverPhoto);
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
    }

    // Default placeholder if no driver photo
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.person, size: 32, color: Colors.grey[600]),
    );
  }

  Widget _buildCurrentUserPhoto() {
    final currentUser = AuthService.currentUser;

    if (currentUser != null &&
        currentUser.profilePhotoUrl != null &&
        currentUser.profilePhotoUrl!.isNotEmpty) {
      // Check if it's an asset or file path
      if (currentUser.profilePhotoUrl!.startsWith('assets/')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            currentUser.profilePhotoUrl!,
            width: 54,
            height: 54,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.person, size: 28, color: Colors.grey[700]);
            },
          ),
        );
      } else {
        final photoFile = File(currentUser.profilePhotoUrl!);
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
    }

    // Default placeholder for current user without photo
    return Icon(Icons.person, size: 28, color: Colors.grey[700]);
  }

  Widget _buildRiderPhoto(int seatIndex) {
    // Find the rider for this seat
    if (widget.ride.riders != null && widget.ride.riders!.isNotEmpty) {
      try {
        dynamic rider;
        for (var r in widget.ride.riders!) {
          if (r.seatIndex == seatIndex) {
            rider = r;
            break;
          }
        }

        // Check if rider has a profile photo
        if (rider != null &&
            rider.profilePhotoUrl != null &&
            rider.profilePhotoUrl!.isNotEmpty) {
          // Check if it's an asset or file path
          if (rider.profilePhotoUrl!.startsWith('assets/')) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                rider.profilePhotoUrl!,
                width: 54,
                height: 54,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.person, size: 28, color: Colors.grey[700]);
                },
              ),
            );
          } else {
            final photoFile = File(rider.profilePhotoUrl!);
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
        }
      } catch (e) {
        // Handle error silently
      }
    }

    // Default placeholder for riders without photos
    return Icon(Icons.person, size: 28, color: Colors.grey[700]);
  }

  Widget _buildSeatLabel(String name, String? rating) {
    return Container(
      width: 85, // Fixed width
      height: 38, // Fixed height regardless of rating
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 10, color: Colors.amber[700]),
                SizedBox(width: 2),
                Text(
                  rating,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
