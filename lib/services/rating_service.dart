import 'package:flutter/foundation.dart';
import '../models/trip_rating.dart';

// Service to manage trip ratings
// In production, this would connect to a backend API
class RatingService {
  static final RatingService _instance = RatingService._internal();
  factory RatingService() => _instance;
  RatingService._internal();

  // In-memory storage for ratings (replace with backend in production)
  final ValueNotifier<List<TripRating>> ratings = ValueNotifier<List<TripRating>>([]);

  // Submit a new rating
  void submitRating(TripRating rating) {
    ratings.value = [...ratings.value, rating];
    if (kDebugMode) {
      print('⭐ Rating submitted: ${rating.toUserName} - ${rating.averageRating.toStringAsFixed(1)}');
      print('   Polite: ${rating.polite}, Clean: ${rating.clean}, Communicative: ${rating.communicative}');
      print('   Safe: ${rating.safe}, Punctual: ${rating.punctual}');
    }
  }

  // Check if user has already rated someone for a specific trip
  bool hasRated(String bookingId, String fromUserId, String toUserId) {
    return ratings.value.any((r) => 
      r.bookingId == bookingId && 
      r.fromUserId == fromUserId && 
      r.toUserId == toUserId
    );
  }

  // Get existing rating for a trip
  TripRating? getRating(String bookingId, String fromUserId, String toUserId) {
    try {
      return ratings.value.firstWhere((r) => 
        r.bookingId == bookingId && 
        r.fromUserId == fromUserId && 
        r.toUserId == toUserId
      );
    } catch (e) {
      return null;
    }
  }

  // Get all ratings a user has received
  List<TripRating> getRatingsForUser(String userId) {
    return ratings.value.where((r) => r.toUserId == userId).toList();
  }

  // Get all ratings a user has given
  List<TripRating> getRatingsByUser(String userId) {
    return ratings.value.where((r) => r.fromUserId == userId).toList();
  }

  // Calculate user's average rating across all trips
  double getUserAverageRating(String userId) {
    final userRatings = getRatingsForUser(userId);
    if (userRatings.isEmpty) return 0.0;
    
    final sum = userRatings.fold<double>(
      0.0, 
      (sum, rating) => sum + rating.averageRating
    );
    return sum / userRatings.length;
  }

  // Get category averages for a user
  Map<String, double> getUserCategoryAverages(String userId) {
    final userRatings = getRatingsForUser(userId);
    if (userRatings.isEmpty) {
      return {
        'polite': 0.0,
        'clean': 0.0,
        'communicative': 0.0,
        'safe': 0.0,
        'punctual': 0.0,
      };
    }

    return {
      'polite': userRatings.fold<double>(0.0, (sum, r) => sum + r.polite) / userRatings.length,
      'clean': userRatings.fold<double>(0.0, (sum, r) => sum + r.clean) / userRatings.length,
      'communicative': userRatings.fold<double>(0.0, (sum, r) => sum + r.communicative) / userRatings.length,
      'safe': userRatings.fold<double>(0.0, (sum, r) => sum + r.safe) / userRatings.length,
      'punctual': userRatings.fold<double>(0.0, (sum, r) => sum + r.punctual) / userRatings.length,
    };
  }

  // Clear all ratings (for testing)
  void clearAll() {
    ratings.value = [];
    if (kDebugMode) {
      print('🗑️ All ratings cleared');
    }
  }
}
