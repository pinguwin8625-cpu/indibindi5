import 'package:flutter/material.dart';
import '../services/messaging_service.dart';
import '../services/auth_service.dart';
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

class _InboxScreenState extends State<InboxScreen> {
  final MessagingService _messagingService = MessagingService();
  
  @override
  void initState() {
    super.initState();
    // Conversations are only created when users click seat icons in My Bookings
    // No automatic initialization from bookings
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
            createConversationOnFirstMessage: true, // Add to inbox on first message
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
      final currentUser = AuthService.currentUser;
      final l10n = AppLocalizations.of(context)!;
      
      return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.support_agent, color: Colors.white),
          onPressed: _sendSupportEmail,
        ),
        title: Text(
          l10n.inbox,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
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
          if (currentUser == null) {
            return Center(child: Text('Please log in to view messages'));
          }

          final userConversations = _messagingService.getConversationsForUser(currentUser.id);

          if (userConversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mail_outline, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Messages will appear when you book a ride',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: userConversations.length,
            itemBuilder: (context, index) {
              final conversation = userConversations[index];
              return _buildConversationTile(conversation, currentUser.id);
            },
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
        body: Center(
          child: Text('Error loading inbox: ${e.toString()}'),
        ),
      );
    }
  }

  Widget _buildConversationTile(Conversation conversation, String currentUserId) {
    final otherUserName = conversation.getOtherUserName(currentUserId);
    final unreadCount = conversation.getUnreadCount(currentUserId);
    final lastMessage = conversation.lastMessage;
    final isExpired = !conversation.isMessagingAllowed;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Icon(
          Icons.person,
          color: Theme.of(context).primaryColor,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherUserName,
                  style: TextStyle(
                    fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  conversation.routeName,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unreadCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lastMessage != null)
            Text(
              lastMessage.content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          if (isExpired)
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Messaging expired',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
      trailing: lastMessage != null
          ? Text(
              _formatMessageTime(lastMessage.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            )
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(conversation: conversation),
          ),
        );
      },
    );
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return formatTimeHHmm(timestamp);
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}';
  }
}
