import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/messaging_service.dart';
import '../services/auth_service.dart';
import '../services/mock_users.dart';
import '../utils/date_time_helpers.dart';
import '../l10n/app_localizations.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;
  final bool createConversationOnFirstMessage;
  final String? initialMessagePrefix;

  const ChatScreen({
    super.key,
    required this.conversation,
    this.createConversationOnFirstMessage = false,
    this.initialMessagePrefix,
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

    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    if (!widget.conversation.isMessagingAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Messaging period has expired (3 days after arrival)',
          ),
          backgroundColor: Colors.red,
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
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

      final otherUserName = widget.conversation.getOtherUserName(
        currentUser.id,
      );
      final isExpired = !widget.conversation.isMessagingAllowed;

      // Get other user's info for profile photo and rating
      final otherUserId = widget.conversation.getOtherUserId(currentUser.id);
      final otherUser = MockUsers.getUserById(otherUserId);

      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              // Profile photo
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
              Column(
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
                  ),
                  if (otherUser?.rating != null)
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
            ],
          ),
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            if (isExpired)
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
              child: ValueListenableBuilder(
                valueListenable: _messagingService.conversations,
                builder: (context, List<Conversation> conversations, child) {
                  final l10n = AppLocalizations.of(context)!;
                  // Use the conversation from the service if it exists, otherwise use the widget's conversation
                  final conversation =
                      _messagingService.getConversation(
                        widget.conversation.id,
                      ) ??
                      widget.conversation;

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

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: conversation.messages.length,
                    itemBuilder: (context, index) {
                      final message = conversation.messages[index];
                      final isMe = message.senderId == currentUser.id;
                      return _buildMessageBubble(message, isMe);
                    },
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
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

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
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
      ),
    );
  }

  Widget _buildMessageInput() {
    final isExpired = !widget.conversation.isMessagingAllowed;

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
              enabled: !isExpired,
              decoration: InputDecoration(
                hintText: isExpired ? 'Messaging expired' : 'Type a message...',
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
            backgroundColor: isExpired
                ? Colors.grey
                : Theme.of(context).primaryColor,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: isExpired ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
