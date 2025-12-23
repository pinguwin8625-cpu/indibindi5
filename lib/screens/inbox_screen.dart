import 'package:flutter/material.dart';
import 'dart:io';
import '../services/messaging_service.dart';
import '../services/auth_service.dart';
import '../services/mock_users.dart';
import '../models/message.dart';
import '../l10n/app_localizations.dart';
import '../utils/dialog_helper.dart';
import 'chat_screen.dart';
import '../utils/date_time_helpers.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> with WidgetsBindingObserver {
  final MessagingService _messagingService = MessagingService();
  String? _lastUserId;
  bool _showArchived = false; // Whether to show archived conversations section

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
            label: 'Suggestion',
            value: 'Suggestion',
            color: Colors.green,
          ),
          DialogChoice(
            label: 'Complaint',
            value: 'Complaint',
            color: Colors.red,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.snackbarErrorOpeningChat(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  OverlayEntry? _overlayEntry;

  void _showCustomSnackbar(String message, {String? undoLabel, VoidCallback? onUndo}) {
    // Remove any existing overlay
    _overlayEntry?.remove();
    _overlayEntry = null;

    _overlayEntry = OverlayEntry(
      builder: (context) => _CustomSnackbar(
        message: message,
        undoLabel: undoLabel,
        onUndo: onUndo,
        onDismiss: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    try {
      final l10n = AppLocalizations.of(context)!;

      return Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: EdgeInsets.only(left: 12),
            child: GestureDetector(
              onTap: _sendSupportEmail,
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Text(
                        '?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    // Speech bubble tail
                    Positioned(
                      bottom: -4,
                      left: 4,
                      child: CustomPaint(
                        size: Size(6, 5),
                        painter: _SpeechBubbleTailPainter(
                          fillColor: Colors.white.withOpacity(0.2),
                          borderColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
          actions: [
            // Archive toggle button (icon only)
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showArchived = !_showArchived;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _showArchived
                        ? Colors.white.withOpacity(0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _showArchived ? Icons.archive : Icons.archive_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: ValueListenableBuilder(
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

            // Split into active (messaging allowed) and archived (3-7 days after arrival or manually archived)
            // Exclude deleted conversations from both lists
            final activeConversations = allUserConversations
                .where((c) => c.isVisible && !c.isArchived && !c.isManuallyArchived && !c.isDeleted)
                .toList();
            final archivedConversations = allUserConversations
                .where((c) => (c.isArchived || c.isManuallyArchived) && !c.isDeleted)
                .toList();

            print('📬 InboxScreen: Found ${activeConversations.length} active, ${archivedConversations.length} archived conversations');

            // Show either active or archived based on toggle
            final conversationsToShow = _showArchived ? archivedConversations : activeConversations;

            if (conversationsToShow.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _showArchived ? Icons.archive_outlined : Icons.mail_outline,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      _showArchived ? l10n.archived : l10n.noMessagesYet,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              children: [
                ...conversationsToShow.asMap().entries.map((entry) {
                  return _buildConversationTile(entry.value, currentUser.id, entry.key, isArchived: _showArchived);
                }),
              ],
            );
          },
        ),
      );
    } catch (e, stackTrace) {
      print('Error in inbox screen build: $e');
      print('Stack trace: $stackTrace');
      return Scaffold(
        appBar: AppBar(
          title: Text('Inbox'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Center(child: Text('Error loading inbox: ${e.toString()}')),
      );
    }
  }

  Widget _buildConversationTile(
    Conversation conversation,
    String currentUserId,
    int index, {
    bool isArchived = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final isSupport = conversation.id.startsWith('support_');
    final currentUser = AuthService.currentUser;
    final isAdmin = currentUser?.isAdmin ?? false;

    // Simple logic: show the OTHER person (not yourself)
    // If you are the driver, show the rider. If you are the rider, show the driver.
    final bool amITheDriver = conversation.driverId == currentUserId;

    final String otherUserId = amITheDriver ? conversation.riderId : conversation.driverId;
    final unreadCount = conversation.getUnreadCount(currentUserId);

    final otherUser = MockUsers.getUserById(otherUserId);

    // Use live user data for name, fall back to conversation stored name
    // Format: "FirstName S." (name + surname initial)
    final String otherUserName = (isSupport && !isAdmin)
        ? l10n.support
        : (otherUser != null
            ? '${otherUser.name} ${otherUser.surname.isNotEmpty ? '${otherUser.surname[0]}.' : ''}'
            : (amITheDriver ? conversation.riderName : conversation.driverName));

    print('📧 Inbox tile for conversation ${conversation.id}:');
    print('   currentUserId: $currentUserId');
    print('   conversation.driverId: ${conversation.driverId}');
    print('   conversation.riderId: ${conversation.riderId}');
    print('   amITheDriver: $amITheDriver');
    print('   otherUserId: $otherUserId');
    print('   otherUserName: $otherUserName');

    if (otherUser == null) {
      print('❌ Inbox: User not found for ID: "$otherUserId"');
      print('   Available user IDs: ${MockUsers.users.map((u) => u.id).join(", ")}');
    } else {
      print('✅ Found user: ${otherUser.name} ${otherUser.surname}');
    }

    final profilePhotoUrl = otherUser?.profilePhotoUrl;

    // Different colors for archived vs active, and unread vs read
    final cardColor = isArchived
        ? Colors.grey[100]
        : (unreadCount > 0 ? Colors.blue[100] : Colors.blue[50]);

    return _SwipeableConversationTile(
      key: Key('conversation_${conversation.id}'),
      isArchived: isArchived || conversation.isManuallyArchived,
      onArchive: () {
        final message = (isArchived || conversation.isManuallyArchived)
            ? l10n.snackbarConversationRestored
            : l10n.conversationArchived;
        final showUndo = !(isArchived || conversation.isManuallyArchived);
        final conversationIdToRestore = conversation.id;
        final undoLabel = l10n.undo;

        // Perform the archive/unarchive action
        if (isArchived || conversation.isManuallyArchived) {
          _messagingService.unarchiveConversation(conversation.id);
        } else {
          _messagingService.archiveConversation(conversation.id);
        }

        // Show custom overlay snackbar - independent of scaffold rebuilds
        _showCustomSnackbar(
          message,
          undoLabel: showUndo ? undoLabel : null,
          onUndo: showUndo ? () {
            _messagingService.unarchiveConversation(conversationIdToRestore);
          } : null,
        );
      },
      child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(conversation: conversation),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            // Ride info card with integrated profile - compact version
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!, width: 0.5),
              ),
              child: Column(
                children: [
                  // Top: Date and times (or support type for support conversations)
                  _buildConversationTopRow(conversation),
                  SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Profile photo and name (fixed narrow width)
                      SizedBox(
                        width: 70,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Show support icon for support conversations (only for non-admin users)
                            if (isSupport && !isAdmin)
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.support_agent, size: 22, color: Colors.white),
                              )
                            else
                              _buildAvatar(profilePhotoUrl),
                            SizedBox(height: 4),
                            SizedBox(
                              width: 70,
                              child: Text(
                                otherUserName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Don't show rating for support conversations (except for admins)
                            if ((!isSupport || isAdmin) && otherUser?.rating != null) ...[
                              SizedBox(height: 3),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 12,
                                    color: Colors.amber,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    (otherUser?.rating ?? 0.0).toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      // Message preview - takes all remaining space with high flex
                      Expanded(
                        flex: 100,
                        child: conversation.getLastMessageForUser(currentUserId) != null
                            ? _buildMessagePreview(conversation, currentUserId)
                            : SizedBox.shrink(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildConversationTopRow(Conversation conversation) {
    final l10n = AppLocalizations.of(context)!;
    final isSupport = conversation.id.startsWith('support_');

    if (isSupport) {
      // For support conversations, show the support type
      final routeName = conversation.routeName;
      String supportType;
      Color typeColor;
      IconData typeIcon;

      if (routeName.startsWith('Suggestion')) {
        supportType = l10n.suggestion;
        typeColor = Colors.green;
        typeIcon = Icons.lightbulb_outline;
      } else if (routeName.startsWith('Complaint')) {
        supportType = l10n.complaint;
        typeColor = Colors.red;
        typeIcon = Icons.report_problem_outlined;
      } else if (routeName.startsWith('New Route Suggestion')) {
        supportType = l10n.newRouteSuggestion;
        typeColor = Colors.blue;
        typeIcon = Icons.add_road;
      } else if (routeName.startsWith('New Stop Suggestion')) {
        supportType = l10n.newStopSuggestion;
        typeColor = Colors.teal;
        typeIcon = Icons.add_location;
      } else {
        supportType = l10n.support;
        typeColor = Colors.amber;
        typeIcon = Icons.support_agent;
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: typeColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: typeColor.withOpacity(0.3), width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(typeIcon, color: typeColor, size: 14),
            SizedBox(width: 6),
            Text(
              supportType,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: typeColor,
              ),
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
            color: Colors.grey.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _formatDate(conversation.departureTime),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(width: 8),
        // Departure: icon + time + stop name
        Expanded(
          child: Row(
            children: [
              Icon(Icons.location_on, color: Colors.green, size: 14),
              SizedBox(width: 2),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  formatTimeHHmm(conversation.departureTime),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
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
        // Arrival: icon + time + stop name
        Expanded(
          child: Row(
            children: [
              Icon(Icons.flag, color: Colors.red, size: 14),
              SizedBox(width: 2),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  formatTimeHHmm(conversation.arrivalTime),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
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

  Widget _buildMessagePreview(Conversation conversation, String currentUserId) {
    final lastMessage = conversation.getLastMessageForUser(currentUserId)!;
    // For system messages, they're never "from" the current user
    // For regular messages, check senderId
    final isFromCurrentUser = !lastMessage.isSystemMessage && lastMessage.senderId == currentUserId;
    
    // Use consistent light color for both, just change tail direction
    final bubbleColor = Colors.white;
    final textColor = Colors.grey[700]!;
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isFromCurrentUser ? 8 : 2),
              topRight: Radius.circular(isFromCurrentUser ? 2 : 8),
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            border: Border.all(color: Colors.grey[300]!, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: isFromCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lastMessage.content,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: isFromCurrentUser ? TextAlign.right : TextAlign.left,
              ),
              SizedBox(height: 4),
              // Timestamp at opposite side
              Align(
                alignment: isFromCurrentUser ? Alignment.bottomLeft : Alignment.bottomRight,
                child: Text(
                  _formatMessageTime(lastMessage.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Chat bubble tail
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
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diffDays = target.difference(today).inDays;

    if (diffDays == 0) return 'Today';
    if (diffDays == 1) return 'Tomorrow';

    final monthAbbr = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${monthAbbr[date.month - 1]}';
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

  Widget _buildAvatar(String? profilePhotoUrl) {
    if (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty) {
      if (profilePhotoUrl.startsWith('assets/')) {
        return CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage(profilePhotoUrl),
          onBackgroundImageError: (exception, stackTrace) {
            // Fallback handled by builder below
          },
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
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Icon(Icons.person, color: Theme.of(context).primaryColor),
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

// Custom painter for speech bubble tail (support button)
class _SpeechBubbleTailPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;

  _SpeechBubbleTailPainter({required this.fillColor, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    // Triangle pointing down-left
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Draw border on the outer edges
    final borderPath = Path();
    borderPath.moveTo(size.width, 0);
    borderPath.lineTo(0, size.height);
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Swipeable conversation tile that reveals archive button
class _SwipeableConversationTile extends StatefulWidget {
  final Widget child;
  final bool isArchived;
  final VoidCallback onArchive;

  const _SwipeableConversationTile({
    super.key,
    required this.child,
    required this.isArchived,
    required this.onArchive,
  });

  @override
  State<_SwipeableConversationTile> createState() => _SwipeableConversationTileState();
}

class _SwipeableConversationTileState extends State<_SwipeableConversationTile> {
  double _dragExtent = 0;
  static const double _archiveButtonWidth = 80.0;

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.delta.dx;
      // Only allow dragging to the right (positive direction)
      _dragExtent = _dragExtent.clamp(0.0, _archiveButtonWidth);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    // If dragged more than half the button width, snap open, otherwise snap closed
    if (_dragExtent > _archiveButtonWidth / 2) {
      setState(() {
        _dragExtent = _archiveButtonWidth;
      });
    } else {
      setState(() {
        _dragExtent = 0;
      });
    }
  }

  void _closeSwipe() {
    setState(() {
      _dragExtent = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ClipRect(
      child: Stack(
        children: [
          // Archive button - positioned behind, only visible when content slides
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: _dragExtent, // Width matches how far content has slid
            child: GestureDetector(
              onTap: _dragExtent > 0 ? () {
                widget.onArchive();
                _closeSwipe();
              } : null,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                decoration: BoxDecoration(
                  color: widget.isArchived ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _dragExtent >= _archiveButtonWidth * 0.5
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.isArchived ? Icons.unarchive : Icons.archive,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(height: 2),
                            Text(
                              widget.isArchived ? l10n.unarchive : l10n.archive,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
            ),
          ),
          // Main content that slides
          GestureDetector(
            onHorizontalDragUpdate: _handleDragUpdate,
            onHorizontalDragEnd: _handleDragEnd,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              transform: Matrix4.translationValues(_dragExtent, 0, 0),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom snackbar using Overlay - completely independent of Scaffold rebuilds
class _CustomSnackbar extends StatefulWidget {
  final String message;
  final String? undoLabel;
  final VoidCallback? onUndo;
  final VoidCallback onDismiss;

  const _CustomSnackbar({
    required this.message,
    this.undoLabel,
    this.onUndo,
    required this.onDismiss,
  });

  @override
  State<_CustomSnackbar> createState() => _CustomSnackbarState();
}

class _CustomSnackbarState extends State<_CustomSnackbar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 70, // Above bottom nav
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(_animation),
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[850],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  if (widget.undoLabel != null && widget.onUndo != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        widget.onUndo!();
                        _dismiss();
                      },
                      child: Text(
                        widget.undoLabel!,
                        style: TextStyle(
                          color: Colors.amber[300],
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}