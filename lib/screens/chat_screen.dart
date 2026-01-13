import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../models/feedback_event.dart';
import '../services/messaging_service.dart';
import '../services/auth_service.dart';
import '../services/mock_users.dart';
import '../services/feedback_service.dart';
import '../utils/date_time_helpers.dart';
import '../l10n/app_localizations.dart';
import '../widgets/ride_info_card.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;
  final bool createConversationOnFirstMessage;
  final String? initialMessagePrefix;
  final bool isAdminView;
  final void Function(User user, Conversation conversation)? onNavigateToUser;

  const ChatScreen({
    super.key,
    required this.conversation,
    this.createConversationOnFirstMessage = false,
    this.initialMessagePrefix,
    this.isAdminView = false,
    this.onNavigateToUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessagingService _messagingService = MessagingService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Mark messages as read after the first frame (only if conversation exists in service)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = AuthService.currentUser;
      if (currentUser != null && !widget.createConversationOnFirstMessage) {
        _messagingService.markMessagesAsRead(
          widget.conversation.id,
          currentUser.id,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;

    // Prevent admins from sending messages in admin view mode (except for support)
    final isSupport = widget.conversation.id.startsWith('support_');
    if (widget.isAdminView && !isSupport) {
      final l10n = AppLocalizations.of(context)!;
      FeedbackService.show(context, FeedbackEvent.warning(l10n.snackbarAdminViewOnly));
      return;
    }

    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    if (!widget.conversation.isMessagingAllowed) {
      final l10n = AppLocalizations.of(context)!;
      FeedbackService.show(context, FeedbackEvent.error(l10n.snackbarMessagingExpired));
      return;
    }

    try {
      // Check if this is the first message
      final isFirstMessage =
          widget.createConversationOnFirstMessage &&
          _messagingService.getConversation(widget.conversation.id) == null;

      print('💬 ChatScreen._sendMessage: isFirstMessage=$isFirstMessage');
      print('   createConversationOnFirstMessage=${widget.createConversationOnFirstMessage}');
      print('   conversationId=${widget.conversation.id}');
      print('   existing conversation=${_messagingService.getConversation(widget.conversation.id) != null}');

      // If this is the first message, add conversation to inbox first
      if (isFirstMessage) {
        print('💬 ChatScreen: Adding conversation to inbox...');
        _messagingService.addConversation(widget.conversation);
        print('💬 ChatScreen: Conversation added, total conversations=${_messagingService.conversations.value.length}');
      }

      // Prepare message content with prefix if it's the first message
      final messageContent =
          isFirstMessage && widget.initialMessagePrefix != null
          ? '${widget.initialMessagePrefix}$content'
          : content;

      _messagingService.sendMessage(
        conversationId: widget.conversation.id,
        senderId: currentUser.id,
        senderName: currentUser.fullName,
        receiverId: widget.conversation.getOtherUserId(currentUser.id),
        receiverName: widget.conversation.getOtherUserName(currentUser.id),
        content: messageContent,
      );

      _messageController.clear();

      // Scroll to bottom after sending
      Future.delayed(Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      FeedbackService.show(context, FeedbackEvent.error(e.toString()));
    }
  }

  Widget _buildSupportTypeBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final routeName = widget.conversation.routeName;

    // Parse support type from routeName
    // Format: "Suggestion - REF1001" or "Complaint - REF1002" or just "Support"
    String supportType;
    Color typeColor;
    IconData typeIcon;

    if (routeName.startsWith('New Route Suggestion')) {
      supportType = l10n.newRouteSuggestion;
      typeColor = Colors.blue;
      typeIcon = Icons.add_road;
    } else if (routeName.startsWith('New Stop Suggestion')) {
      supportType = l10n.newStopSuggestion;
      typeColor = Colors.teal;
      typeIcon = Icons.add_location;
    } else if (routeName.startsWith('Suggestion')) {
      supportType = l10n.suggestion;
      typeColor = Colors.green;
      typeIcon = Icons.lightbulb_outline;
    } else if (routeName.startsWith('Complaint')) {
      supportType = l10n.complaint;
      typeColor = Colors.red;
      typeIcon = Icons.report_problem_outlined;
    } else if (routeName.startsWith('Question')) {
      supportType = l10n.question;
      typeColor = Colors.blue;
      typeIcon = Icons.help_outline;
    } else {
      supportType = l10n.support;
      typeColor = Colors.amber;
      typeIcon = Icons.support_agent;
    }

    return Container(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: typeColor.withOpacity(0.3), width: 1),
        color: typeColor.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(typeIcon, color: typeColor, size: 20),
          SizedBox(width: 8),
          Text(
            supportType,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: typeColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      final currentUser = AuthService.currentUser;
      if (currentUser == null) {
        return Scaffold(
          appBar: AppBar(title: Text('Chat')),
          body: Center(child: Text('Please log in')),
        );
      }

      final l10n = AppLocalizations.of(context)!;
      final isSupport = widget.conversation.id.startsWith('support_');
      final isAdmin = currentUser.isAdmin;
      // For support conversations: admins see user name, users see "Support"
      final otherUserName = (isSupport && !isAdmin)
          ? l10n.support
          : widget.conversation.getOtherUserName(currentUser.id);

      // Get other user's info for profile photo and rating
      final otherUserId = widget.conversation.getOtherUserId(currentUser.id);
      // Admins see user profile in support conversations
      final otherUser = (isSupport && !isAdmin) ? null : MockUsers.getUserById(otherUserId);

      return Scaffold(
        appBar: AppBar(
          title: widget.isAdminView
              ? Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Monitoring: ${widget.conversation.driverName} ↔ ${widget.conversation.riderName}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    // Profile photo or support icon (support icon only for non-admin users)
                    if (isSupport && !isAdmin)
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.support_agent, size: 20, color: Colors.white),
                      )
                    else
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: otherUser?.profilePhotoUrl != null
                            ? (otherUser!.profilePhotoUrl!.startsWith('assets/')
                                ? AssetImage(otherUser.profilePhotoUrl!) as ImageProvider
                                : FileImage(File(otherUser.profilePhotoUrl!)))
                            : null,
                        child: otherUser?.profilePhotoUrl == null
                            ? Icon(Icons.person, size: 18, color: Colors.grey[600])
                            : null,
                      ),
                    SizedBox(width: 12),
                    // Name and rating
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            otherUserName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if ((!isSupport || isAdmin) && otherUser?.rating != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  (otherUser?.rating ?? 0.0).toStringAsFixed(1),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: ValueListenableBuilder(
          valueListenable: _messagingService.conversations,
          builder: (context, List<Conversation> conversations, child) {
            final l10n = AppLocalizations.of(context)!;
            // Use the conversation from the service if it exists, otherwise use the widget's conversation
            final conversation =
                _messagingService.getConversation(
                  widget.conversation.id,
                ) ??
                widget.conversation;

            // Check if messaging is expired using the live conversation data
            final isMessagingExpired = !conversation.isMessagingAllowed;

            return Column(
              children: [
                // Ride details card (only show for non-support conversations)
                if (!widget.conversation.id.startsWith('support_'))
                  RideInfoCard(
                    routeName: conversation.routeName,
                    originName: conversation.originName,
                    destinationName: conversation.destinationName,
                    departureTime: conversation.departureTime,
                    arrivalTime: conversation.arrivalTime,
                  ),
                // Support type bar (only show for support conversations)
                if (widget.conversation.id.startsWith('support_'))
                  _buildSupportTypeBar(context),
                if (isMessagingExpired)
                  Container(
                    padding: EdgeInsets.all(12),
                    color: Colors.red[50],
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.red[700], size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Messaging expired (3 days after arrival)',
                            style: TextStyle(color: Colors.red[700], fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _buildMessagesArea(conversation, currentUser, l10n),
                ),
                _buildMessageInput(),
              ],
            );
          },
        ),
      );
    } catch (e, stackTrace) {
      print('Error in ChatScreen build: $e');
      print('Stack trace: $stackTrace');
      return Scaffold(
        appBar: AppBar(title: Text('Chat Error')),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Error loading chat: ${e.toString()}'),
          ),
        ),
      );
    }
  }

  Widget _buildMessagesArea(Conversation conversation, dynamic currentUser, AppLocalizations l10n) {
    if (conversation.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              l10n.noMessagesYet,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              l10n.startConversation,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Filter messages: show all regular messages, but only show
    // system messages intended for the current user
    final visibleMessages = conversation.messages.where((msg) {
      if (!msg.isSystemMessage) return true;
      // System messages: only show to the intended receiver
      // In admin view, show all system messages
      if (widget.isAdminView) return true;
      return msg.receiverId == currentUser.id;
    }).toList();

    if (visibleMessages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              l10n.noMessagesYet,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              l10n.startConversation,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      itemCount: visibleMessages.length,
      itemBuilder: (context, index) {
        final message = visibleMessages[index];
        // In admin view, position based on driver/rider
        // In normal view, position based on current user
        final isMe = widget.isAdminView
            ? message.senderId == conversation.riderId
            : message.senderId == currentUser.id;
        return _buildMessageBubble(message, isMe);
      },
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    // Handle system messages - centered with robot icon
    if (message.isSystemMessage) {
      return _buildSystemMessageBubble(message);
    }

    // In admin view, show profile photos for both participants
    Widget? profilePhoto;
    if (widget.isAdminView) {
      final sender = MockUsers.getUserById(message.senderId);
      Widget avatar = CircleAvatar(
        radius: 16,
        backgroundColor: Colors.grey[300],
        backgroundImage: sender?.profilePhotoUrl != null
            ? (sender!.profilePhotoUrl!.startsWith('assets/')
                ? AssetImage(sender.profilePhotoUrl!) as ImageProvider
                : FileImage(File(sender.profilePhotoUrl!)))
            : null,
        child: sender?.profilePhotoUrl == null
            ? Icon(Icons.person, size: 14, color: Colors.grey[600])
            : null,
      );

      // Make avatar tappable if callback is provided
      if (widget.onNavigateToUser != null && sender != null) {
        profilePhoto = GestureDetector(
          onTap: () => widget.onNavigateToUser!(sender, widget.conversation),
          child: avatar,
        );
      } else {
        profilePhoto = avatar;
      }
    }

    final messageContent = Container(
      margin: EdgeInsets.only(bottom: 12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65,
      ),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Show sender name in admin view
          if (widget.isAdminView)
            Padding(
              padding: EdgeInsets.only(
                left: isMe ? 0 : 4,
                right: isMe ? 4 : 0,
                bottom: 4,
              ),
              child: Text(
                message.senderName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? Theme.of(context).primaryColor : Colors.grey[200],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              formatTimeHHmm(message.timestamp),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );

    // In admin view, show with profile photos
    if (widget.isAdminView) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe) ...[
              profilePhoto!,
              SizedBox(width: 8),
            ],
            messageContent,
            if (isMe) ...[
              SizedBox(width: 8),
              profilePhoto!,
            ],
          ],
        ),
      );
    }

    // Normal view without profile photos
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: messageContent,
    );
  }

  // Build a system notification message bubble - centered with robot icon
  Widget _buildSystemMessageBubble(Message message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueGrey[200]!, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Robot icon
                  Icon(
                    Icons.smart_toy_outlined,
                    color: Colors.blueGrey[600],
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  // Message content
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.content,
                          style: TextStyle(
                            color: Colors.blueGrey[800],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          formatTimeHHmm(message.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blueGrey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final isExpired = !widget.conversation.isMessagingAllowed;
    final isSupport = widget.conversation.id.startsWith('support_');
    // Admin can send messages for support conversations only
    final isDisabled = isExpired || (widget.isAdminView && !isSupport);

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !isDisabled,
              decoration: InputDecoration(
                hintText: (widget.isAdminView && !isSupport)
                    ? 'Admin view (read-only)'
                    : isExpired
                        ? 'Messaging expired'
                        : 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: isDisabled
                ? Colors.grey
                : Theme.of(context).primaryColor,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: isDisabled ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
