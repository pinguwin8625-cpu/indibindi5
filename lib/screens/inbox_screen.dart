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
            bool isUpcoming(Conversation c) {
              if (c.id.startsWith('support_')) return false;
              final booking = BookingStorage().getBookingById(c.bookingId);
              if (booking == null) return false;
              return booking.departureTime.isAfter(now) &&
                  booking.isCanceled != true &&
                  booking.isArchived != true;
            }

            bool isOngoing(Conversation c) {
              if (c.id.startsWith('support_')) return false;
              final booking = BookingStorage().getBookingById(c.bookingId);
              if (booking == null) return false;
              return booking.departureTime.isBefore(now) &&
                  booking.arrivalTime.isAfter(now) &&
                  booking.isCanceled != true &&
                  booking.isArchived != true;
            }

            bool isCompleted(Conversation c) {
              if (c.id.startsWith('support_')) return false;
              final booking = BookingStorage().getBookingById(c.bookingId);
              if (booking == null) return false;
              return booking.arrivalTime.isBefore(now) &&
                  booking.isCanceled != true &&
                  booking.isArchived != true;
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

            final archived = validConversations
                .where((c) => (c.isArchived || c.isManuallyArchived))
                .toList()
              ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

            // Check if we have any conversations
            final hasAnyConversations = support.isNotEmpty || upcoming.isNotEmpty || ongoing.isNotEmpty || completed.isNotEmpty || archived.isNotEmpty;

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
                if (archived.isNotEmpty)
                  _CollapsibleMessageSection(
                    title: l10n.archived,
                    count: archived.length,
                    conversations: archived,
                    currentUserId: currentUser.id,
                    startCollapsed: true,
                    color: Colors.grey[700],
                    showArchiveSwipe: false,
                    showUnarchiveSwipe: true,
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
  final bool showArchiveSwipe;
  final bool showUnarchiveSwipe;

  const _CollapsibleMessageSection({
    required this.title,
    required this.count,
    required this.conversations,
    required this.currentUserId,
    this.startCollapsed = false,
    this.color,
    this.showArchiveSwipe = true,
    this.showUnarchiveSwipe = false,
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
            final card = ConversationCard(
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
            );

            Widget wrappedCard = card;
            final l10n = AppLocalizations.of(context)!;

            if (widget.showArchiveSwipe) {
              wrappedCard = _SwipeToRevealAction(
                icon: Icons.archive_outlined,
                label: l10n.archive,
                color: Colors.grey[500]!,
                onAction: () {
                  final convId = conversation.id;
                  MessagingService().archiveConversation(convId);
                  FeedbackService.show(
                    context,
                    FeedbackEvent.success(
                      l10n.conversationArchived,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: card,
              );
            } else if (widget.showUnarchiveSwipe) {
              wrappedCard = _SwipeToRevealAction(
                icon: Icons.unarchive_outlined,
                label: l10n.unarchive,
                color: Colors.grey[500]!,
                onAction: () {
                  final convId = conversation.id;
                  MessagingService().unarchiveConversation(convId);
                  FeedbackService.show(
                    context,
                    FeedbackEvent.success(
                      l10n.conversationUnarchived,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: card,
              );
            }

            return Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: wrappedCard,
            );
          }),
        ],
        SizedBox(height: 4),
      ],
    );
  }
}

/// Swipe to reveal action button widget (archive/unarchive)
class _SwipeToRevealAction extends StatefulWidget {
  final Widget child;
  final VoidCallback onAction;
  final IconData icon;
  final String label;
  final Color color;

  const _SwipeToRevealAction({
    required this.child,
    required this.onAction,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  State<_SwipeToRevealAction> createState() => _SwipeToRevealActionState();
}

class _SwipeToRevealActionState extends State<_SwipeToRevealAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isRevealed = false;
  static const double _revealWidth = 80.0;

  // Track the currently active (swiped) instance
  static _SwipeToRevealActionState? _currentlyRevealed;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    if (_currentlyRevealed == this) {
      _currentlyRevealed = null;
    }
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    // Close any other revealed card when starting to swipe a new one
    if (_currentlyRevealed != null && _currentlyRevealed != this) {
      _currentlyRevealed!._closeReveal();
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (details.delta.dx < 0) {
      _controller.value += -details.delta.dx / _revealWidth;
    } else {
      _controller.value -= details.delta.dx / _revealWidth;
    }
    _controller.value = _controller.value.clamp(0.0, 1.0);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_controller.value > 0.5) {
      _controller.forward();
      setState(() => _isRevealed = true);
      _currentlyRevealed = this;
    } else {
      _controller.reverse();
      setState(() => _isRevealed = false);
      if (_currentlyRevealed == this) {
        _currentlyRevealed = null;
      }
    }
  }

  void _closeReveal() {
    _controller.reverse();
    setState(() => _isRevealed = false);
    if (_currentlyRevealed == this) {
      _currentlyRevealed = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Action button behind (only visible when swiping)
                if (_controller.value > 0)
                  Positioned(
                    right: 0,
                    top: 4,
                    bottom: 4,
                    child: Opacity(
                      opacity: _controller.value,
                      child: GestureDetector(
                        onTap: () {
                          _closeReveal();
                          widget.onAction();
                        },
                        child: Container(
                          width: _revealWidth,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: widget.color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(widget.icon, color: Colors.white, size: 22),
                              SizedBox(height: 2),
                              Text(
                                widget.label,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                // Card that slides left
                Transform.translate(
                  offset: Offset(-_controller.value * (_revealWidth + 8), 0),
                  child: GestureDetector(
                    onHorizontalDragStart: _onHorizontalDragStart,
                    onHorizontalDragUpdate: _onHorizontalDragUpdate,
                    onHorizontalDragEnd: _onHorizontalDragEnd,
                    onTap: _isRevealed ? _closeReveal : null,
                    child: widget.child,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
