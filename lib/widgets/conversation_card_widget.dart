import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../models/message.dart';
import '../models/user.dart';
import '../models/booking.dart';
import '../services/booking_storage.dart';
import '../services/rating_service.dart';
import '../services/mock_users.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import 'rating_widgets.dart';
import 'ride_info_card.dart';

/// Display mode for ConversationCard
enum ConversationCardMode {
  /// Admin mode: Shows both driver and rider with labels, status badges, no message preview
  admin,
  /// Inbox mode: Shows single avatar (other party) with message preview
  inbox,
}

/// Shared conversation card widget used across:
/// - Admin Panel Messages tab (admin mode)
/// - Admin Panel User details (admin mode)
/// - Inbox screen (inbox mode)
class ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final ConversationCardMode mode;
  final String? currentUserId; // Required for inbox mode to determine "other" user
  final bool showUnreadBadge;
  final String unreadUserId; // User ID to check unread count for
  final void Function(User user)? onAvatarTap; // Callback when avatar is tapped
  final bool isArchived; // For inbox mode styling

  const ConversationCard({
    super.key,
    required this.conversation,
    required this.onTap,
    this.mode = ConversationCardMode.admin,
    this.currentUserId,
    this.showUnreadBadge = true,
    this.unreadUserId = 'admin',
    this.onAvatarTap,
    this.isArchived = false,
  });

  @override
  Widget build(BuildContext context) {
    if (mode == ConversationCardMode.inbox) {
      return _buildInboxMode(context);
    }
    return _buildAdminMode(context);
  }

  /// Build inbox mode: single avatar + message preview
  Widget _buildInboxMode(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userId = currentUserId ?? AuthService.currentUser?.id ?? '';
    final isSupport = conversation.id.startsWith('support_');
    final currentUser = AuthService.currentUser;
    final isAdmin = currentUser?.isAdmin ?? false;

    // Determine the "other" person (not yourself)
    final bool amITheDriver = conversation.driverId == userId;
    final String otherUserId = amITheDriver ? conversation.riderId : conversation.driverId;
    final unreadCount = conversation.getUnreadCount(userId);
    final otherUser = MockUsers.getUserById(otherUserId);

    // Format name: "FirstName S." (name + surname initial)
    final String otherUserName = (isSupport && !isAdmin)
        ? l10n.support
        : (otherUser != null
            ? '${otherUser.name} ${otherUser.surname.isNotEmpty ? '${otherUser.surname[0]}.' : ''}'
            : (amITheDriver ? conversation.riderName : conversation.driverName));

    final profilePhotoUrl = otherUser?.profilePhotoUrl;

    // Get booking status - need to check for the CURRENT USER's booking, not just any booking
    // For riders: look for rider booking (format: driverBookingId_rider_userId)
    // For drivers: check if THIS SPECIFIC rider (the one in this conversation) has booked
    Booking? booking;
    bool isBooked = false;
    bool isCanceled = false;

    if (currentUser != null) {
      if (amITheDriver) {
        // Current user is the driver - check if the specific rider in this conversation has booked
        // Format: driverBookingId_rider_riderId
        final riderBookingId = '${conversation.bookingId}_rider_${conversation.riderId}';
        booking = BookingStorage().getBookingById(riderBookingId);

        if (kDebugMode) {
          print('📋 Driver looking for rider booking: $riderBookingId');
        }

        // Also check if the driver's own booking is canceled (affects all riders)
        final driverBooking = BookingStorage().getBookingById(conversation.bookingId);
        if (driverBooking?.isCanceled == true) {
          isCanceled = true;
        } else if (booking?.isCanceled == true) {
          // This specific rider canceled their booking
          isCanceled = true;
        }

        isBooked = booking != null && !isCanceled;
      } else {
        // Current user is the rider - look for their rider booking
        // Format: driverBookingId_rider_userId
        final riderBookingId = '${conversation.bookingId}_rider_${currentUser.id}';
        booking = BookingStorage().getBookingById(riderBookingId);

        if (kDebugMode) {
          print('📋 Rider looking for their booking: $riderBookingId');
        }

        isBooked = booking != null;
        isCanceled = booking?.isCanceled == true;
      }
    }

    if (kDebugMode) {
      print('📋 ConversationCard inbox mode for conversation: ${conversation.id}');
      print('   conversation.bookingId=${conversation.bookingId}');
      print('   current user booking found=${booking != null}');
      print('   booking id searched=${booking?.id}');
      print('   isBooked=$isBooked');
      print('   isCanceled=$isCanceled');
      print('   isSupport=$isSupport');
      print('   Will show icon: ${!isSupport}');
    }

    // Use white background like booking cards
    // Layout: Cross/Grid format
    // Top row: [Avatar + Name + Rating] | [Message Bubble]
    // Bottom row: [Booking Status Label] | [Ride Details]
    return Card(
      margin: EdgeInsets.only(bottom: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              // TOP ROW: Avatar section (left) + Message bubble (right)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top-Left: Avatar + Name + Rating
                  SizedBox(
                    width: 80,
                    height: 48, // Match bubble height
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            if (isSupport && !isAdmin)
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.support_agent, size: 16, color: Colors.white),
                              )
                            else
                              _buildInboxAvatar(profilePhotoUrl, radius: 16),
                            SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    otherUserName,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // Rating below name
                                  if ((!isSupport || isAdmin) && otherUser?.rating != null) ...[
                                    SizedBox(height: 2),
                                    RatingDisplay(
                                      rating: otherUser?.rating ?? 0.0,
                                      starSize: 9,
                                      fontSize: 8,
                                      starColor: Colors.amber,
                                      fontWeight: FontWeight.w600,
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
                  SizedBox(width: 8),
                  // Top-Right: Message bubble
                  Expanded(
                    child: conversation.getLastMessageForUser(userId) != null
                        ? _buildMessagePreview(userId, unreadCount)
                        : SizedBox(height: 48),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // BOTTOM ROW: Booking status label (left) + Ride details (right)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bottom-Left: Booking status label
                  SizedBox(
                    width: 80,
                    child: !isSupport
                        ? _buildBookingStatusBadge(context, isBooked, isCanceled)
                        : SizedBox.shrink(),
                  ),
                  SizedBox(width: 8),
                  // Bottom-Right: Ride details
                  Expanded(
                    child: _buildTopRow(context, isSupport, forInbox: true, l10n: l10n),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build admin mode: both avatars with labels
  Widget _buildAdminMode(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unreadCount = conversation.getUnreadCount(unreadUserId);
    final isSupport = conversation.id.startsWith('support_');

    // Get driver and rider info
    final driver = MockUsers.getUserById(conversation.driverId);
    final rider = MockUsers.getUserById(conversation.riderId);
    final driverRating = driver != null ? RatingService().getUserAverageRating(driver.id) : 0.0;
    final riderRating = rider != null ? RatingService().getUserAverageRating(rider.id) : 0.0;

    // Card color based on unread status
    final cardColor = unreadCount > 0 ? Colors.blue[100] : Colors.blue[50];

    // For support: determine admin vs user labels
    final isDriverAdmin = driver?.isAdmin == true;
    final leftLabel = isSupport ? (isDriverAdmin ? 'User' : 'Admin') : 'Rider';
    final rightLabel = isSupport ? (isDriverAdmin ? 'Admin' : 'User') : 'Driver';
    final leftIcon = isSupport ? (isDriverAdmin ? Icons.person : Icons.admin_panel_settings) : Icons.person;
    final rightIcon = isSupport ? (isDriverAdmin ? Icons.admin_panel_settings : Icons.person) : Icons.directions_car;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 0.5),
        ),
        child: Column(
          children: [
            // Status label at top (like booking cards)
            if (!isSupport) _buildStatusLabel(context, l10n),
            // Top row: Date and route info (or support type)
            _buildTopRow(context, isSupport),
            SizedBox(height: 10),
            // Middle row: Left person - unread badge - Right person
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left section (Rider)
                Expanded(
                  child: Row(
                    children: [
                      // Left label with semi-circle cutout
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
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
                                child: _buildAvatar(rider?.profilePhotoUrl, isDriver: false, user: rider),
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
                              rider != null
                                  ? '${rider.name} ${rider.surname.isNotEmpty ? '${rider.surname[0]}.' : ''}'
                                  : conversation.riderName,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (rider != null && !isSupport) ...[
                              SizedBox(height: 2),
                              RatingDisplay(
                                rating: riderRating,
                                starSize: 11,
                                fontSize: 11,
                                starColor: Colors.amber,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Center: Unread badge (optional)
                if (showUnreadBadge && unreadCount > 0)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
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
                  ),
                // Right section (Driver)
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
                              driver != null
                                  ? '${driver.name} ${driver.surname.isNotEmpty ? '${driver.surname[0]}.' : ''}'
                                  : conversation.driverName,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (driver != null && !isSupport) ...[
                              SizedBox(height: 2),
                              RatingDisplay(
                                rating: driverRating,
                                starSize: 11,
                                fontSize: 11,
                                starColor: Colors.amber,
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
                                child: _buildAvatar(driver?.profilePhotoUrl, isDriver: !isSupport, user: driver),
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

  Widget _buildStatusLabel(BuildContext context, AppLocalizations l10n) {
    final booking = BookingStorage().getBookingById(conversation.bookingId);

    if (booking == null) return SizedBox.shrink();

    // Determine status - use booking's archived status (includes hidden)
    final bool isCanceled = booking.isCanceled == true;
    final bool isBookingArchived = booking.isArchived == true;
    final bool isOngoing = booking.isActive;
    final bool isCompleted = booking.isPast && !isCanceled;

    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isBookingArchived
              ? Colors.grey.withValues(alpha: 0.1)
              : isCanceled
                  ? Colors.red.withValues(alpha: 0.1)
                  : isOngoing
                      ? Colors.orange.withValues(alpha: 0.1)
                      : isCompleted
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: isBookingArchived
              ? RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    children: [
                      TextSpan(
                        text: booking.isAutoArchived == true ? l10n.autoArchived : l10n.userArchived,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      TextSpan(
                        text: ' (${isCanceled ? l10n.canceled : l10n.completed})',
                        style: TextStyle(color: isCanceled ? Colors.red[700] : Colors.green[700]),
                      ),
                    ],
                  ),
                )
              : Text(
                  isCanceled
                      ? l10n.canceled
                      : isOngoing
                          ? l10n.ongoing
                          : isCompleted
                              ? l10n.completed
                              : l10n.upcoming,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCanceled
                        ? Colors.red[700]
                        : isOngoing
                            ? Colors.orange[700]
                            : isCompleted
                                ? Colors.green[700]
                                : Colors.blue[700],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTopRow(BuildContext context, bool isSupport, {bool forInbox = false, AppLocalizations? l10n}) {
    l10n ??= AppLocalizations.of(context)!;

    if (isSupport) {
      // For support conversations, show the support type banner
      final routeName = conversation.routeName;
      String supportType;
      Color typeColor;
      IconData typeIcon;

      if (routeName.startsWith('Question')) {
        supportType = forInbox ? l10n.question : 'Question';
        typeColor = Colors.blue;
        typeIcon = Icons.help_outline;
      } else if (routeName.startsWith('Suggestion')) {
        supportType = forInbox ? l10n.suggestion : 'Suggestion';
        typeColor = Colors.green;
        typeIcon = Icons.lightbulb_outline;
      } else if (routeName.startsWith('Complaint')) {
        supportType = forInbox ? l10n.complaint : 'Complaint';
        typeColor = Colors.red;
        typeIcon = Icons.report_problem_outlined;
      } else if (routeName.startsWith('New Route Suggestion')) {
        supportType = forInbox ? l10n.newRouteSuggestion : 'New Route';
        typeColor = Colors.blue;
        typeIcon = Icons.add_road;
      } else if (routeName.startsWith('New Stop Suggestion')) {
        supportType = forInbox ? l10n.newStopSuggestion : 'New Stop';
        typeColor = Colors.teal;
        typeIcon = Icons.add_location;
      } else {
        supportType = forInbox ? l10n.support : 'Support';
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

    // Use RideInfoCard for both inbox and admin modes (same as search screens)
    return RideInfoCard(
      routeName: conversation.routeName,
      originName: conversation.originName,
      destinationName: conversation.destinationName,
      departureTime: conversation.departureTime,
      arrivalTime: conversation.arrivalTime,
      embedded: true,
    );
  }

  /// Build avatar for admin mode (with label styling)
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
      avatar = CircleAvatar(
        radius: 20,
        backgroundColor: defaultColor.withValues(alpha: 0.1),
        child: Icon(defaultIcon, color: defaultColor),
      );
    }

    // Wrap with GestureDetector if onAvatarTap callback exists and user is provided
    if (user != null && onAvatarTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onAvatarTap!(user),
        child: avatar,
      );
    }

    return avatar;
  }

  /// Build avatar for inbox mode (simpler, no labels)
  Widget _buildInboxAvatar(String? profilePhotoUrl, {double radius = 20}) {
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

    // Fallback to default icon
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blue.withValues(alpha: 0.1),
      child: Icon(Icons.person, color: Colors.blue, size: radius),
    );
  }

  /// Build message preview bubble for inbox mode
  Widget _buildMessagePreview(String currentUserId, int unreadCount) {
    final lastMessage = conversation.getLastMessageForUser(currentUserId)!;
    final isSystemMessage = lastMessage.isSystemMessage;
    // For system messages, they're never "from" the current user
    final isFromCurrentUser = !isSystemMessage && lastMessage.senderId == currentUserId;

    // Check if this specific message is unread
    final isMessageUnread = !lastMessage.isRead && lastMessage.receiverId == currentUserId;

    // Change bubble color if there are unread messages (app's signature green)
    // BUT: don't highlight system messages with green bubble
    final bubbleColor = (unreadCount > 0 && !isSystemMessage) ? Colors.green[100]! : Colors.white;
    final textColor = Colors.grey[700]!;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: 48, // Fixed height for 2-row bubble (approximately 2 lines of text + padding)
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: isSystemMessage
                ? BorderRadius.circular(8)
                : BorderRadius.only(
                    topLeft: Radius.circular(isFromCurrentUser ? 8 : 2),
                    topRight: Radius.circular(isFromCurrentUser ? 2 : 8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
            border: Border.all(color: Colors.grey[300]!, width: 0.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Robot icon for system messages
              if (isSystemMessage) ...[
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.smart_toy_outlined,
                    size: 14,
                    color: _getSystemMessageColor(lastMessage.content),
                  ),
                ),
                SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  lastMessage.content,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSystemMessage ? _getSystemMessageColor(lastMessage.content) : textColor,
                    fontWeight: (isSystemMessage && isMessageUnread) ? FontWeight.bold : FontWeight.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: isSystemMessage ? TextAlign.left : (isFromCurrentUser ? TextAlign.right : TextAlign.left),
                ),
              ),
              SizedBox(width: 6),
              Text(
                _formatMessageTime(lastMessage.timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        // Chat bubble tail (not for system messages)
        if (!isSystemMessage) ...[
          if (isFromCurrentUser)
            // Tail on right side (sent by current user)
            Positioned(
              right: -8,
              top: 8,
              child: CustomPaint(
                size: Size(12, 16),
                painter: _BubbleTailPainterRight(color: bubbleColor),
              ),
            )
          else
            // Tail on left side (sent by other user)
            Positioned(
              left: -8,
              top: 8,
              child: CustomPaint(
                size: Size(12, 16),
                painter: _BubbleTailPainterLeft(color: bubbleColor),
              ),
            ),
        ],
      ],
    );
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';

    return '${timestamp.day}/${timestamp.month}';
  }

  /// Get color for system message based on content
  Color _getSystemMessageColor(String content) {
    // Check if message is about cancellation
    if (content.contains('iptal') ||
        content.contains('canceled') ||
        content.contains('İptal')) {
      return Colors.red[700]!; // Standard red (matches badge)
    }
    // Check if message is about booking/confirmation
    else if (content.contains('rezerve') ||
             content.contains('booked') ||
             content.contains('Rezerve')) {
      return Colors.green[700]!; // Standard green (matches badge)
    }
    // Check if message is about pre-booking contact (pending)
    else if (content.contains('iletişime geçti') ||
             content.contains('contacted')) {
      return Colors.orange[700]!; // Orange for pending/pre-booking (matches badge)
    }
    // Default color for other system messages
    return Colors.grey[700]!;
  }

  /// Build booking status badge with icon and text
  Widget _buildBookingStatusBadge(BuildContext context, bool isBooked, bool isCanceled) {
    final l10n = AppLocalizations.of(context)!;
    IconData icon;
    Color color;
    String text;

    if (isCanceled) {
      icon = Icons.cancel;
      color = Colors.red[700]!;
      text = l10n.canceled;
    } else if (isBooked) {
      icon = Icons.check_circle;
      color = Colors.green[700]!;
      text = l10n.booked;
    } else {
      icon = Icons.schedule;
      color = Colors.orange[700]!;
      text = l10n.pending;
    }

    if (kDebugMode) {
      print('🎨 Building booking status badge: isBooked=$isBooked, isCanceled=$isCanceled, text=$text');
    }

    // Split text into words for two-row display
    final words = text.split(' ');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          SizedBox(height: 4),
          // Display text in two rows (one word per row if multiple words)
          if (words.length == 1)
            Text(
              words[0],
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            )
          else
            Column(
              children: [
                Text(
                  words[0],
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  words.sublist(1).join(' '),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// Custom painter for chat bubble tail pointing LEFT (message from other user)
class _BubbleTailPainterLeft extends CustomPainter {
  final Color color;

  _BubbleTailPainterLeft({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final path = Path();
    // Start from top right of tail
    path.moveTo(size.width, 0);
    // Curve to the point (profile photo side - left)
    path.quadraticBezierTo(
      size.width * 0.3, size.height * 0.3,
      0, size.height * 0.5,
    );
    // Curve back to bottom right
    path.quadraticBezierTo(
      size.width * 0.3, size.height * 0.7,
      size.width, size.height,
    );
    path.close();

    canvas.drawPath(path, paint);

    // Draw border only on the outer curve
    final borderPath = Path();
    borderPath.moveTo(size.width, 0);
    borderPath.quadraticBezierTo(
      size.width * 0.3, size.height * 0.3,
      0, size.height * 0.5,
    );
    borderPath.quadraticBezierTo(
      size.width * 0.3, size.height * 0.7,
      size.width, size.height,
    );
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for chat bubble tail pointing RIGHT (message from current user)
class _BubbleTailPainterRight extends CustomPainter {
  final Color color;

  _BubbleTailPainterRight({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final path = Path();
    // Start from top left of tail
    path.moveTo(0, 0);
    // Curve to the point (right side)
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.3,
      size.width, size.height * 0.5,
    );
    // Curve back to bottom left
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.7,
      0, size.height,
    );
    path.close();

    canvas.drawPath(path, paint);

    // Draw border only on the outer curve
    final borderPath = Path();
    borderPath.moveTo(0, 0);
    borderPath.quadraticBezierTo(
      size.width * 0.7, size.height * 0.3,
      size.width, size.height * 0.5,
    );
    borderPath.quadraticBezierTo(
      size.width * 0.7, size.height * 0.7,
      0, size.height,
    );
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
