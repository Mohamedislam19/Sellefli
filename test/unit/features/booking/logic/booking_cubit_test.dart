import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sellefli/src/data/models/booking_model.dart';
import 'package:sellefli/src/features/Booking/logic/booking_cubit.dart';

import '../../../../helpers/fake_http_overrides.dart';
import '../../../../helpers/test_bootstrap.dart';

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

  group('BookingCubit (unit)', () {
    blocTest<BookingCubit, BookingState>(
      'fetchBookingDetails: emits [Loading, Error("Booking not found")] when booking missing',
      setUp: () {
        FakeHttpRouter.instance.setRoutes([
          // Supabase PostgREST: return an empty list for no rows.
          FakeHttpRoute(
            matches: (method, uri) =>
                method == 'GET' &&
                uri.path == '/rest/v1/bookings' &&
                uri.queryParameters['id'] == 'eq.missing-booking',
            statusCode: 200,
            body: '[]',
          ),
        ]);
      },
      tearDown: () {
        FakeHttpRouter.instance
          ..clearRoutes()
          ..clearOnRequest();
      },
      build: () => BookingCubit(),
      act: (cubit) => cubit.fetchBookingDetails('missing-booking'),
      expect: () => [
        isA<BookingLoading>(),
        isA<BookingError>().having((s) => s.error, 'error', 'Booking not found'),
      ],
    );

    blocTest<BookingCubit, BookingState>(
      'markDepositReceived: emits Error when booking not in accepted/none state',
      setUp: () {
        final bookingJson = {
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
        };

        FakeHttpRouter.instance.setRoutes([
          FakeHttpRoute(
            matches: (method, uri) =>
                method == 'GET' && uri.path == '/rest/v1/bookings',
            statusCode: 200,
            body: jsonEncode([bookingJson]),
            headers: const {
              // PostgREST single-object response
              'content-type': 'application/json; charset=utf-8',
            },
          ),
          // These are called for related fetches (items/users/images). Returning
          // 406 makes `.maybeSingle()` resolve to null.
          FakeHttpRoute(
            matches: (method, uri) =>
                method == 'GET' &&
                (uri.path == '/rest/v1/items' ||
                    uri.path == '/rest/v1/users' ||
                    uri.path == '/rest/v1/item_images'),
            statusCode: 200,
            body: '[]',
          ),
        ]);
      },
      tearDown: () => FakeHttpRouter.instance.clearRoutes(),
      build: () => BookingCubit(),
      act: (cubit) => cubit.markDepositReceived('b1'),
      expect: () => [
        isA<BookingActionLoading>(),
        isA<BookingError>().having(
          (s) => s.error,
          'error',
          'Cannot mark deposit received in current state',
        ),
      ],
    );

    blocTest<BookingCubit, BookingState>(
      'markDepositReceived: emits Success when accepted/none and updates succeed',
      setUp: () {
        final bookingJson = {
          'id': 'b1',
          'item_id': 'i1',
          'owner_id': 'o1',
          'borrower_id': 'u1',
          'status': BookingStatus.accepted.name,
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
                method == 'GET' && uri.path == '/rest/v1/bookings',
            statusCode: 200,
            body: jsonEncode([bookingJson]),
          ),
          FakeHttpRoute(
            matches: (method, uri) =>
                method == 'GET' &&
                (uri.path == '/rest/v1/items' ||
                    uri.path == '/rest/v1/users' ||
                    uri.path == '/rest/v1/item_images'),
            statusCode: 200,
            body: '[]',
          ),
          FakeHttpRoute(
            matches: (method, uri) =>
                (method == 'PATCH' || method == 'POST') &&
                uri.path == '/rest/v1/bookings',
            statusCode: 204,
            body: '',
            headers: const {'content-type': 'application/json; charset=utf-8'},
          ),
        ]);
      },
      tearDown: () => FakeHttpRouter.instance.clearRoutes(),
      build: () => BookingCubit(),
      act: (cubit) => cubit.markDepositReceived('b1'),
      expect: () => [
        isA<BookingActionLoading>(),
        isA<BookingActionSuccess>().having(
          (s) => s.message,
          'message',
          'Deposit marked as received',
        ),
      ],
    );

    blocTest<BookingCubit, BookingState>(
      'acceptBooking: emits Success when updates succeed',
      setUp: () {
        FakeHttpRouter.instance.setRoutes([
          FakeHttpRoute(
            matches: (method, uri) =>
                (method == 'PATCH' || method == 'POST') &&
                uri.path == '/rest/v1/bookings',
            statusCode: 204,
            body: '',
          ),
        ]);
      },
      tearDown: () => FakeHttpRouter.instance.clearRoutes(),
      build: () => BookingCubit(),
      act: (cubit) => cubit.acceptBooking('b1'),
      expect: () => [
        isA<BookingActionLoading>(),
        isA<BookingActionSuccess>().having(
          (s) => s.message,
          'message',
          'Booking accepted successfully',
        ),
      ],
    );

    blocTest<BookingCubit, BookingState>(
      'acceptBooking: emits Error when update fails',
      setUp: () {
        FakeHttpRouter.instance.setRoutes([
          FakeHttpRoute(
            matches: (method, uri) =>
                (method == 'PATCH' || method == 'POST') &&
                uri.path == '/rest/v1/bookings',
            statusCode: 400,
            body: jsonEncode({'message': 'bad update'}),
          ),
        ]);
      },
      tearDown: () => FakeHttpRouter.instance.clearRoutes(),
      build: () => BookingCubit(),
      act: (cubit) => cubit.acceptBooking('b1'),
      expect: () => [
        isA<BookingActionLoading>(),
        isA<BookingError>(),
      ],
    );

    blocTest<BookingCubit, BookingState>(
      'declineBooking: emits Success when update succeeds',
      setUp: () {
        FakeHttpRouter.instance.setRoutes([
          const FakeHttpRoute(
            matches: _matchPatchBookings,
            statusCode: 204,
            body: '',
          ),
        ]);
      },
      tearDown: () => FakeHttpRouter.instance.clearRoutes(),
      build: () => BookingCubit(),
      act: (cubit) => cubit.declineBooking('b1'),
      expect: () => [
        isA<BookingActionLoading>(),
        isA<BookingActionSuccess>()
            .having((s) => s.message, 'message', 'Booking declined'),
      ],
    );

    blocTest<BookingCubit, BookingState>(
      'keepDeposit: emits Success when updates succeed',
      setUp: () {
        FakeHttpRouter.instance.setRoutes([
          const FakeHttpRoute(
            matches: _matchPatchBookings,
            statusCode: 204,
            body: '',
          ),
        ]);
      },
      tearDown: () => FakeHttpRouter.instance.clearRoutes(),
      build: () => BookingCubit(),
      act: (cubit) => cubit.keepDeposit('b1'),
      expect: () => [
        isA<BookingActionLoading>(),
        isA<BookingActionSuccess>()
            .having((s) => s.message, 'message', 'Deposit kept'),
      ],
    );

    blocTest<BookingCubit, BookingState>(
      'markDepositReturned: emits Success when updates succeed',
      setUp: () {
        FakeHttpRouter.instance.setRoutes([
          const FakeHttpRoute(
            matches: _matchPatchBookings,
            statusCode: 204,
            body: '',
          ),
        ]);
      },
      tearDown: () => FakeHttpRouter.instance.clearRoutes(),
      build: () => BookingCubit(),
      act: (cubit) => cubit.markDepositReturned('b1'),
      expect: () => [
        isA<BookingActionLoading>(),
        isA<BookingActionSuccess>()
            .having((s) => s.message, 'message', 'Deposit marked as returned'),
      ],
    );

    blocTest<BookingCubit, BookingState>(
      'markDepositReturned: emits Error when update fails',
      setUp: () {
        FakeHttpRouter.instance.setRoutes([
          FakeHttpRoute(
            matches: _matchPatchBookings,
            statusCode: 400,
            body: jsonEncode({'message': 'bad update'}),
          ),
        ]);
      },
      tearDown: () => FakeHttpRouter.instance.clearRoutes(),
      build: () => BookingCubit(),
      act: (cubit) => cubit.markDepositReturned('b1'),
      expect: () => [
        isA<BookingActionLoading>(),
        isA<BookingError>(),
      ],
    );

    blocTest<BookingCubit, BookingState>(
      'createBookingRequest: emits Success when repository create succeeds',
      setUp: () {
        FakeHttpRouter.instance.setRoutes([
          FakeHttpRoute(
            matches: (method, uri) =>
                method == 'POST' && uri.path == '/rest/v1/bookings',
            statusCode: 201,
            body: jsonEncode({'id': 'b1'}),
          ),
        ]);
      },
      tearDown: () => FakeHttpRouter.instance.clearRoutes(),
      build: () => BookingCubit(),
      act: (cubit) => cubit.createBookingRequest(
        itemId: 'i1',
        ownerId: 'o1',
        borrowerId: 'u1',
        startDate: DateTime.parse('2024-01-01T00:00:00.000Z'),
        returnByDate: DateTime.parse('2024-01-03T00:00:00.000Z'),
        totalCost: 10.0,
      ),
      expect: () => [
        isA<BookingActionLoading>(),
        isA<BookingActionSuccess>().having(
          (s) => s.message,
          'message',
          'Booking request sent successfully',
        ),
      ],
    );

    blocTest<BookingCubit, BookingState>(
      'submitRating: emits Success when Django API returns 2xx',
      setUp: () {
        FakeHttpRouter.instance.setRoutes([
          const FakeHttpRoute(
            matches: _matchPostRatings,
            statusCode: 201,
            body: '{}',
          ),
        ]);
      },
      tearDown: () => FakeHttpRouter.instance.clearRoutes(),
      build: () => BookingCubit(),
      act: (cubit) => cubit.submitRating(
        bookingId: 'b1',
        raterUserId: 'u1',
        targetUserId: 'o1',
        stars: 5,
      ),
      expect: () => [
        isA<BookingActionLoading>(),
        isA<BookingActionSuccess>().having(
          (s) => s.message,
          'message',
          'Rating submitted successfully',
        ),
      ],
    );

    blocTest<BookingCubit, BookingState>(
      'submitRating: emits Error when Django API returns non-2xx',
      setUp: () {
        FakeHttpRouter.instance.setRoutes([
          FakeHttpRoute(
            matches: _matchPostRatings,
            statusCode: 400,
            body: jsonEncode({'detail': 'Bad rating'}),
          ),
        ]);
      },
      tearDown: () => FakeHttpRouter.instance.clearRoutes(),
      build: () => BookingCubit(),
      act: (cubit) => cubit.submitRating(
        bookingId: 'b1',
        raterUserId: 'u1',
        targetUserId: 'o1',
        stars: 0,
      ),
      expect: () => [
        isA<BookingActionLoading>(),
        isA<BookingError>().having(
          (s) => s.error,
          'error',
          contains('Bad rating'),
        ),
      ],
    );

    test('hasAlreadyRated returns parsed true/false', () async {
      FakeHttpRouter.instance.setRoutes([
        FakeHttpRoute(
          matches: _matchGetHasRated,
          statusCode: 200,
          body: jsonEncode({'has_rated': true}),
        ),
      ]);

      final cubit = BookingCubit();
      addTearDown(cubit.close);

      final hasRated = await cubit.hasAlreadyRated(
        bookingId: 'b1',
        raterUserId: 'u1',
      );
      expect(hasRated, isTrue);

      FakeHttpRouter.instance.setRoutes([
        FakeHttpRoute(
          matches: _matchGetHasRated,
          statusCode: 200,
          body: jsonEncode({'has_rated': false}),
        ),
      ]);

      final hasRated2 = await cubit.hasAlreadyRated(
        bookingId: 'b2',
        raterUserId: 'u1',
      );
      expect(hasRated2, isFalse);
    });
  });
}

bool _matchPatchBookings(String method, Uri uri) {
  return method == 'PATCH' && uri.path == '/rest/v1/bookings';
}

bool _matchPostRatings(String method, Uri uri) {
  return method == 'POST' && uri.path == '/api/ratings/';
}

bool _matchGetHasRated(String method, Uri uri) {
  return method == 'GET' && uri.path == '/api/ratings/has-rated/';
}
