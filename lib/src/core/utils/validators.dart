import 'package:flutter/material.dart';
import 'package:sellefli/l10n/app_localizations.dart';

class Validators {
  // Full Name Validator
  // Rules: Only letters, spaces, hyphens, apostrophes; 3–50 chars; no numbers/emojis
  static String? validateFullName(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context);

    if (value == null || value.trim().isEmpty) {
      return l10n.validateFullNameEmpty;
    }

    final trimmed = value.trim();

    if (trimmed.length < 3) {
      return l10n.validateFullNameMin;
    }

    if (trimmed.length > 50) {
      return l10n.validateFullNameMax;
    }

    // Only letters, spaces, hyphens, apostrophes
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(trimmed)) {
      return l10n.validateFullNameChars;
    }

    return null;
  }

  // Phone Validator
  // Rules: Digits only, no letters/symbols
  static String? validatePhone(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context);

    if (value == null || value.trim().isEmpty) {
      return l10n.validatePhoneEmpty;
    }

    final trimmed = value.trim();

    // Only digits
    final phoneRegex = RegExp(r'^[0-9]+$');
    if (!phoneRegex.hasMatch(trimmed)) {
      return l10n.validatePhoneDigits;
    }

    if (trimmed.length < 8) {
      return l10n.validatePhoneMin;
    }

    return null;
  }

  // Email Validator
  static String? validateEmail(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context);

    if (value == null || value.trim().isEmpty) {
      return l10n.validateEmailEmpty;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return l10n.validateEmailInvalid;
    }

    return null;
  }

  // Password Validator
  // Rules: Min 8 chars, ≥1 uppercase, ≥1 lowercase, ≥1 number, ≥1 symbol, no spaces
  static String? validatePassword(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context);

    if (value == null || value.isEmpty) {
      return l10n.validatePasswordEmpty;
    }

    if (value.contains(' ')) {
      return l10n.validatePasswordNoSpaces;
    }

    if (value.length < 8) {
      return l10n.validatePasswordMin;
    }

    // Check for uppercase
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return l10n.validatePasswordUpper;
    }

    // Check for lowercase
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return l10n.validatePasswordLower;
    }

    // Check for number
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return l10n.validatePasswordNumber;
    }

    // Check for special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return l10n.validatePasswordSpecial;
    }

    return null;
  }

  // Login Password Validator (less strict, just check if not empty)
  static String? validateLoginPassword(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context);

    if (value == null || value.isEmpty) {
      return l10n.validateLoginPasswordEmpty;
    }
    return null;
  }
}


