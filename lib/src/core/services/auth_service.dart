import 'package:supabase_flutter/supabase_flutter.dart';

/// AuthService - Centralized authentication service.
///
/// This service encapsulates all authentication-related operations.
/// While it internally uses Supabase Auth for session management,
/// all data operations (items, ratings, bookings) go through the Django backend.
///
/// The Django backend verifies the JWT token passed in the Authorization header
/// and handles all database operations with Supabase.
class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  /// Get the Supabase auth client (internal use only)
  GoTrueClient get _auth => Supabase.instance.client.auth;

  /// Get the current user ID, or null if not authenticated.
  String? get currentUserId => _auth.currentUser?.id;

  /// Get the current user email, or null if not authenticated.
  String? get currentUserEmail => _auth.currentUser?.email;

  /// Check if user is currently authenticated.
  bool get isAuthenticated => _auth.currentUser != null;

  /// Get the current session, or null if not authenticated.
  Session? get currentSession => _auth.currentSession;

  /// Get the current access token for API calls to Django.
  /// This token is passed to Django in the Authorization header.
  /// Django verifies this token using the Supabase JWT secret.
  String? get accessToken => _auth.currentSession?.accessToken;

  /// Refresh the current session if needed.
  /// Returns the new access token, or null if refresh failed.
  Future<String?> refreshTokenIfNeeded() async {
    final session = _auth.currentSession;
    if (session == null) return null;

    final expiresAt = session.expiresAt;
    if (expiresAt == null) return session.accessToken;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final timeUntilExpiry = expiresAt - now;

    // Refresh if token expires within 5 minutes
    if (timeUntilExpiry < 300) {
      try {
        final response = await _auth.refreshSession();
        return response.session?.accessToken;
      } catch (e) {
        // If refresh fails but token is still valid, return current token
        if (timeUntilExpiry > 0) {
          return session.accessToken;
        }
        return null;
      }
    }

    return session.accessToken;
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Listen to auth state changes.
  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;
}
