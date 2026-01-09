import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sellefli/src/core/services/api_client.dart';

void main() {
  group('ApiClient (unit)', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await ApiClient().clearTokens();
    });

    test('setTokens + getAuthHeaders includes Bearer token', () async {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await ApiClient().setTokens(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
        userId: 'user-1',
        userEmail: 'u@example.com',
        expiresAt: now + 100000,
      );

      final headers = await ApiClient().getAuthHeaders();

      expect(headers[HttpHeaders.contentTypeHeader], 'application/json');
      expect(headers[HttpHeaders.authorizationHeader], 'Bearer access-1');
      expect(ApiClient().isAuthenticated, isTrue);
      expect(ApiClient().currentUserId, 'user-1');
      expect(ApiClient().currentUserEmail, 'u@example.com');
    });

    test('clearTokens removes authentication state', () async {
      await ApiClient().setTokens(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
        userId: 'user-1',
        userEmail: 'u@example.com',
        expiresAt: 9999999999,
      );

      await ApiClient().clearTokens();

      expect(ApiClient().isAuthenticated, isFalse);
      expect(ApiClient().currentUserId, isNull);
      expect(ApiClient().accessToken, isNull);

      final headers = await ApiClient().getAuthHeaders();
      expect(headers.containsKey(HttpHeaders.authorizationHeader), isFalse);
    });

    test('uri builds query parameters using toString', () {
      final uri = ApiClient().uri('/api/items/', {
        'page': 2,
        'q': 'camera',
        'nullable': null,
      });

      expect(uri.path, '/api/items/');
      expect(uri.queryParameters['page'], '2');
      expect(uri.queryParameters['q'], 'camera');
      // Null becomes empty string by implementation.
      expect(uri.queryParameters['nullable'], '');
    });
  });
}
