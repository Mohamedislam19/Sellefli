import 'package:flutter_test/flutter_test.dart';
import 'package:sellefli/src/data/models/item_model.dart';

import '../../../helpers/test_bootstrap.dart';

void main() {
  bootstrapUnitTests();

  group('Item model', () {
    test('fromJson parses images from item_images ordered by position', () {
      final json = {
        'id': 'i1',
        'owner_id': 'u1',
        'title': 'Drill',
        'category': 'Tools',
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-02T00:00:00.000Z',
        'item_images': [
          {'id': 'img2', 'item_id': 'i1', 'image_url': 'b', 'position': 2},
          {'id': 'img1', 'item_id': 'i1', 'image_url': 'a', 'position': 1},
        ],
        'owner': {
          'username': 'owner',
          'avatar_url': 'https://example.com/av.png',
          'rating_sum': 3,
          'rating_count': 1,
        },
      };

      final item = Item.fromJson(json);
      expect(item.images, ['a', 'b']);
      expect(item.ownerUsername, 'owner');
      expect(item.ownerRatingSum, 3);
      expect(item.ownerRatingCount, 1);
    });

    test('fromJson coerces numeric strings to double', () {
      final json = {
        'id': 'i1',
        'owner_id': 'u1',
        'title': 'Drill',
        'category': 'Tools',
        'estimated_value': '12.5',
        'deposit_amount': 10,
        'lat': '36.1',
        'lng': 3.2,
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-02T00:00:00.000Z',
      };

      final item = Item.fromJson(json);
      expect(item.estimatedValue, 12.5);
      expect(item.depositAmount, 10.0);
      expect(item.lat, 36.1);
      expect(item.lng, 3.2);
    });

    test('copyWith overrides selected fields', () {
      final item = Item(
        id: 'i1',
        ownerId: 'u1',
        title: 'Drill',
        category: 'Tools',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
      );

      final updated = item.copyWith(title: 'New', distance: 1.2);
      expect(updated.title, 'New');
      expect(updated.distance, 1.2);
      expect(updated.id, 'i1');
    });
  });
}
