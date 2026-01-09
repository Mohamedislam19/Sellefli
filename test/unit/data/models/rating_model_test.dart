import 'package:flutter_test/flutter_test.dart';
import 'package:sellefli/src/data/models/rating_model.dart';

import '../../../helpers/test_bootstrap.dart';

void main() {
  bootstrapUnitTests();

  group('Rating model', () {
    test('fromJson/toJson round-trip', () {
      final json = {
        'id': 'r1',
        'booking_id': 'b1',
        'rater_user_id': 'u1',
        'target_user_id': 'u2',
        'stars': 5,
        'created_at': '2024-01-01T00:00:00.000Z',
      };

      final rating = Rating.fromJson(json);
      expect(rating.stars, 5);

      final serialized = rating.toJson();
      expect(serialized['stars'], 5);
      expect(serialized['booking_id'], 'b1');
    });
  });
}
