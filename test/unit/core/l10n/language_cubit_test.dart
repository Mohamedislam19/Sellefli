import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sellefli/src/core/l10n/language_cubit.dart';

import '../../../helpers/test_bootstrap.dart';

void main() {
  bootstrapUnitTests();

  group('LanguageCubit', () {
    test('loads saved locale from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'preferred_language_code': 'fr'});

      final cubit = LanguageCubit();

      // The cubit emits once on construction after reading prefs.
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.locale.languageCode, 'fr');
      await cubit.close();
    });

    test('changeLocale persists to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});

      final cubit = LanguageCubit();
      await cubit.changeLocale(const Locale('ar'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('preferred_language_code'), 'ar');

      await cubit.close();
    });
  });
}
