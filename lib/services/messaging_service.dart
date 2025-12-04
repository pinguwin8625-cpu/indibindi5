import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/message.dart';
import '../models/booking.dart';
import '../services/auth_service.dart';

class MessagingService {
  static final MessagingService _instance = MessagingService._internal();
  factory MessagingService() => _instance;
  MessagingService._internal() {
    _loadConversations();
  }

  final ValueNotifier<List<Conversation>> conversations = ValueNotifier([]);
  int _messageIdCounter = 1;
  int _supportTicketCounter = 1000; // Start support tickets from 1000
  static const String _storageKey = 'conversations_data';
  bool _isInitialized = false;

  // AI Model Configuration
  static const String aiModel = 'claude-sonnet-4.5';
  static const bool enableAIForAllClients = true;

  // Load conversations from persistent storage
  Future<void> _loadConversations() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? conversationsJson = prefs.getString(_storageKey);

      if (conversationsJson != null) {
        final List<dynamic> decoded = json.decode(conversationsJson);
        final List<Conversation> loadedConversations = [];
        int skippedCount = 0;
        
        for (var data in decoded) {
          try {
            // Skip conversations with fake/invalid rider IDs (old format)
            // Check both riderId field AND conversation ID
            final riderId = data['riderId'] as String?;
            final conversationId = data['id'] as String?;
            
            if ((riderId != null && riderId.contains('_rider_')) ||
                (conversationId != null && conversationId.contains('_rider_') && conversationId.split('_').length > 4)) {
              skippedCount++;
              if (kDebugMode) {
                print('💬 Skipping conversation with old format: $conversationId (riderId: $riderId)');
              }
              continue;
            }
            
            final conversation = Conversation(
              id: data['id'],
              bookingId: data['bookingId'],
              driverId: data['driverId'],
              driverName: data['driverName'],
              riderId: riderId ?? '',
              riderName: data['riderName'],
              routeName: data['routeName'],
              originName: data['originName'],
              destinationName: data['destinationName'],
              departureTime: DateTime.parse(data['departureTime']),
              arrivalTime: DateTime.parse(data['arrivalTime']),
              messages: (data['messages'] as List<dynamic>).map((msgData) {
                return Message(
                  id: msgData['id'],
                  conversationId: msgData['conversationId'],
                  senderId: msgData['senderId'],
                  senderName: msgData['senderName'],
                  receiverId: msgData['receiverId'],
                  receiverName: msgData['receiverName'],
                  content: msgData['content'],
                  timestamp: DateTime.parse(msgData['timestamp']),
                  isRead: msgData['isRead'] ?? false,
                );
              }).toList(),
            );
            
            loadedConversations.add(conversation);
          } catch (e) {
            if (kDebugMode) {
              print('💬 Error loading conversation, skipping: $e');
            }
          }
        }

        conversations.value = loadedConversations;
        
        // If we skipped any old conversations, save the cleaned list
        if (skippedCount > 0) {
          if (kDebugMode) {
            print('💬 Deleted $skippedCount old conversations, saving cleaned list');
          }
          await _saveConversations();
        }
        
        // Update counters based on loaded data
        if (loadedConversations.isNotEmpty) {
          for (var conv in loadedConversations) {
            for (var msg in conv.messages) {
              final msgId = int.tryParse(msg.id.replaceAll('msg_', '')) ?? 0;
              if (msgId >= _messageIdCounter) {
                _messageIdCounter = msgId + 1;
              }
            }
            if (conv.id.startsWith('support_')) {
              final refNum = int.tryParse(conv.routeName.split('REF')[1].split(' ')[0]) ?? 0;
              if (refNum >= _supportTicketCounter) {
                _supportTicketCounter = refNum + 1;
              }
            }
          }
        }

        if (kDebugMode) {
          print('💬 Loaded ${loadedConversations.length} conversations from storage');
        }
      }

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('💬 Error loading conversations: $e');
      }
      _isInitialized = true;
    }
  }

  // Save conversations to persistent storage
  Future<void> _saveConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationsData = conversations.value.map((conv) {
        return {
          'id': conv.id,
          'bookingId': conv.bookingId,
          'driverId': conv.driverId,
          'driverName': conv.driverName,
          'riderId': conv.riderId,
          'riderName': conv.riderName,
          'routeName': conv.routeName,
          'originName': conv.originName,
          'destinationName': conv.destinationName,
          'departureTime': conv.departureTime.toIso8601String(),
          'arrivalTime': conv.arrivalTime.toIso8601String(),
          'messages': conv.messages.map((msg) {
            return {
              'id': msg.id,
              'conversationId': msg.conversationId,
              'senderId': msg.senderId,
              'senderName': msg.senderName,
              'receiverId': msg.receiverId,
              'receiverName': msg.receiverName,
              'content': msg.content,
              'timestamp': msg.timestamp.toIso8601String(),
              'isRead': msg.isRead,
            };
          }).toList(),
        };
      }).toList();

      await prefs.setString(_storageKey, json.encode(conversationsData));

      if (kDebugMode) {
        print('💬 Saved ${conversations.value.length} conversations to storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('💬 Error saving conversations: $e');
      }
    }
  }

  // Clear all conversations (useful for migration or reset)
  static Future<void> clearAllConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      _instance.conversations.value = [];
      if (kDebugMode) {
        print('💬 Cleared all conversations');
      }
    } catch (e) {
      if (kDebugMode) {
        print('💬 Error clearing conversations: $e');
      }
    }
  }

  // Ensure conversations are loaded
  Future<void> ensureLoaded() async {
    await _loadConversations();
  }

  // Note: Conversations are created manually when users click seat icons in My Bookings
  // No automatic initialization from bookings happens

  // Get all conversations for current user
  List<Conversation> getConversationsForUser(String userId) {
    try {
      print('📬 getConversationsForUser called with userId: $userId');
      print('   Total conversations in storage: ${conversations.value.length}');
      
      for (var c in conversations.value) {
        print('   Conv ${c.id}: driverId=${c.driverId}, riderId=${c.riderId}');
        final matches = c.driverId == userId || c.riderId == userId;
        print('      matches user $userId: $matches');
      }
      
      final userConvs = conversations.value
          .where((c) => c.driverId == userId || c.riderId == userId)
          .toList();
      
      print('   Found ${userConvs.length} conversations for user $userId');

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
      final index = conversations.value.indexWhere(
        (c) => c.id == conversationId,
      );
      if (index == -1) {
        if (kDebugMode) {
          print('💬 Conversation not found: $conversationId');
        }
        return null;
      }
      return conversations.value[index];
    } catch (e) {
      if (kDebugMode) {
        print('💬 Error getting conversation: $e');
      }
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
    print('💬 MessagingService.sendMessage called:');
    print('   conversationId=$conversationId');
    print('   senderId=$senderId, senderName=$senderName');
    print('   receiverId=$receiverId, receiverName=$receiverName');
    
    var conversation = getConversation(conversationId);

    // If conversation doesn't exist, it means it's being created with first message
    // This shouldn't happen with current flow, but handle it gracefully
    if (conversation == null) {
      print('⚠️ Conversation $conversationId not found when sending message');
      print('⚠️ Available conversations: ${conversations.value.map((c) => c.id).toList()}');
      return;
    }

    print('💬 Conversation found, current messages: ${conversation.messages.length}');

    // Check if messaging is still allowed
    if (!conversation.isMessagingAllowed) {
      throw Exception('Messaging period has expired (3 days after arrival)');
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
    final updatedConversation = conversation.copyWith(
      messages: updatedMessages,
    );

    final updatedConversations = conversations.value.map((c) {
      return c.id == conversationId ? updatedConversation : c;
    }).toList();

    conversations.value = updatedConversations;
    print('💬 Message added, total conversations: ${conversations.value.length}');
    print('💬 Updated conversation has ${updatedConversation.messages.length} messages');
    _saveConversations(); // Persist changes
  }

  // Add conversation to the list (used when first message is sent)
  void addConversation(Conversation conversation) {
    print('💬 MessagingService.addConversation called:');
    print('   conversationId=${conversation.id}');
    print('   Current conversations count: ${conversations.value.length}');
    
    // Check if conversation already exists
    if (conversations.value.any((c) => c.id == conversation.id)) {
      print('💬 Conversation ${conversation.id} already exists, skipping');
      return;
    }

    conversations.value = [...conversations.value, conversation];
    print('💬 Conversation added, new count: ${conversations.value.length}');
    _saveConversations(); // Persist changes

    if (kDebugMode) {
      print('💬 Added conversation ${conversation.id} to inbox');
    }
  }

  // Create or get conversation between two users (called when message button is tapped)
  Conversation getOrCreateConversation({
    required String bookingId,
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
    required String routeName,
    required String originName,
    required String destinationName,
    required DateTime departureTime,
    required DateTime arrivalTime,
    required bool isCurrentUserDriver,
    required bool isOtherUserDriver,
  }) {
    // Generate conversation ID
    // For rider bookings, the bookingId is already in format: driverBookingId_rider_userId
    // For driver-rider conversations: use the base driver booking ID
    String baseBookingId = bookingId;
    if (bookingId.contains('_rider_')) {
      // Extract the driver booking ID
      baseBookingId = bookingId.split('_rider_')[0];
    }

    // For driver with specific rider: use bookingId_riderName for uniqueness
    // For rider with driver: use the base booking ID
    final conversationId = isCurrentUserDriver && !isOtherUserDriver
        ? '${baseBookingId}_$otherUserName' // Unique conversation per rider
        : baseBookingId; // Single conversation with driver

    if (kDebugMode) {
      print(
        '💬 getOrCreateConversation: bookingId=$bookingId, conversationId=$conversationId',
      );
      print('   currentUser=$currentUserName (driver=$isCurrentUserDriver)');
      print('   otherUser=$otherUserName (driver=$isOtherUserDriver)');
    }

    // Check if conversation already exists
    var conversation = getConversation(conversationId);

    if (conversation == null) {
      // Create new conversation
      final driverId = isCurrentUserDriver ? currentUserId : otherUserId;
      final driverName = isCurrentUserDriver ? currentUserName : otherUserName;
      final riderId = isCurrentUserDriver ? otherUserId : currentUserId;
      final riderName = isCurrentUserDriver ? otherUserName : currentUserName;

      conversation = Conversation(
        id: conversationId,
        bookingId: baseBookingId,
        driverId: driverId,
        driverName: driverName,
        riderId: riderId,
        riderName: riderName,
        routeName: routeName,
        originName: originName,
        destinationName: destinationName,
        departureTime: departureTime,
        arrivalTime: arrivalTime,
        messages: [],
      );

      addConversation(conversation);

      if (kDebugMode) {
        print(
          '💬 Created new conversation between $driverName (driver) and $riderName (rider)',
        );
      }
    } else {
      if (kDebugMode) {
        print('💬 Found existing conversation: ${conversation.id}');
      }
    }

    return conversation;
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

    final updatedConversation = conversation.copyWith(
      messages: updatedMessages,
    );

    final updatedConversations = conversations.value.map((c) {
      return c.id == conversationId ? updatedConversation : c;
    }).toList();

    conversations.value = updatedConversations;
    _saveConversations(); // Persist changes
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
    final isDriver =
        booking.userRole.toLowerCase() == 'driver' ||
        booking.userRole.toLowerCase() == 'sürücü';

    final conversation = Conversation(
      id: booking.id,
      bookingId: booking.id,
      driverId: isDriver ? currentUser.id : 'other_user_${booking.id}',
      driverName: isDriver
          ? currentUser.fullName
          : (booking.driverName ?? 'Driver'),
      riderId: isDriver ? 'other_user_${booking.id}' : currentUser.id,
      riderName: isDriver ? 'Rider' : currentUser.fullName,
      routeName: booking.route.name,
      originName: booking.originName,
      destinationName: booking.destinationName,
      departureTime: booking.departureTime,
      arrivalTime: booking.arrivalTime,
      messages: [],
    );

    conversations.value = [...conversations.value, conversation];
    _saveConversations(); // Persist changes

    if (kDebugMode) {
      print('💬 Created conversation for booking ${booking.id}');
    }
  }

  // Create a new support conversation with unique reference number
  Conversation createSupportConversation(
    String userId,
    String userName,
    String type,
  ) {
    // Generate unique reference number
    final referenceNumber = 'REF${_supportTicketCounter++}';
    final ticketId =
        'support_${userId}_${DateTime.now().millisecondsSinceEpoch}';

    // Create conversation with subject line including type and reference
    final conversation = Conversation(
      id: ticketId,
      bookingId: 'support',
      driverId: 'admin', // Admin is always the receiver
      driverName: 'Support',
      riderId: userId,
      riderName: userName,
      routeName: '$type - $referenceNumber',
      originName: 'Support Request',
      destinationName: 'Admin',
      departureTime: DateTime.now(),
      arrivalTime: DateTime.now().add(Duration(days: 365)), // Never expires
      messages: [],
    );

    // DON'T add to conversations list here - will be added when first message is sent
    // This way empty conversations don't appear in inbox

    if (kDebugMode) {
      print('💬 Created support ticket: $referenceNumber ($type)');
    }

    return conversation;
  }
}
