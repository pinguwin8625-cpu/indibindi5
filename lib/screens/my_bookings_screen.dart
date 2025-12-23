import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import '../services/booking_storage.dart';
import '../services/auth_service.dart';
import '../services/rating_service.dart';
import '../services/messaging_service.dart';
import '../services/mock_users.dart';
import '../models/booking.dart';
import '../models/trip_rating.dart';
import '../models/message.dart';
import '../utils/dialog_helper.dart';
import '../l10n/app_localizations.dart';
import '../widgets/scroll_indicator.dart';
import '../widgets/language_selector.dart';
import '../widgets/seat_layout_widget.dart';
import '../widgets/booking_card_widget.dart';
import 'chat_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  final int initialTabIndex;

  const MyBookingsScreen({super.key, this.initialTabIndex = 0});

  @override
  State<MyBookingsScreen> createState() => MyBookingsScreenState();
}

class MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  final BookingStorage _bookingStorage = BookingStorage();
  bool _showOlderPastBookings = false; // Archived starts folded
  bool _showUpcoming = true;
  bool _showOngoing = true;
  bool _showCompleted = true;
  bool _showCanceled = false; // Canceled starts folded
  final ScrollController _driverScrollController = ScrollController();
  final ScrollController _riderScrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  void switchToTab(int tabIndex) {
    if (mounted && _tabController.index != tabIndex) {
      _tabController.animateTo(tabIndex);
    }
  }

  @override
  void dispose() {
    _driverScrollController.dispose();
    _riderScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = AuthService.currentUser;

    return Scaffold(
      key: ValueKey(currentUser?.id ?? 'no-user'), // Force rebuild when user changes
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
      body: Column(
        children: [
          // Toggle style tab buttons (same as booking widget)
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: AnimatedBuilder(
              animation: _tabController,
              builder: (context, child) {
                return Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildToggleButton(
                          context,
                          label: l10n.driver,
                          icon: Icons.directions_car,
                          isSelected: _tabController.index == 0,
                          isLeft: true,
                          onTap: () {
                            _tabController.animateTo(0);
                          },
                        ),
                        _buildToggleButton(
                          context,
                          label: l10n.rider,
                          icon: Icons.person,
                          isSelected: _tabController.index == 1,
                          isLeft: false,
                          onTap: () {
                            _tabController.animateTo(1);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBookingsList('driver', _driverScrollController),
                _buildBookingsList('rider', _riderScrollController),
              ],
            ),
          ),
        ],
      ),
    );
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

  Widget _buildToggleButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isLeft,
    required VoidCallback onTap,
  }) {
    // Responsive sizing based on platform
    final isMobileApp = _isMobileApp();
    final isMobileWeb = _isMobileWeb(context);

    // Different padding and sizes for each platform
    // Mobile App: compact, Mobile Web: medium, Desktop Web: larger
    final horizontalPadding = isMobileApp ? 16.0 : (isMobileWeb ? 20.0 : 24.0);
    final verticalPadding = isMobileApp ? 8.0 : (isMobileWeb ? 10.0 : 12.0);
    final iconSize = isMobileApp ? 16.0 : (isMobileWeb ? 18.0 : 20.0);
    final fontSize = isMobileApp ? 13.0 : (isMobileWeb ? 14.0 : 15.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFDD2C00) : Colors.white,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? Radius.circular(19) : Radius.zero,
            right: isLeft ? Radius.zero : Radius.circular(19),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: iconSize,
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(
    String userRole,
    ScrollController scrollController,
  ) {
    return ValueListenableBuilder(
      valueListenable: _bookingStorage.bookings,
      builder: (context, List<Booking> bookings, child) {
        final l10n = AppLocalizations.of(context)!;
        final now = DateTime.now();

        // Get the localized role name for comparison
        final localizedRole = userRole.toLowerCase() == 'driver' 
            ? l10n.driver.toLowerCase() 
            : l10n.rider.toLowerCase();

        // Filter bookings based on user and role
        // Compare with both English role and localized role for compatibility
        final user = AuthService.currentUser;
        final userBookings = bookings
            .where(
              (b) =>
                  b.userId == user?.id &&
                  (b.userRole.toLowerCase() == userRole.toLowerCase() ||
                   b.userRole.toLowerCase() == localizedRole),
            )
            .toList();

        // Debug: Print all user bookings
        print('🔍 MyBookings: user=${user?.id}, role=$userRole, localizedRole=$localizedRole');
        print('🔍 MyBookings: total bookings=${bookings.length}, userBookings=${userBookings.length}');
        for (final b in userBookings) {
          print('🔍 Booking: id=${b.id}, departure=${b.departureTime}, arrival=${b.arrivalTime}, role=${b.userRole}, canceled=${b.isCanceled}, archived=${b.isArchived}');
        }

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
              ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

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
              ..sort((a, b) => b.departureTime.compareTo(a.departureTime));
        
        print('🔍 MyBookings: now=$now, ongoing=${ongoingBookings.length}');

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
              ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

        final canceledBookings =
            userBookings
                .where((b) => b.isCanceled == true && (b.isArchived != true))
                .toList()
              ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

        // Archived bookings (exclude hidden ones - those are completely hidden from UI)
        final archivedBookings =
            userBookings.where((b) => b.isArchived == true && b.isHidden != true).toList()
              ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

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
          scrollController: scrollController,
          child: CustomScrollView(
            controller: scrollController,
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

  Future<void> _cancelBooking(Booking booking) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await DialogHelper.showConfirmDialog(
      context: context,
      title: 'Cancel Booking',
      content: 'Are you sure you want to cancel this booking?',
      cancelText: 'No',
      confirmText: 'Yes, Cancel',
      isDangerous: true,
    );

    if (confirmed) {
      final currentUser = AuthService.currentUser;
      final isDriver = booking.userRole.toLowerCase() == 'driver';

      // Send system notification to affected parties before canceling
      final messagingService = MessagingService();

      if (isDriver) {
        // Driver canceled - notify all riders in existing conversations
        final notificationContent = l10n.systemNotificationDriverCanceled(
          currentUser?.fullName ?? 'Driver',
          booking.route.name,
        );
        messagingService.sendSystemNotificationForBooking(
          bookingId: booking.id,
          content: notificationContent,
          excludeUserId: currentUser?.id,
        );
      } else {
        // Rider canceled - notify the driver
        final notificationContent = l10n.systemNotificationRiderCanceled(
          currentUser?.fullName ?? 'Rider',
        );
        messagingService.sendSystemNotificationForBooking(
          bookingId: booking.id,
          content: notificationContent,
          excludeUserId: currentUser?.id,
        );
      }

      BookingStorage().cancelBooking(booking.id);
    }
  }

  Future<void> _archiveBooking(Booking booking) async {
    final isArchived = booking.isArchived == true;
    final confirmed = await DialogHelper.showConfirmDialog(
      context: context,
      title: isArchived ? 'Unarchive Booking' : 'Archive Booking',
      content: isArchived
          ? 'Are you sure you want to unarchive this booking?'
          : 'Are you sure you want to archive this booking?',
      cancelText: 'No',
      confirmText: isArchived ? 'Yes, Unarchive' : 'Yes, Archive',
    );

    if (confirmed) {
      if (isArchived) {
        BookingStorage().unarchiveBooking(booking.id);
      } else {
        BookingStorage().archiveBooking(booking.id);
      }
    }
  }

  Widget _buildBookingCard(
    Booking booking, {
    required bool isPast,
    bool isCanceled = false,
    bool isOngoing = false,
    bool isArchived = false,
  }) {
    return BookingCard(
      booking: booking,
      isPast: isPast,
      isCanceled: isCanceled,
      isOngoing: isOngoing,
      isArchived: isArchived,
      onCancel: () => _cancelBooking(booking),
      onArchive: () => _archiveBooking(booking),
      showActions: true, // Show action buttons in My Bookings
      showSeatsForCanceled: false, // Don't show seats for canceled rides
      isCollapsible: false, // Individual cards are not collapsible
      buildMiniatureSeatLayout: (selectedSeats, booking) =>
          _buildMiniatureSeatLayout(selectedSeats, booking),
    );
  }

  Widget _buildMiniatureSeatLayout(List<int> selectedSeats, Booking booking) {
    // Use the centralized seat layout widget
    return SeatLayoutWidget(
      booking: booking,
      isInteractive: false,
      currentUserId: AuthService.currentUser?.id,
      onDriverPhotoTap: () {
        _showUserActionDialog(booking, isDriver: true);
      },
      onRiderPhotoTap: (seatIndex) {
        _showUserActionDialog(booking, isDriver: false, riderSeatIndex: seatIndex);
      },
    );
  }

  Widget _buildUserCardAvatar(String? profilePhotoUrl) {
    print('🖼️ Building user card avatar with URL: $profilePhotoUrl');

    if (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty) {
      // Check if it's an asset image
      if (profilePhotoUrl.startsWith('assets/')) {
        print('🖼️ Loading asset image: $profilePhotoUrl');
        return CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey[300],
          child: ClipOval(
            child: Image.asset(
              profilePhotoUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('❌ Error loading asset: $error');
                return Icon(Icons.person, size: 40, color: Colors.grey[600]);
              },
            ),
          ),
        );
      } else {
        // Local file path
        print('🖼️ Loading file image: $profilePhotoUrl');
        final photoFile = File(profilePhotoUrl);
        if (photoFile.existsSync()) {
          return CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[300],
            child: ClipOval(
              child: Image.file(
                photoFile,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          print('❌ File does not exist: $profilePhotoUrl');
        }
      }
    } else {
      print('⚠️ No profile photo URL provided');
    }

    // Default placeholder
    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.grey[300],
      child: Icon(Icons.person, size: 40, color: Colors.grey[600]),
    );
  }

  // Show dialog with options to message or rate a user
  void _showUserActionDialog(Booking booking, {required bool isDriver, int? riderSeatIndex}) {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;

    final l10n = AppLocalizations.of(context)!;
    
    // Determine if current user is the driver of this booking
    final currentUserIsDriver = booking.userId == currentUser.id && booking.userRole.toLowerCase() == 'driver';
    
    // Get the other user's info
    String otherUserName;
    String? profilePhotoUrl;
    String? otherUserId;
    
    if (isDriver) {
      // Clicked on driver photo - always look up from MockUsers first
      final driverId = booking.driverUserId ?? booking.userId;
      final driver = MockUsers.getUserById(driverId);
      if (driver != null) {
        otherUserName = driver.name;
        if (driver.surname.isNotEmpty) {
          otherUserName = '${driver.name} ${driver.surname[0]}.';
        }
      } else {
        otherUserName = booking.driverName ?? 'Driver';
      }
      profilePhotoUrl = driver?.profilePhotoUrl;
      otherUserId = driverId;
    } else if (riderSeatIndex != null && booking.riders != null) {
      // Clicked on rider photo
      final rider = booking.riders!.firstWhere(
        (r) => r.seatIndex == riderSeatIndex,
        orElse: () => RiderInfo(userId: '', name: '', rating: 0.0, seatIndex: -1),
      );
      otherUserName = rider.name;
      profilePhotoUrl = rider.profilePhotoUrl;
      otherUserId = rider.userId;
    } else {
      return;
    }
    
    // Get live rating from RatingService
    final rating = otherUserId.isNotEmpty 
        ? MockUsers.getLiveRating(otherUserId) 
        : 0.0;
    // Determine if messaging is allowed based on rules:
    // - Riders can message driver only
    // - Drivers can message riders
    // - Riders cannot message other riders
    bool canMessage = false;
    if (currentUserIsDriver) {
      // Driver can message any rider
      canMessage = !isDriver; // Can't message themselves if they're the driver
    } else {
      // Rider can only message driver
      canMessage = isDriver;
    }

    // Check if this is the current user's own card (can't rate yourself)
    bool isSelf = false;
    if (isDriver) {
      final driverId = booking.driverUserId ?? booking.userId;
      isSelf = driverId == currentUser.id;
    } else if (riderSeatIndex != null && booking.riders != null) {
      final rider = booking.riders!.firstWhere(
        (r) => r.seatIndex == riderSeatIndex,
        orElse: () => RiderInfo(userId: '', name: '', rating: 0.0, seatIndex: -1),
      );
      isSelf = rider.userId == currentUser.id;
    }

    // Check if rating is allowed (1 hour after arrival time)
    final now = DateTime.now();
    final ratingAllowedTime = booking.arrivalTime.add(Duration(hours: 1));
    final canRate = now.isAfter(ratingAllowedTime);

    // Check if user has already rated this person for this trip
    final hasAlreadyRated = otherUserId.isNotEmpty
        ? RatingService().hasRated(booking.id, currentUser.id, otherUserId)
        : false;
    final existingRating = hasAlreadyRated
        ? RatingService().getRating(booking.id, currentUser.id, otherUserId)
        : null;

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
                // User avatar
                _buildUserCardAvatar(profilePhotoUrl),
                SizedBox(height: 16),
                
                // User name
                Text(
                  otherUserName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                
                // Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                
                // Action buttons
                if (canMessage)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _navigateToChat(booking, isDriver, riderSeatIndex);
                    },
                    icon: Icon(Icons.message),
                    label: Text(l10n.message),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                
                if (canMessage) SizedBox(height: 12),

                // Show rate button or existing rating
                if (!isSelf && canRate && !hasAlreadyRated)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showSimpleRatingDialog(booking, isDriver, otherUserName);
                    },
                    icon: Icon(Icons.star_rate),
                    label: Text(l10n.rate),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                    ),
                  ),

                // Show the rating the user gave
                if (!isSelf && hasAlreadyRated && existingRating != null)
                  Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.yourRating,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        ...List.generate(
                          existingRating.averageRating.toInt(),
                          (index) => Icon(Icons.star, color: Colors.white, size: 20),
                        ),
                        ...List.generate(
                          5 - existingRating.averageRating.toInt(),
                          (index) => Icon(Icons.star_border, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),

                if (!isSelf && canRate) SizedBox(height: 12),
                
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                  ),
                  child: Text(l10n.cancel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToChat(Booking booking, bool isClickedOnDriver, int? riderSeatIndex) {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;

    // Determine driver and rider info
    String driverId;
    String driverName;
    String riderId;
    String riderName;

    final currentUserIsDriver = booking.userId == currentUser.id && booking.userRole.toLowerCase() == 'driver';

    if (currentUserIsDriver) {
      // Current user is driver, messaging a rider
      driverId = currentUser.id;
      driverName = '${currentUser.name} ${currentUser.surname[0]}.';
      
      if (riderSeatIndex != null && booking.riders != null) {
        final rider = booking.riders!.firstWhere(
          (r) => r.seatIndex == riderSeatIndex,
          orElse: () => RiderInfo(userId: '', name: '', rating: 0.0, seatIndex: -1),
        );
        riderId = rider.userId;  // Use the actual user ID from RiderInfo
        riderName = rider.name;
        
        // Prevent messaging yourself
        if (riderId == currentUser.id) {
          return;
        }
      } else {
        return; // No rider found
      }
    } else {
      // Current user is rider, messaging driver
      riderId = currentUser.id;
      riderName = '${currentUser.name} ${currentUser.surname[0]}.';
      
      driverId = booking.driverUserId ?? booking.userId;
      
      // Prevent messaging yourself
      if (driverId == currentUser.id) {
        return;
      }
      
      // Always look up driver name from MockUsers first for accuracy
      final driver = MockUsers.getUserById(driverId);
      if (driver != null) {
        driverName = driver.name;
        if (driver.surname.isNotEmpty) {
          driverName = '${driver.name} ${driver.surname[0]}.';
        }
      } else {
        driverName = booking.driverName ?? 'Driver';
      }
    }

    // Extract base driver booking ID for consistent conversation ID
    // Rider bookings have format: driverBookingId_rider_userId
    String baseBookingId = booking.id;
    if (booking.id.contains('_rider_')) {
      baseBookingId = booking.id.split('_rider_')[0];
    }

    // Create conversation object with consistent ID regardless of who initiates
    final conversation = Conversation(
      id: '${baseBookingId}_${driverId}_$riderId',
      bookingId: baseBookingId,
      driverId: driverId,
      driverName: driverName,
      riderId: riderId,
      riderName: riderName,
      routeName: booking.route.name,
      originName: booking.originName,
      destinationName: booking.destinationName,
      departureTime: booking.departureTime,
      arrivalTime: booking.arrivalTime,
    );

    print('💬 MyBookings: Creating conversation with ID: ${conversation.id}');
    print('   original bookingId: ${booking.id}');
    print('   baseBookingId: $baseBookingId');
    print('   driverId: $driverId, driverName: $driverName');
    print('   riderId: $riderId, riderName: $riderName');
    print('   currentUserIsDriver: $currentUserIsDriver');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversation: conversation,
          createConversationOnFirstMessage: true,
        ),
      ),
    );
  }

  void _showSimpleRatingDialog(Booking booking, bool isDriver, String otherUserName) {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;

    final l10n = AppLocalizations.of(context)!;

    // Get the actual other user ID to check for self-rating
    String otherUserId;
    if (isDriver) {
      // Rating the driver
      otherUserId = booking.driverUserId ?? booking.userId;
    } else {
      // Rating a rider - need to find by name
      final rider = booking.riders?.firstWhere(
        (r) => r.name == otherUserName,
        orElse: () => RiderInfo(userId: '', name: '', rating: 0.0, seatIndex: -1),
      );
      otherUserId = rider?.userId ?? '';
    }
    
    // Prevent rating yourself
    if (otherUserId == currentUser.id) {
      return;
    }

    // Check if already rated
    final hasAlreadyRated = RatingService().hasRated(booking.id, currentUser.id, otherUserId);

    if (hasAlreadyRated) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.snackbarAlreadyRated(otherUserName)),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Initialize ratings for 5 categories (0 or 1 for each)
    int polite = 0;
    int clean = 0;
    int communicative = 0;
    int safe = 0;
    int punctual = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Calculate total stars (sum of selected categories)
            final totalStars = polite + clean + communicative + safe + punctual;
            final canSubmit = totalStars > 0; // At least one category must be selected

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.rateUser(otherUserName),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E2E),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Rating categories - reordered: Safe, Punctual, Clean, Polite, Communicative
                      _buildInlineRatingCategory(
                        l10n.safe,
                        Icons.security,
                        safe,
                        (rating) => setState(() => safe = rating),
                      ),
                      SizedBox(height: 8),
                      _buildInlineRatingCategory(
                        l10n.punctual,
                        Icons.schedule,
                        punctual,
                        (rating) => setState(() => punctual = rating),
                      ),
                      SizedBox(height: 8),
                      _buildInlineRatingCategory(
                        l10n.clean,
                        Icons.cleaning_services,
                        clean,
                        (rating) => setState(() => clean = rating),
                      ),
                      SizedBox(height: 8),
                      _buildInlineRatingCategory(
                        l10n.polite,
                        Icons.sentiment_satisfied_alt,
                        polite,
                        (rating) => setState(() => polite = rating),
                      ),
                      SizedBox(height: 8),
                      _buildInlineRatingCategory(
                        l10n.communicative,
                        Icons.chat_bubble_outline,
                        communicative,
                        (rating) => setState(() => communicative = rating),
                      ),
                      SizedBox(height: 20),

                      // Submit button with stars display
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: canSubmit ? () {
                            _submitDetailedRating(
                              booking,
                              isDriver,
                              otherUserName,
                              polite,
                              clean,
                              communicative,
                              safe,
                              punctual,
                            );
                            Navigator.pop(context);
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...List.generate(
                                totalStars,
                                (index) => Icon(Icons.star, size: 24),
                              ),
                              ...List.generate(
                                5 - totalStars,
                                (index) => Icon(Icons.star_border, size: 24),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.cancel),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInlineRatingCategory(
    String title,
    IconData icon,
    int currentRating,
    Function(int) onRatingChanged,
  ) {
    final isSelected = currentRating == 1;

    return GestureDetector(
      onTap: () => onRatingChanged(isSelected ? 0 : 1),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.amber[700] : Colors.grey[600],
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Color(0xFF2E2E2E) : Colors.grey[700],
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  void _submitDetailedRating(
    Booking booking,
    bool isDriver,
    String otherUserName,
    int polite,
    int clean,
    int communicative,
    int safe,
    int punctual,
  ) {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;

    // Get the actual other user ID (same logic as in _showSimpleRatingDialog)
    String otherUserId;
    if (isDriver) {
      // Rating the driver
      otherUserId = booking.driverUserId ?? booking.userId;
    } else {
      // Rating a rider - need to find by name
      final rider = booking.riders?.firstWhere(
        (r) => r.name == otherUserName,
        orElse: () => RiderInfo(userId: '', name: '', rating: 0.0, seatIndex: -1),
      );
      otherUserId = rider?.userId ?? '';
    }

    // Generate rating ID
    final ratingId =
        '${booking.id}_${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}';

    // Create rating
    final rating = TripRating(
      id: ratingId,
      bookingId: booking.id,
      fromUserId: currentUser.id,
      toUserId: otherUserId,
      toUserName: otherUserName,
      polite: polite,
      clean: clean,
      communicative: communicative,
      safe: safe,
      punctual: punctual,
      ratedAt: DateTime.now(),
    );

    // Submit to service
    RatingService().submitRating(rating);

    // Show success message
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.snackbarRatingSubmitted(rating.averageRating.toStringAsFixed(1), otherUserName)),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
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
                    // Chevron icon for collapsible sections
                    if (isCollapsible) ...[
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                        color: textColor,
                      ),
                      SizedBox(width: 4),
                    ],
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
