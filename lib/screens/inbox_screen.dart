import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/messaging_service.dart';
import '../services/auth_service.dart';
import '../services/booking_storage.dart';
import '../services/feedback_service.dart';
import '../services/mock_users.dart';
import '../models/message.dart';
import '../models/feedback_event.dart';
import '../l10n/app_localizations.dart';
import '../utils/dialog_helper.dart';
import '../widgets/conversation_card_widget.dart';
import '../widgets/rating_widgets.dart';
import '../widgets/ride_info_card.dart';
import 'chat_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final MessagingService _messagingService = MessagingService();
  String? _lastUserId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

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
    final isMobileApp = _isMobileApp();
    final isMobileWeb = _isMobileWeb(context);

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if user changed and trigger rebuild
    final currentUser = AuthService.currentUser;
    if (currentUser?.id != _lastUserId) {
      _lastUserId = currentUser?.id;
      // Force rebuild by triggering a small state change
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _sendSupportEmail() async {
    try {
      final currentUser = AuthService.currentUser;
      if (currentUser == null) return;

      // Show dialog to choose between suggestion or complaint
      final String? selectedType = await DialogHelper.showChoiceDialog<String>(
        context: context,
        title: 'Contact Support',
        content: 'What would you like to share with us?',
        showCancelButton: false,
        choices: [
          DialogChoice(
            label: 'Question',
            value: 'Question',
            color: Colors.blue,
            icon: Icons.help_outline,
          ),
          DialogChoice(
            label: 'Suggestion',
            value: 'Suggestion',
            color: Colors.green,
            icon: Icons.lightbulb_outline,
          ),
          DialogChoice(
            label: 'Complaint',
            value: 'Complaint',
            color: Colors.red,
            icon: Icons.report_problem_outlined,
          ),
        ],
      );

      // If user dismissed dialog, return
      if (selectedType == null) return;

      final messagingService = MessagingService();

      // Create NEW support conversation with unique reference number
      final supportConversation = messagingService.createSupportConversation(
        currentUser.id,
        currentUser.fullName,
        selectedType,
      );

      // Navigate to chat screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            conversation: supportConversation,
            createConversationOnFirstMessage:
                true, // Add to inbox on first message
            initialMessagePrefix: null, // Type is already in subject line
          ),
        ),
      );
    } catch (e, stackTrace) {
      print('Error in _sendSupportEmail: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        FeedbackService.show(
          context,
          FeedbackEvent.error(l10n.snackbarErrorOpeningChat(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      final l10n = AppLocalizations.of(context)!;

      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _sendSupportEmail,
            icon: Icon(Icons.headset_mic, color: Colors.white),
          ),
          title: Text(
            l10n.inbox,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            // Toggle style tab buttons (same as my bookings)
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
                  _buildInboxContent(context, 'driver'),
                  _buildInboxContent(context, 'rider'),
                ],
              ),
            ),
          ],
        ),
      );
    } catch (e, stackTrace) {
      print('Error in InboxScreen build: $e');
      print('Stack trace: $stackTrace');
      return Scaffold(
        appBar: AppBar(title: Text('Inbox')),
        body: Center(child: Text('Error loading inbox')),
      );
    }
  }

  Widget _buildInboxContent(BuildContext context, String role) {
    final l10n = AppLocalizations.of(context)!;

    return ValueListenableBuilder(
          valueListenable: _messagingService.conversations,
          builder: (context, List<Conversation> conversations, child) {
            // Get current user INSIDE the builder so it's always fresh
            final currentUser = AuthService.currentUser;
            
            if (currentUser == null) {
              return Center(child: Text(l10n.pleaseLoginToViewMessages));
            }

            print('📬 InboxScreen: currentUser.id = ${currentUser.id}, name = ${currentUser.name}');
            
            // Get conversations and filter by visibility (hide after 7 days from arrival)
            final allUserConversations = _messagingService.getConversationsForUser(
              currentUser.id,
            );

            // Filter out deleted conversations, support conversations, and conversations with no messages
            // Also filter by role: driver sees conversations where they are the driver
            // rider sees conversations where they are the rider
            final validConversations = allUserConversations
                .where((c) => !c.isDeleted && c.messages.isNotEmpty && !c.id.startsWith('support_'))
                .where((c) {
                  if (role == 'driver') {
                    return c.driverId == currentUser.id;
                  } else {
                    return c.riderId == currentUser.id;
                  }
                })
                .toList();

            print('📬 InboxScreen ($role): Found ${validConversations.length} valid conversations');

            // Categorize conversations
            final now = DateTime.now();

            // Helper to check booking status
            // IMPORTANT: Must check the CURRENT USER's booking, not just conversation.bookingId
            // For drivers: check driver booking (conversation.bookingId)
            // For riders: check rider booking (conversation.bookingId_rider_currentUserId)
            bool isUpcoming(Conversation c) {
              if (c.id.startsWith('support_')) return false;

              // Determine which booking to check based on current user role
              String bookingIdToCheck;
              if (c.driverId == currentUser.id) {
                // Current user is driver - check the SPECIFIC RIDER'S booking, not the driver booking
                // This ensures we see the correct status for each rider individually
                bookingIdToCheck = '${c.bookingId}_rider_${c.riderId}';
              } else {
                // Current user is rider - check rider booking
                bookingIdToCheck = '${c.bookingId}_rider_${currentUser.id}';
              }

              final booking = BookingStorage().getBookingById(bookingIdToCheck);

              // If no booking found, this is a pre-booking conversation where rider messaged but hasn't booked yet
              // Show it in Upcoming if the departure time is in the future
              if (booking == null) {
                // Check if this is a pre-booking conversation (has messages but no booking)
                // Use conversation's departure time to determine if it should show
                return c.departureTime.isAfter(now);
              }

              // Include canceled bookings in their time-based category (they'll be sorted to bottom within ride groups)
              return booking.departureTime.isAfter(now) &&
                  booking.isArchived != true;
            }

            bool isOngoing(Conversation c) {
              if (c.id.startsWith('support_')) return false;

              String bookingIdToCheck;
              if (c.driverId == currentUser.id) {
                // Driver checks the specific rider's booking
                bookingIdToCheck = '${c.bookingId}_rider_${c.riderId}';
              } else {
                bookingIdToCheck = '${c.bookingId}_rider_${currentUser.id}';
              }

              final booking = BookingStorage().getBookingById(bookingIdToCheck);
              if (booking == null) return false;
              // Include canceled bookings in their time-based category (they'll be sorted to bottom within ride groups)
              return booking.departureTime.isBefore(now) &&
                  booking.arrivalTime.isAfter(now) &&
                  booking.isArchived != true;
            }

            bool isCompleted(Conversation c) {
              if (c.id.startsWith('support_')) return false;

              String bookingIdToCheck;
              if (c.driverId == currentUser.id) {
                // Driver checks the specific rider's booking
                bookingIdToCheck = '${c.bookingId}_rider_${c.riderId}';
              } else {
                bookingIdToCheck = '${c.bookingId}_rider_${currentUser.id}';
              }

              final booking = BookingStorage().getBookingById(bookingIdToCheck);
              if (booking == null) return false;
              // Include canceled bookings in their time-based category (they'll be sorted to bottom within ride groups)
              return booking.arrivalTime.isBefore(now) &&
                  booking.isArchived != true;
            }

            // Categorize (no support or archived sections - completed rides hidden after 7 days)
            final sevenDaysAgo = now.subtract(Duration(days: 7));
            final oneDayAgo = now.subtract(Duration(days: 1));

            // Helper to check if a conversation's booking is canceled
            bool isCanceled(Conversation c) {
              String bookingIdToCheck;
              if (c.driverId == currentUser.id) {
                bookingIdToCheck = '${c.bookingId}_rider_${c.riderId}';
              } else {
                bookingIdToCheck = '${c.bookingId}_rider_${currentUser.id}';
              }
              final booking = BookingStorage().getBookingById(bookingIdToCheck);
              return booking?.isCanceled == true;
            }

            // Current: upcoming + ongoing, NON-canceled only
            // Sort by departure time
            final current = validConversations
                .where((c) => !c.id.startsWith('support_') && (isUpcoming(c) || isOngoing(c)) && !isCanceled(c))
                .toList()
              ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

            // Canceled: all canceled rides (visible for 1 day after cancellation)
            // Sort by departure time desc (most recent first)
            final canceled = validConversations
                .where((c) => !c.id.startsWith('support_') && isCanceled(c) && c.departureTime.isAfter(oneDayAgo))
                .toList()
              ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

            // Completed: completed rides within the last 7 days, NON-canceled only
            // Sort by departure time desc (most recent first)
            final completed = validConversations
                .where((c) => !c.id.startsWith('support_') && isCompleted(c) && !isCanceled(c) && c.arrivalTime.isAfter(sevenDaysAgo))
                .toList()
              ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

            // Check if we have any conversations
            final hasAnyConversations = current.isNotEmpty || canceled.isNotEmpty || completed.isNotEmpty;

            if (!hasAnyConversations) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mail_outline, size: 80, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(l10n.noMessagesYet, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  ],
                ),
              );
            }

            // Group each category by bookingId
            Map<String, List<Conversation>> groupByRide(List<Conversation> conversations) {
              final Map<String, List<Conversation>> grouped = {};
              for (final conv in conversations) {
                grouped.putIfAbsent(conv.bookingId, () => []).add(conv);
              }
              return grouped;
            }

            List<List<Conversation>> toRideGroups(List<Conversation> conversations) {
              final grouped = groupByRide(conversations);
              final groups = <List<Conversation>>[];
              final addedKeys = <String>{};
              for (final conv in conversations) {
                if (!addedKeys.contains(conv.bookingId)) {
                  addedKeys.add(conv.bookingId);
                  groups.add(grouped[conv.bookingId]!);
                }
              }
              return groups;
            }

            final currentGroups = toRideGroups(current);
            final canceledGroups = toRideGroups(canceled);
            final completedGroups = toRideGroups(completed);

            // Build list items with section headers
            final List<Widget> listItems = [];

            // Current section
            if (currentGroups.isNotEmpty) {
              listItems.add(_buildSectionHeader(l10n.current, Icons.schedule, Colors.blue[700]!));
              for (final group in currentGroups) {
                listItems.add(Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: _RideGroupCard(
                    bookingId: group.first.bookingId,
                    conversations: group,
                    currentUserId: currentUser.id,
                    isDriver: role == 'driver',
                  ),
                ));
              }
            }

            // Canceled section
            if (canceledGroups.isNotEmpty) {
              listItems.add(_buildSectionHeader(l10n.canceled, Icons.cancel, Colors.red[700]!));
              for (final group in canceledGroups) {
                listItems.add(Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: _RideGroupCard(
                    bookingId: group.first.bookingId,
                    conversations: group,
                    currentUserId: currentUser.id,
                    isDriver: role == 'driver',
                  ),
                ));
              }
            }

            // Completed section
            if (completedGroups.isNotEmpty) {
              listItems.add(_buildSectionHeader(l10n.completed, Icons.check_circle, Colors.green[700]!));
              for (final group in completedGroups) {
                listItems.add(Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: _RideGroupCard(
                    bookingId: group.first.bookingId,
                    conversations: group,
                    currentUserId: currentUser.id,
                    isDriver: role == 'driver',
                  ),
                ));
              }
            }

            return ListView(
              padding: EdgeInsets.all(16),
              children: listItems,
            );
          },
        );
  }

  /// Build section header separator
  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: color.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

