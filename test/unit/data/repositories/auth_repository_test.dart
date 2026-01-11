import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:sellefli/src/data/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../helpers/test_bootstrap.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockAuthResponse extends Mock implements AuthResponse {}

void main() {
  bootstrapUnitTests();

  late MockHttpClient httpClient;
  late MockSupabaseClient supabaseClient;
  late MockGoTrueClient goTrueClient;
  late AuthRepository repository;

  setUp(() {
    httpClient = MockHttpClient();
    supabaseClient = MockSupabaseClient();
    goTrueClient = MockGoTrueClient();

    when(() => supabaseClient.auth).thenReturn(goTrueClient);

    repository = AuthRepository(supabase: supabaseClient, client: httpClient);
  });

  group('AuthRepository', () {
    test(
      'signIn posts to /api/users/login/ and sets session from refresh token',
      () async {
        const email = 'test@example.com';
        const password = 'pass12345';

        when(
          () => httpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({'access_token': 'a', 'refresh_token': 'r'}),
            200,
          ),
        );

        final authResponse = MockAuthResponse();
        when(
          () => goTrueClient.setSession('r'),
        ).thenAnswer((_) async => authResponse);

        final res = await repository.signIn(email: email, password: password);
        expect(res, authResponse);

        verify(
          () => httpClient.post(
            any(
              that: isA<Uri>().having(
                (u) => u.path,
                'path',
                contains('/api/users/login/'),
              ),
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          ),
        ).called(1);

        verify(() => goTrueClient.setSession('r')).called(1);
      },
    );

    test(
      'signIn throws user-friendly error when backend returns error field',
      () async {
        when(
          () => httpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async =>
              http.Response(jsonEncode({'error': 'Login failed'}), 400),
        );

        expect(
          () => repository.signIn(email: 'a@b.com', password: 'x'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Login failed'),
            ),
          ),
        );
      },
    );

    test('signUp posts to /api/users/signup/ then signs in', () async {
      const email = 'test@example.com';
      const password = 'pass12345';
      const username = 'user';
      const phone = '12345678';

      // 1st post = signup (success)
      // 2nd post = login (success tokens)
      when(
        () => httpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((invocation) async {
        final uri = invocation.positionalArguments.first as Uri;
        if (uri.path.endsWith('/api/users/signup/')) {
          return http.Response('', 201);
        }
        if (uri.path.endsWith('/api/users/login/')) {
          return http.Response(
            jsonEncode({'access_token': 'a', 'refresh_token': 'r'}),
            200,
          );
        }
        return http.Response('Not mocked', 500);
      });

      final authResponse = MockAuthResponse();
      when(
        () => goTrueClient.setSession('r'),
      ).thenAnswer((_) async => authResponse);

      final res = await repository.signUp(
        email: email,
        password: password,
        username: username,
        phone: phone,
      );

      expect(res, authResponse);

      verify(
        () => httpClient.post(
          any(
            that: isA<Uri>().having(
              (u) => u.path,
              'path',
              contains('/api/users/signup/'),
            ),
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
            'username': username,
            'phone': phone,
          }),
        ),
      ).called(1);

      verify(() => goTrueClient.setSession('r')).called(1);
    });
  });
}
