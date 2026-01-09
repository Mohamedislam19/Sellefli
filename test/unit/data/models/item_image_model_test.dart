import 'package:flutter_test/flutter_test.dart';
import 'package:sellefli/src/data/models/item_image_model.dart';

import '../../../helpers/test_bootstrap.dart';

void main() {
  bootstrapUnitTests();

  group('ItemImage model', () {
    test('fromJson/toJson round-trip', () {
      final json = {
        'id': 'img1',
        'item_id': 'i1',
        'image_url': 'https://example.com/img.png',
        'position': 1,
      };

      final image = ItemImage.fromJson(json);
      expect(image.itemId, 'i1');
      expect(image.position, 1);

      final serialized = image.toJson();
      expect(serialized['image_url'], 'https://example.com/img.png');
    });
  });
}
