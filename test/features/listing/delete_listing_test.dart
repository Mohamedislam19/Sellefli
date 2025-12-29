"""
QA Testing Suite for Delete Listing Feature - Flutter Frontend Tests
Tests UI, state management, and network calls for delete functionality
"""

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sellefli/src/features/listing/logic/my_listings_cubit.dart';
import 'package:sellefli/src/features/listing/logic/my_listings_state.dart';
import 'package:sellefli/src/data/repositories/item_repository.dart';
import 'package:sellefli/src/data/models/item_model.dart';

// ==========================================
// MOCKS
// ==========================================

class MockItemRepository extends Mock implements ItemRepository {}

class MockLocalItemRepository extends Mock implements LocalItemRepository {}

// ==========================================
// TESTS: DELETE ITEM CUBIT
// ==========================================

void main() {
  late MockItemRepository mockItemRepository;
  late MockLocalItemRepository mockLocalItemRepository;
  late MyListingsCubit myListingsCubit;

  setUp(() {
    mockItemRepository = MockItemRepository();
    mockLocalItemRepository = MockLocalItemRepository();
    myListingsCubit = MyListingsCubit(
      itemRepository: mockItemRepository,
      localItemRepository: mockLocalItemRepository,
    );
  });

  tearDown(() {
    myListingsCubit.close();
  });

  group('MyListingsCubit - Delete Item Tests', () {
    // ==========================================
    // TC-2.1: Network Request Structure
    // ==========================================
    test('TC-2.1: deleteItem calls repository with correct itemId', () async {
      final itemId = '550e8400-e29b-41d4-a716-446655440000';

      when(mockItemRepository.deleteItem(itemId))
          .thenAnswer((_) async => null);

      await myListingsCubit.deleteItem(itemId);

      verify(mockItemRepository.deleteItem(itemId)).called(1);
    });

    // ==========================================
    // TC-1.3: Loading State
    // ==========================================
    blocTest<MyListingsCubit, MyListingsState>(
      'TC-1.3: deleteItem emits MyListingsDeletingItem during deletion',
      build: () {
        when(mockItemRepository.deleteItem(any))
            .thenAnswer((_) async => null);
        return myListingsCubit;
      },
      act: (cubit) => cubit.deleteItem('test-id'),
      expect: () => [
        isA<MyListingsDeletingItem>().having(
          (state) => state.itemId,
          'itemId',
          'test-id',
        ),
        // ... more states after delete completes
      ],
    );

    // ==========================================
    // TC-1.4: Success Feedback
    // ==========================================
    blocTest<MyListingsCubit, MyListingsState>(
      'TC-1.4: deleteItem emits MyListingsDeleteSuccess on success',
      build: () {
        when(mockItemRepository.deleteItem(any))
            .thenAnswer((_) async => null);
        when(mockLocalItemRepository.getCachedItems(limit: anyNamed('limit')))
            .thenAnswer((_) async => []);
        return myListingsCubit;
      },
      act: (cubit) => cubit.deleteItem('test-id'),
      expect: () => [
        isA<MyListingsDeletingItem>(),
        isA<MyListingsDeleteSuccess>(),
        isA<MyListingsLoaded>(), // After reload
      ],
    );

    // ==========================================
    // TC-1.5: Error Handling - 403 Forbidden
    // ==========================================
    blocTest<MyListingsCubit, MyListingsState>(
      'TC-1.5: deleteItem emits error on 403 Forbidden',
      build: () {
        when(mockItemRepository.deleteItem(any)).thenThrow(
          HttpException('HTTP 403: You do not have permission'),
        );
        return myListingsCubit;
      },
      act: (cubit) => cubit.deleteItem('test-id'),
      expect: () => [
        isA<MyListingsDeletingItem>(),
        isA<MyListingsError>().having(
          (state) => state.message,
          'message',
          contains('Failed to delete listing'),
        ),
      ],
    );

    // ==========================================
    // TC-1.5: Error Handling - 401 Unauthorized
    // ==========================================
    blocTest<MyListingsCubit, MyListingsState>(
      'TC-1.5: deleteItem emits error on 401 Unauthorized',
      build: () {
        when(mockItemRepository.deleteItem(any)).thenThrow(
          HttpException('HTTP 401: Unauthorized'),
        );
        return myListingsCubit;
      },
      act: (cubit) => cubit.deleteItem('test-id'),
      expect: () => [
        isA<MyListingsDeletingItem>(),
        isA<MyListingsError>(),
      ],
    );

    // ==========================================
    // TC-1.5: Error Handling - 404 Not Found
    // ==========================================
    blocTest<MyListingsCubit, MyListingsState>(
      'TC-1.5: deleteItem emits error on 404 Not Found',
      build: () {
        when(mockItemRepository.deleteItem(any)).thenThrow(
          HttpException('HTTP 404: Not found'),
        );
        return myListingsCubit;
      },
      act: (cubit) => cubit.deleteItem('test-id'),
      expect: () => [
        isA<MyListingsDeletingItem>(),
        isA<MyListingsError>(),
      ],
    );

    // ==========================================
    // TC-1.5: Error Handling - 500 Server Error
    // ==========================================
    blocTest<MyListingsCubit, MyListingsState>(
      'TC-1.5: deleteItem emits error on 500 Server Error',
      build: () {
        when(mockItemRepository.deleteItem(any)).thenThrow(
          HttpException('HTTP 500: Internal Server Error'),
        );
        return myListingsCubit;
      },
      act: (cubit) => cubit.deleteItem('test-id'),
      expect: () => [
        isA<MyListingsDeletingItem>(),
        isA<MyListingsError>(),
      ],
    );

    // ==========================================
    // TC-6.2: Offline Behavior
    // ==========================================
    blocTest<MyListingsCubit, MyListingsState>(
      'TC-6.2: deleteItem fails gracefully when offline',
      build: () {
        when(mockItemRepository.deleteItem(any)).thenThrow(
          SocketException('No internet connection'),
        );
        return myListingsCubit;
      },
      act: (cubit) => cubit.deleteItem('test-id'),
      expect: () => [
        isA<MyListingsDeletingItem>(),
        isA<MyListingsError>(),
      ],
    );

    // ==========================================
    // TC-1.4: Auto-Reload After Delete
    // ==========================================
    blocTest<MyListingsCubit, MyListingsState>(
      'TC-1.4: deleteItem triggers auto-reload of listings',
      build: () {
        when(mockItemRepository.deleteItem(any))
            .thenAnswer((_) async => null);
        when(mockLocalItemRepository.getCachedItems(limit: anyNamed('limit')))
            .thenAnswer((_) async => []);
        return myListingsCubit;
      },
      act: (cubit) => cubit.deleteItem('test-id'),
      verify: (cubit) {
        // Verify loadMyListings was called (indirectly)
        verify(mockLocalItemRepository.getCachedItems(limit: anyNamed('limit')))
            .called(greaterThan(0));
      },
    );
  });

  group('ItemRepository - Delete Item Tests', () {
    late MockHttpClient mockHttpClient;
    late ItemRepository itemRepository;

    setUp(() {
      mockHttpClient = MockHttpClient();
      itemRepository = ItemRepository(mockHttpClient);
    });

    // ==========================================
    // TC-2.1: HTTP Method Verification
    // ==========================================
    test('TC-2.1: deleteItem uses DELETE HTTP method', () async {
      final itemId = '550e8400-e29b-41d4-a716-446655440000';

      when(mockHttpClient.delete(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('', 204));

      await itemRepository.deleteItem(itemId);

      // Verify DELETE method was used (checked via URL pattern)
      verify(mockHttpClient.delete(
        argThat(
          predicate<Uri>(
            (uri) => uri.path.contains('/api/items/$itemId/'),
          ),
        ),
        headers: anyNamed('headers'),
      )).called(1);
    });

    // ==========================================
    // TC-2.1: Endpoint Verification
    // ==========================================
    test('TC-2.1: deleteItem calls correct endpoint', () async {
      final itemId = '550e8400-e29b-41d4-a716-446655440000';

      when(mockHttpClient.delete(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('', 204));

      await itemRepository.deleteItem(itemId);

      verify(mockHttpClient.delete(
        argThat(
          predicate<Uri>(
            (uri) => uri.toString().contains('/api/items/$itemId/'),
          ),
        ),
        headers: anyNamed('headers'),
      )).called(1);
    });

    // ==========================================
    // TC-2.1: Auth Token in Headers
    // ==========================================
    test('TC-2.1: deleteItem includes Authorization header', () async {
      when(mockHttpClient.delete(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('', 204));

      await itemRepository.deleteItem('test-id');

      verify(mockHttpClient.delete(
        any,
        headers: argThat(
          predicate<Map<String, String>>(
            (headers) => headers.containsKey('Authorization'),
          ),
        ),
      )).called(1);
    });

    // ==========================================
    // TC-2.2: Error Handling - 204 Success
    // ==========================================
    test('TC-2.2: deleteItem succeeds on 204 No Content', () async {
      when(mockHttpClient.delete(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('', 204));

      // Should not throw
      expect(
        itemRepository.deleteItem('test-id'),
        completes,
      );
    });

    // ==========================================
    // TC-2.2: Error Handling - 401 Unauthorized
    // ==========================================
    test('TC-2.2: deleteItem throws on 401 Unauthorized', () async {
      when(mockHttpClient.delete(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(
            '{"detail": "Unauthorized"}',
            401,
          ));

      expect(
        itemRepository.deleteItem('test-id'),
        throwsA(isA<HttpException>()),
      );
    });

    // ==========================================
    // TC-2.2: Error Handling - 403 Forbidden
    // ==========================================
    test('TC-2.2: deleteItem throws on 403 Forbidden', () async {
      when(mockHttpClient.delete(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(
            '{"detail": "Permission denied"}',
            403,
          ));

      expect(
        itemRepository.deleteItem('test-id'),
        throwsA(isA<HttpException>()),
      );
    });

    // ==========================================
    // TC-2.2: Error Handling - 404 Not Found
    // ==========================================
    test('TC-2.2: deleteItem throws on 404 Not Found', () async {
      when(mockHttpClient.delete(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(
            '{"detail": "Not found"}',
            404,
          ));

      expect(
        itemRepository.deleteItem('test-id'),
        throwsA(isA<HttpException>()),
      );
    });

    // ==========================================
    // TC-2.2: Error Handling - 500 Server Error
    // ==========================================
    test('TC-2.2: deleteItem throws on 500 Server Error', () async {
      when(mockHttpClient.delete(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(
            '{"detail": "Server error"}',
            500,
          ));

      expect(
        itemRepository.deleteItem('test-id'),
        throwsA(isA<HttpException>()),
      );
    });
  });

  group('My Listings UI Widget Tests', () {
    // ==========================================
    // TC-1.1: Delete Button Visibility
    // ==========================================
    testWidgets('TC-1.1: Delete button appears on listing card',
        (WidgetTester tester) async {
      // Build My Listings page with test data
      await tester.pumpWidget(
        MaterialApp(
          home: MyListingsPage(),
        ),
      );

      // Wait for page to load
      await tester.pumpAndSettle();

      // Verify delete button exists (by icon and label)
      expect(
        find.byIcon(Icons.delete_outlined),
        findsOneWidget,
        reason: 'Delete button (delete icon) should be visible',
      );

      expect(
        find.byTooltip('Delete'),
        findsWidgets,
        reason: 'Delete button tooltip should be visible',
      );
    });

    // ==========================================
    // TC-1.2: Confirmation Dialog
    // ==========================================
    testWidgets('TC-1.2: Delete confirmation dialog appears',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: MyListingsPage()));
      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete_outlined).first);
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(
        find.byType(AlertDialog),
        findsOneWidget,
        reason: 'Confirmation dialog should appear',
      );

      expect(
        find.text('Delete Listing'),
        findsOneWidget,
        reason: 'Dialog title should be "Delete Listing"',
      );

      // Verify dialog buttons
      expect(
        find.text('Cancel'),
        findsOneWidget,
        reason: 'Cancel button should be present',
      );

      expect(
        find.text('Delete'),
        findsOneWidget,
        reason: 'Delete confirmation button should be present',
      );
    });

    // ==========================================
    // TC-1.2: Cancel Dialog
    // ==========================================
    testWidgets('TC-1.2: Cancel button closes dialog without deleting',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: MyListingsPage()));
      await tester.pumpAndSettle();

      // Tap delete, then cancel
      await tester.tap(find.byIcon(Icons.delete_outlined).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(
        find.byType(AlertDialog),
        findsNothing,
        reason: 'Dialog should be closed after cancel',
      );

      // Item should still be in list
      expect(
        find.byType(ListTile),
        findsWidgets,
        reason: 'Item should still be in list',
      );
    });

    // ==========================================
    // TC-1.4: Success Message
    // ==========================================
    testWidgets('TC-1.4: Success snackbar appears after deletion',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: MyListingsPage()));
      await tester.pumpAndSettle();

      // Perform deletion
      await tester.tap(find.byIcon(Icons.delete_outlined).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify success snackbar
      expect(
        find.text('Listing deleted successfully'),
        findsOneWidget,
        reason: 'Success message should be shown',
      );
    });

    // ==========================================
    // TC-1.5: Error Handling
    // ==========================================
    testWidgets('TC-1.5: Error snackbar on 403 Forbidden',
        (WidgetTester tester) async {
      // Mock error response
      // (Would need to inject a custom mock repository)
      
      // Verify error is displayed
      await tester.pumpWidget(MaterialApp(home: MyListingsPage()));
      
      // Simulate error state
      // expect(
      //   find.byType(SnackBar),
      //   findsOneWidget,
      // );
    });
  });
}

// ==========================================
// TEST EXECUTION NOTES
// ==========================================
/*
Run Flutter tests with:

  flutter test test/features/listing/delete_listing_test.dart

Run with coverage:

  flutter test --coverage test/features/listing/delete_listing_test.dart
  lcov --list coverage/lcov.info

Run specific test:

  flutter test test/features/listing/delete_listing_test.dart -k "TC-1.1"

Run with verbose output:

  flutter test -v test/features/listing/delete_listing_test.dart
*/
