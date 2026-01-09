import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sellefli/src/data/repositories/auth_repository.dart';
import 'package:sellefli/src/features/auth/logic/auth_cubit.dart';
import 'package:sellefli/src/features/auth/logic/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../../../helpers/test_bootstrap.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockUser extends Mock implements User {}

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late AuthRepository authRepository;
  late MockUser mockUser;
  late MockConnectivity mockConnectivity;

  setUpAll(() async {
    bootstrapUnitTests();

    // supabase_flutter uses SharedPreferences-backed storage.
    // In unit tests, we need to provide the in-memory mock.
    SharedPreferences.setMockInitialValues(<String, Object>{});

    // AuthCubit uses Supabase.instance directly. For unit tests we only need
    // the singleton initialized (no real network/session required).
    try {
      await Supabase.initialize(
        url: 'https://example.supabase.co',
        anonKey: 'test-anon-key',
      );
    } catch (_) {
      // Ignore if already initialized by another test.
    }
  });

  setUp(() {
    authRepository = MockAuthRepository();
    mockUser = MockUser();
    mockConnectivity = MockConnectivity();

    // Default mocks
    when(
      () => authRepository.onAuthStateChange,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockConnectivity.checkConnectivity(),
    ).thenAnswer((_) async => [ConnectivityResult.wifi]);
  });

  group('AuthCubit', () {
    test('starts unauthenticated when currentUser is null', () {
      when(() => authRepository.currentUser).thenReturn(null);
      final cubit = AuthCubit(authRepository, connectivity: mockConnectivity);
      expect(cubit.state, isA<AuthUnauthenticated>());
      cubit.close();
    });

    test('becomes authenticated when currentUser is non-null', () {
      when(() => authRepository.currentUser).thenReturn(mockUser);
      final cubit = AuthCubit(authRepository, connectivity: mockConnectivity);
      expect(cubit.state, isA<AuthAuthenticated>());
      cubit.close();
    });

    test('becomes unauthenticated when currentUser is null', () {
      when(() => authRepository.currentUser).thenReturn(null);
      final cubit = AuthCubit(authRepository, connectivity: mockConnectivity);
      expect(cubit.state, isA<AuthUnauthenticated>());
      cubit.close();
    });

    group('login', () {
      const email = 'test@example.com';
      const password = 'password';

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when session is missing',
        build: () {
          when(() => authRepository.currentUser).thenReturn(null);
          when(
            () => authRepository.signIn(email: email, password: password),
          ).thenAnswer((_) async => MockAuthResponse());
          // After login, currentUser should return user
          when(() => authRepository.currentUser).thenReturn(mockUser);

          return AuthCubit(authRepository, connectivity: mockConnectivity);
        },
        act: (cubit) => cubit.login(email, password),
        expect: () => [isA<AuthLoading>(), isA<AuthError>()],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] on failure',
        build: () {
          when(() => authRepository.currentUser).thenReturn(null);
          when(
            () => authRepository.signIn(email: email, password: password),
          ).thenThrow(const AuthException('Invalid credentials'));
          return AuthCubit(authRepository, connectivity: mockConnectivity);
        },
        act: (cubit) => cubit.login(email, password),
        expect: () => [isA<AuthLoading>(), isA<AuthError>()],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] on no internet',
        build: () {
          when(
            () => mockConnectivity.checkConnectivity(),
          ).thenAnswer((_) async => [ConnectivityResult.none]);
          when(() => authRepository.currentUser).thenReturn(null);
          return AuthCubit(authRepository, connectivity: mockConnectivity);
        },
        act: (cubit) => cubit.login(email, password),
        expect: () => [isA<AuthLoading>(), isA<AuthError>()],
      );
    });
  });
}
