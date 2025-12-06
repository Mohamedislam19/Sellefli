import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sellefli/src/data/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:sellefli/src/features/auth/logic/auth_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final Connectivity _connectivity;
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

  void checkAuthStatus() {
    final user = _authRepository.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
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
      if (user != null) {
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
      if (user != null) {
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
        errorMessage = 'Failed to create account. Please try again.';
      }
      emit(AuthError(errorMessage));
    } catch (e) {
      // Handle custom exceptions from repository (like duplicate check)
      if (e.toString().contains('already registered')) {
        emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
      } else {
        emit(
          const AuthError('An unexpected error occurred. Please try again.'),
        );
      }
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(const AuthError('Logout failed. Please try again.'));
    }
  }
}


