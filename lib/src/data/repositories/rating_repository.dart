import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/rating_model.dart';

class RatingRepository {
  final SupabaseClient supabase;

  RatingRepository(this.supabase);

  Future<void> createRating({
    required String bookingId,
    required String raterUserId,
    required String targetUserId,
    required int stars,
  }) async {
    await supabase.from('ratings').insert({
      'booking_id': bookingId,
      'rater_user_id': raterUserId,
      'target_user_id': targetUserId,
      'stars': stars,
    });
  }

  Future<List<Rating>> getUserRatings(String userId) async {
    final data = await supabase
        .from('ratings')
        .select()
        .eq('target_user_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((json) => Rating.fromJson(json)).toList();
  }
}
