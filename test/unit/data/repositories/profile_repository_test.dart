import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sellefli/src/core/services/api_client.dart';
import 'package:sellefli/src/data/repositories/profile_repository.dart';

import '../../../helpers/test_bootstrap.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  bootstrapUnitTests();

  late MockHttpClient httpClient;
  late ProfileRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    // Ensure ApiClient has a user + token so ProfileRepository can build auth headers.
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await ApiClient().setTokens(
      accessToken: 'access',
      refreshToken: 'refresh',
      userId: 'u1',
      userEmail: 'a@b.com',
      expiresAt: now + 3600,
    );

    httpClient = MockHttpClient();
    repository = ProfileRepository(client: httpClient);
  });

  tearDown(() async {
    await ApiClient().clearTokens();
  });

  group('ProfileRepository', () {
    test('getMyProfile returns null when userId missing', () async {
      await ApiClient().clearTokens();

      final res = await repository.getMyProfile();
      expect(res, isNull);
      verifyNever(() => httpClient.get(any(), headers: any(named: 'headers')));
    });

    test('getMyProfile returns user when backend returns 200', () async {
      when(
        () => httpClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'id': 'u1',
            'username': 'name',
            'phone': '123',
            'avatar_url': null,
            'email': 'a@b.com',
            'rating_sum': 0,
            'rating_count': 0,
            'created_at': '2024-01-01T00:00:00.000Z',
            'updated_at': '2024-01-02T00:00:00.000Z',
          }),
          200,
        ),
      );

      final profile = await repository.getMyProfile();
      expect(profile, isNotNull);
      expect(profile!.id, 'u1');

      verify(
        () => httpClient.get(
          any(
            that: isA<Uri>().having(
              (u) => u.path,
              'path',
              contains('/api/users/me/'),
            ),
          ),
          headers: any(named: 'headers'),
        ),
      ).called(1);
    });

    test('getProfileById returns null on 404', () async {
      when(
        () => httpClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response('', 404));

      final profile = await repository.getProfileById('u2');
      expect(profile, isNull);
    });

    test('updateProfile throws when user not authenticated', () async {
      await ApiClient().clearTokens();

      expect(
        () => repository.updateProfile(username: 'new'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('not authenticated'),
          ),
        ),
      );

      verifyNever(() => httpClient.patch(any(), headers: any(named: 'headers'), body: any(named: 'body')));
    });

    test('updateProfile returns getMyProfile when no updates provided', () async {
      when(
        () => httpClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'id': 'u1',
            'username': 'cached',
            'phone': '999',
            'avatar_url': null,
            'email': 'a@b.com',
            'rating_sum': 0,
            'rating_count': 0,
            'created_at': '2024-01-01T00:00:00.000Z',
            'updated_at': '2024-01-02T00:00:00.000Z',
          }),
          200,
        ),
      );

      final profile = await repository.updateProfile();

      expect(profile, isNotNull);
      expect(profile!.username, 'cached');

      verify(
        () => httpClient.get(any(), headers: any(named: 'headers')),
      ).called(1);
      verifyNever(
        () => httpClient.patch(any(), headers: any(named: 'headers'), body: any(named: 'body')),
      );
    });

    test('updateProfile sends patch with provided fields', () async {
      when(
        () => httpClient.patch(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'id': 'u1',
            'username': 'new',
            'phone': '12345678',
            'avatar_url': 'http://example.com/avatar.png',
            'email': 'a@b.com',
            'rating_sum': 0,
            'rating_count': 0,
            'created_at': '2024-01-01T00:00:00.000Z',
            'updated_at': '2024-01-03T00:00:00.000Z',
          }),
          200,
        ),
      );

      final profile = await repository.updateProfile(
        username: 'new',
        phone: '12345678',
        avatarUrl: 'http://example.com/avatar.png',
      );

      expect(profile, isNotNull);
      expect(profile!.username, 'new');

      verify(
        () => httpClient.patch(
          any(
            that: isA<Uri>().having(
              (u) => u.path,
              'path',
              contains('/api/users/u1/update-profile/'),
            ),
          ),
          headers: any(named: 'headers'),
          body: jsonEncode({
            'username': 'new',
            'phone': '12345678',
            'avatar_url': 'http://example.com/avatar.png',
          }),
        ),
      ).called(1);
    });

    test('updateProfile rethrows descriptive error on failure', () async {
      when(
        () => httpClient.patch(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('bad', 500));

      expect(
        () => repository.updateProfile(username: 'fail'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to update profile'),
          ),
        ),
      );
    });
  });
}
