import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sellefli/src/data/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:sellefli/src/features/auth/logic/auth_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sellefli/src/core/services/api_client.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final Connectivity _connectivity;
  final ApiClient _apiClient = ApiClient();
  StreamSubscription? _authStateSubscription;

  AuthCubit(this._authRepository, {Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity(),
      super(AuthInitial()) {
    _initAuthListener();
    checkAuthStatus();
  }

  void _initAuthListener() {
    _authStateSubscription = _authRepository.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        emit(AuthAuthenticated(session.user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  /// Check auth status and refresh session on app startup
  Future<void> checkAuthStatus() async {
    final user = _authRepository.currentUser;
    if (user != null) {
      // Try to refresh the session on app startup to ensure token is valid
      try {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          // Store tokens in ApiClient if not already stored
          if (_apiClient.currentUserId == null) {
            await _apiClient.setTokens(
              accessToken: session.accessToken,
              refreshToken: session.refreshToken ?? '',
              userId: user.id,
              userEmail: user.email ?? '',
              expiresAt: session.expiresAt,
            );
            debugPrint('[AuthCubit] Existing session tokens stored in ApiClient');
          }
          
          final expiresAt = session.expiresAt;
          final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          
          // Refresh if token is expired or will expire within 10 minutes
          if (expiresAt != null && (expiresAt - now) < 600) {
            debugPrint('[AuthCubit] Session expiring/expired, refreshing...');
            final response = await Supabase.instance.client.auth.refreshSession();
            // Update tokens in ApiClient after refresh
            if (response.session != null) {
              await _apiClient.setTokens(
                accessToken: response.session!.accessToken,
                refreshToken: response.session!.refreshToken ?? '',
                userId: response.user!.id,
                userEmail: response.user!.email ?? '',
                expiresAt: response.session!.expiresAt,
              );
            }
            debugPrint('[AuthCubit] Session refreshed successfully');
          }
        }
        emit(AuthAuthenticated(Supabase.instance.client.auth.currentUser ?? user));
      } catch (e) {
        debugPrint('[AuthCubit] Session refresh failed: $e');
        // If refresh fails, sign out the user so they can re-authenticate
        await Supabase.instance.client.auth.signOut();
        await _apiClient.clearTokens();
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }

  Future<bool> _checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult.first != ConnectivityResult.none;
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    // Check connectivity
    if (!await _checkConnectivity()) {
      emit(
        const AuthError(
          'No internet connection. Please check your network and try again.',
        ),
      );
      return;
    }

    try {
      await _authRepository.signIn(email: email, password: password);
      final user = _authRepository.currentUser;
      final session = Supabase.instance.client.auth.currentSession;
      
      if (user != null && session != null) {
        // Store tokens in ApiClient for Django backend calls
        await _apiClient.setTokens(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken ?? '',
          userId: user.id,
          userEmail: user.email ?? '',
          expiresAt: session.expiresAt,
        );
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Login failed. Please try again.'));
      }
    } on AuthException catch (e) {
      // Provide user-friendly error messages
      String errorMessage;
      if (e.message.toLowerCase().contains('invalid') ||
          e.message.toLowerCase().contains('credentials')) {
        errorMessage = 'Invalid email or password. Please try again.';
      } else if (e.message.toLowerCase().contains('not found')) {
        errorMessage =
            'No account found with this email. Please sign up first.';
      } else {
        errorMessage = e.message;
      }
      emit(AuthError(errorMessage));
    } catch (e) {
      emit(const AuthError('An unexpected error occurred. Please try again.'));
    }
  }

  Future<void> signup({
    required String email,
    required String phone,
    required String password,
    required String username,
  }) async {
    emit(AuthLoading());

    // Check connectivity
    if (!await _checkConnectivity()) {
      emit(
        const AuthError(
          'No internet connection. Please check your network and try again.',
        ),
      );
      return;
    }

    try {
      await _authRepository.signUp(
        email: email,
        phone: phone,
        password: password,
        username: username,
      );
      final user = _authRepository.currentUser;
      final session = Supabase.instance.client.auth.currentSession;
      
      if (user != null && session != null) {
        // Store tokens in ApiClient for Django backend calls
        await _apiClient.setTokens(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken ?? '',
          userId: user.id,
          userEmail: user.email ?? '',
          expiresAt: session.expiresAt,
        );
        emit(AuthAuthenticated(user));
        // Success message will be shown by BlocListener
      } else {
        // If email confirmation is enabled, user might be null
        emit(
          const AuthError(
            'Account created! Please check your email to verify your account.',
          ),
        );
      }
    } on AuthException catch (e) {
      // Provide user-friendly error messages
      String errorMessage;
      if (e.message.toLowerCase().contains('already') ||
          e.message.toLowerCase().contains('exists')) {
        errorMessage =
            'This email is already registered. Please sign in instead.';
      } else if (e.message.toLowerCase().contains('weak password')) {
        errorMessage = 'Password is too weak. Please use a stronger password.';
      } else {
        errorMessage = e.message;
      }
      emit(AuthError(errorMessage));
    } on PostgrestException catch (e) {
      // Handle database errors (e.g., duplicate phone number)
      String errorMessage;
      if (e.message.toLowerCase().contains('duplicate') ||
          e.message.toLowerCase().contains('unique')) {
        errorMessage =
            'This phone number or email is already registered. Please use a different one.';
      } else {
        // Log the actual error for debugging
        debugPrint('PostgrestException during signup: ${e.message}');
        debugPrint('PostgrestException code: ${e.code}');
        debugPrint('PostgrestException details: ${e.details}');
        errorMessage = 'Failed to create account: ${e.message}';
      }
      emit(AuthError(errorMessage));
    } catch (e) {
      // Handle custom exceptions from repository (like duplicate check)
      debugPrint('Signup error: $e');
      if (e.toString().contains('already registered')) {
        emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
      } else {
        emit(AuthError('An unexpected error occurred: ${e.toString()}'));
      }
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      // Clear tokens from ApiClient
      await _apiClient.clearTokens();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(const AuthError('Logout failed. Please try again.'));
    }
  }
}
