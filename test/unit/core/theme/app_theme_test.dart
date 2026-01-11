import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sellefli/src/core/theme/app_theme.dart';

void main() {
  group('appTheme (unit)', () {
    test('defines key colors and brightness', () {
      expect(appTheme.brightness, Brightness.light);
      expect(appTheme.primaryColor, AppColors.primary);
      expect(appTheme.scaffoldBackgroundColor, AppColors.background);
    });

    test('defines expected text styles (key fields)', () {
      final titleLarge = appTheme.textTheme.titleLarge;
      final titleMedium = appTheme.textTheme.titleMedium;
      final bodyMedium = appTheme.textTheme.bodyMedium;
      final bodySmall = appTheme.textTheme.bodySmall;

      expect(titleLarge, isNotNull);
      expect(titleMedium, isNotNull);
      expect(bodyMedium, isNotNull);
      expect(bodySmall, isNotNull);

      expect(titleLarge!.fontSize, AppTextStyles.title.fontSize);
      expect(titleLarge.fontWeight, AppTextStyles.title.fontWeight);

      expect(titleMedium!.fontSize, AppTextStyles.subtitle.fontSize);
      expect(titleMedium.fontWeight, AppTextStyles.subtitle.fontWeight);

      expect(bodyMedium!.fontSize, AppTextStyles.body.fontSize);
      expect(bodyMedium.fontWeight, AppTextStyles.body.fontWeight);
      expect(bodyMedium.color, AppTextStyles.body.color);

      expect(bodySmall!.fontSize, AppTextStyles.caption.fontSize);
      expect(bodySmall.fontWeight, AppTextStyles.caption.fontWeight);
      expect(bodySmall.color, AppTextStyles.caption.color);
    });

    test('input decoration theme uses expected border radii', () {
      final enabled = appTheme.inputDecorationTheme.enabledBorder;
      final focused = appTheme.inputDecorationTheme.focusedBorder;

      expect(enabled, isA<OutlineInputBorder>());
      expect(focused, isA<OutlineInputBorder>());

      final enabledBorder = enabled as OutlineInputBorder;
      final focusedBorder = focused as OutlineInputBorder;

      expect(
        enabledBorder.borderRadius,
        const BorderRadius.all(Radius.circular(10)),
      );
      expect(
        focusedBorder.borderRadius,
        const BorderRadius.all(Radius.circular(10)),
      );
    });

    test('primary gradient has 3 colors', () {
      expect(AppColors.primaryGradient.colors.length, 3);
    });
  });
}
