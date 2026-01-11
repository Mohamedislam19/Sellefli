class User {
  final String id;
  final String? username;
  final String? phone;
  final String? avatarUrl;
  final String? email;
  final int ratingSum;
  final int ratingCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    this.username,
    this.phone,
    this.avatarUrl,
    this.email,
    this.ratingSum = 0,
    this.ratingCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v, {int fallback = 0}) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) {
        final parsedInt = int.tryParse(v);
        if (parsedInt != null) return parsedInt;
        final parsedDouble = double.tryParse(v);
        if (parsedDouble != null) return parsedDouble.toInt();
      }
      return fallback;
    }

    return User(
      id: json['id'] as String,
      username: json['username'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      email: json['email'] as String?,
      ratingSum: _toInt(json['rating_sum']),
      ratingCount: _toInt(json['rating_count']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'phone': phone,
      'avatar_url': avatarUrl,
      'email': email,
      'rating_sum': ratingSum,
      'rating_count': ratingCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
