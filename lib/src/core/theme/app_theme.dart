import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2F6CE6);
  static const appBarBackground = Color(0xFFDCEBFF);
  static const primaryDark = Color(0xFF1F4FD6);
  static const accent = Color(0xFFFFC107);
  static const danger = Color(0xFFE04B3B); // red
  static const background = Color(0xFFF6F7FB);
  static Color primaryBlue = Color(0xFF4A7BD6);
  static Color pageBackground = Color(0xFFF6F7FB);
  static const surface = Colors.white;
  static const muted = Color(0xFF9AA0AB);
  static const border = Color(0xFFE9EDF2);
  static const success = Color(0xFF2ECC71);
  static const star = Color(0xFFFFC107);

  /// Main App Gradient (Sellefli Sky)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFFBFD9FF), // very soft blue (top)
      Color(0xFFDCEBFF), // lighter mid tone
      Color(0xFFF4F9FF), // almost white pastel blue (bottom)
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTextStyles {
  static const title = TextStyle(fontSize: 22, fontWeight: FontWeight.w700);
  static const subtitle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF182028),
  );
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );
  static const chip = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surface,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black87),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Colors.black87,
    ),
  ),
  textTheme: const TextTheme(
    titleLarge: AppTextStyles.title,
    titleMedium: AppTextStyles.subtitle,
    bodyMedium: AppTextStyles.body,
    bodySmall: AppTextStyles.caption,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.border),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.primary),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.danger),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
);
