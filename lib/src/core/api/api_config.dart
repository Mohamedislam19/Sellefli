/// API Configuration for the Sellefli backend.
///
/// Configure your backend base URL.
/// Prefer --dart-define=DJANGO_BASE_URL (used across the app). For compatibility,
/// --dart-define=API_BASE_URL is also supported as a fallback.
/// if needed.
class ApiConfig {
  /// The base URL for the Django backend API.
  /// Production: https://sellefli.onrender.com
  /// Override via --dart-define=DJANGO_BASE_URL for local development.
  static const String apiBaseUrl = String.fromEnvironment(
    'DJANGO_BASE_URL',
    defaultValue: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://sellefli.onrender.com',
    ),
  );

  /// Private constructor to prevent instantiation.
  ApiConfig._();
}
