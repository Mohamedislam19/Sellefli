class ItemImage {
  final String id;
  final String itemId;
  final String imageUrl;
  final int? position;

  ItemImage({
    required this.id,
    required this.itemId,
    required this.imageUrl,
    this.position,
  });

  factory ItemImage.fromJson(Map<String, dynamic> json) {
    int? _toIntOrNull(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) {
        final parsedInt = int.tryParse(v);
        if (parsedInt != null) return parsedInt;
        final parsedDouble = double.tryParse(v);
        if (parsedDouble != null) return parsedDouble.toInt();
      }
      return null;
    }

    return ItemImage(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      imageUrl: json['image_url'] as String,
      position: _toIntOrNull(json['position']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'image_url': imageUrl,
      'position': position,
    };
  }
}
