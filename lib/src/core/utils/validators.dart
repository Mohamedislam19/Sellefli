class Validators {
  // Full Name Validator
  // Rules: Only letters, spaces, hyphens, apostrophes; 3–50 chars; no numbers/emojis
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }

    final trimmed = value.trim();

    if (trimmed.length < 3) {
      return 'Name must be at least 3 characters';
    }

    if (trimmed.length > 50) {
      return 'Name must not exceed 50 characters';
    }

    // Only letters, spaces, hyphens, apostrophes
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(trimmed)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  // Phone Validator
  // Rules: Digits only, no letters/symbols
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }

    final trimmed = value.trim();

    // Only digits
    final phoneRegex = RegExp(r'^[0-9]+$');
    if (!phoneRegex.hasMatch(trimmed)) {
      return 'Phone number can only contain digits';
    }

    if (trimmed.length < 8) {
      return 'Phone number must be at least 8 digits';
    }

    return null;
  }

  // Email Validator
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password Validator
  // Rules: Min 8 chars, ≥1 uppercase, ≥1 lowercase, ≥1 number, ≥1 symbol, no spaces
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.contains(' ')) {
      return 'No spaces allowed';
    }

    if (value.length < 8) {
      return 'Min 8 characters required';
    }

    // Check for uppercase
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Add at least 1 uppercase letter';
    }

    // Check for lowercase
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Add at least 1 lowercase letter';
    }

    // Check for number
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Add at least 1 number';
    }

    // Check for special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Add at least 1 special character';
    }

    return null;
  }

  // Login Password Validator (less strict, just check if not empty)
  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }
}
