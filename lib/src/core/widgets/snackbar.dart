import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart'; // Assuming AppColors is here

/// Utility class to show styled snackbars consistently across the application.
class SnackbarHelper {
  /// Clears any existing snackbars and shows a new one.
  static void showSnackBar(
    BuildContext context, {
    required String message,
    required bool isSuccess,
  }) {
    final Color backgroundColor = isSuccess
        ? AppColors.primaryBlue
        : Colors.red.shade400;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Center(
            // Added Center widget here
            child: Text(
              message,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15.0, // Made the writing a little bigger
              ),
            ),
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          // Added margin to float above the bottom edge and give padding from sides
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          // Set duration for error messages to be slightly longer
          duration: Duration(seconds: isSuccess ? 3 : 5),
        ),
      );
  }
}
