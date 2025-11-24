class Rating {
  final String id;
  final String bookingId;
  final String raterUserId;
  final String targetUserId;
  final int stars;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.bookingId,
    required this.raterUserId,
    required this.targetUserId,
    required this.stars,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      raterUserId: json['rater_user_id'] as String,
      targetUserId: json['target_user_id'] as String,
      stars: json['stars'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
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
