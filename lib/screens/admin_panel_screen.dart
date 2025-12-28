import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/booking_storage.dart';
import '../services/messaging_service.dart';
import '../services/rating_service.dart';
import '../services/mock_users.dart';
import '../models/user.dart';
import '../models/booking.dart';
import '../models/message.dart';
import '../models/trip_rating.dart';
import '../widgets/booking_card_widget.dart';
import '../widgets/seat_layout_widget.dart';
import '../utils/dialog_helper.dart';
import '../utils/date_time_helpers.dart';
import 'chat_screen.dart';

/// Navigation context for preserving exact state when navigating to user cards
class AdminNavigationContext {
  final int sourceTabIndex;
  final Conversation? conversation; // For returning to ChatScreen
  final Booking? booking; // For scrolling to specific booking
  final String? ratingId; // For scrolling to specific rating
  final bool fromChatScreen; // True if navigation started from inside a chat

  AdminNavigationContext({
    required this.sourceTabIndex,
    this.conversation,
    this.booking,
    this.ratingId,
    this.fromChatScreen = false,
  });
}

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<_BookingsTabState> _bookingsTabKey = GlobalKey<_BookingsTabState>();
  final GlobalKey<_MessagesTabState> _messagesTabKey = GlobalKey<_MessagesTabState>();
  final GlobalKey<_RatingsTabState> _ratingsTabKey = GlobalKey<_RatingsTabState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToUser(User user, {AdminNavigationContext? navContext}) {
    // Use provided context or create one from current tab
    final context = navContext ?? AdminNavigationContext(
      sourceTabIndex: _tabController.index,
    );

    // Switch to Users tab (index 0)
    _tabController.animateTo(0);
    // Show user details modal with navigation context
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        _showUserDetails(this.context, user, navContext: context);
      }
    });
  }

  String _getTabName(int index) {
    switch (index) {
      case 0: return 'Users';
      case 1: return 'Bookings';
      case 2: return 'Messages';
      case 3: return 'Ratings';
      default: return '';
    }
  }

  String _getBackLabel(AdminNavigationContext navContext) {
    // If coming from a chat, show "Chat"
    if (navContext.conversation != null) {
      return 'Chat';
    }
    return _getTabName(navContext.sourceTabIndex);
  }

  void _navigateBack(AdminNavigationContext navContext) {
    // First switch to the source tab
    _tabController.animateTo(navContext.sourceTabIndex);

    // If we need to restore a chat screen (only if came from inside a chat, not from message list)
    if (navContext.conversation != null && navContext.fromChatScreen && navContext.sourceTabIndex == 2) {
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                conversation: navContext.conversation!,
                isAdminView: true,
                onNavigateToUser: (user, conv) {
                  Navigator.pop(context);
                  _navigateToUser(
                    user,
                    navContext: AdminNavigationContext(
                      sourceTabIndex: 2,
                      conversation: conv,
                      fromChatScreen: true,
                    ),
                  );
                },
              ),
            ),
          );
        }
      });
    }

    // If we need to scroll to a specific booking
    if (navContext.booking != null && navContext.sourceTabIndex == 1) {
      Future.delayed(Duration(milliseconds: 300), () {
        _bookingsTabKey.currentState?.scrollToBooking(navContext.booking!);
      });
    }

    // If we need to scroll to a specific rating
    if (navContext.ratingId != null && navContext.sourceTabIndex == 3) {
      Future.delayed(Duration(milliseconds: 300), () {
        _ratingsTabKey.currentState?.scrollToRating(navContext.ratingId!);
      });
    }
  }

  void _showUserDetails(BuildContext context, User user, {AdminNavigationContext? navContext}) {
    final bookings = BookingStorage().getBookingsForUser(user.id);
    final conversations = MessagingService()
        .getConversationsForUser(user.id)
        .where((c) => c.messages.isNotEmpty)
        .toList();
    final ratings = RatingService().getRatingsForUser(user.id);

    // Only show back button if navigating from a different tab
    final showBackButton = navContext != null && navContext.sourceTabIndex != 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFDD2C00),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  // Back button to source location
                  if (showBackButton)
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _navigateBack(navContext);
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chevron_left, color: Colors.white, size: 20),
                            Text(
                              _getBackLabel(navContext),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage: user.profilePhotoUrl != null
                        ? (user.profilePhotoUrl!.startsWith('http')
                            ? NetworkImage(user.profilePhotoUrl!) as ImageProvider
                            : AssetImage(user.profilePhotoUrl!))
                        : null,
                    child: user.profilePhotoUrl == null
                        ? Icon(
                            user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                            color: Color(0xFFDD2C00),
                            size: 30,
                          )
                        : null,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _UserDetailsContent(
                user: user,
                bookings: bookings,
                conversations: conversations,
                ratings: ratings,
                scrollController: scrollController,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.currentUser;

    // Only allow access to admin users
    if (currentUser == null || !currentUser.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Access Denied'),
          backgroundColor: Color(0xFFDD2C00),
        ),
        body: Center(
          child: Text('You do not have permission to access this page.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        backgroundColor: Color(0xFFDD2C00),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 11),
          tabs: [
            Tab(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, size: 14),
                  Icon(Icons.person, size: 14),
                ],
              ),
              text: 'Users',
            ),
            Tab(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_seat, size: 14),
                  Icon(Icons.event_seat, size: 14),
                ],
              ),
              text: 'Bookings',
            ),
            Tab(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.message, size: 14),
                  Icon(Icons.message, size: 14),
                ],
              ),
              text: 'Messages',
            ),
            Tab(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 14),
                  Icon(Icons.star, size: 14),
                ],
              ),
              text: 'Ratings',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _UsersTab(onNavigateToUser: _navigateToUser),
          _BookingsTab(key: _bookingsTabKey, onNavigateToUser: _navigateToUser),
          _MessagesTab(key: _messagesTabKey, onNavigateToUser: _navigateToUser),
          _RatingsTab(key: _ratingsTabKey, onNavigateToUser: _navigateToUser),
        ],
      ),
    );
  }
}

// Users Management Tab
class _UsersTab extends StatelessWidget {
  final void Function(User user, {AdminNavigationContext? navContext})? onNavigateToUser;

