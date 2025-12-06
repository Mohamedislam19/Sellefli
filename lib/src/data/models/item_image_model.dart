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
    return ItemImage(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      imageUrl: json['image_url'] as String,
      position: json['position'] as int?,
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


