import 'package:flutter/material.dart';
import '../services/messaging_service.dart';
import '../services/auth_service.dart';
import '../services/booking_storage.dart';
import '../services/feedback_service.dart';
import '../models/message.dart';
import '../models/feedback_event.dart';
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

            // Filter out deleted conversations and conversations with no messages
            final validConversations = allUserConversations
                .where((c) => !c.isDeleted && c.messages.isNotEmpty)
                .toList();

            print('📬 InboxScreen: Found ${validConversations.length} valid conversations');

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

              return booking.departureTime.isAfter(now) &&
                  booking.isCanceled != true &&
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
              // Check canceled first to avoid categorizing in multiple sections
              if (booking.isCanceled == true) return false;
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
              // Check canceled first to avoid categorizing in multiple sections
              if (booking.isCanceled == true) return false;
              return booking.arrivalTime.isBefore(now) &&
                  booking.isArchived != true;
            }

            bool isCanceled(Conversation c) {
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
              return booking.isCanceled == true && booking.isArchived != true;
            }

            // Categorize
            final support = validConversations
                .where((c) => c.id.startsWith('support_') && !c.isArchived && !c.isManuallyArchived)
                .toList()
              ..sort((a, b) {
                final aLast = a.lastMessage?.timestamp ?? a.arrivalTime;
                final bLast = b.lastMessage?.timestamp ?? b.arrivalTime;
                return bLast.compareTo(aLast);
              });

            final upcoming = validConversations
                .where((c) => isUpcoming(c) && !c.isArchived && !c.isManuallyArchived)
                .toList()
              ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

            final ongoing = validConversations
                .where((c) => isOngoing(c) && !c.isArchived && !c.isManuallyArchived)
                .toList()
              ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

            final completed = validConversations
                .where((c) => isCompleted(c) && !c.isArchived && !c.isManuallyArchived)
                .toList()
              ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

            final canceled = validConversations
                .where((c) => isCanceled(c) && !c.isArchived && !c.isManuallyArchived)
                .toList()
              ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

            final archived = validConversations
                .where((c) => (c.isArchived || c.isManuallyArchived))
                .toList()
              ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

            // Check if we have any conversations
            final hasAnyConversations = support.isNotEmpty || upcoming.isNotEmpty || ongoing.isNotEmpty || completed.isNotEmpty || canceled.isNotEmpty || archived.isNotEmpty;

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

            return ListView(
              padding: EdgeInsets.all(16),
              children: [
                if (support.isNotEmpty)
                  _CollapsibleMessageSection(
                    title: l10n.support,
                    count: support.length,
                    conversations: support,
                    currentUserId: currentUser.id,
                    startCollapsed: true,
                    color: Colors.amber[700],
                  ),
                if (ongoing.isNotEmpty)
                  _CollapsibleMessageSection(
                    title: l10n.ongoing,
                    count: ongoing.length,
                    conversations: ongoing,
                    currentUserId: currentUser.id,
                    startCollapsed: false,
                    color: Colors.orange[700],
                  ),
                if (upcoming.isNotEmpty)
                  _CollapsibleMessageSection(
                    title: l10n.upcoming,
                    count: upcoming.length,
                    conversations: upcoming,
                    currentUserId: currentUser.id,
                    startCollapsed: false,
                    color: Colors.blue[700],
                  ),
                if (completed.isNotEmpty)
                  _CollapsibleMessageSection(
                    title: l10n.completed,
                    count: completed.length,
                    conversations: completed,
                    currentUserId: currentUser.id,
                    startCollapsed: true,
                    color: Colors.green[700],
                  ),
                if (canceled.isNotEmpty)
                  _CollapsibleMessageSection(
                    title: l10n.canceledRides,
                    count: canceled.length,
                    conversations: canceled,
                    currentUserId: currentUser.id,
                    startCollapsed: false,
                    color: Colors.red[700],
                  ),
                if (archived.isNotEmpty)
                  _CollapsibleMessageSection(
                    title: l10n.archived,
                    count: archived.length,
                    conversations: archived,
                    currentUserId: currentUser.id,
                    startCollapsed: true,
                    color: Colors.grey[700],
                  ),
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

/// Collapsible section for grouping conversations by status
class _CollapsibleMessageSection extends StatefulWidget {
  final String title;
  final int count;
  final List<Conversation> conversations;
  final String currentUserId;
  final bool startCollapsed;
  final Color? color;

  const _CollapsibleMessageSection({
    required this.title,
    required this.count,
    required this.conversations,
    required this.currentUserId,
    this.startCollapsed = false,
    this.color,
  });

  @override
  State<_CollapsibleMessageSection> createState() =>
      _CollapsibleMessageSectionState();
}

class _CollapsibleMessageSectionState
    extends State<_CollapsibleMessageSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = !widget.startCollapsed;
  }

  @override
  Widget build(BuildContext context) {
    final sectionColor = widget.color ?? Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 50,
                  child: Row(
                    children: [
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                        color: sectionColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: sectionColor,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '(${widget.count})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: sectionColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isExpanded) ...[
          SizedBox(height: 4),
          ...widget.conversations.map((conversation) {
            return Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: ConversationCard(
                conversation: conversation,
                mode: ConversationCardMode.inbox,
                currentUserId: widget.currentUserId,
                unreadUserId: widget.currentUserId,
                onTap: () {
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
        SizedBox(height: 4),
      ],
    );
  }
}
