import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trip_rating.dart';

// Service to manage trip ratings with persistence
class RatingService {
  static final RatingService _instance = RatingService._internal();
  factory RatingService() => _instance;
  RatingService._internal();

  static const String _storageKey = 'ratings_data';
  bool _isLoaded = false;

  // In-memory storage for ratings
  final ValueNotifier<List<TripRating>> ratings =
      ValueNotifier<List<TripRating>>([]);

  // Ensure ratings are loaded (call this at app startup)
  Future<void> ensureLoaded() async {
    if (_isLoaded) return;
    await _loadRatings();
    _isLoaded = true;
  }

  // Load ratings from SharedPreferences
  Future<void> _loadRatings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ratingsJson = prefs.getString(_storageKey);
      
      if (ratingsJson != null) {
        final List<dynamic> decoded = json.decode(ratingsJson);
        ratings.value = decoded.map((data) => TripRating.fromJson(data)).toList();
        if (kDebugMode) {
          print('⭐ Loaded ${ratings.value.length} ratings from storage');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⭐ Error loading ratings: $e');
      }
    }
  }

  // Save ratings to SharedPreferences
  Future<void> _saveRatings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ratingsData = ratings.value.map((r) => r.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(ratingsData));
      if (kDebugMode) {
        print('⭐ Saved ${ratings.value.length} ratings to storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⭐ Error saving ratings: $e');
      }
    }
  }

  // Submit a new rating
  void submitRating(TripRating rating) {
    ratings.value = [...ratings.value, rating];
    _saveRatings();
    if (kDebugMode) {
      print(
        '⭐ Rating submitted: ${rating.toUserName} - ${rating.averageRating.toStringAsFixed(1)}',
      );
      print(
        '   Polite: ${rating.polite}, Clean: ${rating.clean}, Communicative: ${rating.communicative}',
      );
      print('   Safe: ${rating.safe}, Punctual: ${rating.punctual}');
    }
  }

  // Check if user has already rated someone for a specific trip
  bool hasRated(String bookingId, String fromUserId, String toUserId) {
    return ratings.value.any(
      (r) =>
          r.bookingId == bookingId &&
          r.fromUserId == fromUserId &&
          r.toUserId == toUserId,
    );
  }

  // Get existing rating for a trip
  TripRating? getRating(String bookingId, String fromUserId, String toUserId) {
    try {
      return ratings.value.firstWhere(
        (r) =>
            r.bookingId == bookingId &&
            r.fromUserId == fromUserId &&
            r.toUserId == toUserId,
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
      (sum, rating) => sum + rating.averageRating,
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
      'polite':
          userRatings.fold<double>(0.0, (sum, r) => sum + r.polite) /
          userRatings.length,
      'clean':
          userRatings.fold<double>(0.0, (sum, r) => sum + r.clean) /
          userRatings.length,
      'communicative':
          userRatings.fold<double>(0.0, (sum, r) => sum + r.communicative) /
          userRatings.length,
      'safe':
          userRatings.fold<double>(0.0, (sum, r) => sum + r.safe) /
          userRatings.length,
      'punctual':
          userRatings.fold<double>(0.0, (sum, r) => sum + r.punctual) /
          userRatings.length,
    };
  }

  // Clear all ratings (for testing)
  Future<void> clearAll() async {
    ratings.value = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      if (kDebugMode) {
        print('⭐ Error clearing ratings storage: $e');
      }
    }
    if (kDebugMode) {
      print('🗑️ All ratings cleared');
    }
  }
}
