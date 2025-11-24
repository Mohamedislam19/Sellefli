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
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      estimatedValue: (json['estimated_value'] as num?)?.toDouble(),
      depositAmount: (json['deposit_amount'] as num?)?.toDouble(),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      isAvailable: json['is_available'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
