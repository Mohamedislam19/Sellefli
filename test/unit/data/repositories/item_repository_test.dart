import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sellefli/src/data/models/item_model.dart';
import 'package:sellefli/src/data/repositories/item_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../helpers/test_bootstrap.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() async {
    bootstrapUnitTests();

    // supabase_flutter uses SharedPreferences-backed storage.
    SharedPreferences.setMockInitialValues(<String, Object>{});

    // ItemRepository reads Supabase.instance for auth headers.
    try {
      await Supabase.initialize(
        url: 'https://example.supabase.co',
        anonKey: 'test-anon-key',
      );
    } catch (_) {
      // Ignore if already initialized by another test.
    }
  });

  late MockHttpClient httpClient;
  late ItemRepository repository;

  setUp(() {
    httpClient = MockHttpClient();
    repository = ItemRepository(httpClient);
  });

  group('ItemRepository (unit)', () {
    test('createItem posts to /api/items/ and returns backend id', () async {
      final item = Item(
        id: 'local',
        ownerId: 'owner-1',
        title: 'Camera',
        category: 'Electronics',
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 1),
      );

      when(
        () => httpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(jsonEncode({'id': 'server-id'}), 200),
      );

      final id = await repository.createItem(item);
      expect(id, 'server-id');

      verify(
        () => httpClient.post(
          any(
            that: isA<Uri>().having(
              (u) => u.path,
              'path',
              contains('/api/items/'),
            ),
          ),
          headers: any(
            named: 'headers',
            that: isA<Map<String, String>>().having(
              (h) => h[HttpHeaders.contentTypeHeader],
              'content-type',
              'application/json',
            ),
          ),
          body: jsonEncode(item.toJson()),
        ),
      ).called(1);
    });

    test('createItem throws HttpException on non-2xx response', () async {
      final item = Item(
        id: 'local',
        ownerId: 'owner-1',
        title: 'Camera',
        category: 'Electronics',
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 1),
      );

      when(
        () => httpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('boom', 500));

      expect(
        () => repository.createItem(item),
        throwsA(
          isA<HttpException>().having(
            (e) => e.message,
            'message',
            contains('HTTP 500'),
          ),
        ),
      );
    });

    test('getItemById returns null on 404', () async {
      when(
        () => httpClient.get(any()),
      ).thenAnswer((_) async => http.Response('not found', 404));

      final item = await repository.getItemById('missing');
      expect(item, isNull);

      verify(
        () => httpClient.get(
          any(
            that: isA<Uri>().having(
              (u) => u.path,
              'path',
              contains('/api/items/missing/'),
            ),
          ),
        ),
      ).called(1);
    });

    test('getMyItems calls /api/items/my-items/ with JSON headers', () async {
      when(
        () => httpClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer(
        (_) async => http.Response(jsonEncode({'results': []}), 200),
      );

      final items = await repository.getMyItems(page: 1, pageSize: 10);
      expect(items, isEmpty);

      verify(
        () => httpClient.get(
          any(
            that: isA<Uri>().having(
              (u) => u.path,
              'path',
              contains('/api/items/my-items/'),
            ),
          ),
          headers: any(
            named: 'headers',
            that: isA<Map<String, String>>().having(
              (h) => h[HttpHeaders.contentTypeHeader],
              'content-type',
              'application/json',
            ),
          ),
        ),
      ).called(1);
    });
  });
}
