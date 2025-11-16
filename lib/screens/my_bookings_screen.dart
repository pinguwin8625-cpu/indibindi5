import 'package:flutter/material.dart';
import 'dart:io';
import '../services/booking_storage.dart';
import '../services/auth_service.dart';
import '../services/messaging_service.dart';
import '../models/booking.dart';
import '../models/message.dart';
import '../utils/date_time_helpers.dart';
import '../l10n/app_localizations.dart';
import '../widgets/scroll_indicator.dart';
import '../widgets/language_selector.dart';
import 'chat_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final BookingStorage _bookingStorage = BookingStorage();
  bool _showOlderPastBookings = false;
  bool _showUpcoming = true;
  bool _showOngoing = true;
  bool _showCompleted = true;
  bool _showCanceled = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.myBookings,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          automaticallyImplyLeading: false, // Remove back button
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: LanguageSelector(isDarkBackground: true),
            ),
          ],
        ),
        body: Builder(
          builder: (BuildContext context) {
            final TabController tabController = DefaultTabController.of(context);
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: AnimatedBuilder(
                    animation: tabController,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTabButton(
                            label: l10n.driver,
                            icon: Icons.directions_car,
                            isSelected: tabController.index == 0,
                            onTap: () {
                              tabController.animateTo(0);
                            },
                          ),
                          SizedBox(width: 20),
                          _buildTabButton(
                            label: l10n.rider,
                            icon: Icons.person,
                            isSelected: tabController.index == 1,
                            onTap: () {
                              tabController.animateTo(1);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildBookingsList(l10n.driver),
                      _buildBookingsList(l10n.rider),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFDD2C00) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Color(0xFFDD2C00) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Color(0xFFDD2C00),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Color(0xFFDD2C00),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(String userRole) {
    return ValueListenableBuilder(
      valueListenable: _bookingStorage.bookings,
      builder: (context, List<Booking> bookings, child) {
        final l10n = AppLocalizations.of(context)!;
        final now = DateTime.now();

        // Filter bookings based on user
        final user = AuthService.currentUser;
        final userBookings = bookings
            .where((b) => b.userId == user?.id)
            .toList();

        // Upcoming: departure time is in the future
        final upcomingBookings =
            userBookings
                .where(
                  (b) =>
                      b.departureTime.isAfter(now) &&
                      (b.isCanceled != true) &&
                      (b.isArchived != true),
                )
                .toList()
              ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

        // Ongoing: departure time has passed but arrival time hasn't (strictly after now)
        final ongoingBookings =
            userBookings
                .where(
                  (b) =>
                      b.departureTime.isBefore(now) &&
                      b.arrivalTime.isAfter(now) &&
                      (b.isCanceled != true) &&
                      (b.isArchived != true),
                )
                .toList()
              ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

        // Past: arrival time has passed or equals now
        final pastBookings =
            userBookings
                .where(
                  (b) =>
                      !b.arrivalTime.isAfter(now) &&
                      (b.isCanceled != true) &&
                      (b.isArchived != true),
                )
                .toList()
              ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

        final canceledBookings =
            userBookings
                .where((b) => b.isCanceled == true && (b.isArchived != true))
                .toList()
              ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

        // Archived bookings
        final archivedBookings =
            userBookings.where((b) => b.isArchived == true).toList()
              ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

        // Recent completed bookings (for Completed section)
        final recentBookings = pastBookings;

        if (userBookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_seat, size: 80, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  l10n.noBookingsYet,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ScrollIndicator(
          scrollController: _scrollController,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Upcoming section
              if (upcomingBookings.isNotEmpty) ...[
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SectionHeaderDelegate(
                    title: l10n.upcoming,
                    minHeight: 50,
                    maxHeight: 50,
                    sectionColor: Colors.blue[700]!,
                    isCollapsible: true,
                    isExpanded: _showUpcoming,
                    count: upcomingBookings.length,
                    onTap: () {
                      setState(() {
                        _showUpcoming = !_showUpcoming;
                      });
                    },
                  ),
                ),
                if (_showUpcoming)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildBookingCard(
                          upcomingBookings[index],
                          isPast: false,
                        ),
                        childCount: upcomingBookings.length,
                      ),
                    ),
                  ),
              ],

              // Ongoing section
              if (ongoingBookings.isNotEmpty) ...[
                SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SectionHeaderDelegate(
                    title: l10n.ongoing,
                    minHeight: 50,
                    maxHeight: 50,
                    sectionColor: Colors.orange[700]!,
                    isCollapsible: true,
                    isExpanded: _showOngoing,
                    count: ongoingBookings.length,
                    onTap: () {
                      setState(() {
                        _showOngoing = !_showOngoing;
                      });
                    },
                  ),
                ),
                if (_showOngoing)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildBookingCard(
                          ongoingBookings[index],
                          isPast: false,
                          isOngoing: true,
                        ),
                        childCount: ongoingBookings.length,
                      ),
                    ),
                  ),
              ],

              // Completed section (last 24 hours)
              if (recentBookings.isNotEmpty) ...[
                SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SectionHeaderDelegate(
                    title: l10n.completed,
                    minHeight: 50,
                    maxHeight: 50,
                    sectionColor: Colors.green[600]!,
                    isCollapsible: true,
                    isExpanded: _showCompleted,
                    count: recentBookings.length,
                    onTap: () {
                      setState(() {
                        _showCompleted = !_showCompleted;
                      });
                    },
                  ),
                ),
                if (_showCompleted)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildBookingCard(
                          recentBookings[index],
                          isPast: true,
                        ),
                        childCount: recentBookings.length,
                      ),
                    ),
                  ),
              ],

              // Canceled section
              if (canceledBookings.isNotEmpty) ...[
                SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SectionHeaderDelegate(
                    title: l10n.canceledRides,
                    minHeight: 50,
                    maxHeight: 50,
                    sectionColor: Colors.red[700]!,
                    isCollapsible: true,
                    isExpanded: _showCanceled,
                    count: canceledBookings.length,
                    onTap: () {
                      setState(() {
                        _showCanceled = !_showCanceled;
                      });
                    },
                  ),
                ),
                if (_showCanceled)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildBookingCard(
                          canceledBookings[index],
                          isPast: false,
                          isCanceled: true,
                        ),
                        childCount: canceledBookings.length,
                      ),
                    ),
                  ),
              ],

              // Archive section at the bottom
              if (archivedBookings.isNotEmpty) ...[
                SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SectionHeaderDelegate(
                    title: l10n.archive,
                    minHeight: 50,
                    maxHeight: 50,
                    isCollapsible: true,
                    isExpanded: _showOlderPastBookings,
                    count: archivedBookings.length,
                    sectionColor: Colors.grey[700]!,
                    onTap: () {
                      setState(() {
                        _showOlderPastBookings = !_showOlderPastBookings;
                      });
                    },
                  ),
                ),
                if (_showOlderPastBookings)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final booking = archivedBookings[index];
                        return _buildBookingCard(
                          booking,
                          isPast: !booking.arrivalTime.isAfter(DateTime.now()),
                          isCanceled: booking.isCanceled == true,
                          isOngoing:
                              booking.departureTime.isBefore(DateTime.now()) &&
                              booking.arrivalTime.isAfter(DateTime.now()),
                          isArchived: true,
                        );
                      }, childCount: archivedBookings.length),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _cancelBooking(Booking booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Booking'),
          content: Text('Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('No', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                BookingStorage().cancelBooking(booking.id);
                Navigator.of(context).pop();
              },
              child: Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _archiveBooking(Booking booking) {
    final isArchived = booking.isArchived == true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isArchived ? 'Unarchive Booking' : 'Archive Booking'),
          content: Text(
            isArchived
                ? 'Are you sure you want to unarchive this booking?'
                : 'Are you sure you want to archive this booking?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('No', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                if (isArchived) {
                  BookingStorage().unarchiveBooking(booking.id);
                } else {
                  BookingStorage().archiveBooking(booking.id);
                }
                Navigator.of(context).pop();
              },
              child: Text(
                isArchived ? 'Yes, Unarchive' : 'Yes, Archive',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookingCard(
    Booking booking, {
    required bool isPast,
    bool isCanceled = false,
    bool isOngoing = false,
    bool isArchived = false,
  }) {
    return _BookingCard(
      booking: booking,
      isPast: isPast,
      isCanceled: isCanceled,
      isOngoing: isOngoing,
      isArchived: isArchived,
      onCancel: () => _cancelBooking(booking),
      onArchive: () => _archiveBooking(booking),
      buildMiniatureSeatLayout: (selectedSeats, booking) =>
          _buildMiniatureSeatLayout(selectedSeats, booking),
    );
  }

  Widget _buildMiniatureSeatLayout(List<int> selectedSeats, Booking booking) {
    final l10n = AppLocalizations.of(context)!;

    // Format driver name (first name + last initial) and get rating
    String driverDisplayName = l10n.driver;
    String driverRating = '0.0';

    // Use driver info stored in booking (if user was driver when booking was made)
    print(
      '📖 My Bookings - userRole: ${booking.userRole}, driverName: ${booking.driverName}, driverRating: ${booking.driverRating}',
    );
    if (booking.userRole.toLowerCase() == l10n.driver.toLowerCase()) {
      if (booking.driverName != null && booking.driverName!.isNotEmpty) {
        driverDisplayName = booking.driverName!;
      }
      if (booking.driverRating != null) {
        driverRating = booking.driverRating!.toStringAsFixed(1);
      }
      print(
        '📖 Display values - Name: $driverDisplayName, Rating: $driverRating',
      );
    }

    // Helper function to get rider info for a seat
    String getRiderName(int seatIndex) {
      if (booking.riders != null) {
        final rider = booking.riders!.firstWhere(
          (r) => r.seatIndex == seatIndex,
          orElse: () => RiderInfo(name: '${l10n.passenger}-${seatIndex + 1}', rating: 0.0, seatIndex: seatIndex),
        );
        return rider.name;
      }
      return '${l10n.passenger}-${seatIndex + 1}';
    }

    String getRiderRating(int seatIndex) {
      if (booking.riders != null) {
        final rider = booking.riders!.firstWhere(
          (r) => r.seatIndex == seatIndex,
          orElse: () => RiderInfo(name: '', rating: 0.0, seatIndex: seatIndex),
        );
        return rider.rating.toStringAsFixed(1);
      }
      return '0.0';
    }

    return Center(
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
                  _buildSeatLabel(getRiderName(1), getRiderRating(1)),
                  SizedBox(width: 4),
                  _buildMiniSeat(
                    seatIndex: 1,
                    isSelected: selectedSeats.contains(1),
                    booking: booking,
                    passengerName: getRiderName(1),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  _buildSeatLabel(getRiderName(2), getRiderRating(2)),
                  SizedBox(width: 4),
                  _buildMiniSeat(
                    seatIndex: 2,
                    isSelected: selectedSeats.contains(2),
                    booking: booking,
                    passengerName: getRiderName(2),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  _buildSeatLabel(getRiderName(3), getRiderRating(3)),
                  SizedBox(width: 4),
                  _buildMiniSeat(
                    seatIndex: 3,
                    isSelected: selectedSeats.contains(3),
                    booking: booking,
                    passengerName: getRiderName(3),
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
                    booking: booking,
                    passengerName: driverDisplayName,
                  ),
                  SizedBox(width: 4),
                  _buildSeatLabel(driverDisplayName, driverRating),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  _buildMiniSeat(
                    seatIndex: 0,
                    isSelected: selectedSeats.contains(0),
                    booking: booking,
                    passengerName: getRiderName(0),
                  ),
                  SizedBox(width: 4),
                  _buildSeatLabel(getRiderName(0), getRiderRating(0)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniSeat({
    int? seatIndex,
    bool isSelected = false,
    bool isDriver = false,
    required Booking booking,
    required String passengerName,
  }) {
    Color backgroundColor;
    Color borderColor;
    bool isOccupied;

    if (isDriver) {
      // Driver seat is always red/occupied
      backgroundColor = Colors.red[100]!;
      borderColor = Color(0xFFDD2C00);
      isOccupied = true;
    } else {
      // For passenger seats, the meaning of isSelected depends on the booking role
      bool isAvailable;
      if (booking.userRole.toLowerCase() == 'driver') {
        // For driver bookings: seats in selectedSeats list are AVAILABLE (driver offering these seats)
        isAvailable = isSelected;
        isOccupied = !isSelected;
      } else {
        // For rider bookings: seats in selectedSeats list are OCCUPIED (rider booked these seats)
        isAvailable = !isSelected;
        isOccupied = isSelected;
      }

      if (isAvailable) {
        backgroundColor = Colors.green[100]!;
        borderColor = Color(0xFF00C853);
      } else {
        backgroundColor = Colors.red[100]!;
        borderColor = Color(0xFFDD2C00);
      }
    }

    // Make driver and all occupied seats clickable
    final isClickable = isDriver || isOccupied;

    return GestureDetector(
      onTap: isClickable
          ? () => _showUserCard(booking, isDriver, passengerName)
          : null,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Center(
          child: isDriver
              ? _buildDriverPhoto(booking)
              : Icon(Icons.person, size: 28, color: Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _buildDriverPhoto(Booking booking) {
    final currentUser = AuthService.currentUser;
    final l10n = AppLocalizations.of(context)!;

    // Check if current user is the driver and has a profile photo
    if (currentUser != null &&
        booking.userRole.toLowerCase() == l10n.driver.toLowerCase()) {
      if (currentUser.profilePhotoUrl != null &&
          currentUser.profilePhotoUrl!.isNotEmpty) {
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

    // Default placeholder
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

  void _showUserCard(Booking booking, bool isDriver, String otherUserName) {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;

    // Get rating for the user
    double rating = 0.0;
    if (isDriver && booking.driverRating != null) {
      rating = booking.driverRating!;
    } else if (!isDriver && booking.riders != null) {
      // Find rider by name
      final rider = booking.riders!.firstWhere(
        (r) => r.name == otherUserName,
        orElse: () => RiderInfo(name: '', rating: 0.0, seatIndex: -1),
      );
      rating = rider.rating;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // User avatar and name
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 40, color: Colors.grey[600]),
                ),
                SizedBox(height: 16),
                Text(
                  otherUserName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  isDriver ? 'Driver' : 'Rider',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 4),
                // Rating display
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  booking.route.name,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 24),

                // Action buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _openMessaging(booking, isDriver, otherUserName, currentUser);
                    },
                    icon: Icon(Icons.chat_bubble_outline),
                    label: Text('Message'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2E2E2E),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showBlockDialog(otherUserName);
                    },
                    icon: Icon(Icons.block),
                    label: Text('Block User'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openMessaging(Booking booking, bool isTargetDriver, String otherUserName, currentUser) {
    final l10n = AppLocalizations.of(context)!;
    
    // Check if current user is a rider trying to message another rider
    final isCurrentUserDriver = booking.userRole.toLowerCase() == l10n.driver.toLowerCase();
    
    if (!isCurrentUserDriver && !isTargetDriver) {
      // Rider trying to message another rider - not allowed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can only message the driver'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create or get conversation
    final messagingService = MessagingService();

    // For drivers: create conversation with specific rider
    // For riders: create conversation with driver
    final conversationId = isCurrentUserDriver 
        ? '${booking.id}_${otherUserName}' // Unique conversation per rider
        : booking.id; // Single conversation with driver

    var conversation = messagingService.getConversation(conversationId);

    if (conversation == null) {
      // Create new conversation
      final driverId = isTargetDriver
          ? 'driver_${booking.route.name}'
          : currentUser.id;
      final driverName = isTargetDriver ? otherUserName : currentUser.fullName;
      final riderId = isTargetDriver ? currentUser.id : 'rider_${booking.id}';
      final riderName = isTargetDriver ? currentUser.fullName : otherUserName;

      conversation = Conversation(
        id: conversationId,
        bookingId: booking.id,
        driverId: driverId,
        driverName: driverName,
        riderId: riderId,
        riderName: riderName,
        routeName: booking.route.name,
        arrivalTime: booking.arrivalTime,
        messages: [],
      );

      // Add to messaging service
      final updatedConversations = [
        ...messagingService.conversations.value,
        conversation,
      ];
      messagingService.conversations.value = updatedConversations;
    }

    // Navigate to chat screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(conversation: conversation!),
      ),
    );
  }

  void _showBlockDialog(String userName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Block User'),
          content: Text(
            'Are you sure you want to block $userName? You will no longer be able to message each other.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$userName has been blocked')),
                );
              },
              child: Text('Block', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSeatLabel(String name, String rating) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          name,
          style: TextStyle(
            color: Color(0xFF2E2E2E),
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.amber, size: 10),
            SizedBox(width: 1),
            Text(
              rating,
              style: TextStyle(
                color: Color(0xFF2E2E2E),
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Sticky section header delegate
class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final double minHeight;
  final double maxHeight;
  final bool isCollapsible;
  final bool isExpanded;
  final int? count;
  final VoidCallback? onTap;
  final Color? sectionColor;

  _SectionHeaderDelegate({
    required this.title,
    required this.minHeight,
    required this.maxHeight,
    this.isCollapsible = false,
    this.isExpanded = false,
    this.count,
    this.onTap,
    this.sectionColor,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Static styling - no animations
    final fontSize = 18.0;
    final baseColor = sectionColor ?? Color(0xFF2E2E2E);
    final textColor = baseColor;
    final underlineWidth = 60.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    if (count != null) ...[
                      SizedBox(width: 8),
                      Text(
                        '($count)',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4),
                // Static underline
                Container(
                  height: 2,
                  width: underlineWidth,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SectionHeaderDelegate oldDelegate) {
    return title != oldDelegate.title ||
        isExpanded != oldDelegate.isExpanded ||
        count != oldDelegate.count;
  }
}

// Collapsible booking card widget
class _BookingCard extends StatefulWidget {
  final Booking booking;
  final bool isPast;
  final bool isCanceled;
  final bool isOngoing;
  final bool isArchived;
  final VoidCallback onCancel;
  final VoidCallback onArchive;
  final Widget Function(List<int>, Booking) buildMiniatureSeatLayout;

  const _BookingCard({
    required this.booking,
    required this.isPast,
    required this.isCanceled,
    this.isOngoing = false,
    this.isArchived = false,
    required this.onCancel,
    required this.onArchive,
    required this.buildMiniatureSeatLayout,
  });

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  bool _isExpanded = false;

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shouldBeCollapsible = widget.isPast || widget.isCanceled;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
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
                    widget.booking.route.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 85,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        _formatDate(context, widget.booking.departureTime),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
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
                    widget.booking.originName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  width: 85,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        formatTimeHHmm(widget.booking.departureTime),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
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
                    widget.booking.destinationName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  width: 85,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        formatTimeHHmm(widget.booking.arrivalTime),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Miniature seat layout and status button
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Miniature seat layout - show for upcoming/ongoing OR when expanded for past/canceled
                if ((!widget.isPast && !widget.isCanceled) || widget.isOngoing)
                  Expanded(
                    child: widget.buildMiniatureSeatLayout(
                      widget.booking.selectedSeats,
                      widget.booking,
                    ),
                  )
                else if (_isExpanded)
                  Expanded(
                    child: widget.buildMiniatureSeatLayout(
                      widget.booking.selectedSeats,
                      widget.booking,
                    ),
                  )
                else if (shouldBeCollapsible)
                  // Show expand button for past/canceled rides
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isExpanded = true;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.expand_more,
                            size: 16,
                            color: Colors.grey[700],
                          ),
                          SizedBox(width: 4),
                          Text(
                            'View seats',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Spacer(),

                // Status button/label in bottom right
                if (widget.isCanceled)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 85,
                        child: GestureDetector(
                          onTap: widget.onArchive,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: widget.isArchived
                                  ? Colors.orange[600]
                                  : Colors.blue[600],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    widget.isArchived
                                        ? Icons.unarchive
                                        : Icons.archive,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      widget.isArchived
                                          ? l10n.unarchive
                                          : l10n.archive,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else if (widget.isPast && !widget.isOngoing)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 85,
                        child: GestureDetector(
                          onTap: widget.onArchive,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: widget.isArchived
                                  ? Colors.orange[600]
                                  : Colors.blue[600],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    widget.isArchived
                                        ? Icons.unarchive
                                        : Icons.archive,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      widget.isArchived
                                          ? l10n.unarchive
                                          : l10n.archive,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else if (!widget.isOngoing &&
                    !widget.isPast &&
                    !widget.isCanceled)
                  // Only show cancel button for upcoming rides (not ongoing)
                  GestureDetector(
                    onTap: widget.onCancel,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      constraints: BoxConstraints(minWidth: 85),
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close, size: 16, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              l10n.cancel,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  // Ongoing rides: no badge, just empty space
                  SizedBox.shrink(),
              ],
            ),

            // Collapse button when expanded
            if (_isExpanded && shouldBeCollapsible)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isExpanded = false;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.expand_less,
                            size: 16,
                            color: Colors.grey[700],
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Hide seats',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
