import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sellefli/src/core/services/auth_service.dart';

import '../../../helpers/fake_http_overrides.dart';
import '../../../helpers/test_bootstrap.dart';

void main() {
  setUpAll(() async {
    bootstrapUnitTests();
    SharedPreferences.setMockInitialValues(<String, Object>{});

    try {
      await Supabase.initialize(
        url: 'https://example.supabase.co',
        anonKey: 'test-anon-key',
      );
    } catch (_) {
      // Ignore if already initialized.
    }
  });

  group('AuthService (unit)', () {
    setUp(() {
      FakeHttpRouter.instance.setRoutes([
        FakeHttpRoute(matches: (_, __) => true, statusCode: 200, body: '{}'),
      ]);
    });

    tearDown(() {
      FakeHttpRouter.instance
        ..clearRoutes()
        ..clearOnRequest();
    });

    test('exposes null user fields when unauthenticated', () {
      final service = AuthService();

      expect(service.currentUserId, isNull);
      expect(service.currentUserEmail, isNull);
      expect(service.isAuthenticated, isFalse);
      expect(service.currentSession, isNull);
      expect(service.accessToken, isNull);
    });

    test('refreshTokenIfNeeded returns null when no session', () async {
      final service = AuthService();
      final token = await service.refreshTokenIfNeeded();
      expect(token, isNull);
    });

    test('signOut completes without throwing', () async {
      final service = AuthService();
      await service.signOut();
    });

    test('onAuthStateChange is a stream', () {
      final service = AuthService();
      expect(service.onAuthStateChange, isA<Stream<AuthState>>());
    });
  });
}