/// Expandable ride card that groups all conversations for a single ride
class _RideGroupCard extends StatefulWidget {
  final String bookingId;
  final List<Conversation> conversations;
  final String currentUserId;
  final bool isDriver;

  const _RideGroupCard({
    required this.bookingId,
    required this.conversations,
    required this.currentUserId,
    required this.isDriver,
  });

  @override
  State<_RideGroupCard> createState() => _RideGroupCardState();
}

class _RideGroupCardState extends State<_RideGroupCard> {
  @override
  Widget build(BuildContext context) {
    // Sort conversations: non-canceled first, then canceled at the bottom
    final sortedConversations = List<Conversation>.from(widget.conversations);
    sortedConversations.sort((a, b) {
      // Check if each conversation's booking is canceled
      final aRiderBookingId = '${a.bookingId}_rider_${a.riderId}';
      final bRiderBookingId = '${b.bookingId}_rider_${b.riderId}';

      final aBooking = BookingStorage().getBookingById(aRiderBookingId);
      final bBooking = BookingStorage().getBookingById(bRiderBookingId);

      final aIsCanceled = aBooking?.isCanceled == true;
      final bIsCanceled = bBooking?.isCanceled == true;

      // Canceled rides go to bottom (return 1 if a is canceled, -1 if b is canceled)
      if (aIsCanceled && !bIsCanceled) return 1;
      if (!aIsCanceled && bIsCanceled) return -1;

      // Both same status - maintain original order
      return 0;
    });

    // Use the first conversation for ride details (they all have the same ride info)
    final firstConversation = sortedConversations.first;

    // For riders: show header with message card semi-detached (same dimensions as driver's)
    // For drivers with multiple riders: show expandable view with chevron
    if (!widget.isDriver) {
      // Rider view: compact header + message card below with subtle connection
      final conversation = sortedConversations.first;

      // Get booking status for rider
      final riderBookingId = '${conversation.bookingId}_rider_${widget.currentUserId}';
      final booking = BookingStorage().getBookingById(riderBookingId);
      final isCanceled = booking?.isCanceled == true;

      // Get driver info for photo and rating
      final driver = MockUsers.getUserById(firstConversation.driverId);
      final driverPhotoUrl = driver?.profilePhotoUrl;
      final driverName = driver != null
          ? (driver.surname.isNotEmpty ? '${driver.name} ${driver.surname[0]}.' : driver.name)
          : 'Driver';
      final driverRating = driver != null ? MockUsers.getLiveRating(driver.id) : 0.0;

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCanceled ? Colors.grey[300]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Compact ride header - Ride details | Driver sign (original layout)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isCanceled
                    ? Colors.grey.withValues(alpha: 0.08)
                    : Colors.grey.withValues(alpha: 0.04),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(11),
                  topRight: Radius.circular(11),
                ),
              ),
              child: Row(
                children: [
                  // Left: Ride details
                  Expanded(
                    child: RideInfoCard(
                      routeName: firstConversation.routeName,
                      originName: firstConversation.originName,
                      destinationName: firstConversation.destinationName,
                      departureTime: firstConversation.departureTime,
                      arrivalTime: firstConversation.arrivalTime,
                      embedded: true,
                      centered: false,
                    ),
                  ),
                  SizedBox(width: 8),
                  // Right: Driver sign with name/rating next to avatar
                  _buildDriverSign(driverPhotoUrl, driverName, driverRating),
                ],
              ),
            ),
            // Subtle separator
            Container(
              height: 1,
              color: isCanceled ? Colors.grey[300] : Colors.grey[200],
            ),
            // Message card area - same padding as driver's cards
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(11),
                  bottomRight: Radius.circular(11),
                ),
              ),
              child: ConversationCard(
                conversation: conversation,
                mode: ConversationCardMode.inboxGrouped,
                currentUserId: widget.currentUserId,
                unreadUserId: widget.currentUserId,
                isCanceled: isCanceled,
                hideAvatar: true, // Driver already shown in header above
                onTap: isCanceled ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(conversation: conversation),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    // Driver view: expandable header with rider count indicator
    // Get driver info for photo and rating
    final driver = MockUsers.getUserById(firstConversation.driverId);
    final driverPhotoUrl = driver?.profilePhotoUrl;
    final driverName = driver != null
        ? (driver.surname.isNotEmpty ? '${driver.name} ${driver.surname[0]}.' : driver.name)
        : 'Driver';
    final driverRating = driver != null ? MockUsers.getLiveRating(driver.id) : 0.0;

    // Get the driver booking for seat mapping
    final driverBooking = BookingStorage().getBookingById(widget.bookingId);

    // Build seat-to-rider mapping for all 4 seats
    final seatRiderMap = _buildSeatRiderMap(sortedConversations, driverBooking);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: EdgeInsets.zero,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row: Ride Info only (full width)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: RideInfoCard(
                  routeName: firstConversation.routeName,
                  originName: firstConversation.originName,
                  destinationName: firstConversation.destinationName,
                  departureTime: firstConversation.departureTime,
                  arrivalTime: firstConversation.arrivalTime,
                  embedded: true,
                  centered: false,
                ),
              ),
              // Subtle horizontal separator
              Container(
                height: 1,
                color: Colors.grey.withValues(alpha: 0.15),
              ),
              // Bottom row: riders who messaged + Driver
              Container(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: _buildSeatsAndDriverRow(seatRiderMap, sortedConversations, driverPhotoUrl, driverName, driverRating),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build mapping of seat index to rider info for mini grid
  Map<int, _SeatRiderInfo> _buildSeatRiderMap(List<Conversation> conversations, dynamic driverBooking) {
    final Map<int, _SeatRiderInfo> seatMap = {};

    // Get available seats from driver booking
    final availableSeats = driverBooking?.selectedSeats as List<int>? ?? [0, 1, 2, 3];

    // Mark all 4 seats - unavailable ones as blocked
    for (int i = 0; i < 4; i++) {
      if (!availableSeats.contains(i)) {
        seatMap[i] = _SeatRiderInfo(
          seatIndex: i,
          isBlocked: true,
        );
      }
    }

    // Map riders from driver booking's riders list (has seat info)
    if (driverBooking?.riders != null) {
      for (final rider in driverBooking.riders) {
        final riderId = rider.userId;
        final seatIndex = rider.seatIndex;

        // Find conversation for this rider
        final conversation = conversations.where((c) => c.riderId == riderId).firstOrNull;
        final unreadCount = conversation?.getUnreadCount(widget.currentUserId) ?? 0;

        // Check if this rider's booking is canceled
        final riderBookingId = '${widget.bookingId}_rider_$riderId';
        final riderBooking = BookingStorage().getBookingById(riderBookingId);
        final isCanceled = riderBooking?.isCanceled == true;

        seatMap[seatIndex] = _SeatRiderInfo(
          seatIndex: seatIndex,
          riderId: riderId,
          riderName: rider.name,
          profilePhotoUrl: rider.profilePhotoUrl,
          rating: rider.rating,
          hasUnread: unreadCount > 0,
          unreadCount: unreadCount,
          isCanceled: isCanceled,
          conversation: conversation,
        );
      }
    }

    return seatMap;
  }

  /// Build slot avatar from photo URL
  Widget _buildSlotAvatar(String photoUrl, bool isCanceled, {double size = 60}) {
    Widget image;
    if (photoUrl.startsWith('assets/')) {
      image = Image.asset(
        photoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(Icons.person, size: size * 0.5, color: Colors.blue[400]),
      );
    } else {
      final file = File(photoUrl);
      if (file.existsSync()) {
        image = Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      } else {
        return Icon(Icons.person, size: size * 0.5, color: Colors.blue[400]);
      }
    }

    if (isCanceled) {
      return ColorFiltered(
        colorFilter: ColorFilter.mode(Colors.grey, BlendMode.saturation),
        child: image,
      );
    }
    return image;
  }

  /// Build driver sign with avatar above name/rating + DRIVER label on right
  Widget _buildDriverSign(String? profilePhotoUrl, String name, double rating) {
    const avatarSize = 40.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar and info
        SizedBox(
          width: 52,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red[300]!, width: 2),
                ),
                child: ClipOval(
                  child: profilePhotoUrl != null
                      ? _buildSlotAvatar(profilePhotoUrl, false, size: avatarSize)
                      : Icon(Icons.person, size: avatarSize * 0.5, color: Colors.red[400]),
                ),
              ),
              // Name and rating below avatar
              Transform.translate(
                offset: Offset(0, -3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name.split(' ').first,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    RatingDisplay(
                      rating: rating,
                      starSize: 8,
                      fontSize: 8,
                      starColor: Colors.amber,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 6),
        // Vertical "DRIVER" label on right (notched style)
        RotatedBox(
          quarterTurns: 1,
          child: Text(
            'DRIVER',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.red[600],
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  /// Build bottom row with riders who messaged + driver
  Widget _buildSeatsAndDriverRow(
    Map<int, _SeatRiderInfo> seatRiderMap,
    List<Conversation> conversations,
    String? driverPhotoUrl,
    String driverName,
    double driverRating,
  ) {
    // Collect booked riders who have messaged
    final ridersWithMessages = <_SeatRiderInfo>[];
    final bookedRiderIds = <String>{};

    for (int i = 0; i < 4; i++) {
      final rider = seatRiderMap[i];
      if (rider != null && rider.conversation != null && rider.riderId != null && !rider.isCanceled) {
        ridersWithMessages.add(rider);
        bookedRiderIds.add(rider.riderId!);
      }
    }

    // Add messaged-but-not-booked riders (orange)
    for (final conv in conversations) {
      if (!bookedRiderIds.contains(conv.riderId)) {
        // This rider messaged but didn't book
        final riderUser = MockUsers.getUserById(conv.riderId);
        ridersWithMessages.add(_SeatRiderInfo(
          seatIndex: -1, // Not booked, so no seat
          riderId: conv.riderId,
          riderName: riderUser != null
              ? (riderUser.surname.isNotEmpty ? '${riderUser.name} ${riderUser.surname[0]}.' : riderUser.name)
              : 'Rider',
          profilePhotoUrl: riderUser?.profilePhotoUrl,
          rating: riderUser != null ? MockUsers.getLiveRating(riderUser.id) : null,
          hasUnread: conv.getUnreadCount(widget.currentUserId) > 0,
          unreadCount: conv.getUnreadCount(widget.currentUserId),
          conversation: conv,
        ));
      }
    }

    // Sort by most recent message timestamp (newest first)
    // This ensures new messages bring the rider to the leftmost position
    ridersWithMessages.sort((a, b) {
      final aLastMessage = a.conversation?.messages.lastOrNull?.timestamp;
      final bLastMessage = b.conversation?.messages.lastOrNull?.timestamp;

      if (aLastMessage == null && bLastMessage == null) return 0;
      if (aLastMessage == null) return 1;
      if (bLastMessage == null) return -1;

      // Newest first (reverse chronological)
      return bLastMessage.compareTo(aLastMessage);
    });

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Vertical "RIDERS" label (notched style)
          if (ridersWithMessages.isNotEmpty)
            RotatedBox(
              quarterTurns: 3,
              child: Text(
                'RIDERS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.green[600],
                  letterSpacing: 1.5,
                ),
              ),
            ),
          if (ridersWithMessages.isNotEmpty)
            SizedBox(width: 6),
          // Riders who messaged (scrollable with edge fade)
          if (ridersWithMessages.isNotEmpty)
            Expanded(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white,
                      Colors.white,
                      Colors.white,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.7, 0.85, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final rider in ridersWithMessages)
                        Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: _buildRiderSlot(rider),
                        ),
                      SizedBox(width: 16), // Extra space for fade area
                    ],
                  ),
                ),
              ),
            )
          else
            Spacer(),
          // Subtle vertical divider with indicator dots
          SizedBox(
            width: 21, // 10 (margin) + 1 (divider) + 10 (margin)
            child: Stack(
              children: [
                // Vertical divider line
                Center(
                  child: Container(
                    width: 1,
                    margin: EdgeInsets.symmetric(vertical: 4),
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                // Check if there are hidden riders with unread
                // Assume first 2 riders are visible, check if riders beyond that have unread
                Builder(
                  builder: (context) {
                    // Only check riders that are likely hidden (beyond first 2)
                    final hiddenRiders = ridersWithMessages.length > 2
                        ? ridersWithMessages.skip(2).toList()
                        : <_SeatRiderInfo>[];

                    // Check if any hidden riders have unread
                    final hiddenBookedWithUnread = hiddenRiders.where((r) => r.seatIndex >= 0 && r.hasUnread).isNotEmpty;
                    final hiddenMessagedWithUnread = hiddenRiders.where((r) => r.seatIndex < 0 && r.hasUnread).isNotEmpty;

                    return Stack(
                      children: [
                        // Green dot for hidden booked riders with unread (on separator line)
                        if (hiddenBookedWithUnread)
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green[600],
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        // Orange dot for hidden messaged-but-not-booked riders with unread (on separator line)
                        // Only show if no green dot (green takes priority)
                        if (!hiddenBookedWithUnread && hiddenMessagedWithUnread)
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.orange[600],
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          // Driver
          _buildDriverSign(driverPhotoUrl, driverName, driverRating),
        ],
      ),
    );
  }

  /// Build a rider slot (booked = green, messaged only = orange)
  Widget _buildRiderSlot(_SeatRiderInfo rider) {
    const avatarSize = 40.0;

    // Booked riders have a seat index assigned, messaged-only don't
    final bool isBooked = rider.seatIndex >= 0;
    final bool hasUnread = rider.hasUnread;

    // Green for booked, orange for messaged-only
    final Color borderColor = isBooked ? Colors.green[400]! : Colors.orange[400]!;
    final Color bgColor = isBooked ? Colors.green[50]! : Colors.orange[50]!;

    return GestureDetector(
      onTap: rider.conversation != null ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(conversation: rider.conversation!),
          ),
        );
      } : null,
      child: SizedBox(
        width: 52,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar with breathing animation for unread
            SizedBox(
              width: avatarSize + 4,
              height: avatarSize + 4,
              child: hasUnread
                  ? _BreathingAvatar(
                      borderColor: borderColor,
                      bgColor: bgColor,
                      avatarSize: avatarSize,
                      child: rider.profilePhotoUrl != null
                          ? _buildSlotAvatar(rider.profilePhotoUrl!, false, size: avatarSize)
                          : Icon(Icons.person, size: avatarSize * 0.5, color: borderColor),
                    )
                  : Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: bgColor,
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: ClipOval(
                        child: rider.profilePhotoUrl != null
                            ? _buildSlotAvatar(rider.profilePhotoUrl!, false, size: avatarSize)
                            : Icon(Icons.person, size: avatarSize * 0.5, color: borderColor),
                      ),
                    ),
            ),
            // Name and rating below
            Transform.translate(
              offset: Offset(0, -3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    rider.riderName?.split(' ').first ?? '',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  if (rider.rating != null)
                    RatingDisplay(
                      rating: rider.rating!,
                      starSize: 8,
                      fontSize: 8,
                      starColor: Colors.amber,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

/// Helper class to hold rider info for mini seat grid
class _SeatRiderInfo {
  final int seatIndex;
  final String? riderId;
  final String? riderName;
  final String? profilePhotoUrl;
  final double? rating;
  final bool hasUnread;
  final int unreadCount;
  final bool isCanceled;
  final bool isBlocked;
  final Conversation? conversation;

  _SeatRiderInfo({
    required this.seatIndex,
    this.riderId,
    this.riderName,
    this.profilePhotoUrl,
    this.rating,
    this.hasUnread = false,
    this.unreadCount = 0,
    this.isCanceled = false,
    this.isBlocked = false,
    this.conversation,
  });
}

/// Breathing avatar animation for riders with unread messages
class _BreathingAvatar extends StatefulWidget {
  final Color borderColor;
  final Color bgColor;
  final double avatarSize;
  final Widget child;

  const _BreathingAvatar({
    required this.borderColor,
    required this.bgColor,
    required this.avatarSize,
    required this.child,
  });

  @override
  State<_BreathingAvatar> createState() => _BreathingAvatarState();
}

class _BreathingAvatarState extends State<_BreathingAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.avatarSize,
          height: widget.avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.bgColor,
            border: Border.all(
              color: widget.borderColor,
              width: 2 * _animation.value,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.borderColor.withValues(alpha: 0.3 * _animation.value),
                blurRadius: 8 * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
          child: ClipOval(child: widget.child),
        );
      },
    );
  }
}
