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

            // Current: upcoming + ongoing combined (arrival time in the future)
            // Sort by: non-canceled first (by departure time), then canceled (by departure time)
            final current = validConversations
                .where((c) => !c.id.startsWith('support_') && (isUpcoming(c) || isOngoing(c)))
                .toList()
              ..sort((a, b) {
                final aCanceled = isCanceled(a);
                final bCanceled = isCanceled(b);
                if (aCanceled != bCanceled) {
                  return aCanceled ? 1 : -1; // Canceled goes to bottom
                }
                return a.departureTime.compareTo(b.departureTime);
              });

            // Completed: only show rides completed within the last 7 days
            // Sort by: non-canceled first (by departure time desc), then canceled (by departure time desc)
            final completed = validConversations
                .where((c) => !c.id.startsWith('support_') && isCompleted(c) && c.arrivalTime.isAfter(sevenDaysAgo))
                .toList()
              ..sort((a, b) {
                final aCanceled = isCanceled(a);
                final bCanceled = isCanceled(b);
                if (aCanceled != bCanceled) {
                  return aCanceled ? 1 : -1; // Canceled goes to bottom
                }
                return b.departureTime.compareTo(a.departureTime);
              });

            // Check if we have any conversations
            final hasAnyConversations = current.isNotEmpty || completed.isNotEmpty;

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

            // Combine all conversations in order: Current, Completed
            final allConversations = [
              ...current,
              ...completed,
            ];

            // Group by bookingId for ride grouping
            final Map<String, List<Conversation>> groupedByRide = {};
            for (final conv in allConversations) {
              groupedByRide.putIfAbsent(conv.bookingId, () => []).add(conv);
            }

            // Helper to check if a ride group is canceled (check first conversation)
            bool isRideGroupCanceled(List<Conversation> conversations) {
              if (conversations.isEmpty) return false;
              final c = conversations.first;
              String bookingIdToCheck;
              if (c.driverId == currentUser.id) {
                bookingIdToCheck = '${c.bookingId}_rider_${c.riderId}';
              } else {
                bookingIdToCheck = '${c.bookingId}_rider_${currentUser.id}';
              }
              final booking = BookingStorage().getBookingById(bookingIdToCheck);
              return booking?.isCanceled == true;
            }

            // Convert to list of ride groups maintaining order
            final rideGroups = <List<Conversation>>[];
            final addedKeys = <String>{};
            for (final conv in allConversations) {
              if (!addedKeys.contains(conv.bookingId)) {
                addedKeys.add(conv.bookingId);
                rideGroups.add(groupedByRide[conv.bookingId]!);
              }
            }

            // Sort ride groups: non-canceled first, then canceled at the bottom
            rideGroups.sort((a, b) {
              final aCanceled = isRideGroupCanceled(a);
              final bCanceled = isRideGroupCanceled(b);
              if (aCanceled != bCanceled) {
                return aCanceled ? 1 : -1; // Canceled goes to bottom
              }
              // Keep the original order (by departure time) for same-status groups
              return a.first.departureTime.compareTo(b.first.departureTime);
            });

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: rideGroups.length,
              itemBuilder: (context, index) {
                final conversations = rideGroups[index];

                // Ride group
                return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: _RideGroupCard(
                    bookingId: conversations.first.bookingId,
                    conversations: conversations,
                    currentUserId: currentUser.id,
                    isDriver: role == 'driver',
                  ),
                );
              },
            );
          },
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
  bool _isExpanded = false;

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

      // Get driver info for photo
      final driver = MockUsers.getUserById(firstConversation.driverId);
      final driverPhotoUrl = driver?.profilePhotoUrl;

      // Determine ride status
      final now = DateTime.now();
      final isArchived = booking?.isArchived == true;
      final isOngoing = booking != null && booking.departureTime.isBefore(now) && booking.arrivalTime.isAfter(now);
      final isCompleted = booking != null && booking.arrivalTime.isBefore(now) && !isArchived;
      final isUpcoming = booking == null || (booking.departureTime.isAfter(now) && !isArchived);

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
            // Compact ride header - same width as message card
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  // Left: Driver photo with label (opposite of driver's inbox)
                  _buildDriverSignLeft(driverPhotoUrl),
                  SizedBox(width: 8),
                  // Middle: Ride details
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
                  SizedBox(width: 10),
                  // Right: Status badge (compact)
                  _buildStatusBadge(
                    isArchived: isArchived,
                    isCanceled: isCanceled,
                    isOngoing: isOngoing,
                    isCompleted: isCompleted,
                    isUpcoming: isUpcoming,
                  ),
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
    // Get driver info for photo
    final driver = MockUsers.getUserById(firstConversation.driverId);
    final driverPhotoUrl = driver?.profilePhotoUrl;

    // Determine ride status for driver (check the driver booking)
    final driverBooking = BookingStorage().getBookingById(widget.bookingId);
    final now = DateTime.now();
    final isDriverArchived = driverBooking?.isArchived == true;
    final isDriverCanceled = driverBooking?.isCanceled == true;
    final isDriverOngoing = driverBooking != null && driverBooking.departureTime.isBefore(now) && driverBooking.arrivalTime.isAfter(now);
    final isDriverCompleted = driverBooking != null && driverBooking.arrivalTime.isBefore(now) && !isDriverArchived;
    final isDriverUpcoming = driverBooking == null || (driverBooking.departureTime.isAfter(now) && !isDriverArchived);

    // Build seat-to-rider mapping for mini grid
    final seatRiderMap = _buildSeatRiderMap(sortedConversations, driverBooking);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header card with ride details and mini seat grid
        Card(
          margin: EdgeInsets.zero,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row: Status | Ride Info | Driver Sign
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(_isExpanded ? 0 : 12),
                  bottomRight: Radius.circular(_isExpanded ? 0 : 12),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      // Left: Status badge
                      _buildStatusBadge(
                        isArchived: isDriverArchived,
                        isCanceled: isDriverCanceled,
                        isOngoing: isDriverOngoing,
                        isCompleted: isDriverCompleted,
                        isUpcoming: isDriverUpcoming,
                      ),
                      SizedBox(width: 10),
                      // Middle: Ride details
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
                      // Right: Driver photo with label
                      _buildDriverSign(driverPhotoUrl),
                    ],
                  ),
                ),
              ),
              // Mini Seat Grid - always visible, shows rider occupancy
              if (sortedConversations.isNotEmpty)
                _buildMiniSeatGrid(seatRiderMap, sortedConversations),
            ],
          ),
        ),
        // Message cards with status icons (expanded below the card)
        if (_isExpanded)
          ...sortedConversations.map((conversation) {
            // Check if this specific rider's booking is canceled
            final riderBookingId = '${conversation.bookingId}_rider_${conversation.riderId}';
            final riderBooking = BookingStorage().getBookingById(riderBookingId);
            final isRiderCanceled = riderBooking?.isCanceled == true;

            return Padding(
              padding: EdgeInsets.only(left: 10, top: 12),
              child: ConversationCard(
                conversation: conversation,
                mode: ConversationCardMode.inboxGrouped,
                currentUserId: widget.currentUserId,
                unreadUserId: widget.currentUserId,
                showRiderLabel: true,
                isCanceled: isRiderCanceled,
                onTap: isRiderCanceled ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(conversation: conversation),
                    ),
                  );
                },
              ),
            );
          }),
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

  /// Build passenger row - all riders in a clean row with message indicators
  Widget _buildMiniSeatGrid(Map<int, _SeatRiderInfo> seatMap, List<Conversation> conversations) {
    // Separate booked riders from available seats
    final bookedRiders = <_SeatRiderInfo>[];
    int availableCount = 0;

    for (int i = 0; i < 4; i++) {
      final info = seatMap[i];
      if (info != null && info.riderId != null && !info.isCanceled) {
        bookedRiders.add(info);
      } else if (info == null || (!info.isBlocked && info.riderId == null)) {
        availableCount++;
      }
    }

    // All items to display: booked riders + available seats indicator
    final totalItems = bookedRiders.length + (availableCount > 0 ? 1 : 0);

    if (totalItems == 0) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: _buildRiderRow(bookedRiders, availableCount),
    );
  }

  /// Build a clean row of rider avatars (no stacking)
  Widget _buildRiderRow(List<_SeatRiderInfo> bookedRiders, int availableCount) {
    const avatarSize = 40.0;
    const spacing = 12.0;

    // Calculate if we need carousel (more than 4 items won't fit nicely)
    final totalItems = bookedRiders.length + (availableCount > 0 ? 1 : 0);
    final needsCarousel = totalItems > 4;

    if (needsCarousel) {
      return _RiderCarousel(
        bookedRiders: bookedRiders,
        availableCount: availableCount,
        avatarSize: avatarSize,
        onRiderTap: (rider) {
          if (rider.conversation != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(conversation: rider.conversation!),
              ),
            );
          }
        },
        buildAvatar: _buildSlotAvatar,
      );
    }

    // Normal row layout
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Booked riders
        ...bookedRiders.map((rider) => Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: _buildRiderAvatar(rider, avatarSize),
        )),
        // Available seats indicator
        if (availableCount > 0)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: _buildAvailableSeatsIndicator(availableCount, avatarSize),
          ),
      ],
    );
  }

  /// Build a single rider avatar with optional message indicator
  Widget _buildRiderAvatar(_SeatRiderInfo rider, double size) {
    return GestureDetector(
      onTap: rider.conversation != null ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(conversation: rider.conversation!),
          ),
        );
      } : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar with message indicator
          SizedBox(
            width: size + 8, // Extra space for indicator
            height: size + 8,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Main avatar
                Positioned(
                  left: 4,
                  top: 4,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.green[400]!, width: 2),
                    ),
                    child: ClipOval(
                      child: rider.profilePhotoUrl != null
                          ? _buildSlotAvatar(rider.profilePhotoUrl!, false)
                          : Icon(Icons.person, size: size * 0.5, color: Colors.green[600]),
                    ),
                  ),
                ),
                // Small message indicator (top-right, not overlapping avatar)
                if (rider.hasUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green[500],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.mail,
                          size: 9,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 2),
          // Name below
          SizedBox(
            width: size + 8,
            child: Text(
              rider.riderName?.split(' ').first ?? '',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          // Rating below name
          if (rider.rating != null)
            RatingDisplay(
              rating: rider.rating!,
              starSize: 8,
              fontSize: 8,
              starColor: Colors.amber,
            ),
        ],
      ),
    );
  }

  /// Build available seats indicator
  Widget _buildAvailableSeatsIndicator(int count, double size) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size + 8,
          height: size + 8,
          child: Center(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green[50],
                border: Border.all(color: Colors.green[300]!, width: 2),
              ),
              child: Center(
                child: Text(
                  '+$count',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 2),
        Text(
          'seats',
          style: TextStyle(
            fontSize: 9,
            color: Colors.green[600],
          ),
        ),
      ],
    );
  }

  /// Build slot avatar from photo URL
  Widget _buildSlotAvatar(String photoUrl, bool isCanceled) {
    Widget image;
    if (photoUrl.startsWith('assets/')) {
      image = Image.asset(
        photoUrl,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(Icons.person, size: 20, color: Colors.blue[400]),
      );
    } else {
      final file = File(photoUrl);
      if (file.existsSync()) {
        image = Image.file(
          file,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        );
      } else {
        return Icon(Icons.person, size: 20, color: Colors.blue[400]);
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

  /// Build driver sign - notched card style (like admin panel) - avatar on LEFT
  Widget _buildDriverSign(String? profilePhotoUrl) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.only(left: 22, right: 6, top: 6, bottom: 6),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.directions_car, size: 14, color: Colors.grey[600]),
              SizedBox(height: 1),
              Text(
                'Driver',
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Positioned(
          left: -14,
          top: 0,
          bottom: 0,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.withValues(alpha: 0.15), width: 1.5),
              ),
              child: _buildAvatar(profilePhotoUrl, radius: 16),
            ),
          ),
        ),
      ],
    );
  }

  /// Build driver sign for rider's view - avatar on RIGHT (opposite of driver's inbox)
  Widget _buildDriverSignLeft(String? profilePhotoUrl) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.only(left: 6, right: 22, top: 6, bottom: 6),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.directions_car, size: 14, color: Colors.grey[600]),
              SizedBox(height: 1),
              Text(
                'Driver',
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Positioned(
          right: -14,
          top: 0,
          bottom: 0,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.withValues(alpha: 0.15), width: 1.5),
              ),
              child: _buildAvatar(profilePhotoUrl, radius: 16),
            ),
          ),
        ),
      ],
    );
  }

  /// Build avatar widget
  Widget _buildAvatar(String? profilePhotoUrl, {Color? fallbackColor, double radius = 14}) {
    final color = fallbackColor ?? Colors.blue;
    if (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty) {
      if (profilePhotoUrl.startsWith('assets/')) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: AssetImage(profilePhotoUrl),
        );
      } else {
        final photoFile = File(profilePhotoUrl);
        if (photoFile.existsSync()) {
          return CircleAvatar(
            radius: radius,
            backgroundImage: FileImage(photoFile),
          );
        }
      }
    }
    // Fallback
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(Icons.person, color: color, size: radius),
    );
  }

  /// Build status badge - compact icon only
  Widget _buildStatusBadge({
    required bool isArchived,
    required bool isCanceled,
    required bool isOngoing,
    required bool isCompleted,
    required bool isUpcoming,
  }) {
    IconData icon;
    Color color;

    if (isArchived) {
      icon = Icons.archive;
      color = Colors.grey[600]!;
    } else if (isCanceled) {
      icon = Icons.cancel;
      color = Colors.red[700]!;
    } else if (isOngoing) {
      icon = Icons.directions_car;
      color = Colors.orange[700]!;
    } else if (isCompleted) {
      icon = Icons.check_circle;
      color = Colors.green[700]!;
    } else {
      icon = Icons.schedule;
      color = Colors.blue[700]!;
    }

    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 14, color: color),
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

