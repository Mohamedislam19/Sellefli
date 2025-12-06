// lib/src/core/widgets/inputs/field_decoration.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

InputDecoration fieldDecoration({String? label, String? hint, IconData? icon}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    suffixIcon: icon != null ? Icon(icon, color: AppColors.primaryBlue, size: 20) : null,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: BorderSide(color: Colors.grey[200]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: BorderSide(color: Colors.grey[200]!, width: 1.1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.8),
    ),
    labelStyle: GoogleFonts.outfit(
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
    hintStyle: GoogleFonts.outfit(color: Colors.grey[400]),
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 17),
  );
}


