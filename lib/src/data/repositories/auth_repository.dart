import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase;
  final http.Client _client;

  // Uses the same default backend URL as other repositories
  static const String _baseUrl = String.fromEnvironment(
    'DJANGO_BASE_URL',
    defaultValue: 'http://localhost:9000',
  );

  AuthRepository({SupabaseClient? supabase, http.Client? client})
    : _supabase = supabase ?? Supabase.instance.client,
      _client = client ?? http.Client();

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Access token for calling the Django API (Bearer token).
  String? get accessToken => _supabase.auth.currentSession?.accessToken;

  // Get auth state change stream
  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  // Update: SignUp now calls Django to handle user creation in Supabase + DB safely
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
    required String phone,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/users/signup/');

      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'username': username,
          'phone': phone,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Registration successful on backend (created in Auth & DB).
        // Now verify with Supabase Auth to get the session locally.
        return await signIn(email: email, password: password);
      } else {
        // Parse error message
        String errorMessage = 'Registration failed';
        try {
          final body = jsonDecode(response.body);
          if (body is Map) {
            if (body.containsKey('error')) {
              errorMessage = body['error'];
            } else if (body.containsKey('detail')) {
              errorMessage = body['detail'];
            } else {
              // Flatten other errors (like validation dicts)
              errorMessage = body.values
                  .map((v) => v is List ? v.join(' ') : v)
                  .join('\n');
            }
          }
        } catch (_) {
          errorMessage = response.body.isEmpty
              ? 'Unknown error'
              : response.body;
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Sign In with Email
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/users/login/');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        final accessToken = body['access_token'];
        final refreshToken = body['refresh_token'];

        if (accessToken == null || refreshToken == null) {
          throw Exception('Login successful but no tokens returned');
        }

        // Set the session manually in Supabase SDK so the rest of the app works
        return await _supabase.auth.setSession(refreshToken);
      } else {
        String errorMessage = 'Login failed';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body.containsKey('error')) {
            errorMessage = body['error'];
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
