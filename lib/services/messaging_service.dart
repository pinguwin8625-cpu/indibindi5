import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../models/booking.dart';
import '../services/auth_service.dart';

class MessagingService {
  static final MessagingService _instance = MessagingService._internal();
  factory MessagingService() => _instance;
  MessagingService._internal();

  final ValueNotifier<List<Conversation>> conversations = ValueNotifier([]);
  int _messageIdCounter = 1;

  // Note: Conversations are created manually when users click seat icons in My Bookings
  // No automatic initialization from bookings happens

  // Get all conversations for current user
  List<Conversation> getConversationsForUser(String userId) {
    try {
      final userConvs = conversations.value
          .where((c) => c.driverId == userId || c.riderId == userId)
          .toList();
      
      userConvs.sort((a, b) {
        final aLast = a.lastMessage?.timestamp ?? a.arrivalTime;
        final bLast = b.lastMessage?.timestamp ?? b.arrivalTime;
        return bLast.compareTo(aLast); // Most recent first
      });
      
      return userConvs;
    } catch (e) {
      print('Error in getConversationsForUser: $e');
      return [];
    }
  }

  // Get a specific conversation
  Conversation? getConversation(String conversationId) {
    try {
      return conversations.value.firstWhere((c) => c.id == conversationId);
    } catch (e) {
      return null;
    }
  }

  // Send a message
  void sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String content,
  }) {
    final conversation = getConversation(conversationId);
    if (conversation == null) return;

    // Check if messaging is still allowed
    if (!conversation.isMessagingAllowed) {
      throw Exception('Messaging period has expired (24 hours after arrival)');
    }

    final message = Message(
      id: 'msg_${_messageIdCounter++}',
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      receiverName: receiverName,
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
    );

    final updatedMessages = [...conversation.messages, message];
    final updatedConversation = conversation.copyWith(messages: updatedMessages);

    final updatedConversations = conversations.value.map((c) {
      return c.id == conversationId ? updatedConversation : c;
    }).toList();

    conversations.value = updatedConversations;
  }

  // Mark messages as read
  void markMessagesAsRead(String conversationId, String userId) {
    final conversation = getConversation(conversationId);
    if (conversation == null) return;

    final updatedMessages = conversation.messages.map((m) {
      if (m.receiverId == userId && !m.isRead) {
        return m.copyWith(isRead: true);
      }
      return m;
    }).toList();

    final updatedConversation = conversation.copyWith(messages: updatedMessages);

    final updatedConversations = conversations.value.map((c) {
      return c.id == conversationId ? updatedConversation : c;
    }).toList();

    conversations.value = updatedConversations;
  }

  // Get total unread count for a user
  int getTotalUnreadCount(String userId) {
    return conversations.value.fold<int>(
      0,
      (sum, conversation) => sum + conversation.getUnreadCount(userId),
    );
  }

  // Check if user can message in this conversation
  bool canUserMessage(String conversationId, String userId) {
    final conversation = getConversation(conversationId);
    if (conversation == null) return false;

    // Check if user is part of the conversation
    if (conversation.driverId != userId && conversation.riderId != userId) {
      return false;
    }

    // Check if messaging period is still valid
    return conversation.isMessagingAllowed;
  }

  // Create conversation for a new booking
  void createConversationForBooking(Booking booking) {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;

    // Don't create conversation for canceled bookings
    if (booking.isCanceled == true) return;

    // Check if conversation already exists
    if (conversations.value.any((c) => c.bookingId == booking.id)) return;

    // Create conversation based on user role
    final isDriver = booking.userRole.toLowerCase() == 'driver' || 
                     booking.userRole.toLowerCase() == 'sürücü';
    
    final conversation = Conversation(
      id: booking.id,
      bookingId: booking.id,
      driverId: isDriver ? currentUser.id : 'other_user_${booking.id}',
      driverName: isDriver ? currentUser.fullName : (booking.driverName ?? 'Driver'),
      riderId: isDriver ? 'other_user_${booking.id}' : currentUser.id,
      riderName: isDriver ? 'Rider' : currentUser.fullName,
      routeName: booking.route.name,
      arrivalTime: booking.arrivalTime,
      messages: [],
    );

    conversations.value = [...conversations.value, conversation];
    
    if (kDebugMode) {
      print('💬 Created conversation for booking ${booking.id}');
    }
  }

  // Create or get support conversation with admin
  Conversation createSupportConversation(String userId, String userName) {
    // Check if support conversation already exists
    final existingConversation = conversations.value.firstWhere(
      (c) => c.id == 'support_$userId',
      orElse: () => Conversation(
        id: 'support_$userId',
        bookingId: 'support',
        driverId: 'admin', // Admin is always the receiver
        driverName: 'Support',
        riderId: userId,
        riderName: userName,
        routeName: 'Support Request',
        arrivalTime: DateTime.now().add(Duration(days: 365)), // Never expires
        messages: [],
      ),
    );

    // Add to conversations if it's new
    if (!conversations.value.any((c) => c.id == 'support_$userId')) {
      conversations.value = [...conversations.value, existingConversation];
    }

    return existingConversation;
  }
}
