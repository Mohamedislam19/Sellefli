import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get auth state change stream
  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  // Sign Up with Email
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
    required String phone,
  }) async {
    try {
      // Check if email already exists in users table
      final existingEmail = await _supabase
          .from('users')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (existingEmail != null) {
        throw Exception(
          'This email is already registered. Please sign in instead.',
        );
      }

      // Check if phone already exists in users table
      final existingPhone = await _supabase
          .from('users')
          .select('id')
          .eq('phone', phone)
          .maybeSingle();

      if (existingPhone != null) {
        throw Exception(
          'This phone number is already registered. Please use a different one.',
        );
      }

      // 1. Sign up with Supabase Auth using email
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username, 'phone': phone},
      );

      // 2. Create user profile in public.users table if sign up is successful
      if (response.user != null) {
        await _createProfile(
          userId: response.user!.id,
          username: username,
          phone: phone,
          email: email,
        );
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Create Profile in public.users
  Future<void> _createProfile({
    required String userId,
    required String username,
    required String phone,
    required String email,
  }) async {
    await _supabase.from('users').insert({
      'id': userId,
      'username': username,
      'phone': phone,
      'email': email,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Sign In with Email
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}


