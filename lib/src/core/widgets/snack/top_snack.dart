// lib/src/core/widgets/snack/top_snack.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';


class TopSnack {
  /// Shows a temporary overlay at the top (below the AppBar).
  /// `success` chooses the background color: primaryBlue if true, redAccent if false.
  static void show(BuildContext context, String message, bool success) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;

    // Size of app bar or default to 56.0 if not found
    final appBarHeight = Scaffold.maybeOf(context)?.appBarMaxHeight ?? 56.0;
    final topPadding = MediaQuery.of(context).padding.top;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: topPadding + appBarHeight + 8, // 8 for a small gap below app bar
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: success ? AppColors.primaryBlue : Colors.redAccent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Icon(
                    success ? Icons.check_circle_rounded : Icons.error_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () {
      try {
        entry.remove();
      } catch (_) {}
    });
  }
}
