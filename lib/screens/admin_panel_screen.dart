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

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

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

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Panel'),
          backgroundColor: Color(0xFFDD2C00),
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'Users'),
              Tab(icon: Icon(Icons.directions_car), text: 'Bookings'),
              Tab(icon: Icon(Icons.message), text: 'Messages'),
              Tab(icon: Icon(Icons.star), text: 'Ratings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_UsersTab(), _BookingsTab(), _MessagesTab(), _RatingsTab()],
        ),
      ),
    );
  }
}

// Users Management Tab
class _UsersTab extends StatelessWidget {
  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.snackbarCopiedToClipboard(label)),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToSupportChat(BuildContext context, User user) {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;

    // Don't allow messaging yourself
    if (currentUser.id == user.id) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.snackbarCannotMessageYourself),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Create a support conversation ID (use smaller user ID first for consistency)
    final userId1 = currentUser.id;
    final userId2 = user.id;
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
          riderId: user.id,
          riderName: user.fullName,
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

  @override
  Widget build(BuildContext context) {
    final users = MockUsers.users;
    final currentUser = AuthService.currentUser;

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        // Get live rating from RatingService
        final liveRating = RatingService().getUserAverageRating(user.id);
        final userWithLiveRating = user.copyWith(rating: liveRating);

        // Check if this is the current user's own card
        final isSelf = currentUser != null && userWithLiveRating.id == currentUser.id;

        // Extract country info for display
        final countryInfo = User.getCountryInfo(userWithLiveRating.countryCode);

        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => _showUserDetails(context, userWithLiveRating),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
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
                        // Name with admin badge
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
                                  GestureDetector(
                                    onTap: () => _copyToClipboard(context, userWithLiveRating.fullName, 'Name'),
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 4),
                                      child: Icon(Icons.copy, size: 12, color: Colors.grey[400]),
                                    ),
                                  ),
                                ],
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
                        SizedBox(height: 4),
                        // Phone
                        Row(
                          children: [
                            Text(
                              userWithLiveRating.formattedPhone,
                              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                            ),
                            GestureDetector(
                              onTap: () {
                                final phoneDigits = '${countryInfo['code']}${userWithLiveRating.phoneNumber}';
                                _copyToClipboard(context, phoneDigits, 'Phone');
                              },
                              child: Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(Icons.copy, size: 12, color: Colors.grey[400]),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        // Email
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                userWithLiveRating.email,
                                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _copyToClipboard(context, userWithLiveRating.email, 'Email'),
                              child: Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(Icons.copy, size: 12, color: Colors.grey[400]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Message button
                  if (!isSelf)
                    IconButton(
                      onPressed: () => _navigateToSupportChat(context, userWithLiveRating),
                      icon: Icon(Icons.message, size: 20, color: Theme.of(context).primaryColor),
                      constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
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
  @override
  State<_BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<_BookingsTab> {
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
          ),
        if (ongoingBookings.isNotEmpty)
          _CollapsibleBookingSection(
            title: 'Ongoing',
            count: ongoingBookings.length,
            bookings: ongoingBookings,
            buildBookingCard: (booking) => _buildBookingCard(context, booking, cardsCollapsible: true),
            startCollapsed: false,
            color: Colors.orange[700],
          ),
        if (completedBookings.isNotEmpty)
          _CollapsibleBookingSection(
            title: 'Completed',
            count: completedBookings.length,
            bookings: completedBookings,
            buildBookingCard: (booking) => _buildBookingCard(context, booking, cardsCollapsible: true),
            startCollapsed: true,
            color: Colors.green[700],
          ),
        if (canceledBookings.isNotEmpty)
          _CollapsibleBookingSection(
            title: 'Canceled',
            count: canceledBookings.length,
            bookings: canceledBookings,
            buildBookingCard: (booking) => _buildBookingCard(context, booking, cardsCollapsible: true),
            startCollapsed: true,
            color: Colors.red[700],
          ),
        if (archivedBookings.isNotEmpty)
          _CollapsibleBookingSection(
            title: 'Archived',
            count: archivedBookings.length,
            bookings: archivedBookings,
            buildBookingCard: (booking) => _buildBookingCard(context, booking, cardsCollapsible: true),
            startCollapsed: true,
            color: Colors.grey[700],
          ),
        if (hiddenBookings.isNotEmpty)
          _CollapsibleBookingSection(
            title: 'Hidden',
            count: hiddenBookings.length,
            bookings: hiddenBookings,
            buildBookingCard: (booking) => _buildBookingCard(context, booking, cardsCollapsible: true),
            startCollapsed: true,
            color: Colors.purple[700],
          ),
      ],
    );
  }

  Widget _buildBookingCard(BuildContext context, Booking booking, {bool cardsCollapsible = false}) {
    final isPast = booking.arrivalTime.isBefore(DateTime.now());
    final isOngoing = booking.departureTime.isBefore(DateTime.now()) && booking.arrivalTime.isAfter(DateTime.now());

    return BookingCard(
      booking: booking,
      isPast: isPast,
      isCanceled: booking.isCanceled == true,
      isOngoing: isOngoing,
      isArchived: booking.isArchived == true,
      showActions: false, // Admin panel doesn't show action buttons
      showSeatsForCanceled: true, // Admin can see seats even for canceled rides
      isCollapsible: cardsCollapsible,
      initiallyExpanded: false,
      buildMiniatureSeatLayout: (selectedSeats, booking) =>
          _buildMiniatureSeatLayout(selectedSeats, booking),
    );
  }

  Widget _buildMiniatureSeatLayout(List<int> selectedSeats, Booking booking) {
    return SeatLayoutWidget(
      booking: booking,
      isInteractive: false,
      currentUserId: null, // Admin view doesn't highlight specific users
    );
  }
}

// Messages Management Tab
class _MessagesTab extends StatefulWidget {
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
                .toList()
              ..sort((a, b) {
                final aLast = a.lastMessage?.timestamp ?? a.arrivalTime;
                final bLast = b.lastMessage?.timestamp ?? b.arrivalTime;
                return bLast.compareTo(aLast);
              });

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

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: allConversations.length,
              itemBuilder: (context, index) {
                final conversation = allConversations[index];
                final unreadCount = conversation.getUnreadCount('admin');
                final isSupport = conversation.id.startsWith('support_');

                // Get driver and rider info
                final driver = MockUsers.getUserById(conversation.driverId);
                final rider = MockUsers.getUserById(conversation.riderId);
                final driverRating = driver != null ? RatingService().getUserAverageRating(driver.id) : 0.0;
                final riderRating = rider != null ? RatingService().getUserAverageRating(rider.id) : 0.0;

                // Card color based on unread status
                final cardColor = unreadCount > 0 ? Colors.blue[100] : Colors.blue[50];

                return InkWell(
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
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!, width: 0.5),
                    ),
                    child: Column(
                      children: [
                        // Top row: Date and route info (or support type)
                        _buildConversationTopRow(conversation, isSupport),
                        SizedBox(height: 8),
                        // Middle row: Driver avatar (left) - message count - Rider avatar (right)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Driver on left
                            SizedBox(
                              width: 70,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildAvatar(driver?.profilePhotoUrl, isDriver: true),
                                  SizedBox(height: 4),
                                  Text(
                                    driver != null
                                        ? '${driver.name} ${driver.surname.isNotEmpty ? '${driver.surname[0]}.' : ''}'
                                        : conversation.driverName,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (driver != null) ...[
                                    SizedBox(height: 2),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.star, size: 12, color: Colors.amber),
                                        SizedBox(width: 2),
                                        Text(
                                          driverRating.toStringAsFixed(1),
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Center: Status badges
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (unreadCount > 0)
                                    Container(
                                      margin: EdgeInsets.only(top: 4),
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                            // Rider on right
                            SizedBox(
                              width: 70,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildAvatar(rider?.profilePhotoUrl, isDriver: false),
                                  SizedBox(height: 4),
                                  Text(
                                    rider != null
                                        ? '${rider.name} ${rider.surname.isNotEmpty ? '${rider.surname[0]}.' : ''}'
                                        : conversation.riderName,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (rider != null) ...[
                                    SizedBox(height: 2),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.star, size: 12, color: Colors.amber),
                                        SizedBox(width: 2),
                                        Text(
                                          riderRating.toStringAsFixed(1),
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
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
  Widget _buildAvatar(String? profilePhotoUrl, {required bool isDriver}) {
    final defaultIcon = isDriver ? Icons.drive_eta : Icons.person;
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

    // Fallback to default icon
    return CircleAvatar(
      radius: 20,
      backgroundColor: defaultColor.withValues(alpha: 0.1),
      child: Icon(defaultIcon, color: defaultColor),
    );
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
  @override
  State<_RatingsTab> createState() => _RatingsTabState();
}

class _RatingsTabState extends State<_RatingsTab> {
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
          padding: EdgeInsets.all(16),
          itemCount: sortedRatings.length,
          itemBuilder: (context, index) {
            final rating = sortedRatings[index];
            final fromUser = MockUsers.getUserById(rating.fromUserId);
            final toUser = MockUsers.getUserById(rating.toUserId);

            return Card(
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
                          CircleAvatar(
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
                          CircleAvatar(
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
                        color: Colors.amber.withOpacity(0.2),
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
        color: Colors.amber.withOpacity(0.15),
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

  const _CollapsibleBookingSection({
    required this.title,
    required this.count,
    required this.bookings,
    required this.buildBookingCard,
    this.startCollapsed = false,
    this.color,
  });

  @override
  State<_CollapsibleBookingSection> createState() =>
      _CollapsibleBookingSectionState();
}

class _CollapsibleBookingSectionState
    extends State<_CollapsibleBookingSection> {
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
                color: Colors.black.withOpacity(0.05),
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

        // Bookings Section - custom header without nested padding
        Container(
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _bookingsExpanded = !_bookingsExpanded),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _bookingsExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Color(0xFFDD2C00),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Bookings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '(${widget.bookings.length})',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Booking categories - directly in ListView without extra padding
        if (_bookingsExpanded) ...[
          SizedBox(height: 8),
          _buildBookingsContent(),
        ],

        SizedBox(height: 16),

        // Messages Section
        _buildCollapsibleSection(
          title: 'Messages',
          count: widget.conversations.length,
          isExpanded: _messagesExpanded,
          onTap: () => setState(() => _messagesExpanded = !_messagesExpanded),
          children: widget.conversations.isEmpty
              ? [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No conversations found',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                ]
              : widget.conversations.map((conv) {
                  final isSupport = conv.id.startsWith('support_');
                  final unreadCount = conv.getUnreadCount('admin');
                  final driver = MockUsers.getUserById(conv.driverId);
                  final rider = MockUsers.getUserById(conv.riderId);
                  final driverRating = driver != null ? RatingService().getUserAverageRating(driver.id) : 0.0;
                  final riderRating = rider != null ? RatingService().getUserAverageRating(rider.id) : 0.0;
                  final cardColor = unreadCount > 0 ? Colors.blue[100] : Colors.blue[50];

                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              conversation: conv,
                              isAdminView: true,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!, width: 0.5),
                        ),
                        child: Column(
                          children: [
                            _buildUserConversationTopRow(conv, isSupport),
                            SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Driver on left
                                SizedBox(
                                  width: 60,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildUserAvatar(driver?.profilePhotoUrl, isDriver: true),
                                      SizedBox(height: 4),
                                      Text(
                                        driver != null
                                            ? '${driver.name} ${driver.surname.isNotEmpty ? '${driver.surname[0]}.' : ''}'
                                            : conv.driverName,
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (driver != null && !isSupport) ...[
                                        SizedBox(height: 2),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.star, size: 10, color: Colors.amber),
                                            SizedBox(width: 2),
                                            Text(driverRating.toStringAsFixed(1), style: TextStyle(fontSize: 10)),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                // Center: Status badges
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (unreadCount > 0)
                                        Container(
                                          margin: EdgeInsets.only(top: 4),
                                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFDD2C00),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '$unreadCount new',
                                            style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      if (conv.isHidden)
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
                                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.purple[700]),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // Rider on right
                                SizedBox(
                                  width: 60,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildUserAvatar(rider?.profilePhotoUrl, isDriver: false),
                                      SizedBox(height: 4),
                                      Text(
                                        rider != null
                                            ? '${rider.name} ${rider.surname.isNotEmpty ? '${rider.surname[0]}.' : ''}'
                                            : conv.riderName,
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (rider != null) ...[
                                        SizedBox(height: 2),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.star, size: 10, color: Colors.amber),
                                            SizedBox(width: 2),
                                            Text(riderRating.toStringAsFixed(1), style: TextStyle(fontSize: 10)),
                                          ],
                                        ),
                                      ],
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
                }).toList(),
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
      ],
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
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: typeColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: typeColor.withValues(alpha: 0.3), width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(typeIcon, color: typeColor, size: 11),
            SizedBox(width: 4),
            Text(supportType, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: typeColor)),
          ],
        ),
      );
    }

    // For regular conversations - miniature version of Messages tab top row
    return Row(
      children: [
        // Date badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _formatMiniDate(conversation.departureTime),
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        SizedBox(width: 6),
        // Departure
        Expanded(
          child: Row(
            children: [
              Icon(Icons.location_on, color: Colors.green, size: 10),
              SizedBox(width: 2),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  formatTimeHHmm(conversation.departureTime),
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
              ),
              SizedBox(width: 2),
              Expanded(
                child: Text(
                  conversation.originName,
                  style: TextStyle(fontSize: 8, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 4),
        // Arrival
        Expanded(
          child: Row(
            children: [
              Icon(Icons.flag, color: Colors.red, size: 10),
              SizedBox(width: 2),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  formatTimeHHmm(conversation.arrivalTime),
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.red[700]),
                ),
              ),
              SizedBox(width: 2),
              Expanded(
                child: Text(
                  conversation.destinationName,
                  style: TextStyle(fontSize: 8, color: Colors.black87),
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
    final defaultIcon = isDriver ? Icons.drive_eta : Icons.person;
    final defaultColor = isDriver ? Colors.blue : Colors.green;

    if (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty) {
      if (profilePhotoUrl.startsWith('assets/')) {
        return CircleAvatar(
          radius: 16,
          backgroundImage: AssetImage(profilePhotoUrl),
        );
      } else {
        final photoFile = File(profilePhotoUrl);
        if (photoFile.existsSync()) {
          return CircleAvatar(
            radius: 16,
            backgroundImage: FileImage(photoFile),
          );
        }
      }
    }

    return CircleAvatar(
      radius: 16,
      backgroundColor: defaultColor.withValues(alpha: 0.1),
      child: Icon(defaultIcon, color: defaultColor, size: 16),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required int? count,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
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
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.all(16),
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
          if (isExpanded) ...[
            Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(16),
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

  Widget _buildBookingsContent() {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upcoming bookings - collapsible cards
        if (upcoming.isNotEmpty)
          _buildBookingCategory(
            'Upcoming',
            upcoming,
            Colors.blue[700]!,
            _upcomingExpanded,
            () => setState(() => _upcomingExpanded = !_upcomingExpanded),
            isPast: false,
            cardsCollapsible: true,
          ),

        // Ongoing bookings - collapsible cards
        if (ongoing.isNotEmpty) ...[
          SizedBox(height: 8),
          _buildBookingCategory(
            'Ongoing',
            ongoing,
            Colors.orange[700]!,
            _ongoingExpanded,
            () => setState(() => _ongoingExpanded = !_ongoingExpanded),
            isPast: false,
            isOngoing: true,
            cardsCollapsible: true,
          ),
        ],

        // Completed bookings - seats collapsed with chevron
        if (completed.isNotEmpty) ...[
          SizedBox(height: 8),
          _buildBookingCategory(
            'Completed',
            completed,
            Colors.green[700]!,
            _completedExpanded,
            () => setState(() => _completedExpanded = !_completedExpanded),
            isPast: true,
            cardsCollapsible: true,
          ),
        ],

        // Canceled bookings - seats collapsed with chevron
        if (canceled.isNotEmpty) ...[
          SizedBox(height: 8),
          _buildBookingCategory(
            'Canceled',
            canceled,
            Colors.red[700]!,
            _canceledExpanded,
            () => setState(() => _canceledExpanded = !_canceledExpanded),
            isPast: true,
            isCanceled: true,
            cardsCollapsible: true,
          ),
        ],

        // Archived bookings - seats collapsed with chevron
        if (archived.isNotEmpty) ...[
          SizedBox(height: 8),
          _buildBookingCategory(
            'Archived',
            archived,
            Colors.grey[700]!,
            _archivedExpanded,
            () => setState(() => _archivedExpanded = !_archivedExpanded),
            isPast: true,
            isArchived: true,
            cardsCollapsible: true,
          ),
        ],

        // Hidden bookings - seats collapsed with chevron
        if (hidden.isNotEmpty) ...[
          SizedBox(height: 8),
          _buildBookingCategory(
            'Hidden',
            hidden,
            Colors.purple[700]!,
            _hiddenExpanded,
            () => setState(() => _hiddenExpanded = !_hiddenExpanded),
            isPast: true,
            isArchived: true,
            cardsCollapsible: true,
          ),
        ],

        // Show message if no bookings
        if (widget.bookings.isEmpty)
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No bookings found',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
      ],
    );
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
        // Category header - matching main Bookings tab style
        Container(
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
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: color,
                          size: 20,
                        ),
                        SizedBox(width: 4),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '(${bookings.length})',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Category bookings
        if (isExpanded) ...[
          SizedBox(height: 8),
          ...bookings.map((booking) => BookingCard(
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
              )),
        ],
      ],
    );
  }

  Widget _buildRatingChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
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
