import '../services/booking_storage.dart';

class Message {
  final String id;
  final String conversationId; // Links to a specific booking
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final bool isSystemMessage; // System notifications (ride updates, cancellations, etc.)

  // System sender ID for system messages
  static const String systemSenderId = 'system';
  static const String systemSenderName = 'System';

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.isSystemMessage = false,
  });

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? receiverName,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    bool? isSystemMessage,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isSystemMessage: isSystemMessage ?? this.isSystemMessage,
    );
  }
}

class Conversation {
  final String id; // Same as booking ID
  final String bookingId;
  final String driverId;
  final String driverName;
  final String riderId;
  final String riderName;
  final String routeName;
  final String originName;
  final String destinationName;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final List<Message> messages;
  final bool isManuallyArchived; // User manually archived this conversation
  final bool isDeleted; // User deleted this conversation

  Conversation({
    required this.id,
    required this.bookingId,
    required this.driverId,
    required this.driverName,
    required this.riderId,
    required this.riderName,
    required this.routeName,
    required this.originName,
    required this.destinationName,
    required this.departureTime,
    required this.arrivalTime,
    this.messages = const [],
    this.isManuallyArchived = false,
    this.isDeleted = false,
  });

  // Check if messaging is still allowed (synced with booking - not archived)
  bool get isMessagingAllowed {
    // Support conversations don't have a booking - use time-based logic
    if (bookingId.startsWith('support')) {
      final now = DateTime.now();
      final cutoffTime = arrivalTime.add(Duration(days: 3));
      return now.isBefore(cutoffTime);
    }
    // For ride conversations, sync with booking archive status
    final booking = BookingStorage().getBookingById(bookingId);
    if (booking == null) return false;
    return booking.isArchived != true;
  }

  // Check if conversation is archived (synced with booking)
  bool get isArchived {
    // Support conversations - use time-based logic
    if (bookingId.startsWith('support')) {
      final now = DateTime.now();
      final archiveCutoff = arrivalTime.add(Duration(days: 3));
      final hideCutoff = arrivalTime.add(Duration(days: 7));
      return now.isAfter(archiveCutoff) && now.isBefore(hideCutoff);
    }
    // For ride conversations, sync with booking
    final booking = BookingStorage().getBookingById(bookingId);
    if (booking == null) return true;
    return booking.isArchived == true && booking.isHidden != true;
  }

  // Check if conversation should be visible in inbox (synced with booking - not hidden)
  bool get isVisible {
    // Support conversations - use time-based logic
    if (bookingId.startsWith('support')) {
      final now = DateTime.now();
      final cutoffTime = arrivalTime.add(Duration(days: 7));
      return now.isBefore(cutoffTime);
    }
    // For ride conversations, sync with booking
    final booking = BookingStorage().getBookingById(bookingId);
    if (booking == null) return false;
    return booking.isHidden != true;
  }

  // Check if conversation is hidden (synced with booking)
  bool get isHidden {
    // Support conversations - use time-based logic
    if (bookingId.startsWith('support')) {
      final now = DateTime.now();
      final cutoffTime = arrivalTime.add(Duration(days: 7));
      return now.isAfter(cutoffTime);
    }
    // For ride conversations, sync with booking
    final booking = BookingStorage().getBookingById(bookingId);
    if (booking == null) return true;
    return booking.isHidden == true;
  }

  // Get the other user's name based on current user
  String getOtherUserName(String currentUserId) {
    return currentUserId == driverId ? riderName : driverName;
  }

  // Get the other user's ID based on current user
  String getOtherUserId(String currentUserId) {
    return currentUserId == driverId ? riderId : driverId;
  }

  // Get unread message count for a specific user
  // Only counts messages visible to the user (same visibility logic as getLastMessageForUser)
  int getUnreadCount(String userId) {
    return messages.where((m) {
      // Must be unread
      if (m.isRead) return false;
      // Apply same visibility rules as getLastMessageForUser:
      // - Regular messages: visible to all, but only count if addressed to this user
      // - System messages: only visible/counted if receiverId matches
      if (m.isSystemMessage) {
        return m.receiverId == userId;
      }
      // For regular messages, count if addressed to this user
      return m.receiverId == userId;
    }).length;
  }

  // Get last message
  Message? get lastMessage {
    try {
      if (messages.isEmpty) return null;
      return messages.reduce(
        (a, b) => a.timestamp.isAfter(b.timestamp) ? a : b,
      );
    } catch (e) {
      return null;
    }
  }

  // Get last message visible to a specific user
  // For system messages, only show if receiverId matches the user
  // For regular messages, show all
  Message? getLastMessageForUser(String userId) {
    try {
      if (messages.isEmpty) return null;
      final visibleMessages = messages.where((m) {
        if (!m.isSystemMessage) return true;
        return m.receiverId == userId;
      }).toList();
      if (visibleMessages.isEmpty) return null;
      return visibleMessages.reduce(
        (a, b) => a.timestamp.isAfter(b.timestamp) ? a : b,
      );
    } catch (e) {
      return null;
    }
  }

  Conversation copyWith({
    String? id,
    String? bookingId,
    String? driverId,
    String? driverName,
    String? riderId,
    String? riderName,
    String? routeName,
    String? originName,
    String? destinationName,
    DateTime? departureTime,
    DateTime? arrivalTime,
    List<Message>? messages,
    bool? isManuallyArchived,
    bool? isDeleted,
  }) {
    return Conversation(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      riderId: riderId ?? this.riderId,
      riderName: riderName ?? this.riderName,
      routeName: routeName ?? this.routeName,
      originName: originName ?? this.originName,
      destinationName: destinationName ?? this.destinationName,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      messages: messages ?? this.messages,
      isManuallyArchived: isManuallyArchived ?? this.isManuallyArchived,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