/// Carousel widget for rider avatars when there are too many to fit
class _RiderCarousel extends StatefulWidget {
  final List<_SeatRiderInfo> bookedRiders;
  final int availableCount;
  final double avatarSize;
  final void Function(_SeatRiderInfo rider) onRiderTap;
  final Widget Function(String photoUrl, bool isCanceled) buildAvatar;

  const _RiderCarousel({
    required this.bookedRiders,
    required this.availableCount,
    required this.avatarSize,
    required this.onRiderTap,
    required this.buildAvatar,
  });

  @override
  State<_RiderCarousel> createState() => _RiderCarouselState();
}

class _RiderCarouselState extends State<_RiderCarousel> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemWidth = widget.avatarSize + 20; // avatar + padding

    return SizedBox(
      height: widget.avatarSize + 42, // avatar + name + rating + spacing
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.bookedRiders.length + (widget.availableCount > 0 ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < widget.bookedRiders.length) {
            final rider = widget.bookedRiders[index];
            return SizedBox(
              width: itemWidth,
              child: _buildRiderItem(rider),
            );
          } else {
            // Available seats indicator
            return SizedBox(
              width: itemWidth,
              child: _buildAvailableItem(),
            );
          }
        },
      ),
    );
  }

  Widget _buildRiderItem(_SeatRiderInfo rider) {
    return GestureDetector(
      onTap: () => widget.onRiderTap(rider),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar with message indicator
          SizedBox(
            width: widget.avatarSize + 8,
            height: widget.avatarSize + 8,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 4,
                  top: 4,
                  child: Container(
                    width: widget.avatarSize,
                    height: widget.avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.green[400]!, width: 2),
                    ),
                    child: ClipOval(
                      child: rider.profilePhotoUrl != null
                          ? widget.buildAvatar(rider.profilePhotoUrl!, false)
                          : Icon(Icons.person, size: widget.avatarSize * 0.5, color: Colors.green[600]),
                    ),
                  ),
                ),
                if (rider.hasUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green[500],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Center(
                        child: Icon(Icons.mail, size: 9, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 2),
          SizedBox(
            width: widget.avatarSize + 8,
            child: Text(
              rider.riderName?.split(' ').first ?? '',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          // Rating below name
          if (rider.rating != null)
            RatingDisplay(
              rating: rider.rating!,
              starSize: 8,
              fontSize: 8,
              starColor: Colors.amber,
            ),
        ],
      ),
    );
  }

  Widget _buildAvailableItem() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.avatarSize + 8,
          height: widget.avatarSize + 8,
          child: Center(
            child: Container(
              width: widget.avatarSize,
              height: widget.avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green[50],
                border: Border.all(color: Colors.green[300]!, width: 2),
              ),
              child: Center(
                child: Text(
                  '+${widget.availableCount}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 2),
        Text(
          'seats',
          style: TextStyle(fontSize: 9, color: Colors.green[600]),
        ),
      ],
    );
  }
}