  const _UsersTab({this.onNavigateToUser});

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = MockUsers.users;

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        // Get live rating from RatingService
        final liveRating = RatingService().getUserAverageRating(user.id);
        final userWithLiveRating = user.copyWith(rating: liveRating);

        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => _showUserDetails(context, userWithLiveRating),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top row: Profile photo + User info
                  Row(
                    children: [
                      // Profile photo and rating
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: userWithLiveRating.profilePhotoUrl != null
                                ? (userWithLiveRating.profilePhotoUrl!.startsWith('http')
                                    ? NetworkImage(userWithLiveRating.profilePhotoUrl!) as ImageProvider
                                    : AssetImage(userWithLiveRating.profilePhotoUrl!))
                                : null,
                            child: userWithLiveRating.profilePhotoUrl == null
                                ? Icon(
                                    userWithLiveRating.isAdmin ? Icons.admin_panel_settings : Icons.person,
                                    color: Colors.white,
                                    size: 24,
                                  )
                                : null,
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 12, color: Colors.amber),
                              SizedBox(width: 2),
                              Text(
                                userWithLiveRating.rating.toStringAsFixed(1),
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2E2E2E)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: 12),
                      // User information
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Name with admin badge and copy icon
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          userWithLiveRating.fullName,
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2E2E2E)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (userWithLiveRating.isAdmin)
                                        Container(
                                          margin: EdgeInsets.only(left: 6),
                                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.orange[50],
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Admin',
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.orange[900]),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _copyToClipboard(context, userWithLiveRating.fullName, 'Name'),
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Icon(Icons.copy, size: 14, color: Colors.grey[400]),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            // ID with copy icon
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'ID: ${userWithLiveRating.id}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _copyToClipboard(context, userWithLiveRating.id, 'ID'),
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Icon(Icons.copy, size: 12, color: Colors.grey[400]),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showUserDetails(BuildContext context, User user) {
    final bookings = BookingStorage().getBookingsForUser(user.id);
    // Filter out empty conversations (same as inbox) to sync data
    final conversations = MessagingService()
        .getConversationsForUser(user.id)
        .where((c) => c.messages.isNotEmpty)
        .toList();
    final ratings = RatingService().getRatingsForUser(user.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFDD2C00),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage: user.profilePhotoUrl != null
                        ? (user.profilePhotoUrl!.startsWith('http')
                            ? NetworkImage(user.profilePhotoUrl!) as ImageProvider
                            : AssetImage(user.profilePhotoUrl!))
                        : null,
                    child: user.profilePhotoUrl == null
                        ? Icon(
                            user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                            color: Color(0xFFDD2C00),
                            size: 30,
                          )
                        : null,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _UserDetailsContent(
                user: user,
                bookings: bookings,
                conversations: conversations,
                ratings: ratings,
                scrollController: scrollController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bookings Management Tab
class _BookingsTab extends StatefulWidget {
  final void Function(User user, {AdminNavigationContext? navContext})? onNavigateToUser;

  const _BookingsTab({super.key, this.onNavigateToUser});

  @override
  State<_BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<_BookingsTab> {
  final ScrollController _scrollController = ScrollController();
  String? _highlightedBookingId;
  final GlobalKey _highlightedBookingKey = GlobalKey();
  bool _isScrollingToBooking = false; // Prevents clearing highlight during auto-scroll

  @override
  void initState() {
    super.initState();
    // Clear highlight when user manually scrolls
    _scrollController.addListener(_onUserScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onUserScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onUserScroll() {
    // Only clear highlight if user is manually scrolling (not auto-scroll)
    if (_highlightedBookingId != null && !_isScrollingToBooking) {
      setState(() {
        _highlightedBookingId = null;
      });
    }
  }

  /// Scrolls to and highlights a specific booking
  void scrollToBooking(Booking booking) {
    setState(() {
      _highlightedBookingId = booking.id;
      _isScrollingToBooking = true;
    });

    // After the widget rebuilds and section expands, scroll to the booking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Small additional delay to ensure section expansion animation completes
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted && _highlightedBookingKey.currentContext != null) {
          Scrollable.ensureVisible(
            _highlightedBookingKey.currentContext!,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.3, // Position booking 30% from top
          ).then((_) {
            // Allow user scroll to clear highlight after auto-scroll completes
            if (mounted) {
              setState(() {
                _isScrollingToBooking = false;
              });
            }
          });
        } else {
          // If we couldn't scroll, still allow clearing
          if (mounted) {
            setState(() {
              _isScrollingToBooking = false;
            });
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder(
          valueListenable: BookingStorage().bookings,
          builder: (context, bookings, _) {
            return bookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No bookings yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildBookingsList(context, bookings);
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'clear_bookings',
            backgroundColor: Colors.orange[700],
            onPressed: () => _showClearDialog(context),
            child: Icon(Icons.delete_sweep, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _showClearDialog(BuildContext context) {
    final allUsers = MockUsers.users.where((u) => !u.isAdmin).toList();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Clear Bookings'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFDD2C00),
                    child: Icon(Icons.group, color: Colors.white, size: 20),
                  ),
                  title: Text('All Users', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${BookingStorage().bookings.value.length} total bookings',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  onTap: () async {
                    Navigator.pop(dialogContext);
                    await _confirmAndClear(context, null, 'all users');
                  },
                ),
                Divider(),
                ...allUsers.map((user) {
                  final count = BookingStorage().countBookingsForUser(user.id)['total'] ?? 0;
                  final photoUrl = user.profilePhotoUrl;
                  final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundImage: hasPhoto ? AssetImage(photoUrl) : null,
                      backgroundColor: Colors.grey[300],
                      child: !hasPhoto ? Icon(Icons.person, color: Colors.grey[600]) : null,
                    ),
                    title: Text('${user.name} ${user.surname}'),
                    subtitle: Text('$count bookings', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    trailing: count > 0
                        ? Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(0xFFDD2C00).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('$count', style: TextStyle(color: Color(0xFFDD2C00), fontWeight: FontWeight.w600, fontSize: 12)),
                          )
                        : null,
                    onTap: count > 0
                        ? () async {
                            Navigator.pop(dialogContext);
                            await _confirmAndClear(context, user.id, '${user.name} ${user.surname}');
                          }
                        : null,
                    enabled: count > 0,
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel, style: TextStyle(color: Color(0xFFDD2C00))),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmAndClear(BuildContext context, String? userId, String displayName) async {
    final l10n = AppLocalizations.of(context)!;
    final content = userId == null
        ? 'Are you sure you want to clear ALL bookings for all users?'
        : 'Are you sure you want to clear all bookings for $displayName?';

    final confirmed = await DialogHelper.showConfirmDialog(
      context: context,
      title: 'Clear Bookings',
      content: content,
      cancelText: l10n.cancel,
      confirmText: 'Clear',
      isDangerous: true,
    );

    if (!confirmed) return;

    int clearedCount;
    if (userId == null) {
      clearedCount = BookingStorage().bookings.value.length;
      BookingStorage().clearAllBookings();
    } else {
      clearedCount = BookingStorage().clearBookingsForUser(userId);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cleared $clearedCount bookings'),
          backgroundColor: Color(0xFF00C853),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildBookingsList(BuildContext context, List bookings) {
    // Only show driver bookings (rider bookings are duplicates - rider info shown in seat layout)
    final driverBookings = bookings.where((b) => b.userRole.toLowerCase() == 'driver').cast<Booking>().toList();
    final now = DateTime.now();

    // Upcoming: departure time is in the future
    final upcomingBookings = driverBookings
        .where((b) =>
            b.departureTime.isAfter(now) &&
            (b.isCanceled != true) &&
            (b.isArchived != true))
        .toList()
      ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

    // Ongoing: departure time has passed but arrival time hasn't
    final ongoingBookings = driverBookings
        .where((b) =>
            b.departureTime.isBefore(now) &&
            b.arrivalTime.isAfter(now) &&
            (b.isCanceled != true) &&
            (b.isArchived != true))
        .toList()
      ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

    // Completed: arrival time has passed
    final completedBookings = driverBookings
        .where((b) =>
            b.arrivalTime.isBefore(now) &&
            (b.isCanceled != true) &&
            (b.isArchived != true))
        .toList()
      ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

    // Canceled bookings
    final canceledBookings = driverBookings
        .where((b) => b.isCanceled == true && (b.isArchived != true))
        .toList()
      ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

    // Archived bookings (archived but NOT hidden)
    final archivedBookings = driverBookings
        .where((b) => b.isArchived == true && b.isHidden != true)
        .toList()
      ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

    // Hidden bookings (archived AND hidden)
    final hiddenBookings = driverBookings
        .where((b) => b.isArchived == true && b.isHidden == true)
        .toList()
      ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      children: [
        if (upcomingBookings.isNotEmpty)
          _CollapsibleBookingSection(
            title: 'Upcoming',
            count: upcomingBookings.length,
            bookings: upcomingBookings,
            buildBookingCard: (booking) => _buildBookingCard(context, booking, cardsCollapsible: true),
            startCollapsed: true,
            color: Colors.blue[700],
            highlightedBookingId: _highlightedBookingId,
          ),
        if (ongoingBookings.isNotEmpty)
          _CollapsibleBookingSection(
            title: 'Ongoing',
            count: ongoingBookings.length,
            bookings: ongoingBookings,
            buildBookingCard: (booking) => _buildBookingCard(context, booking, cardsCollapsible: true),
            startCollapsed: false,
            color: Colors.orange[700],
            highlightedBookingId: _highlightedBookingId,
          ),
        if (completedBookings.isNotEmpty)
          _CollapsibleBookingSection(
            title: 'Completed',
            count: completedBookings.length,
            bookings: completedBookings,
            buildBookingCard: (booking) => _buildBookingCard(context, booking, cardsCollapsible: true),
            startCollapsed: true,
            color: Colors.green[700],
            highlightedBookingId: _highlightedBookingId,
          ),
        if (canceledBookings.isNotEmpty)
          _CollapsibleBookingSection(
            title: 'Canceled',
            count: canceledBookings.length,
            bookings: canceledBookings,
            buildBookingCard: (booking) => _buildBookingCard(context, booking, cardsCollapsible: true),
            startCollapsed: true,
            color: Colors.red[700],
            highlightedBookingId: _highlightedBookingId,
          ),
        if (archivedBookings.isNotEmpty)
          _CollapsibleBookingSection(
            title: 'Archived',
            count: archivedBookings.length,
            bookings: archivedBookings,
            buildBookingCard: (booking) => _buildBookingCard(context, booking, cardsCollapsible: true),
            startCollapsed: true,
            color: Colors.grey[700],
            highlightedBookingId: _highlightedBookingId,
          ),
        if (hiddenBookings.isNotEmpty)
          _CollapsibleBookingSection(
            title: 'Hidden',
            count: hiddenBookings.length,
            bookings: hiddenBookings,
            buildBookingCard: (booking) => _buildBookingCard(context, booking, cardsCollapsible: true),
            startCollapsed: true,
            color: Colors.purple[700],
            highlightedBookingId: _highlightedBookingId,
          ),
      ],
    );
  }

  Widget _buildBookingCard(BuildContext context, Booking booking, {bool cardsCollapsible = false}) {
    final isPast = booking.arrivalTime.isBefore(DateTime.now());
    final isOngoing = booking.departureTime.isBefore(DateTime.now()) && booking.arrivalTime.isAfter(DateTime.now());
    final isHighlighted = _highlightedBookingId == booking.id;

    Widget card = BookingCard(
      booking: booking,
      isPast: isPast,
      isCanceled: booking.isCanceled == true,
      isOngoing: isOngoing,
      isArchived: booking.isArchived == true,
      showActions: false, // Admin panel doesn't show action buttons
      showSeatsForCanceled: true, // Admin can see seats even for canceled rides
      isCollapsible: cardsCollapsible,
      initiallyExpanded: isHighlighted, // Expand if highlighted
      buildMiniatureSeatLayout: (selectedSeats, booking) =>
          _buildMiniatureSeatLayout(selectedSeats, booking),
    );

    // Add highlight effect when this booking is the one we navigated back to
    if (isHighlighted) {
      return Container(
        key: _highlightedBookingKey, // GlobalKey for scrolling
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFDD2C00), width: 3),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFDD2C00).withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: card,
        ),
      );
    }

    return card;
  }

  Widget _buildMiniatureSeatLayout(List<int> selectedSeats, Booking booking) {
    return SeatLayoutWidget(
      booking: booking,
      isInteractive: false,
      currentUserId: null, // Admin view doesn't highlight specific users
      onDriverPhotoTap: widget.onNavigateToUser != null
          ? () {
              final driverId = booking.driverUserId ?? booking.userId;
              final driver = MockUsers.getUserById(driverId);
              if (driver != null) {
                widget.onNavigateToUser!(
                  driver,
                  navContext: AdminNavigationContext(
                    sourceTabIndex: 1, // Bookings tab
                    booking: booking,
                  ),
                );
              }
            }
          : null,
      onRiderPhotoTap: widget.onNavigateToUser != null
          ? (seatIndex) {
              if (booking.riders != null) {
                for (var rider in booking.riders!) {
                  if (rider.seatIndex == seatIndex) {
                    final riderUser = MockUsers.getUserById(rider.userId);
                    if (riderUser != null) {
                      widget.onNavigateToUser!(
                        riderUser,
                        navContext: AdminNavigationContext(
                          sourceTabIndex: 1, // Bookings tab
                          booking: booking,
                        ),
                      );
                    }
                    break;
                  }
                }
              }
            }
          : null,
    );
  }
}

// Messages Management Tab
class _MessagesTab extends StatefulWidget {
  final void Function(User user, {AdminNavigationContext? navContext})? onNavigateToUser;

  const _MessagesTab({super.key, this.onNavigateToUser});

  @override
  State<_MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<_MessagesTab> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder(
          valueListenable: MessagingService().conversations,
          builder: (context, conversations, _) {
            // Show all conversations with at least one message (same filter as inbox)
            final allConversations = conversations
                .where((c) => c.messages.isNotEmpty)
                .toList();

            if (allConversations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.message, size: 64, color: Colors.grey[300]),
                    SizedBox(height: 16),
                    Text(
                      'No conversations yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return _buildConversationsList(context, allConversations);
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'clear_messages',
            backgroundColor: Colors.orange[700],
            onPressed: () => _showClearDialog(context),
            child: Icon(Icons.delete_sweep, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildConversationsList(BuildContext context, List<Conversation> conversations) {
    final now = DateTime.now();

    // Helper to check booking status for a conversation
    bool isOngoing(Conversation c) {
      if (c.id.startsWith('support_')) return false;
      final booking = BookingStorage().getBookingById(c.bookingId);
      if (booking == null) return false;
      return booking.departureTime.isBefore(now) &&
          booking.arrivalTime.isAfter(now) &&
          booking.isCanceled != true &&
          booking.isArchived != true;
    }

    bool isCompleted(Conversation c) {
      if (c.id.startsWith('support_')) return false;
      final booking = BookingStorage().getBookingById(c.bookingId);
      if (booking == null) return false;
      return booking.arrivalTime.isBefore(now) &&
          booking.isCanceled != true &&
          booking.isArchived != true;
    }

    bool isUpcoming(Conversation c) {
      if (c.id.startsWith('support_')) return false;
      final booking = BookingStorage().getBookingById(c.bookingId);
      if (booking == null) return false;
      return booking.departureTime.isAfter(now) &&
          booking.isCanceled != true &&
          booking.isArchived != true;
    }

    // Categorize conversations
    final upcoming = conversations
        .where((c) => isUpcoming(c) && !c.isHidden)
        .toList()
      ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

    final ongoing = conversations
        .where((c) => isOngoing(c) && !c.isHidden)
        .toList()
      ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

    final completed = conversations
        .where((c) => isCompleted(c) && !c.isHidden)
        .toList()
      ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

    // Support subcategories - Question, Suggestion, Complaint
    // Support messages are never archived or hidden
    final supportQuestion = conversations
        .where((c) => c.id.startsWith('support_') && c.routeName.startsWith('Question'))
        .toList()
      ..sort((a, b) {
        final aLast = a.lastMessage?.timestamp ?? a.arrivalTime;
        final bLast = b.lastMessage?.timestamp ?? b.arrivalTime;
        return bLast.compareTo(aLast);
      });

    final supportSuggestion = conversations
        .where((c) => c.id.startsWith('support_') &&
            (c.routeName.startsWith('Suggestion') || c.routeName.startsWith('New Route') || c.routeName.startsWith('New Stop')))
        .toList()
      ..sort((a, b) {
        final aLast = a.lastMessage?.timestamp ?? a.arrivalTime;
        final bLast = b.lastMessage?.timestamp ?? b.arrivalTime;
        return bLast.compareTo(aLast);
      });

    final supportComplaint = conversations
        .where((c) => c.id.startsWith('support_') && c.routeName.startsWith('Complaint'))
        .toList()
      ..sort((a, b) {
        final aLast = a.lastMessage?.timestamp ?? a.arrivalTime;
        final bLast = b.lastMessage?.timestamp ?? b.arrivalTime;
        return bLast.compareTo(aLast);
      });

    // Other support (fallback)
    final supportOther = conversations
        .where((c) => c.id.startsWith('support_') &&
            !c.routeName.startsWith('Question') &&
            !c.routeName.startsWith('Complaint') &&
            !c.routeName.startsWith('Suggestion') &&
            !c.routeName.startsWith('New Route') &&
            !c.routeName.startsWith('New Stop'))
        .toList()
      ..sort((a, b) {
        final aLast = a.lastMessage?.timestamp ?? a.arrivalTime;
        final bLast = b.lastMessage?.timestamp ?? b.arrivalTime;
        return bLast.compareTo(aLast);
      });

    final archived = conversations
        .where((c) =>
            !c.id.startsWith('support_') &&
            c.isArchived &&
            !c.isHidden)
        .toList()
      ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

    final hidden = conversations
        .where((c) => !c.id.startsWith('support_') && c.isHidden)
        .toList()
      ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

    // Check if any support conversations exist
    final hasSupport = supportQuestion.isNotEmpty || supportComplaint.isNotEmpty ||
        supportSuggestion.isNotEmpty || supportOther.isNotEmpty;
    final totalSupport = supportQuestion.length + supportComplaint.length +
        supportSuggestion.length + supportOther.length;

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Support section at top with subcategories
        if (hasSupport)
          _CollapsibleSupportSection(
            totalCount: totalSupport,
            questionConversations: supportQuestion,
            suggestionConversations: supportSuggestion,
            complaintConversations: supportComplaint,
            otherConversations: supportOther,
            buildConversationCard: (c) => _buildConversationCard(context, c),
          ),
        if (upcoming.isNotEmpty)
          _CollapsibleMessageSection(
            title: 'Upcoming',
            count: upcoming.length,
            conversations: upcoming,
            buildConversationCard: (c) => _buildConversationCard(context, c),
            startCollapsed: true,
            color: Colors.blue[700],
          ),
        if (ongoing.isNotEmpty)
          _CollapsibleMessageSection(
            title: 'Ongoing',
            count: ongoing.length,
            conversations: ongoing,
            buildConversationCard: (c) => _buildConversationCard(context, c),
            startCollapsed: false,
            color: Colors.orange[700],
          ),
        if (completed.isNotEmpty)
          _CollapsibleMessageSection(
            title: 'Completed',
            count: completed.length,
            conversations: completed,
            buildConversationCard: (c) => _buildConversationCard(context, c),
            startCollapsed: true,
            color: Colors.green[700],
          ),
        if (archived.isNotEmpty)
          _CollapsibleMessageSection(
            title: 'Archived',
            count: archived.length,
            conversations: archived,
            buildConversationCard: (c) => _buildConversationCard(context, c),
            startCollapsed: true,
            color: Colors.grey[700],
          ),
        if (hidden.isNotEmpty)
          _CollapsibleMessageSection(
            title: 'Hidden',
            count: hidden.length,
            conversations: hidden,
            buildConversationCard: (c) => _buildConversationCard(context, c),
            startCollapsed: true,
            color: Colors.purple[700],
          ),
      ],
    );
  }

  Widget _buildConversationCard(BuildContext context, Conversation conversation) {
    final unreadCount = conversation.getUnreadCount('admin');
    final isSupport = conversation.id.startsWith('support_');

    // Get driver and rider info
    final driver = MockUsers.getUserById(conversation.driverId);
    final rider = MockUsers.getUserById(conversation.riderId);
    final driverRating = driver != null ? RatingService().getUserAverageRating(driver.id) : 0.0;
    final riderRating = rider != null ? RatingService().getUserAverageRating(rider.id) : 0.0;

    // Card color based on unread status
    final cardColor = unreadCount > 0 ? Colors.blue[100] : Colors.blue[50];

    // For support: driver is admin, rider is user
    // Determine which one is admin based on isAdmin property
    final isDriverAdmin = driver?.isAdmin == true;
    final leftLabel = isSupport ? (isDriverAdmin ? 'Admin' : 'User') : 'Driver';
    final rightLabel = isSupport ? (isDriverAdmin ? 'User' : 'Admin') : 'Rider';
    final leftIcon = isSupport ? (isDriverAdmin ? Icons.admin_panel_settings : Icons.person) : Icons.directions_car;
    final rightIcon = isSupport ? (isDriverAdmin ? Icons.person : Icons.admin_panel_settings) : Icons.person;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversation: conversation,
              isAdminView: true,
              onNavigateToUser: widget.onNavigateToUser != null
                  ? (user, conv) {
                      // Pop back to messages tab first
                      Navigator.pop(context);
                      // Navigate to user with conversation context for back navigation
                      widget.onNavigateToUser!(
                        user,
                        navContext: AdminNavigationContext(
                          sourceTabIndex: 2, // Messages tab
                          conversation: conv,
                          fromChatScreen: true, // Mark that we came from inside the chat
                        ),
                      );
                    }
                  : null,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 0.5),
        ),
        child: Column(
          children: [
            // Top row: Date and route info (or support type)
            _buildConversationTopRow(conversation, isSupport),
            SizedBox(height: 10),
            // Middle row: Left person - status badges - Right person
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left section with label and nested avatar
                Expanded(
                  child: Row(
                    children: [
                      // Left label with semi-circle cutout
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Label background
                          Container(
                            padding: EdgeInsets.only(left: 8, right: 28, top: 8, bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(leftIcon, size: 16, color: Colors.grey[600]),
                                SizedBox(height: 2),
                                Text(
                                  leftLabel,
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          // Avatar positioned to overlap (create cutout effect)
                          Positioned(
                            right: -18,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.withValues(alpha: 0.15), width: 2),
                                ),
                                child: _buildAvatar(driver?.profilePhotoUrl, isDriver: !isSupport, user: driver),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 24),
                      // Name and rating
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driver != null
                                  ? '${driver.name} ${driver.surname.isNotEmpty ? '${driver.surname[0]}.' : ''}'
                                  : conversation.driverName,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (driver != null && !isSupport) ...[
                              SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, size: 11, color: Colors.amber),
                                  SizedBox(width: 2),
                                  Text(
                                    driverRating.toStringAsFixed(1),
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Center: Status badges
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (unreadCount > 0)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Color(0xFFDD2C00),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$unreadCount new',
                            style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (conversation.isHidden)
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple[100],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.purple[300]!, width: 1),
                          ),
                          child: Text(
                            'Hidden',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.purple[700]),
                          ),
                        ),
                    ],
                  ),
                ),
                // Right section with label and nested avatar (mirrored)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Name and rating
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              rider != null
                                  ? '${rider.name} ${rider.surname.isNotEmpty ? '${rider.surname[0]}.' : ''}'
                                  : conversation.riderName,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (rider != null && !isSupport) ...[
                              SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, size: 11, color: Colors.amber),
                                  SizedBox(width: 2),
                                  Text(
                                    riderRating.toStringAsFixed(1),
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 24),
                      // Right label with semi-circle cutout
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Label background
                          Container(
                            padding: EdgeInsets.only(left: 28, right: 8, top: 8, bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(rightIcon, size: 16, color: Colors.grey[600]),
                                SizedBox(height: 2),
                                Text(
                                  rightLabel,
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          // Avatar positioned to overlap (create cutout effect)
                          Positioned(
                            left: -18,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.withValues(alpha: 0.15), width: 2),
                                ),
                                child: _buildAvatar(rider?.profilePhotoUrl, isDriver: false, user: rider),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Format date for conversation card
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diffDays = target.difference(today).inDays;

    if (diffDays == 0) return 'Today';
    if (diffDays == 1) return 'Tomorrow';
    if (diffDays == -1) return 'Yesterday';

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }

  // Build conversation top row (date and route info or support type)
  Widget _buildConversationTopRow(Conversation conversation, bool isSupport) {
    if (isSupport) {
      // For support conversations, show the support type
      final routeName = conversation.routeName;
      String supportType;
      Color typeColor;
      IconData typeIcon;

      if (routeName.startsWith('Question')) {
        supportType = 'Question';
        typeColor = Colors.blue;
        typeIcon = Icons.help_outline;
      } else if (routeName.startsWith('Suggestion')) {
        supportType = 'Suggestion';
        typeColor = Colors.green;
        typeIcon = Icons.lightbulb_outline;
      } else if (routeName.startsWith('Complaint')) {
        supportType = 'Complaint';
        typeColor = Colors.red;
        typeIcon = Icons.report_problem_outlined;
      } else if (routeName.startsWith('New Route Suggestion')) {
        supportType = 'New Route';
        typeColor = Colors.blue;
        typeIcon = Icons.add_road;
      } else if (routeName.startsWith('New Stop Suggestion')) {
        supportType = 'New Stop';
        typeColor = Colors.teal;
        typeIcon = Icons.add_location;
      } else {
        supportType = 'Support';
        typeColor = Colors.amber;
        typeIcon = Icons.support_agent;
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: typeColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: typeColor.withValues(alpha: 0.3), width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(typeIcon, color: typeColor, size: 14),
            SizedBox(width: 6),
            Text(
              supportType,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: typeColor),
            ),
          ],
        ),
      );
    }

    // For regular conversations, show date and times
    return Row(
      children: [
        // Date
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _formatDate(conversation.departureTime),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        SizedBox(width: 8),
        // Departure
        Expanded(
          child: Row(
            children: [
              Icon(Icons.location_on, color: Colors.green, size: 14),
              SizedBox(width: 2),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  formatTimeHHmm(conversation.departureTime),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
              ),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  conversation.originName,
                  style: TextStyle(fontSize: 11, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        // Arrival
        Expanded(
          child: Row(
            children: [
              Icon(Icons.flag, color: Colors.red, size: 14),
              SizedBox(width: 2),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  formatTimeHHmm(conversation.arrivalTime),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red[700]),
                ),
              ),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  conversation.destinationName,
                  style: TextStyle(fontSize: 11, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Build avatar widget
  Widget _buildAvatar(String? profilePhotoUrl, {required bool isDriver, User? user}) {
    final defaultIcon = isDriver ? Icons.directions_car : Icons.person;
    final defaultColor = isDriver ? Colors.blue : Colors.green;

    Widget avatar;
    if (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty) {
      if (profilePhotoUrl.startsWith('assets/')) {
        avatar = CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage(profilePhotoUrl),
        );
      } else {
        final photoFile = File(profilePhotoUrl);
        if (photoFile.existsSync()) {
          avatar = CircleAvatar(
            radius: 20,
            backgroundImage: FileImage(photoFile),
          );
        } else {
          avatar = CircleAvatar(
            radius: 20,
            backgroundColor: defaultColor.withValues(alpha: 0.1),
            child: Icon(defaultIcon, color: defaultColor),
          );
        }
      }
    } else {
      // Fallback to default icon
      avatar = CircleAvatar(
        radius: 20,
        backgroundColor: defaultColor.withValues(alpha: 0.1),
        child: Icon(defaultIcon, color: defaultColor),
      );
    }

    // Wrap with GestureDetector if user is provided and callback exists
    if (user != null && widget.onNavigateToUser != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque, // Prevent tap from bubbling to parent InkWell
        onTap: () => widget.onNavigateToUser!(
          user,
          navContext: AdminNavigationContext(
            sourceTabIndex: 2, // Messages tab
            // Don't pass conversation - tapping from message list should just go back to list, not re-open chat
          ),
        ),
        child: avatar,
      );
    }

    return avatar;
  }

  void _showClearDialog(BuildContext context) {
    final allUsers = MockUsers.users.where((u) => !u.isAdmin).toList();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Clear Messages'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFDD2C00),
                    child: Icon(Icons.group, color: Colors.white, size: 20),
                  ),
                  title: Text('All Users', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${MessagingService().conversations.value.length} total conversations',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  onTap: () async {
                    Navigator.pop(dialogContext);
                    await _confirmAndClear(context, null, 'all users');
                  },
                ),
                Divider(),
                ...allUsers.map((user) {
                  final count = MessagingService.countConversationsForUser(user.id);
                  final photoUrl = user.profilePhotoUrl;
                  final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundImage: hasPhoto ? AssetImage(photoUrl) : null,
                      backgroundColor: Colors.grey[300],
                      child: !hasPhoto ? Icon(Icons.person, color: Colors.grey[600]) : null,
                    ),
                    title: Text('${user.name} ${user.surname}'),
                    subtitle: Text('$count conversations', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    trailing: count > 0
                        ? Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(0xFFDD2C00).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('$count', style: TextStyle(color: Color(0xFFDD2C00), fontWeight: FontWeight.w600, fontSize: 12)),
                          )
                        : null,
                    onTap: count > 0
                        ? () async {
                            Navigator.pop(dialogContext);
                            await _confirmAndClear(context, user.id, '${user.name} ${user.surname}');
                          }
                        : null,
                    enabled: count > 0,
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel, style: TextStyle(color: Color(0xFFDD2C00))),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmAndClear(BuildContext context, String? userId, String displayName) async {
    final l10n = AppLocalizations.of(context)!;
    final content = userId == null
        ? 'Are you sure you want to clear ALL conversations for all users?'
        : 'Are you sure you want to clear all conversations for $displayName?';

    final confirmed = await DialogHelper.showConfirmDialog(
      context: context,
      title: 'Clear Messages',
      content: content,
      cancelText: l10n.cancel,
      confirmText: 'Clear',
      isDangerous: true,
    );

    if (!confirmed) return;

    int clearedCount;
    if (userId == null) {
      clearedCount = MessagingService().conversations.value.length;
      await MessagingService.clearAllConversations();
    } else {
      clearedCount = await MessagingService.clearConversationsForUser(userId);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cleared $clearedCount conversations'),
          backgroundColor: Color(0xFF00C853),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// Ratings Management Tab
class _RatingsTab extends StatefulWidget {
  final void Function(User user, {AdminNavigationContext? navContext})? onNavigateToUser;

  const _RatingsTab({super.key, this.onNavigateToUser});

  @override
  State<_RatingsTab> createState() => _RatingsTabState();
}

class _RatingsTabState extends State<_RatingsTab> {
  final ScrollController _scrollController = ScrollController();
  String? _highlightedRatingId;
  final GlobalKey _highlightedRatingKey = GlobalKey();
  bool _isScrollingToRating = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onUserScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onUserScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onUserScroll() {
    if (_highlightedRatingId != null && !_isScrollingToRating) {
      setState(() {
        _highlightedRatingId = null;
      });
    }
  }

  /// Scrolls to and highlights a specific rating
  void scrollToRating(String ratingId) {
    setState(() {
      _highlightedRatingId = ratingId;
      _isScrollingToRating = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted && _highlightedRatingKey.currentContext != null) {
          Scrollable.ensureVisible(
            _highlightedRatingKey.currentContext!,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.3,
          ).then((_) {
            if (mounted) {
              setState(() {
                _isScrollingToRating = false;
              });
            }
          });
        } else {
          if (mounted) {
            setState(() {
              _isScrollingToRating = false;
            });
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final allRatings = RatingService().getAllRatings();

    if (allRatings.isEmpty) {
      return Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_border, size: 64, color: Colors.grey[300]),
                SizedBox(height: 16),
                Text(
                  'No ratings yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'clear_ratings',
              backgroundColor: Colors.orange[700],
              onPressed: () => _showClearDialog(context),
              child: Icon(Icons.delete_sweep, color: Colors.white),
            ),
          ),
        ],
      );
    }

    // Sort by ratedAt (most recent first)
    final sortedRatings = allRatings.toList()
      ..sort((a, b) => b.ratedAt.compareTo(a.ratedAt));

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(16),
          itemCount: sortedRatings.length,
          itemBuilder: (context, index) {
            final rating = sortedRatings[index];
            final fromUser = MockUsers.getUserById(rating.fromUserId);
            final toUser = MockUsers.getUserById(rating.toUserId);
            final isHighlighted = _highlightedRatingId == rating.id;

            Widget card = Card(
          margin: EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with users and overall rating
                Row(
                  children: [
                    // From user
                    Expanded(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: fromUser != null && widget.onNavigateToUser != null
                                ? () => widget.onNavigateToUser!(
                                    fromUser,
                                    navContext: AdminNavigationContext(
                                      sourceTabIndex: 3,
                                      ratingId: rating.id,
                                    ),
                                  )
                                : null,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: fromUser?.profilePhotoUrl != null
                                  ? (fromUser!.profilePhotoUrl!.startsWith('http')
                                      ? NetworkImage(fromUser.profilePhotoUrl!) as ImageProvider
                                      : AssetImage(fromUser.profilePhotoUrl!))
                                  : null,
                              child: fromUser?.profilePhotoUrl == null
                                  ? Icon(Icons.person, color: Colors.white, size: 20)
                                  : null,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fromUser?.fullName ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward, size: 20, color: Colors.grey[600]),
                    ),

                    // To user
                    Expanded(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: toUser != null && widget.onNavigateToUser != null
                                ? () => widget.onNavigateToUser!(
                                    toUser,
                                    navContext: AdminNavigationContext(
                                      sourceTabIndex: 3,
                                      ratingId: rating.id,
                                    ),
                                  )
                                : null,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: toUser?.profilePhotoUrl != null
                                  ? (toUser!.profilePhotoUrl!.startsWith('http')
                                      ? NetworkImage(toUser.profilePhotoUrl!) as ImageProvider
                                      : AssetImage(toUser.profilePhotoUrl!))
                                  : null,
                              child: toUser?.profilePhotoUrl == null
                                  ? Icon(Icons.person, color: Colors.white, size: 20)
                                  : null,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              toUser?.fullName ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Overall rating
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber[700], size: 18),
                          SizedBox(width: 4),
                          Text(
                            rating.averageRating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Category chips
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (rating.polite == 1) _buildRatingChip('Polite'),
                    if (rating.clean == 1) _buildRatingChip('Clean'),
                    if (rating.communicative == 1) _buildRatingChip('Communicative'),
                    if (rating.safe == 1) _buildRatingChip('Safe'),
                    if (rating.punctual == 1) _buildRatingChip('Punctual'),
                  ],
                ),

                // Timestamp
                SizedBox(height: 8),
                Text(
                  _formatTimestamp(rating.ratedAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );

            // Add highlight effect when this rating is the one we navigated back to
            if (isHighlighted) {
              return Container(
                key: _highlightedRatingKey,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFDD2C00), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFDD2C00).withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: card,
                ),
              );
            }

            return card;
      },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'clear_ratings',
            backgroundColor: Colors.orange[700],
            onPressed: () => _showClearDialog(context),
            child: Icon(Icons.delete_sweep, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _showClearDialog(BuildContext context) {
    final ratingService = RatingService();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Clear Ratings'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: Icon(Icons.select_all, color: Colors.red),
                title: Text('All Ratings'),
                subtitle: Text('${ratingService.getAllRatings().length} ratings'),
                onTap: () async {
                  Navigator.pop(dialogContext);
                  await _confirmAndClear(context, null);
                },
              ),
              Divider(),
              ...MockUsers.users.map((user) {
                final count = ratingService.getRatingsForUser(user.id).length;
                return ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: user.profilePhotoUrl != null
                        ? AssetImage(user.profilePhotoUrl!)
                        : null,
                    child: user.profilePhotoUrl == null
                        ? Icon(Icons.person, size: 16, color: Colors.white)
                        : null,
                  ),
                  title: Text(user.fullName),
                  subtitle: Text('$count ratings received'),
                  onTap: () async {
                    Navigator.pop(dialogContext);
                    await _confirmAndClear(context, user.id);
                  },
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndClear(BuildContext context, String? userId) async {
    final ratingService = RatingService();
    final userName = userId != null
        ? MockUsers.getUserById(userId)?.fullName ?? 'Unknown'
        : 'all users';

    final confirmed = await DialogHelper.showConfirmDialog(
      context: context,
      title: 'Clear Ratings',
      content: 'Are you sure you want to clear ratings for $userName? This cannot be undone.',
      confirmText: 'Clear',
      isDangerous: true,
    );

    if (confirmed && context.mounted) {
      if (userId != null) {
        ratingService.clearRatingsForUser(userId);
      } else {
        ratingService.clearAll();
      }
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ratings cleared for $userName'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildRatingChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[300]!, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 12, color: Colors.amber[700]),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.amber[900],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays > 30) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

// Collapsible section widget for booking groups
class _CollapsibleBookingSection extends StatefulWidget {
  final String title;
  final int count;
  final List<Booking> bookings;
  final Widget Function(Booking) buildBookingCard;
  final bool startCollapsed;
  final Color? color; // Optional color for the section
  final String? highlightedBookingId; // Booking ID to auto-expand for

  const _CollapsibleBookingSection({
    required this.title,
    required this.count,
    required this.bookings,
    required this.buildBookingCard,
    this.startCollapsed = false,
    this.color,
    this.highlightedBookingId,
  });

  @override
  State<_CollapsibleBookingSection> createState() =>
      _CollapsibleBookingSectionState();
}

class _CollapsibleBookingSectionState
    extends State<_CollapsibleBookingSection> {
  late bool _isExpanded;

  bool _containsHighlightedBooking() {
    if (widget.highlightedBookingId == null) return false;
    return widget.bookings.any((b) => b.id == widget.highlightedBookingId);
  }

  @override
  void initState() {
    super.initState();
    // Auto-expand if this section contains the highlighted booking
    _isExpanded = !widget.startCollapsed || _containsHighlightedBooking();
  }

  @override
  void didUpdateWidget(_CollapsibleBookingSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If a new highlighted booking is in this section, expand it
    if (widget.highlightedBookingId != oldWidget.highlightedBookingId &&
        _containsHighlightedBooking()) {
      setState(() {
        _isExpanded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sectionColor = widget.color ?? Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 50,
                  child: Row(
                    children: [
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                        color: sectionColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: sectionColor,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '(${widget.count})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: sectionColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isExpanded) ...[
          SizedBox(height: 8),
          ...widget.bookings.map((booking) => widget.buildBookingCard(booking)),
        ],
        SizedBox(height: 8),
      ],
    );
  }
}

// Collapsible section widget for message groups
class _CollapsibleMessageSection extends StatefulWidget {
  final String title;
  final int count;
  final List<Conversation> conversations;
  final Widget Function(Conversation) buildConversationCard;
  final bool startCollapsed;
  final Color? color;

  const _CollapsibleMessageSection({
    required this.title,
    required this.count,
    required this.conversations,
    required this.buildConversationCard,
    this.startCollapsed = false,
    this.color,
  });

  @override
  State<_CollapsibleMessageSection> createState() =>
      _CollapsibleMessageSectionState();
}

class _CollapsibleMessageSectionState
    extends State<_CollapsibleMessageSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = !widget.startCollapsed;
  }

  @override
  Widget build(BuildContext context) {
    final sectionColor = widget.color ?? Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 50,
                  child: Row(
                    children: [
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                        color: sectionColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: sectionColor,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '(${widget.count})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: sectionColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isExpanded) ...[
          SizedBox(height: 8),
          ...widget.conversations.map((c) => widget.buildConversationCard(c)),
        ],
        SizedBox(height: 8),
      ],
    );
  }
}

// Collapsible section widget for support messages with subcategories
class _CollapsibleSupportSection extends StatefulWidget {
  final int totalCount;
  final List<Conversation> questionConversations;
  final List<Conversation> complaintConversations;
  final List<Conversation> suggestionConversations;
  final List<Conversation> otherConversations;
  final Widget Function(Conversation) buildConversationCard;

  const _CollapsibleSupportSection({
    required this.totalCount,
    required this.questionConversations,
    required this.complaintConversations,
    required this.suggestionConversations,
    required this.otherConversations,
    required this.buildConversationCard,
  });

  @override
  State<_CollapsibleSupportSection> createState() =>
      _CollapsibleSupportSectionState();
}

class _CollapsibleSupportSectionState
    extends State<_CollapsibleSupportSection> {
  bool _isExpanded = false;
  bool _questionExpanded = false;
  bool _complaintExpanded = false;
  bool _suggestionExpanded = false;
  bool _otherExpanded = false;

  @override
  Widget build(BuildContext context) {
    final sectionColor = Colors.amber[700]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Support header
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 50,
                  child: Row(
                    children: [
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                        color: sectionColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Support',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: sectionColor,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '(${widget.totalCount})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: sectionColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isExpanded) ...[
          SizedBox(height: 8),
          // Question subcategory (blue)
          if (widget.questionConversations.isNotEmpty)
            _buildSubcategory(
              'Question',
              widget.questionConversations,
              Colors.blue,
              Icons.help_outline,
              _questionExpanded,
              () => setState(() => _questionExpanded = !_questionExpanded),
            ),
          // Suggestion subcategory (green)
          if (widget.suggestionConversations.isNotEmpty)
            _buildSubcategory(
              'Suggestion',
              widget.suggestionConversations,
              Colors.green,
              Icons.lightbulb_outline,
              _suggestionExpanded,
              () => setState(() => _suggestionExpanded = !_suggestionExpanded),
            ),
          // Complaint subcategory (red) - last
          if (widget.complaintConversations.isNotEmpty)
            _buildSubcategory(
              'Complaint',
              widget.complaintConversations,
              Colors.red,
              Icons.report_problem_outlined,
              _complaintExpanded,
              () => setState(() => _complaintExpanded = !_complaintExpanded),
            ),
          // Other support (fallback)
          if (widget.otherConversations.isNotEmpty)
            _buildSubcategory(
              'Other',
              widget.otherConversations,
              Colors.grey,
              Icons.support_agent,
              _otherExpanded,
              () => setState(() => _otherExpanded = !_otherExpanded),
            ),
        ],
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSubcategory(
    String title,
    List<Conversation> conversations,
    Color color,
    IconData icon,
    bool isExpanded,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: color,
                    size: 18,
                  ),
                  SizedBox(width: 4),
                  Icon(icon, color: color, size: 16),
                  SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    '(${conversations.length})',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            ...conversations.map((c) => widget.buildConversationCard(c)),
          ],
        ],
      ),
    );
  }
}

// User details content widget with collapsible sections
class _UserDetailsContent extends StatefulWidget {
  final User user;
  final List<Booking> bookings;
  final List<Conversation> conversations;
  final List<TripRating> ratings;
  final ScrollController scrollController;

  const _UserDetailsContent({
    required this.user,
    required this.bookings,
    required this.conversations,
    required this.ratings,
    required this.scrollController,
  });

  @override
  State<_UserDetailsContent> createState() => _UserDetailsContentState();
}

class _UserDetailsContentState extends State<_UserDetailsContent> {
  bool _userInfoExpanded = false;

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied'),
        duration: Duration(seconds: 1),
      ),
    );
  }
  bool _messagesExpanded = false;
  bool _ratingsExpanded = false;

  // Bookings section expansion state
  bool _bookingsExpanded = false;

  // Booking category expansion states
  bool _upcomingExpanded = false;
  bool _ongoingExpanded = false;
  bool _completedExpanded = false;
  bool _canceledExpanded = false;
  bool _archivedExpanded = false;
  bool _hiddenExpanded = false;

  // Message category expansion states
  bool _upcomingMessagesExpanded = false;
  bool _ongoingMessagesExpanded = false;
  bool _completedMessagesExpanded = false;
  bool _supportMessagesExpanded = false;
  bool _archivedMessagesExpanded = false;
  bool _hiddenMessagesExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.scrollController,
      padding: EdgeInsets.all(16),
      children: [
        // User Information Section
        _buildCollapsibleSection(
          title: 'User Information',
          count: null,
          isExpanded: _userInfoExpanded,
          onTap: () => setState(() => _userInfoExpanded = !_userInfoExpanded),
          trailing: GestureDetector(
            onTap: () {
              final personalInfo = 'ID: ${widget.user.id}\n'
                  'Name: ${widget.user.name}\n'
                  'Surname: ${widget.user.surname}\n'
                  'Email: ${widget.user.email}\n'
                  'Phone: ${widget.user.formattedPhone}'
                  '${widget.user.isAdmin ? '\nRole: Admin' : ''}';
              final vehicleInfo = widget.user.hasVehicle
                  ? '\n\nVehicle:\n'
                      'Make: ${widget.user.vehicleBrand ?? ''}\n'
                      'Model: ${widget.user.vehicleModel ?? ''}\n'
                      'Color: ${widget.user.vehicleColor ?? ''}\n'
                      'Plate: ${widget.user.licensePlate ?? ''}'
                  : '';
              _copyToClipboard('$personalInfo$vehicleInfo', 'User Information');
            },
            child: Icon(Icons.copy, size: 16, color: Colors.grey[400]),
          ),
          children: [
            // Personal Information subtitle with copy all
            Row(
              children: [
                Text(
                  'Personal Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                GestureDetector(
                  onTap: () {
                    final personalInfo = 'ID: ${widget.user.id}\n'
                        'Name: ${widget.user.name}\n'
                        'Surname: ${widget.user.surname}\n'
                        'Email: ${widget.user.email}\n'
                        'Phone: ${widget.user.formattedPhone}'
                        '${widget.user.isAdmin ? '\nRole: Admin' : ''}';
                    _copyToClipboard(personalInfo, 'Personal Information');
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.copy, size: 14, color: Colors.grey[400]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            _buildInfoRow('ID', widget.user.id),
            _buildInfoRow('Name', widget.user.name),
            _buildInfoRow('Surname', widget.user.surname),
            _buildInfoRow('Email', widget.user.email),
            _buildInfoRow('Phone', widget.user.formattedPhone),
            if (widget.user.isAdmin) _buildInfoRow('Role', 'Admin'),
            if (widget.user.hasVehicle) ...[
              Divider(height: 24),
              // Vehicle Information subtitle with copy all
              Row(
                children: [
                  Text(
                    'Vehicle Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () {
                      final vehicleInfo = 'Make: ${widget.user.vehicleBrand ?? ''}\n'
                          'Model: ${widget.user.vehicleModel ?? ''}\n'
                          'Color: ${widget.user.vehicleColor ?? ''}\n'
                          'Plate: ${widget.user.licensePlate ?? ''}';
                      _copyToClipboard(vehicleInfo, 'Vehicle Information');
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(Icons.copy, size: 14, color: Colors.grey[400]),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              _buildInfoRow('Make', widget.user.vehicleBrand ?? ''),
              _buildInfoRow('Model', widget.user.vehicleModel ?? ''),
              _buildInfoRow('Color', widget.user.vehicleColor ?? ''),
              _buildInfoRow('Plate', widget.user.licensePlate ?? ''),
            ],
          ],
        ),

        SizedBox(height: 16),

        // Bookings Section
        _buildCollapsibleSection(
          title: 'Bookings',
          count: widget.bookings.length,
          isExpanded: _bookingsExpanded,
          onTap: () => setState(() => _bookingsExpanded = !_bookingsExpanded),
          children: _buildBookingsChildren(),
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        ),

        SizedBox(height: 16),

        // Messages Section
        _buildCollapsibleSection(
          title: 'Messages',
          count: widget.conversations.length,
          isExpanded: _messagesExpanded,
          onTap: () => setState(() => _messagesExpanded = !_messagesExpanded),
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          children: _buildMessagesChildren(),
        ),

        SizedBox(height: 16),

        // Ratings Section
        _buildCollapsibleSection(
          title: 'Ratings',
          count: widget.ratings.length,
          isExpanded: _ratingsExpanded,
          onTap: () => setState(() => _ratingsExpanded = !_ratingsExpanded),
          children: widget.ratings.isEmpty
              ? [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No ratings received',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                ]
              : widget.ratings
                  .map((rating) {
                    final fromUser = MockUsers.getUserById(rating.fromUserId);
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with name and overall rating
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    fromUser?.fullName ?? 'Unknown User',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star, color: Colors.amber, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        rating.averageRating.toStringAsFixed(1),
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              // Category details
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  if (rating.polite == 1)
                                    _buildRatingChip('Polite'),
                                  if (rating.clean == 1)
                                    _buildRatingChip('Clean'),
                                  if (rating.communicative == 1)
                                    _buildRatingChip('Communicative'),
                                  if (rating.safe == 1)
                                    _buildRatingChip('Safe'),
                                  if (rating.punctual == 1)
                                    _buildRatingChip('Punctual'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  })
                  .toList(),
        ),

        // Delete Account Button (only for non-admin users)
        if (!widget.user.isAdmin) ...[
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showDeleteAccountDialog(context),
              icon: Icon(Icons.delete_forever, size: 20),
              label: Text(AppLocalizations.of(context)!.deleteAccount),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red[700],
                side: BorderSide(color: Colors.red[300]!),
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],

        // Message Button (don't show for self)
        if (AuthService.currentUser?.id != widget.user.id) ...[
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _navigateToSupportChat(context),
              icon: Icon(Icons.message, size: 20),
              label: Text('Message'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                side: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _navigateToSupportChat(BuildContext context) {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;

    // Create a support conversation ID (use smaller user ID first for consistency)
    final userId1 = currentUser.id;
    final userId2 = widget.user.id;
    final conversationId = userId1.compareTo(userId2) < 0
        ? 'support_${userId1}_$userId2'
        : 'support_${userId2}_$userId1';

    // Get or create conversation - don't add until first message is sent
    var conversation = MessagingService().getConversation(conversationId) ??
        Conversation(
          id: conversationId,
          bookingId: conversationId,
          driverId: currentUser.id,
          driverName: currentUser.fullName,
          riderId: widget.user.id,
          riderName: widget.user.fullName,
          routeName: 'Support',
          originName: '',
          destinationName: '',
          departureTime: DateTime.now(),
          arrivalTime: DateTime.now().add(Duration(days: 365)), // Never expires
          messages: [],
        );

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

  void _showDeleteAccountDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteAccount),
          content: Text(
            'Are you sure you want to delete ${widget.user.fullName}\'s account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // TODO: Implement actual account deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Account deletion would be processed here'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Format date for miniature conversation card
  String _formatMiniDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diffDays = target.difference(today).inDays;

    if (diffDays == 0) return 'Today';
    if (diffDays == 1) return 'Tmrw';
    if (diffDays == -1) return 'Yday';

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }

  Widget _buildUserConversationTopRow(Conversation conversation, bool isSupport) {
    if (isSupport) {
      final routeName = conversation.routeName;
      String supportType;
      Color typeColor;
      IconData typeIcon;

      if (routeName.startsWith('Question')) {
        supportType = 'Question';
        typeColor = Colors.blue;
        typeIcon = Icons.help_outline;
      } else if (routeName.startsWith('Suggestion')) {
        supportType = 'Suggestion';
        typeColor = Colors.green;
        typeIcon = Icons.lightbulb_outline;
      } else if (routeName.startsWith('Complaint')) {
        supportType = 'Complaint';
        typeColor = Colors.red;
        typeIcon = Icons.report_problem_outlined;
      } else if (routeName.startsWith('New Route Suggestion')) {
        supportType = 'New Route';
        typeColor = Colors.blue;
        typeIcon = Icons.add_road;
      } else if (routeName.startsWith('New Stop Suggestion')) {
        supportType = 'New Stop';
        typeColor = Colors.teal;
        typeIcon = Icons.add_location;
      } else {
        supportType = 'Support';
        typeColor = Colors.amber;
        typeIcon = Icons.support_agent;
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: typeColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: typeColor.withValues(alpha: 0.3), width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(typeIcon, color: typeColor, size: 14),
            SizedBox(width: 5),
            Text(supportType, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: typeColor)),
          ],
        ),
      );
    }

    // For regular conversations - readable version
    return Row(
      children: [
        // Date badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _formatMiniDate(conversation.departureTime),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        SizedBox(width: 8),
        // Departure
        Expanded(
          child: Row(
            children: [
              Icon(Icons.location_on, color: Colors.green, size: 12),
              SizedBox(width: 3),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  formatTimeHHmm(conversation.departureTime),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
              ),
              SizedBox(width: 3),
              Expanded(
                child: Text(
                  conversation.originName,
                  style: TextStyle(fontSize: 10, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 6),
        // Arrival
        Expanded(
          child: Row(
            children: [
              Icon(Icons.flag, color: Colors.red, size: 12),
              SizedBox(width: 3),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  formatTimeHHmm(conversation.arrivalTime),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red[700]),
                ),
              ),
              SizedBox(width: 3),
              Expanded(
                child: Text(
                  conversation.destinationName,
                  style: TextStyle(fontSize: 10, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserAvatar(String? profilePhotoUrl, {required bool isDriver}) {
    final defaultIcon = isDriver ? Icons.directions_car : Icons.person;
    final defaultColor = isDriver ? Colors.blue : Colors.green;

    if (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty) {
      if (profilePhotoUrl.startsWith('assets/')) {
        return CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage(profilePhotoUrl),
        );
      } else {
        final photoFile = File(profilePhotoUrl);
        if (photoFile.existsSync()) {
          return CircleAvatar(
            radius: 20,
            backgroundImage: FileImage(photoFile),
          );
        }
      }
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: defaultColor.withValues(alpha: 0.1),
      child: Icon(defaultIcon, color: defaultColor, size: 20),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required int? count,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
    EdgeInsets? contentPadding,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        children: [
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Color(0xFFDD2C00),
                          ),
                          SizedBox(width: 8),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (count != null) ...[
                            SizedBox(width: 8),
                            Text(
                              '($count)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  SizedBox(width: 8),
                  trailing,
                ],
              ],
            ),
          ),
          if (isExpanded) ...[
            Divider(height: 1),
            Padding(
              padding: contentPadding ?? EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (value.isNotEmpty)
            GestureDetector(
              onTap: () => _copyToClipboard(value, label),
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.copy, size: 12, color: Colors.grey[400]),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildBookingsChildren() {
    if (widget.bookings.isEmpty) {
      return [
        Text(
          'No bookings found',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ];
    }

    final now = DateTime.now();

    // Categorize bookings
    final upcoming = widget.bookings
        .where((b) =>
            b.departureTime.isAfter(now) &&
            b.isCanceled != true &&
            b.isArchived != true)
        .toList()
      ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

    final ongoing = widget.bookings
        .where((b) =>
            b.departureTime.isBefore(now) &&
            b.arrivalTime.isAfter(now) &&
            b.isCanceled != true &&
            b.isArchived != true)
        .toList()
      ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

    final completed = widget.bookings
        .where((b) =>
            b.arrivalTime.isBefore(now) &&
            b.isCanceled != true &&
            b.isArchived != true)
        .toList()
      ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

    final canceled = widget.bookings
        .where((b) => b.isCanceled == true && b.isArchived != true)
        .toList()
      ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

    final archived = widget.bookings
        .where((b) => b.isArchived == true && b.isHidden != true)
        .toList()
      ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

    final hidden = widget.bookings
        .where((b) => b.isArchived == true && b.isHidden == true)
        .toList()
      ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

    final List<Widget> children = [];

    if (upcoming.isNotEmpty) {
      children.add(_buildBookingCategory(
        'Upcoming',
        upcoming,
        Colors.blue[700]!,
        _upcomingExpanded,
        () => setState(() => _upcomingExpanded = !_upcomingExpanded),
        isPast: false,
        cardsCollapsible: true,
      ));
    }

    if (ongoing.isNotEmpty) {
      children.add(_buildBookingCategory(
        'Ongoing',
        ongoing,
        Colors.orange[700]!,
        _ongoingExpanded,
        () => setState(() => _ongoingExpanded = !_ongoingExpanded),
        isPast: false,
        isOngoing: true,
        cardsCollapsible: true,
      ));
    }

    if (completed.isNotEmpty) {
      children.add(_buildBookingCategory(
        'Completed',
        completed,
        Colors.green[700]!,
        _completedExpanded,
        () => setState(() => _completedExpanded = !_completedExpanded),
        isPast: true,
        cardsCollapsible: true,
      ));
    }

    if (canceled.isNotEmpty) {
      children.add(_buildBookingCategory(
        'Canceled',
        canceled,
        Colors.red[700]!,
        _canceledExpanded,
        () => setState(() => _canceledExpanded = !_canceledExpanded),
        isPast: true,
        isCanceled: true,
        cardsCollapsible: true,
      ));
    }

    if (archived.isNotEmpty) {
      children.add(_buildBookingCategory(
        'Archived',
        archived,
        Colors.grey[700]!,
        _archivedExpanded,
        () => setState(() => _archivedExpanded = !_archivedExpanded),
        isPast: true,
        isArchived: true,
        cardsCollapsible: true,
      ));
    }

    if (hidden.isNotEmpty) {
      children.add(_buildBookingCategory(
        'Hidden',
        hidden,
        Colors.purple[700]!,
        _hiddenExpanded,
        () => setState(() => _hiddenExpanded = !_hiddenExpanded),
        isPast: true,
        isArchived: true,
        cardsCollapsible: true,
      ));
    }

    return children;
  }

  Widget _buildBookingCategory(
    String title,
    List<Booking> bookings,
    Color color,
    bool isExpanded,
    VoidCallback onTap, {
    bool isPast = false,
    bool isCanceled = false,
    bool isOngoing = false,
    bool isArchived = false,
    bool cardsCollapsible = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header - simple row inside parent card
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: color,
                  size: 20,
                ),
                SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  '(${bookings.length})',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Category bookings - full width
        if (isExpanded) ...[
          ...bookings.map((booking) => Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: BookingCard(
                  booking: booking,
                  isPast: isPast,
                  isCanceled: isCanceled,
                  isOngoing: isOngoing,
                  isArchived: isArchived,
                  showActions: false,
                  showSeatsForCanceled: true,
                  isCollapsible: cardsCollapsible,
                  initiallyExpanded: false,
                  buildMiniatureSeatLayout: (seats, booking) {
                    return SeatLayoutWidget(
                      booking: booking,
                      isInteractive: false,
                      currentUserId: null,
                    );
                  },
                ),
              )),
        ],
      ],
    );
  }

  List<Widget> _buildMessagesChildren() {
    if (widget.conversations.isEmpty) {
      return [
        Text(
          'No conversations found',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ];
    }

    final now = DateTime.now();

    // Helper to check booking status for a conversation
    bool isOngoing(Conversation c) {
      if (c.id.startsWith('support_')) return false;
      final booking = BookingStorage().getBookingById(c.bookingId);
      if (booking == null) return false;
      return booking.departureTime.isBefore(now) &&
          booking.arrivalTime.isAfter(now) &&
          booking.isCanceled != true &&
          booking.isArchived != true;
    }

    bool isCompleted(Conversation c) {
      if (c.id.startsWith('support_')) return false;
      final booking = BookingStorage().getBookingById(c.bookingId);
      if (booking == null) return false;
      return booking.arrivalTime.isBefore(now) &&
          booking.isCanceled != true &&
          booking.isArchived != true;
    }

    bool isUpcoming(Conversation c) {
      if (c.id.startsWith('support_')) return false;
      final booking = BookingStorage().getBookingById(c.bookingId);
      if (booking == null) return false;
      return booking.departureTime.isAfter(now) &&
          booking.isCanceled != true &&
          booking.isArchived != true;
    }

    // Categorize conversations
    final upcoming = widget.conversations
        .where((c) => isUpcoming(c) && !c.isHidden)
        .toList()
      ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

    final ongoing = widget.conversations
        .where((c) => isOngoing(c) && !c.isHidden)
        .toList()
      ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

    final completed = widget.conversations
        .where((c) => isCompleted(c) && !c.isHidden)
        .toList()
      ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

    final support = widget.conversations
        .where((c) => c.id.startsWith('support_') && !c.isHidden)
        .toList()
      ..sort((a, b) {
        final aLast = a.lastMessage?.timestamp ?? a.arrivalTime;
        final bLast = b.lastMessage?.timestamp ?? b.arrivalTime;
        return bLast.compareTo(aLast);
      });

    final archived = widget.conversations
        .where((c) =>
            !c.id.startsWith('support_') &&
            c.isArchived &&
            !c.isHidden)
        .toList()
      ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

    final hidden = widget.conversations
        .where((c) => c.isHidden)
        .toList()
      ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

    final List<Widget> children = [];

    if (upcoming.isNotEmpty) {
      children.add(_buildMessageCategory(
        'Upcoming',
        upcoming,
        Colors.blue[700]!,
        _upcomingMessagesExpanded,
        () => setState(() => _upcomingMessagesExpanded = !_upcomingMessagesExpanded),
      ));
    }

    if (ongoing.isNotEmpty) {
      children.add(_buildMessageCategory(
        'Ongoing',
        ongoing,
        Colors.orange[700]!,
        _ongoingMessagesExpanded,
        () => setState(() => _ongoingMessagesExpanded = !_ongoingMessagesExpanded),
      ));
    }

    if (completed.isNotEmpty) {
      children.add(_buildMessageCategory(
        'Completed',
        completed,
        Colors.green[700]!,
        _completedMessagesExpanded,
        () => setState(() => _completedMessagesExpanded = !_completedMessagesExpanded),
      ));
    }

    if (support.isNotEmpty) {
      children.add(_buildMessageCategory(
        'Support',
        support,
        Colors.amber[700]!,
        _supportMessagesExpanded,
        () => setState(() => _supportMessagesExpanded = !_supportMessagesExpanded),
      ));
    }

    if (archived.isNotEmpty) {
      children.add(_buildMessageCategory(
        'Archived',
        archived,
        Colors.grey[700]!,
        _archivedMessagesExpanded,
        () => setState(() => _archivedMessagesExpanded = !_archivedMessagesExpanded),
      ));
    }

    if (hidden.isNotEmpty) {
      children.add(_buildMessageCategory(
        'Hidden',
        hidden,
        Colors.purple[700]!,
        _hiddenMessagesExpanded,
        () => setState(() => _hiddenMessagesExpanded = !_hiddenMessagesExpanded),
      ));
    }

    return children;
  }

  Widget _buildMessageCategory(
    String title,
    List<Conversation> conversations,
    Color color,
    bool isExpanded,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: color,
                  size: 20,
                ),
                SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  '(${conversations.length})',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Category conversations
        if (isExpanded) ...[
          ...conversations.map((conversation) => _buildMiniConversationCard(conversation)),
        ],
      ],
    );
  }

  Widget _buildMiniConversationCard(Conversation conversation) {
    final isSupport = conversation.id.startsWith('support_');
    final unreadCount = conversation.getUnreadCount(widget.user.id);

    // Get driver and rider info
    final driver = MockUsers.getUserById(conversation.driverId);
    final rider = MockUsers.getUserById(conversation.riderId);
    final driverRating = driver != null ? RatingService().getUserAverageRating(driver.id) : 0.0;
    final riderRating = rider != null ? RatingService().getUserAverageRating(rider.id) : 0.0;

    // Card color based on unread status
    final cardColor = unreadCount > 0 ? Colors.blue[100] : Colors.blue[50];

    // For support: determine admin vs user labels
    final isDriverAdmin = driver?.isAdmin == true;
    final leftLabel = isSupport ? (isDriverAdmin ? 'Admin' : 'User') : 'Driver';
    final rightLabel = isSupport ? (isDriverAdmin ? 'User' : 'Admin') : 'Rider';
    final leftIcon = isSupport ? (isDriverAdmin ? Icons.admin_panel_settings : Icons.person) : Icons.directions_car;
    final rightIcon = isSupport ? (isDriverAdmin ? Icons.person : Icons.admin_panel_settings) : Icons.person;

    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                conversation: conversation,
                isAdminView: true,
              ),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!, width: 0.5),
          ),
          child: Column(
            children: [
              // Top row: Date and route info (or support type)
              _buildUserConversationTopRow(conversation, isSupport),
              SizedBox(height: 10),
              // Middle row: Left person - status badges - Right person
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left section with label and nested avatar
                  Expanded(
                    child: Row(
                      children: [
                        // Left label with semi-circle cutout
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Label background
                            Container(
                              padding: EdgeInsets.only(left: 8, right: 28, top: 8, bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(leftIcon, size: 16, color: Colors.grey[600]),
                                  SizedBox(height: 2),
                                  Text(
                                    leftLabel,
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            // Avatar positioned to overlap (create cutout effect)
                            Positioned(
                              right: -18,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey.withValues(alpha: 0.15), width: 2),
                                  ),
                                  child: _buildUserAvatar(driver?.profilePhotoUrl, isDriver: !isSupport),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 24),
                        // Name and rating
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driver != null
                                    ? '${driver.name} ${driver.surname.isNotEmpty ? '${driver.surname[0]}.' : ''}'
                                    : conversation.driverName,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (driver != null && !isSupport) ...[
                                SizedBox(height: 2),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, size: 11, color: Colors.amber),
                                    SizedBox(width: 2),
                                    Text(
                                      driverRating.toStringAsFixed(1),
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Center: Status badges
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (unreadCount > 0)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Color(0xFFDD2C00),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$unreadCount new',
                              style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        if (conversation.isHidden)
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple[100],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.purple[300]!, width: 1),
                            ),
                            child: Text(
                              'Hidden',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.purple[700]),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Right section with label and nested avatar (mirrored)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Name and rating
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                rider != null
                                    ? '${rider.name} ${rider.surname.isNotEmpty ? '${rider.surname[0]}.' : ''}'
                                    : conversation.riderName,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (rider != null && !isSupport) ...[
                                SizedBox(height: 2),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, size: 11, color: Colors.amber),
                                    SizedBox(width: 2),
                                    Text(
                                      riderRating.toStringAsFixed(1),
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(width: 24),
                        // Right label with semi-circle cutout
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Label background
                            Container(
                              padding: EdgeInsets.only(left: 28, right: 8, top: 8, bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(rightIcon, size: 16, color: Colors.grey[600]),
                                  SizedBox(height: 2),
                                  Text(
                                    rightLabel,
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            // Avatar positioned to overlap (create cutout effect)
                            Positioned(
                              left: -18,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey.withValues(alpha: 0.15), width: 2),
                                  ),
                                  child: _buildUserAvatar(rider?.profilePhotoUrl, isDriver: false),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildRatingChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 12, color: Colors.amber[800]),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.amber[900],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
