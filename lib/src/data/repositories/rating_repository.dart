import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/rating_model.dart';

class RatingRepository {
  final SupabaseClient supabase;

  RatingRepository(this.supabase);

  /// Check if a rating already exists for this booking by this user
  Future<bool> hasAlreadyRated({
    required String bookingId,
    required String raterUserId,
  }) async {
    final result = await supabase
        .from('ratings')
        .select('id')
        .eq('booking_id', bookingId)
        .eq('rater_user_id', raterUserId)
        .maybeSingle();
    return result != null;
  }

  Future<void> createRating({
    required String bookingId,
    required String raterUserId,
    required String targetUserId,
    required int stars,
  }) async {
    // Check for duplicate rating
    final alreadyRated = await hasAlreadyRated(
      bookingId: bookingId,
      raterUserId: raterUserId,
    );
    if (alreadyRated) {
      throw Exception('You have already rated this booking');
    }

    // Insert the rating
    await supabase.from('ratings').insert({
      'booking_id': bookingId,
      'rater_user_id': raterUserId,
      'target_user_id': targetUserId,
      'stars': stars,
    });

    // Recalculate stats for target user
    await _recalculateUserRating(targetUserId);
  }

  /// Recalculate and update user's rating stats
  Future<void> _recalculateUserRating(String userId) async {
    final result = await supabase
        .from('ratings')
        .select('stars')
        .eq('target_user_id', userId);

    final ratings = result as List;
    final sum = ratings.fold<int>(
      0,
      (prev, element) => prev + (element['stars'] as int),
    );
    final count = ratings.length;

    await supabase
        .from('users')
        .update({'rating_sum': sum, 'rating_count': count})
        .eq('id', userId);
  }

  Future<List<Rating>> getUserRatings(String userId) async {
    final data = await supabase
        .from('ratings')
        .select()
        .eq('target_user_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((json) => Rating.fromJson(json)).toList();
  }

  /// Get average rating for a user
  Future<double> getUserAverageRating(String userId) async {
    final result = await supabase
        .from('users')
        .select('rating_sum, rating_count')
        .eq('id', userId)
        .maybeSingle();

    if (result == null) return 0.0;

    final sum = result['rating_sum'] as int? ?? 0;
    final count = result['rating_count'] as int? ?? 0;

    return count > 0 ? sum / count : 0.0;
  }
}


