import 'package:flutter/material.dart';
import '../services/messaging_service.dart';
import '../services/auth_service.dart';
import '../models/message.dart';
import '../l10n/app_localizations.dart';
import '../utils/dialog_helper.dart';
import '../widgets/conversation_card_widget.dart';
import 'chat_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen>
    with WidgetsBindingObserver {
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
            // Exclude deleted conversations and conversations with no messages from both lists
            final activeConversations = allUserConversations
                .where((c) => c.isVisible && !c.isArchived && !c.isManuallyArchived && !c.isDeleted && c.messages.isNotEmpty)
                .toList();
            final archivedConversations = allUserConversations
                .where((c) => (c.isArchived || c.isManuallyArchived) && !c.isDeleted && c.messages.isNotEmpty)
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
                ...conversationsToShow.map((conversation) {
                  return ConversationCard(
                    conversation: conversation,
                    mode: ConversationCardMode.inbox,
                    currentUserId: currentUser.id,
                    isArchived: _showArchived,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(conversation: conversation),
                        ),
                      );
                    },
                  );
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
}

