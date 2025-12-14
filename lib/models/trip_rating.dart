// Trip-specific rating model
// Each user can rate others after a trip ends based on 5 criteria

class TripRating {
  final String id; // Unique rating ID
  final String bookingId; // The trip this rating is for
  final String fromUserId; // User giving the rating
  final String toUserId; // User being rated
  final String toUserName; // Name of user being rated
  
  // Rating categories (0 or 1 star each, max 5 total)
  final int polite; // Was the person polite and respectful?
  final int clean; // Was the person/vehicle clean and tidy?
  final int communicative; // Did they communicate well?
  final int safe; // Did they drive safely / follow safety rules?
  final int punctual; // Were they on time?
  
  final String? comment; // Optional text feedback
  final DateTime ratedAt; // When the rating was given
  
  TripRating({
    required this.id,
    required this.bookingId,
    required this.fromUserId,
    required this.toUserId,
    required this.toUserName,
    required this.polite,
    required this.clean,
    required this.communicative,
    required this.safe,
    required this.punctual,
    this.comment,
    required this.ratedAt,
  });
  
  // Calculate total rating (sum of selected categories, 0-5 stars)
  double get averageRating {
    return (polite + clean + communicative + safe + punctual).toDouble();
  }
  
  // Check if at least one category is selected
  bool get isComplete {
    return (polite + clean + communicative + safe + punctual) > 0;
  }
  
  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'toUserName': toUserName,
      'polite': polite,
      'clean': clean,
      'communicative': communicative,
      'safe': safe,
      'punctual': punctual,
      'comment': comment,
      'ratedAt': ratedAt.toIso8601String(),
    };
  }
  
  // Create from JSON
  factory TripRating.fromJson(Map<String, dynamic> json) {
    return TripRating(
      id: json['id'],
      bookingId: json['bookingId'],
      fromUserId: json['fromUserId'],
      toUserId: json['toUserId'],
      toUserName: json['toUserName'],
      polite: json['polite'],
      clean: json['clean'],
      communicative: json['communicative'],
      safe: json['safe'],
      punctual: json['punctual'],
      comment: json['comment'],
      ratedAt: DateTime.parse(json['ratedAt']),
    );
  }
  
  // Copy with method for updates
  TripRating copyWith({
    String? id,
    String? bookingId,
    String? fromUserId,
    String? toUserId,
    String? toUserName,
    int? polite,
    int? clean,
    int? communicative,
    int? safe,
    int? punctual,
    String? comment,
    DateTime? ratedAt,
  }) {
    return TripRating(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      toUserName: toUserName ?? this.toUserName,
      polite: polite ?? this.polite,
      clean: clean ?? this.clean,
      communicative: communicative ?? this.communicative,
      safe: safe ?? this.safe,
      punctual: punctual ?? this.punctual,
      comment: comment ?? this.comment,
      ratedAt: ratedAt ?? this.ratedAt,
    );
  }
}
