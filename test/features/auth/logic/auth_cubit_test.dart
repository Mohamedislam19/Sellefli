import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sellefli/src/data/repositories/auth_repository.dart';
import 'package:sellefli/src/features/auth/logic/auth_cubit.dart';
import 'package:sellefli/src/features/auth/logic/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class MockAuthRepository extends Mock implements AuthRepository {}
class MockUser extends Mock implements User {}
class MockConnectivity extends Mock implements Connectivity {}
class MockAuthResponse extends Mock implements AuthResponse {}
class MockAuthState extends Mock implements supabase.AuthState {} // Supabase AuthState

// Alias for Supabase AuthState to avoid conflict with our AuthState
typedef SupabaseAuthState = supabase.AuthState;

void main() {
  late AuthRepository authRepository;
  late MockUser mockUser;
  late MockConnectivity mockConnectivity;

  setUp(() {
    authRepository = MockAuthRepository();
    mockUser = MockUser();
    mockConnectivity = MockConnectivity();
    
    // Default mocks
    when(() => authRepository.onAuthStateChange).thenAnswer((_) => const Stream.empty());
    when(() => mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.wifi]);
  });

  group('AuthCubit', () {
    test('initial state is AuthInitial', () {
      when(() => authRepository.currentUser).thenReturn(null);
      final cubit = AuthCubit(authRepository, connectivity: mockConnectivity);
      expect(cubit.state, isA<AuthInitial>());
      cubit.close();
    });

    blocTest<AuthCubit, AuthState>(
      'emits [AuthAuthenticated] when user is already logged in',
      build: () {
        when(() => authRepository.currentUser).thenReturn(mockUser);
        return AuthCubit(authRepository, connectivity: mockConnectivity);
      },
      expect: () => [isA<AuthAuthenticated>()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthUnauthenticated] when user is not logged in',
      build: () {
        when(() => authRepository.currentUser).thenReturn(null);
        return AuthCubit(authRepository, connectivity: mockConnectivity);
      },
      expect: () => [isA<AuthUnauthenticated>()],
    );

    group('login', () {
      const email = 'test@example.com';
      const password = 'password';

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on success',
        build: () {
          when(() => authRepository.currentUser).thenReturn(null);
          when(() => authRepository.signIn(email: email, password: password))
              .thenAnswer((_) async => MockAuthResponse());
          // After login, currentUser should return user
          when(() => authRepository.currentUser).thenReturn(mockUser);
          
          return AuthCubit(authRepository, connectivity: mockConnectivity);
        },
        act: (cubit) => cubit.login(email, password),
        expect: () => [
          isA<AuthUnauthenticated>(),
          isA<AuthLoading>(),
          isA<AuthAuthenticated>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] on failure',
        build: () {
          when(() => authRepository.currentUser).thenReturn(null);
          when(() => authRepository.signIn(email: email, password: password))
              .thenThrow(const AuthException('Invalid credentials'));
          return AuthCubit(authRepository, connectivity: mockConnectivity);
        },
        act: (cubit) => cubit.login(email, password),
        expect: () => [
          isA<AuthUnauthenticated>(),
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );
      
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] on no internet',
        build: () {
          when(() => mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.none]);
          when(() => authRepository.currentUser).thenReturn(null);
          return AuthCubit(authRepository, connectivity: mockConnectivity);
        },
        act: (cubit) => cubit.login(email, password),
        expect: () => [
          isA<AuthUnauthenticated>(),
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );
    });
  });
}
