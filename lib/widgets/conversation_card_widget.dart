import 'dart:io';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/user.dart';
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
  /// Inbox mode: Shows single avatar (other party) with message preview and ride details
  inbox,
  /// Inbox grouped mode: Shows simplified card without ride details (used inside ride groups)
  inboxGrouped,
}

/// Shared conversation card widget used across:
/// - Admin Panel Messages tab (admin mode)
/// - Admin Panel User details (admin mode)
/// - Inbox screen (inbox mode)
class ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback? onTap; // Nullable - when null, the card is non-tappable (e.g., embedded in another tappable widget)
  final ConversationCardMode mode;
  final String? currentUserId; // Required for inbox mode to determine "other" user
  final bool showUnreadBadge;
  final String unreadUserId; // User ID to check unread count for
  final void Function(User user)? onAvatarTap; // Callback when avatar is tapped
  final bool isArchived; // For inbox mode styling
  final bool showRiderLabel; // Show "Rider" label on avatar (for driver's inbox view)
  final bool showDriverLabel; // Show "Driver" label on avatar (for rider's inbox view)
  final bool isCanceled; // For greyed out canceled booking styling
  final bool hideAvatar; // Hide avatar completely (when shown in header already)

  const ConversationCard({
    super.key,
    required this.conversation,
    this.onTap,
    this.mode = ConversationCardMode.admin,
    this.currentUserId,
    this.showUnreadBadge = true,
    this.unreadUserId = 'admin',
    this.onAvatarTap,
    this.isArchived = false,
    this.showRiderLabel = false,
    this.showDriverLabel = false,
    this.isCanceled = false,
    this.hideAvatar = false,
  });

  @override
  Widget build(BuildContext context) {
    if (mode == ConversationCardMode.inbox) {
      return _buildInboxMode(context);
    } else if (mode == ConversationCardMode.inboxGrouped) {
      return _buildInboxGroupedMode(context);
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

    // Use white background like booking cards
    // Layout: Top row: [Avatar + Name/Rating] | [Message Bubble]
    // Bottom row: Ride Details
    return Card(
      margin: EdgeInsets.only(bottom: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              // TOP ROW: [Avatar + Name/Rating] | Message bubble
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Avatar + Name/Rating side by side
                  Row(
                    mainAxisSize: MainAxisSize.min,
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
                      SizedBox(
                        width: 48,
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
                  SizedBox(width: 8),
                  // Message bubble
                  Expanded(
                    child: conversation.getLastMessageForUser(userId) != null
                        ? _buildMessagePreview(userId, unreadCount)
                        : SizedBox(height: 48),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // BOTTOM ROW: Ride details (full width)
              _buildTopRow(context, isSupport, forInbox: true, l10n: l10n),
            ],
          ),
        ),
      ),
    );
  }

  /// Build inbox grouped mode: simplified card without ride details (for use inside ride groups)
  Widget _buildInboxGroupedMode(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unreadCount = conversation.getUnreadCount(unreadUserId);
    final isSupport = conversation.id.startsWith('support_');
    final isAdmin = AuthService.currentUser?.id == 'admin';

    // Determine current user and other user
    final currentUser = AuthService.currentUser;
    final amITheDriver = currentUser?.id == conversation.driverId;
    final otherUserId = amITheDriver ? conversation.riderId : conversation.driverId;
    final otherUser = MockUsers.getUserById(otherUserId);

    final String otherUserName = (isSupport && !isAdmin)
        ? l10n.support
        : (otherUser != null
            ? '${otherUser.name} ${otherUser.surname.isNotEmpty ? '${otherUser.surname[0]}.' : ''}'
            : (amITheDriver ? conversation.riderName : conversation.driverName));

    final profilePhotoUrl = otherUser?.profilePhotoUrl;

    // Determine if we need a labeled avatar (rider or driver) - affects bubble tail visibility
    final hasLabeledAvatar = showRiderLabel || showDriverLabel;

    // Build the card content
    final cardContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar with Name/Rating BELOW (optionally with Rider/Driver label)
        // Skip avatar completely if hideAvatar is true
        if (!hideAvatar) ...[
          if (showRiderLabel)
            _buildLabeledAvatar(
              profilePhotoUrl: profilePhotoUrl,
              label: 'Rider',
              icon: Icons.person,
              name: otherUserName,
              rating: (!isSupport || isAdmin) && otherUser?.rating != null ? otherUser?.rating : null,
            )
          else if (showDriverLabel)
            _buildLabeledAvatar(
              profilePhotoUrl: profilePhotoUrl,
              label: 'Driver',
              icon: Icons.directions_car,
              name: otherUserName,
              rating: (!isSupport || isAdmin) && otherUser?.rating != null ? otherUser?.rating : null,
              isDriver: true,
            )
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSupport && !isAdmin)
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.support_agent, size: 20, color: Colors.white),
                  )
                else
                  _buildInboxAvatar(profilePhotoUrl, radius: 20),
                SizedBox(height: 4),
                // Name below avatar
                SizedBox(
                  width: 60,
                  child: Text(
                    otherUserName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
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
          SizedBox(width: 8),
        ],
        // Message bubble + system status below
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // User message bubble (or empty placeholder if no messages)
              if (currentUserId != null)
                _getLastUserMessage(currentUserId!) != null
                    ? _buildUserMessagePreview(currentUserId!, unreadCount, hideLeftTail: hasLabeledAvatar)
                    : _buildEmptyMessageBubble(),
              // System status below bubble (priority: canceled > booked > contact)
              _buildSystemStatus(currentUserId),
            ],
          ),
        ),
      ],
    );

    // When onTap is null (canceled), return content with grey background
    if (onTap == null) {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: cardContent,
      );
    }

    // Normal card with tap behavior
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: cardContent,
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

  /// Build avatar with label - notched card style (like admin panel)
  /// isDriver: if true, avatar is on left side; if false, avatar is on right side
  Widget _buildLabeledAvatar({
    required String? profilePhotoUrl,
    required String label,
    required IconData icon,
    required String name,
    double? rating,
    bool isDriver = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Notched label with avatar
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: isDriver
                  ? EdgeInsets.only(left: 22, right: 6, top: 6, bottom: 6)
                  : EdgeInsets.only(left: 6, right: 22, top: 6, bottom: 6),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: Colors.grey[600]),
                  SizedBox(height: 1),
                  Text(
                    label,
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Positioned(
              left: isDriver ? -14 : null,
              right: isDriver ? null : -14,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.15), width: 1.5),
                  ),
                  child: _buildInboxAvatar(profilePhotoUrl, radius: 16),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        // Name below
        SizedBox(
          width: 60,
          child: Text(
            name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        // Rating below name
        if (rating != null) ...[
          SizedBox(height: 2),
          RatingDisplay(
            rating: rating,
            starSize: 9,
            fontSize: 8,
            starColor: Colors.amber,
            fontWeight: FontWeight.w600,
          ),
        ],
      ],
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Robot icon for system messages
              if (isSystemMessage) ...[
                Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(
                    Icons.smart_toy_outlined,
                    size: 14,
                    color: _getSystemMessageColor(lastMessage.content),
                  ),
                ),
                SizedBox(width: 6),
              ],
              // Message text (2 lines max)
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
              // Timestamp at end
              SizedBox(width: 8),
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

  /// Get the last non-system message for a user
  Message? _getLastUserMessage(String userId) {
    final messages = conversation.messages
        .where((m) => !m.isSystemMessage)
        .toList();
    if (messages.isEmpty) return null;
    messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return messages.first;
  }

  /// Get the most relevant system message (priority: canceled > booked > contact)
  Message? _getRelevantSystemMessage() {
    final systemMessages = conversation.messages
        .where((m) => m.isSystemMessage)
        .toList();
    if (systemMessages.isEmpty) return null;

    // Priority: canceled > booked > contact
    Message? canceledMsg;
    Message? bookedMsg;
    Message? contactMsg;

    for (final msg in systemMessages) {
      final content = msg.content.toLowerCase();
      if (content.contains('iptal') || content.contains('canceled') || content.contains('cancel')) {
        canceledMsg = msg;
      } else if (content.contains('rezerve') || content.contains('booked') || content.contains('book')) {
        bookedMsg = msg;
      } else if (content.contains('iletişime') || content.contains('contacted') || content.contains('contact')) {
        contactMsg = msg;
      }
    }

    // Return by priority
    return canceledMsg ?? bookedMsg ?? contactMsg;
  }

  /// Build empty message bubble placeholder (same size as regular bubble)
  Widget _buildEmptyMessageBubble() {
    // Fixed height for exactly 2 rows of text
    const double fixedBubbleHeight = 48.0;

    return Container(
      width: double.infinity,
      height: fixedBubbleHeight,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCanceled ? Colors.grey[300]! : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 0.5),
      ),
      child: Center(
        child: Text(
          'No messages yet',
          style: TextStyle(
            fontSize: 12,
            color: isCanceled ? Colors.grey[500]! : Colors.grey[400]!,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  /// Build user message preview (non-system messages only)
  Widget _buildUserMessagePreview(String currentUserId, int unreadCount, {bool hideLeftTail = false}) {
    final lastMessage = _getLastUserMessage(currentUserId)!;
    final isFromCurrentUser = lastMessage.senderId == currentUserId;

    // Change bubble color: grey for canceled, green for unread, white otherwise
    final bubbleColor = isCanceled
        ? Colors.grey[300]!
        : (unreadCount > 0 ? Colors.green[100]! : Colors.white);
    final textColor = isCanceled ? Colors.grey[600]! : Colors.grey[700]!;

    // Fixed height for exactly 2 rows of text (fontSize 12 * lineHeight ~1.4 * 2 rows + padding)
    const double fixedBubbleHeight = 48.0;

    // Don't show left tail when hideLeftTail is true (e.g., when notched avatar is present)
    final showLeftTail = !isFromCurrentUser && !hideLeftTail;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: fixedBubbleHeight,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isFromCurrentUser ? 8 : (showLeftTail ? 2 : 8)),
              topRight: Radius.circular(isFromCurrentUser ? 2 : 8),
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            border: Border.all(color: Colors.grey[300]!, width: 0.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message text (2 lines max)
              Expanded(
                child: Text(
                  lastMessage.content,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: isFromCurrentUser ? TextAlign.right : TextAlign.left,
                ),
              ),
              // Timestamp at end
              SizedBox(width: 8),
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
        // Chat bubble tail - right tail for current user, left tail only if not hidden
        if (isFromCurrentUser)
          Positioned(
            right: -8,
            top: 8,
            child: CustomPaint(
              size: Size(12, 16),
              painter: _BubbleTailPainterRight(color: bubbleColor),
            ),
          )
        else if (showLeftTail)
          Positioned(
            left: -8,
            top: 8,
            child: CustomPaint(
              size: Size(12, 16),
              painter: _BubbleTailPainterLeft(color: bubbleColor),
            ),
          ),
      ],
    );
  }

  /// Build system status row below the bubble
  Widget _buildSystemStatus(String? currentUserId) {
    final systemMessage = _getRelevantSystemMessage();
    if (systemMessage == null) return SizedBox.shrink();

    // Determine the status based on message content
    final content = systemMessage.content.toLowerCase();
    String statusText;
    Color color;
    IconData icon;

    if (content.contains('iptal') || content.contains('canceled') || content.contains('cancel')) {
      statusText = 'Canceled';
      color = Colors.red[700]!;
      icon = Icons.cancel;
    } else if (content.contains('rezerve') || content.contains('booked') || content.contains('book')) {
      statusText = 'Booked';
      color = Colors.green[700]!;
      icon = Icons.check_circle;
    } else {
      return SizedBox.shrink(); // No contact message needed
    }

    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
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
