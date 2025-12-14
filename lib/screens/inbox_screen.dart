import 'package:flutter/material.dart';
import 'dart:io';
import '../services/messaging_service.dart';
import '../services/auth_service.dart';
import '../services/mock_users.dart';
import '../models/message.dart';
import '../widgets/language_selector.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening support chat: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: LanguageSelector(isDarkBackground: true),
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
            
            // Split into active (messaging allowed) and archived (3-7 days after arrival)
            final activeConversations = allUserConversations
                .where((c) => c.isVisible && !c.isArchived)
                .toList();
            final archivedConversations = allUserConversations
                .where((c) => c.isArchived)
                .toList();

            print('📬 InboxScreen: Found ${activeConversations.length} active, ${archivedConversations.length} archived conversations');

            if (activeConversations.isEmpty && archivedConversations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mail_outline, size: 80, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      l10n.noMessagesYet,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      l10n.messagesWillAppear,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              children: [
                // Active conversations
                ...activeConversations.asMap().entries.map((entry) {
                  return _buildConversationTile(entry.value, currentUser.id, entry.key, isArchived: false);
                }),
                
                // Archived section header (if there are archived conversations)
                if (archivedConversations.isNotEmpty) ...[
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showArchived = !_showArchived;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: Colors.grey[200],
                      child: Row(
                        children: [
                          Icon(
                            _showArchived ? Icons.expand_less : Icons.expand_more,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.archive_outlined,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            l10n.archived,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${archivedConversations.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Archived conversations (if expanded)
                  if (_showArchived)
                    ...archivedConversations.asMap().entries.map((entry) {
                      return _buildConversationTile(entry.value, currentUser.id, entry.key, isArchived: true);
                    }),
                ],
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
    // Simple logic: show the OTHER person (not yourself)
    // If you are the driver, show the rider. If you are the rider, show the driver.
    final bool amITheDriver = conversation.driverId == currentUserId;
    
    final String otherUserId = amITheDriver ? conversation.riderId : conversation.driverId;
    final String otherUserName = amITheDriver ? conversation.riderName : conversation.driverName;
    final unreadCount = conversation.getUnreadCount(currentUserId);

    print('📧 Inbox tile for conversation ${conversation.id}:');
    print('   currentUserId: $currentUserId');
    print('   conversation.driverId: ${conversation.driverId}');
    print('   conversation.riderId: ${conversation.riderId}');
    print('   amITheDriver: $amITheDriver');
    print('   otherUserId: $otherUserId');
    print('   otherUserName: $otherUserName');
    
    final otherUser = MockUsers.getUserById(otherUserId);
    
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

    return InkWell(
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
                            if (otherUser?.rating != null) ...[
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
                        child: conversation.lastMessage != null
                            ? _buildMessagePreview(conversation, currentUserId)
                            : SizedBox.shrink(),
                      ),
                    ],
                  ),
                  // Bottom: Date and times
                  SizedBox(height: 6),
                  Row(
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagePreview(Conversation conversation, String currentUserId) {
    final lastMessage = conversation.lastMessage!;
    final isFromCurrentUser = lastMessage.senderId == currentUserId;
    
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