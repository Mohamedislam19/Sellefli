import 'package:flutter_test/flutter_test.dart';

import 'package:sellefli/src/core/constants/categories.dart';

void main() {
  group('AppCategories (unit)', () {
    test('categories list is non-empty and unique', () {
      expect(AppCategories.categories, isNotEmpty);

      final unique = AppCategories.categories.toSet();
      expect(unique.length, AppCategories.categories.length);
    });

    test('every category has an icon mapping', () {
      for (final category in AppCategories.categories) {
        expect(AppCategories.categoryIcons.containsKey(category), isTrue);
      }
    });

    test('icons map contains no extra categories', () {
      expect(
        AppCategories.categoryIcons.keys.toSet(),
        AppCategories.categories.toSet(),
      );
    });
  });
}
