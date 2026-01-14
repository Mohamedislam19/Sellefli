// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sellefli/src/data/models/booking_model.dart';
import 'package:sellefli/src/data/models/item_model.dart';
import 'package:sellefli/src/data/models/user_model.dart' as models;
import 'package:sellefli/src/data/repositories/booking_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      // Ignore if already initialized by another test.
    }
  });

  group('BookingRepository (unit)', () {
    late BookingRepository repo;

    setUp(() {
      repo = BookingRepository(Supabase.instance.client);
    });

    tearDown(() {
      FakeHttpRouter.instance
        ..clearRoutes()
        ..clearOnRequest();
    });

    test('createBooking returns id', () async {
      FakeHttpRouter.instance.setRoutes([
        FakeHttpRoute(
          matches: (method, uri) =>
              method == 'POST' && uri.path == '/rest/v1/bookings',
          statusCode: 201,
          body: jsonEncode({'id': 'b1'}),
        ),
      ]);

      final booking = Booking(
        id: 'local-id',
        itemId: 'i1',
        ownerId: 'o1',
        borrowerId: 'u1',
        startDate: DateTime.parse('2024-01-01T00:00:00.000Z'),
        returnByDate: DateTime.parse('2024-01-03T00:00:00.000Z'),
        totalCost: 10.0,
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      final id = await repo.createBooking(booking);
      expect(id, 'b1');
    });

    test('createBooking throws on non-2xx response', () async {
      FakeHttpRouter.instance.setRoutes([
        FakeHttpRoute(
          matches: (method, uri) =>
              method == 'POST' && uri.path == '/rest/v1/bookings',
          statusCode: 400,
          body: jsonEncode({'message': 'bad insert'}),
        ),
      ]);

      final booking = Booking(
        id: 'local-id',
        itemId: 'i1',
        ownerId: 'o1',
        borrowerId: 'u1',
        startDate: DateTime.parse('2024-01-01T00:00:00.000Z'),
        returnByDate: DateTime.parse('2024-01-03T00:00:00.000Z'),
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      expect(() => repo.createBooking(booking), throwsA(isA<Object>()));
    });

    test('getBookingDetails returns null when booking not found', () async {
      FakeHttpRouter.instance.setRoutes([
        FakeHttpRoute(
          matches: (method, uri) =>
              method == 'GET' && uri.path == '/api/bookings/missing/',
          statusCode: 404,
          body: '{}',
        ),
      ]);

      final result = await repo.getBookingDetails('missing');
      expect(result, isNull);
    });

    test('getBookingDetails returns booking + related data', () async {
      const bookingId = 'b1';
      const itemId = 'i1';

      final bookingJson = {
        'id': bookingId,
        'item_id': itemId,
        'owner_id': 'o1',
        'borrower_id': 'u1',
        'status': BookingStatus.accepted.name,
        'deposit_status': DepositStatus.none.name,
        'booking_code': 'SF-123-456',
        'start_date': '2024-01-01T00:00:00.000Z',
        'return_by_date': '2024-01-03T00:00:00.000Z',
        'total_cost': 10.0,
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-01T00:00:00.000Z',
      };

      final itemJson = {
        'id': itemId,
        'owner_id': 'o1',
        'title': 'Camera',
        'category': 'Electronics',
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-01T00:00:00.000Z',
      };

      final imageJson = {
        'id': 'img1',
        'item_id': itemId,
        'image_url': 'http://example.com/1.png',
        'position': 0,
      };

      final borrowerJson = {
        'id': 'u1',
        'email': 'u1@example.com',
        'name': 'Borrower',
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-01T00:00:00.000Z',
      };

      final ownerJson = {
        'id': 'o1',
        'email': 'o1@example.com',
        'name': 'Owner',
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-01T00:00:00.000Z',
      };

      FakeHttpRouter.instance.setRoutes([
        FakeHttpRoute(
          matches: (method, uri) =>
              method == 'GET' && uri.path == '/api/bookings/$bookingId/',
          statusCode: 200,
          body: jsonEncode({
            ...bookingJson,
            'item': itemJson,
            'borrower': borrowerJson,
            'owner': ownerJson,
            'image_url': imageJson['image_url'],
          }),
        ),
      ]);

      final result = await repo.getBookingDetails(bookingId);
      expect(result, isNotNull);

      final booking = result!['booking'] as Booking;
      final item = result['item'] as Item?;
      final borrower = result['borrower'] as models.User?;
      final owner = result['owner'] as models.User?;
      final imageUrl = result['imageUrl'] as String?;

      expect(booking.id, bookingId);
      expect(item, isNotNull);
      expect(item!.id, itemId);
      expect(borrower, isNotNull);
      expect(borrower!.id, 'u1');
      expect(owner, isNotNull);
      expect(owner!.id, 'o1');
      expect(imageUrl, 'http://example.com/1.png');
    });

    test('getBookingDetails handles missing related records as null', () async {
      const bookingId = 'b1';
      const itemId = 'i1';

      final bookingJson = {
        'id': bookingId,
        'item_id': itemId,
        'owner_id': 'o1',
        'borrower_id': 'u1',
        'status': BookingStatus.pending.name,
        'deposit_status': DepositStatus.none.name,
        'booking_code': null,
        'start_date': '2024-01-01T00:00:00.000Z',
        'return_by_date': '2024-01-03T00:00:00.000Z',
        'total_cost': 10.0,
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-01T00:00:00.000Z',
      };

      FakeHttpRouter.instance.setRoutes([
        FakeHttpRoute(
          matches: (method, uri) =>
              method == 'GET' && uri.path == '/api/bookings/$bookingId/',
          statusCode: 200,
          body: jsonEncode({...bookingJson}),
        ),
      ]);

      final result = await repo.getBookingDetails(bookingId);
      expect(result, isNotNull);

      expect(result!['booking'], isA<Booking>());
      expect(result['item'], isNull);
      expect(result['borrower'], isNull);
      expect(result['owner'], isNull);
      expect(result['imageUrl'], isNull);
    });

    test('updateBookingStatus issues PATCH to bookings', () async {
      final seen = <String>[];
      FakeHttpRouter.instance
        ..setOnRequest((m, u) => seen.add('$m ${u.path}'))
        ..setRoutes([
          FakeHttpRoute(
            matches: (method, uri) =>
                method == 'PATCH' && uri.path == '/api/bookings/b1/status/',
            statusCode: 204,
            body: '',
          ),
        ]);

      await repo.updateBookingStatus('b1', BookingStatus.accepted);

      expect(seen.any((s) => s == 'PATCH /api/bookings/b1/status/'), isTrue);
    });

    test('updateBookingStatus throws on non-2xx response', () async {
      FakeHttpRouter.instance.setRoutes([
        FakeHttpRoute(
          matches: (method, uri) =>
              method == 'PATCH' && uri.path == '/api/bookings/b1/status/',
          statusCode: 400,
          body: jsonEncode({'message': 'bad update'}),
        ),
      ]);

      expect(
        () => repo.updateBookingStatus('b1', BookingStatus.accepted),
        throwsA(isA<Object>()),
      );
    });

    test('updateDepositStatus issues PATCH to bookings', () async {
      final seen = <String>[];
      FakeHttpRouter.instance
        ..setOnRequest((m, u) => seen.add('$m ${u.path}'))
        ..setRoutes([
          FakeHttpRoute(
            matches: (method, uri) =>
                method == 'PATCH' && uri.path == '/api/bookings/b1/deposit/',
            statusCode: 204,
            body: '',
          ),
        ]);

      await repo.updateDepositStatus('b1', DepositStatus.received);

      expect(seen.any((s) => s == 'PATCH /api/bookings/b1/deposit/'), isTrue);
    });

    test('updateDepositStatus throws on non-2xx response', () async {
      FakeHttpRouter.instance.setRoutes([
        FakeHttpRoute(
          matches: (method, uri) =>
              method == 'PATCH' && uri.path == '/api/bookings/b1/deposit/',
          statusCode: 400,
          body: jsonEncode({'message': 'bad update'}),
        ),
      ]);

      expect(
        () => repo.updateDepositStatus('b1', DepositStatus.received),
        throwsA(isA<Object>()),
      );
    });

    test('generateBookingCode issues PATCH to bookings', () async {
      final seen = <String>[];
      FakeHttpRouter.instance
        ..setOnRequest((m, u) => seen.add('$m ${u.path}'))
        ..setRoutes([
          FakeHttpRoute(
            matches: (method, uri) =>
                method == 'POST' &&
                uri.path == '/api/bookings/b1/generate-code/',
            statusCode: 204,
            body: '',
          ),
        ]);

      await repo.generateBookingCode('b1');

      expect(
        seen.any((s) => s == 'POST /api/bookings/b1/generate-code/'),
        isTrue,
      );
    });

    test('generateBookingCode throws on non-2xx response', () async {
      FakeHttpRouter.instance.setRoutes([
        FakeHttpRoute(
          matches: (method, uri) =>
              method == 'POST' && uri.path == '/api/bookings/b1/generate-code/',
          statusCode: 400,
          body: jsonEncode({'message': 'bad update'}),
        ),
      ]);

      expect(() => repo.generateBookingCode('b1'), throwsA(isA<Object>()));
    });

    test('deleteBooking issues DELETE to bookings', () async {
      final seen = <String>[];
      FakeHttpRouter.instance
        ..setOnRequest((m, u) => seen.add('$m ${u.path}'))
        ..setRoutes([
          FakeHttpRoute(
            matches: (method, uri) =>
                method == 'DELETE' && uri.path == '/api/bookings/b1/',
            statusCode: 204,
            body: '',
          ),
        ]);

      await repo.deleteBooking('b1');

      expect(seen.any((s) => s == 'DELETE /api/bookings/b1/'), isTrue);
    });

    test('deleteBooking throws on non-2xx response', () async {
      FakeHttpRouter.instance.setRoutes([
        FakeHttpRoute(
          matches: (method, uri) =>
              method == 'DELETE' && uri.path == '/api/bookings/b1/',
          statusCode: 400,
          body: jsonEncode({'message': 'bad delete'}),
        ),
      ]);

      expect(() => repo.deleteBooking('b1'), throwsA(isA<Object>()));
    });

    test(
      'getIncomingRequests maps bookings with item/borrower/image',
      () async {
        final bookings = [
          {
            'id': 'b1',
            'item_id': 'i1',
            'owner_id': 'o1',
            'borrower_id': 'u1',
            'status': BookingStatus.pending.name,
            'deposit_status': DepositStatus.none.name,
            'booking_code': null,
            'start_date': '2024-01-01T00:00:00.000Z',
            'return_by_date': '2024-01-03T00:00:00.000Z',
            'total_cost': 10.0,
            'created_at': '2024-01-01T00:00:00.000Z',
            'updated_at': '2024-01-01T00:00:00.000Z',
          },
          {
            'id': 'b2',
            'item_id': 'i2',
            'owner_id': 'o1',
            'borrower_id': 'u2',
            'status': BookingStatus.accepted.name,
            'deposit_status': DepositStatus.none.name,
            'booking_code': null,
            'start_date': '2024-02-01T00:00:00.000Z',
            'return_by_date': '2024-02-03T00:00:00.000Z',
            'total_cost': 20.0,
            'created_at': '2024-02-01T00:00:00.000Z',
            'updated_at': '2024-02-01T00:00:00.000Z',
          },
        ];

        FakeHttpRouter.instance.setRoutes([
          FakeHttpRoute(
            matches: (method, uri) =>
                method == 'GET' &&
                uri.path == '/api/bookings/incoming/' &&
                uri.queryParameters['owner_id'] == 'o1',
            statusCode: 200,
            body: jsonEncode([
              {
                ...bookings[0],
                'item': {
                  'id': 'i1',
                  'owner_id': 'o1',
                  'title': 'Camera',
                  'category': 'Electronics',
                  'created_at': '2024-01-01T00:00:00.000Z',
                  'updated_at': '2024-01-01T00:00:00.000Z',
                },
                'borrower': {
                  'id': 'u1',
                  'email': 'u1@example.com',
                  'name': 'Borrower 1',
                  'created_at': '2024-01-01T00:00:00.000Z',
                  'updated_at': '2024-01-01T00:00:00.000Z',
                },
                'owner': {
                  'id': 'o1',
                  'email': 'o1@example.com',
                  'name': 'Owner',
                  'created_at': '2024-01-01T00:00:00.000Z',
                  'updated_at': '2024-01-01T00:00:00.000Z',
                },
                'image_url': 'http://example.com/i1.png',
              },
              {
                ...bookings[1],
                'item': {
                  'id': 'i2',
                  'owner_id': 'o1',
                  'title': 'Bike',
                  'category': 'Vehicles',
                  'created_at': '2024-02-01T00:00:00.000Z',
                  'updated_at': '2024-02-01T00:00:00.000Z',
                },
                'borrower': {
                  'id': 'u2',
                  'email': 'u2@example.com',
                  'name': 'Borrower 2',
                  'created_at': '2024-02-01T00:00:00.000Z',
                  'updated_at': '2024-02-01T00:00:00.000Z',
                },
                'owner': {
                  'id': 'o1',
                  'email': 'o1@example.com',
                  'name': 'Owner',
                  'created_at': '2024-01-01T00:00:00.000Z',
                  'updated_at': '2024-01-01T00:00:00.000Z',
                },
                'image_url': 'http://example.com/i2.png',
              },
            ]),
          ),
        ]);

        final results = await repo.getIncomingRequests('o1');
        expect(results, hasLength(2));

        final first = results.first;
        expect((first['booking'] as Booking).id, 'b1');
        expect((first['item'] as Item?)?.id, 'i1');
        expect((first['borrower'] as models.User?)?.id, 'u1');
        expect(first['imageUrl'], 'http://example.com/i1.png');
      },
    );

    test('getMyRequests maps bookings with item/owner/image', () async {
      final bookings = [
        {
          'id': 'b1',
          'item_id': 'i1',
          'owner_id': 'o1',
          'borrower_id': 'u1',
          'status': BookingStatus.pending.name,
          'deposit_status': DepositStatus.none.name,
          'booking_code': null,
          'start_date': '2024-01-01T00:00:00.000Z',
          'return_by_date': '2024-01-03T00:00:00.000Z',
          'total_cost': 10.0,
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
        },
      ];

      FakeHttpRouter.instance.setRoutes([
        FakeHttpRoute(
          matches: (method, uri) =>
              method == 'GET' &&
              uri.path == '/api/bookings/my-requests/' &&
              uri.queryParameters['borrower_id'] == 'u1',
          statusCode: 200,
          body: jsonEncode([
            {
              ...bookings[0],
              'item': {
                'id': 'i1',
                'owner_id': 'o1',
                'title': 'Camera',
                'category': 'Electronics',
                'created_at': '2024-01-01T00:00:00.000Z',
                'updated_at': '2024-01-01T00:00:00.000Z',
              },
              'owner': {
                'id': 'o1',
                'email': 'o1@example.com',
                'name': 'Owner 1',
                'created_at': '2024-01-01T00:00:00.000Z',
                'updated_at': '2024-01-01T00:00:00.000Z',
              },
              'borrower': {
                'id': 'u1',
                'email': 'u1@example.com',
                'name': 'Borrower 1',
                'created_at': '2024-01-01T00:00:00.000Z',
                'updated_at': '2024-01-01T00:00:00.000Z',
              },
              'image_url': 'http://example.com/i1.png',
            },
          ]),
        ),
      ]);

      final results = await repo.getMyRequests('u1');
      expect(results, hasLength(1));

      final first = results.first;
      expect((first['booking'] as Booking).borrowerId, 'u1');
      expect((first['item'] as Item?)?.id, 'i1');
      expect((first['owner'] as models.User?)?.id, 'o1');
      expect(first['imageUrl'], 'http://example.com/i1.png');
    });

    test('getUserTransactions sets isBorrower correctly', () async {
      const userId = 'u1';

      final bookings = [
        {
          'id': 'b1',
          'item_id': 'i1',
          'owner_id': 'o1',
          'borrower_id': userId,
          'status': BookingStatus.completed.name,
          'deposit_status': DepositStatus.returned.name,
          'booking_code': null,
          'start_date': '2024-01-01T00:00:00.000Z',
          'return_by_date': '2024-01-03T00:00:00.000Z',
          'total_cost': 10.0,
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
        },
        {
          'id': 'b2',
          'item_id': 'i2',
          'owner_id': userId,
          'borrower_id': 'u2',
          'status': BookingStatus.closed.name,
          'deposit_status': DepositStatus.kept.name,
          'booking_code': null,
          'start_date': '2024-02-01T00:00:00.000Z',
          'return_by_date': '2024-02-03T00:00:00.000Z',
          'total_cost': 20.0,
          'created_at': '2024-02-01T00:00:00.000Z',
          'updated_at': '2024-02-01T00:00:00.000Z',
        },
      ];

      FakeHttpRouter.instance.setRoutes([
        FakeHttpRoute(
          matches: (method, uri) =>
              method == 'GET' &&
              uri.path == '/api/bookings/user-transactions/' &&
              uri.queryParameters['user_id'] == userId &&
              uri.queryParameters['limit'] == '10',
          statusCode: 200,
          body: jsonEncode([
            {
              ...bookings[0],
              'item': {
                'id': 'i1',
                'owner_id': 'o1',
                'title': 'Camera',
                'category': 'Electronics',
                'created_at': '2024-01-01T00:00:00.000Z',
                'updated_at': '2024-01-01T00:00:00.000Z',
              },
              'image_url': 'http://example.com/i1.png',
              'is_borrower': true,
            },
            {
              ...bookings[1],
              'item': {
                'id': 'i2',
                'owner_id': userId,
                'title': 'Bike',
                'category': 'Vehicles',
                'created_at': '2024-02-01T00:00:00.000Z',
                'updated_at': '2024-02-01T00:00:00.000Z',
              },
              'image_url': 'http://example.com/i2.png',
              'is_borrower': false,
            },
          ]),
        ),
      ]);

      final results = await repo.getUserTransactions(userId);
      expect(results, hasLength(2));

      expect(results[0]['isBorrower'], isTrue);
      expect(results[1]['isBorrower'], isFalse);
    });
  });
}

// No shared matchers needed; tests stub exact /api/bookings routes.
