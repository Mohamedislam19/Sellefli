import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sellefli/src/data/repositories/rating_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../helpers/test_bootstrap.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() async {
    bootstrapUnitTests();
    SharedPreferences.setMockInitialValues(<String, Object>{});

    // RatingRepository uses Supabase.instance for auth headers.
    try {
      await Supabase.initialize(
        url: 'https://example.supabase.co',
        anonKey: 'test-anon-key',
      );
    } catch (_) {
      // Ignore if already initialized.
    }
  });

  group('RatingRepository (unit)', () {
    late MockHttpClient client;

    setUp(() {
      client = MockHttpClient();
    });

    test('hasAlreadyRated returns parsed boolean', () async {
      when(
        () => client.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response('{"has_rated": true}', 200));

      final repo = RatingRepository(client);
      final result = await repo.hasAlreadyRated(
        bookingId: 'b1',
        raterUserId: 'u1',
      );

      expect(result, isTrue);

      final captured = verify(
        () => client.get(captureAny(), headers: captureAny(named: 'headers')),
      ).captured;

      final uri = captured[0] as Uri;
      final headers = captured[1] as Map<String, String>;

      expect(uri.path, '/api/ratings/has-rated/');
      expect(uri.queryParameters['booking_id'], 'b1');
      expect(uri.queryParameters['rater_id'], 'u1');
      expect(headers[HttpHeaders.contentTypeHeader], 'application/json');
    });

    test(
      'getUserAverageRating returns sum/count and 0 when count is 0',
      () async {
        when(
          () => client.get(any(), headers: any(named: 'headers')),
        ).thenAnswer(
          (_) async =>
              http.Response('{"rating_sum": 7, "rating_count": 2}', 200),
        );

        final repo = RatingRepository(client);
        final avg = await repo.getUserAverageRating('u1');
        expect(avg, closeTo(3.5, 0.0001));

        when(
          () => client.get(any(), headers: any(named: 'headers')),
        ).thenAnswer(
          (_) async =>
              http.Response('{"rating_sum": 0, "rating_count": 0}', 200),
        );

        final avg0 = await repo.getUserAverageRating('u1');
        expect(avg0, 0.0);
      },
    );

    test('throws HttpException on non-2xx responses', () async {
      when(
        () => client.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response('nope', 500));

      final repo = RatingRepository(client);

      expect(
        () => repo.hasAlreadyRated(bookingId: 'b1', raterUserId: 'u1'),
        throwsA(isA<HttpException>()),
      );
    });
  });
}
