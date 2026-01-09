class Rating {
  final String id;
  final String bookingId;
  final String raterUserId;
  final String targetUserId;
  final int stars;
  final DateTime createdAt;
  final String? raterUsername;
  final String? raterAvatarUrl;

  Rating({
    required this.id,
    required this.bookingId,
    required this.raterUserId,
    required this.targetUserId,
    required this.stars,
    required this.createdAt,
    this.raterUsername,
    this.raterAvatarUrl,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    // Handle both flat and nested formats
    String raterId;
    String? raterUsername;
    String? raterAvatarUrl;
    String targetUserId;

    if (json['rater'] is Map<String, dynamic>) {
      // Nested format from API
      final rater = json['rater'] as Map<String, dynamic>;
      raterId = rater['id'] as String;
      raterUsername = rater['username'] as String?;
      raterAvatarUrl = rater['avatar_url'] as String?;
    } else {
      // Flat format (rater_id or rater_user_id)
      raterId = (json['rater_id'] ?? json['rater_user_id']) as String;
    }

    if (json['target_user'] is Map<String, dynamic>) {
      // Nested format from API
      final targetUser = json['target_user'] as Map<String, dynamic>;
      targetUserId = targetUser['id'] as String;
    } else {
      // Flat format
      targetUserId = json['target_user_id'] as String;
    }

    return Rating(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      raterUserId: raterId,
      targetUserId: targetUserId,
      stars: json['stars'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      raterUsername: raterUsername,
      raterAvatarUrl: raterAvatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'rater_user_id': raterUserId,
      'target_user_id': targetUserId,
      'stars': stars,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
