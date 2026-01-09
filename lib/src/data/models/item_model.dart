class Item {
  final String id;
  final String ownerId;
  final String title;
  final String category;
  final String? description;
  final double? estimatedValue;
  final double? depositAmount;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? lat;
  final double? lng;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? distance; // Distance in km from user
  final List<String> images;
  final String? ownerUsername; // Owner's username
  final String? ownerAvatarUrl; // Owner's avatar
  final int ownerRatingSum; // Owner's rating sum
  final int ownerRatingCount; // Owner's rating count

  Item({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.category,
    this.description,
    this.estimatedValue,
    this.depositAmount,
    this.startDate,
    this.endDate,
    this.lat,
    this.lng,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
    this.distance,
    this.images = const [],
    this.ownerUsername,
    this.ownerAvatarUrl,
    this.ownerRatingSum = 0,
    this.ownerRatingCount = 0,
  });

  Item copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? category,
    String? description,
    double? estimatedValue,
    double? depositAmount,
    DateTime? startDate,
    DateTime? endDate,
    double? lat,
    double? lng,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? distance,
    List<String>? images,
    String? ownerUsername,
    String? ownerAvatarUrl,
    int? ownerRatingSum,
    int? ownerRatingCount,
  }) {
    return Item(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      depositAmount: depositAmount ?? this.depositAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      distance: distance ?? this.distance,
      images: images ?? this.images,
      ownerUsername: ownerUsername ?? this.ownerUsername,
      ownerAvatarUrl: ownerAvatarUrl ?? this.ownerAvatarUrl,
      ownerRatingSum: ownerRatingSum ?? this.ownerRatingSum,
      ownerRatingCount: ownerRatingCount ?? this.ownerRatingCount,
    );
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) {
        final parsed = double.tryParse(v);
        return parsed;
      }
      return null;
    }

    // Parse images if available from join, sorted by position
    // Django returns 'images', Supabase might return 'item_images'
    List<String> imagesList = [];
    final imagesKey = json.containsKey('images') ? 'images' : 'item_images';
    if (json[imagesKey] != null && json[imagesKey] is List) {
      final imagesData = List<Map<String, dynamic>>.from(
        json[imagesKey] as List,
      );
      // Sort by position to ensure first image is at index 0
      imagesData.sort(
        (a, b) => ((a['position'] as int?) ?? 0).compareTo(
          (b['position'] as int?) ?? 0,
        ),
      );
      imagesList = imagesData.map((img) => img['image_url'] as String).toList();
    }

    // Parse owner data if available from join
    // Django returns 'owner', Supabase might return 'users'
    String? ownerUsername;
    String? ownerAvatarUrl;
    int ownerRatingSum = 0;
    int ownerRatingCount = 0;
    final ownerData = json['owner'] ?? json['users'];
    if (ownerData != null && ownerData is Map) {
      ownerUsername = ownerData['username'] as String?;
      ownerAvatarUrl = ownerData['avatar_url'] as String?;
      ownerRatingSum = ownerData['rating_sum'] as int? ?? 0;
      ownerRatingCount = ownerData['rating_count'] as int? ?? 0;
    }

    return Item(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      estimatedValue: _toDouble(json['estimated_value']),
      depositAmount: _toDouble(json['deposit_amount']),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      lat: _toDouble(json['lat']),
      lng: _toDouble(json['lng']),
      isAvailable: json['is_available'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      images: imagesList,
      ownerUsername: ownerUsername,
      ownerAvatarUrl: ownerAvatarUrl,
      ownerRatingSum: ownerRatingSum,
      ownerRatingCount: ownerRatingCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'category': category,
      'description': description,
      'estimated_value': estimatedValue,
      'deposit_amount': depositAmount,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'lat': lat,
      'lng': lng,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
