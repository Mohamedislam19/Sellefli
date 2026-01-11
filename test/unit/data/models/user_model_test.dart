import 'package:flutter_test/flutter_test.dart';
import 'package:sellefli/src/data/models/user_model.dart';

import '../../../helpers/test_bootstrap.dart';

void main() {
  bootstrapUnitTests();

  group('User model', () {
    test('fromJson/toJson round-trip', () {
      final json = {
        'id': 'u1',
        'username': 'mohamed',
        'phone': '12345678',
        'avatar_url': 'https://example.com/a.png',
        'email': 'a@b.com',
        'rating_sum': 10,
        'rating_count': 2,
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-02T00:00:00.000Z',
      };

      final user = User.fromJson(json);
      expect(user.id, 'u1');
      expect(user.username, 'mohamed');
      expect(user.ratingSum, 10);
      expect(user.ratingCount, 2);

      final serialized = user.toJson();
      expect(serialized['id'], 'u1');
      expect(serialized['username'], 'mohamed');
      expect(serialized['rating_sum'], 10);
      expect(serialized['rating_count'], 2);
    });

    test('defaults rating fields when missing', () {
      final json = {
        'id': 'u1',
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-02T00:00:00.000Z',
      };

      final user = User.fromJson(json);
      expect(user.ratingSum, 0);
      expect(user.ratingCount, 0);
    });
  });
}
