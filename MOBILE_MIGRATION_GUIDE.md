# Mobile App HTTP Migration: Supabase → Django REST API

This document outlines all changes required to migrate the Flutter mobile app from Supabase direct access to Django HTTP API endpoints.

---

## 1. ITEM REPOSITORY MIGRATION

### File: `lib/src/data/repositories/item_repository.dart`

#### Change 1: Update Base URL to Django Backend

**Current** (Supabase):
```dart
static const String _baseUrl = String.fromEnvironment(
  'DJANGO_BASE_URL',
  defaultValue: 'http://localhost:8000',
);
```

✅ This is already correct! The repository is HTTP-based, not Supabase SDK-based.

#### Change 2: Update getItems() Request

The current implementation is already using HTTP! Verify it sends correct headers and parameters:

```dart
// Current: Correct HTTP-based implementation
Future<List<Item>> getItems({
  required int page,
  required int pageSize,
  String? excludeUserId,
  List<String>? categories,
  String? searchQuery,
}) async {
  final query = <String, dynamic>{
    'page': page.toString(),
    'page_size': pageSize.toString(),
  };
  if (excludeUserId != null) {
    query['excludeUserId'] = excludeUserId;
  }
  if (categories != null && categories.isNotEmpty && !categories.contains('All')) {
    query['categories'] = categories.join(',');
  }
  if (searchQuery != null && searchQuery.isNotEmpty) {
    query['searchQuery'] = searchQuery;
  }

  final res = await _client.get(_uri('/api/items/', query));
  return _decode<List<Item>>(res, (body) {
    final results = body is Map<String, dynamic> ? body['results'] : body;
    return (results as List)
        .map((json) => Item.fromJson(json as Map<String, dynamic>))
        .toList();
  });
}
```

✅ **Status**: Already compatible with Django!

---

## 2. PROFILE REPOSITORY MIGRATION

### File: `lib/src/data/repositories/profile_repository.dart`

This currently uses Supabase SDK. Must switch to HTTP.

#### Current Implementation (Supabase):
```dart
class ProfileRepository {
  final SupabaseClient _supabase;

  Future<models.User?> getMyProfile() async {
    final userId = _supabase.auth.currentUser?.id;  // ← Supabase auth
    final data = await _supabase
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return data == null ? null : models.User.fromJson(data);
  }
}
```

#### New Implementation (Django HTTP):

```dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileRepository {
  /// Configure your backend base URL
  static const String _baseUrl = String.fromEnvironment(
    'DJANGO_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  final http.Client _client;

  ProfileRepository([Object? client])
    : _client = client is http.Client ? client : http.Client();

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('$_baseUrl$path');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...query.map((k, v) => MapEntry(k, v?.toString() ?? '')),
      },
    );
  }

  Map<String, String> get _jsonHeaders => {
    HttpHeaders.contentTypeHeader: 'application/json',
  };

  T _decode<T>(http.Response res, T Function(dynamic) mapper) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = res.body.isEmpty ? null : jsonDecode(res.body);
      return mapper(body);
    }
    throw HttpException('HTTP ${res.statusCode}: ${res.body}');
  }

  /// Get user profile by ID
  Future<models.User?> getProfileById(String userId) async {
    try {
      final res = await _client.get(_uri('/api/users/$userId/'));
      return _decode<models.User?>(res, (body) {
        if (body == null) return null;
        return models.User.fromJson(body as Map<String, dynamic>);
      });
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  /// Get current user profile (requires user ID from auth context)
  /// Usage: Pass current user ID from your auth provider
  Future<models.User?> getMyProfile(String currentUserId) async {
    return getProfileById(currentUserId);
  }

  /// Update user profile
  Future<models.User?> updateProfile({
    required String userId,
    String? username,
    String? phone,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (username != null && username.isNotEmpty) {
      updates['username'] = username;
    }
    if (phone != null && phone.isNotEmpty) {
      updates['phone'] = phone;
    }
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      updates['avatar_url'] = avatarUrl;
    }

    try {
      final res = await _client.patch(
        _uri('/api/users/$userId/'),
        headers: _jsonHeaders,
        body: jsonEncode(updates),
      );

      return _decode<models.User?>(res, (body) {
        if (body == null) return null;
        return models.User.fromJson(body as Map<String, dynamic>);
      });
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Upload avatar (requires storage setup)
  /// For now, pass image URL directly to updateProfile()
  Future<models.User?> updateProfileWithAvatar({
    required String userId,
    required String avatarUrl,
    String? username,
    String? phone,
  }) async {
    return updateProfile(
      userId: userId,
      username: username,
      phone: phone,
      avatarUrl: avatarUrl,
    );
  }
}
```

---

## 3. BOOKING REPOSITORY MIGRATION

### File: `lib/src/data/repositories/booking_repository.dart`

This currently uses Supabase SDK. Must switch to HTTP.

#### New Implementation (Django HTTP):

```dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingRepository {
  static const String _baseUrl = String.fromEnvironment(
    'DJANGO_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  final http.Client _client;

  BookingRepository([Object? client])
    : _client = client is http.Client ? client : http.Client();

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('$_baseUrl$path');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...query.map((k, v) => MapEntry(k, v?.toString() ?? '')),
      },
    );
  }

  Map<String, String> get _jsonHeaders => {
    HttpHeaders.contentTypeHeader: 'application/json',
  };

  T _decode<T>(http.Response res, T Function(dynamic) mapper) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = res.body.isEmpty ? null : jsonDecode(res.body);
      return mapper(body);
    }
    throw HttpException('HTTP ${res.statusCode}: ${res.body}');
  }

  // CREATE BOOKING
  Future<String> createBooking(Booking booking) async {
    final res = await _client.post(
      _uri('/api/bookings/'),
      headers: _jsonHeaders,
      body: jsonEncode(booking.toJson()),
    );

    return _decode<String>(res, (body) => body['id'] as String);
  }

  // GET BOOKING DETAILS
  Future<Map<String, dynamic>?> getBookingDetails(String bookingId) async {
    try {
      final res = await _client.get(_uri('/api/bookings/$bookingId/'));
      return _decode<Map<String, dynamic>?>(res, (body) {
        if (body == null) return null;
        
        final booking = Booking.fromJson(body as Map<String, dynamic>);
        final itemData = body['item'] as Map<String, dynamic>?;
        final borrowerData = body['borrower'] as Map<String, dynamic>?;
        final ownerData = body['owner'] as Map<String, dynamic>?;

        return {
          'booking': booking,
          'item': itemData != null ? Item.fromJson(itemData) : null,
          'borrower': borrowerData != null ? User.fromJson(borrowerData) : null,
          'owner': ownerData != null ? User.fromJson(ownerData) : null,
          'imageUrl': body['item']?['images']?.first?['image_url'] as String?,
        };
      });
    } catch (e) {
      print('Error fetching booking details: $e');
      return null;
    }
  }

  // GET INCOMING REQUESTS (for owner)
  Future<List<Map<String, dynamic>>> getIncomingRequests(String ownerId) async {
    try {
      final res = await _client.get(_uri('/api/bookings/', {'owner_id': ownerId}));
      return _decode<List<Map<String, dynamic>>>(res, (body) {
        // Handle paginated response
        final results = body is Map<String, dynamic> ? body['results'] : body;
        return (results as List)
            .map((json) {
              final booking = Booking.fromJson(json as Map<String, dynamic>);
              final itemData = json['item'] as Map<String, dynamic>?;
              final borrowerData = json['borrower'] as Map<String, dynamic>?;
              return {
                'booking': booking,
                'item': itemData != null ? Item.fromJson(itemData) : null,
                'borrower': borrowerData != null ? User.fromJson(borrowerData) : null,
                'imageUrl': json['item']?['images']?.first?['image_url'] as String?,
              };
            })
            .toList();
      });
    } catch (e) {
      print('Error fetching incoming requests: $e');
      return [];
    }
  }

  // GET MY REQUESTS (for borrower)
  Future<List<Map<String, dynamic>>> getMyRequests(String borrowerId) async {
    try {
      final res = await _client.get(
        _uri('/api/bookings/', {'borrower_id': borrowerId}),
      );
      return _decode<List<Map<String, dynamic>>>(res, (body) {
        final results = body is Map<String, dynamic> ? body['results'] : body;
        return (results as List)
            .map((json) {
              final booking = Booking.fromJson(json as Map<String, dynamic>);
              final itemData = json['item'] as Map<String, dynamic>?;
              final ownerData = json['owner'] as Map<String, dynamic>?;
              return {
                'booking': booking,
                'item': itemData != null ? Item.fromJson(itemData) : null,
                'owner': ownerData != null ? User.fromJson(ownerData) : null,
                'imageUrl': json['item']?['images']?.first?['image_url'] as String?,
              };
            })
            .toList();
      });
    } catch (e) {
      print('Error fetching my requests: $e');
      return [];
    }
  }

  // UPDATE BOOKING STATUS (Accept/Decline)
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    final endpoint = status == BookingStatus.accepted 
        ? '/api/bookings/$bookingId/accept/'
        : status == BookingStatus.declined
        ? '/api/bookings/$bookingId/decline/'
        : '/api/bookings/$bookingId/';

    await _client.post(
      _uri(endpoint),
      headers: _jsonHeaders,
      body: jsonEncode({'status': status.name}),
    );
  }

  // UPDATE DEPOSIT STATUS
  Future<void> updateDepositStatus(
    String bookingId,
    DepositStatus depositStatus,
  ) async {
    final endpoint = depositStatus == DepositStatus.received
        ? '/api/bookings/$bookingId/mark-deposit-received/'
        : depositStatus == DepositStatus.returned
        ? '/api/bookings/$bookingId/mark-deposit-returned/'
        : depositStatus == DepositStatus.kept
        ? '/api/bookings/$bookingId/keep-deposit/'
        : '/api/bookings/$bookingId/';

    await _client.post(
      _uri(endpoint),
      headers: _jsonHeaders,
    );
  }

  // GENERATE BOOKING CODE
  Future<void> generateBookingCode(String bookingId) async {
    await _client.post(
      _uri('/api/bookings/$bookingId/generate-code/'),
      headers: _jsonHeaders,
    );
  }
}
```

---

## 4. RATING REPOSITORY MIGRATION

### File: `lib/src/data/repositories/rating_repository.dart`

This currently uses Supabase SDK. Must switch to HTTP.

#### New Implementation (Django HTTP):

```dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RatingRepository {
  static const String _baseUrl = String.fromEnvironment(
    'DJANGO_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  final http.Client _client;

  RatingRepository([Object? client])
    : _client = client is http.Client ? client : http.Client();

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('$_baseUrl$path');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...query.map((k, v) => MapEntry(k, v?.toString() ?? '')),
      },
    );
  }

  Map<String, String> get _jsonHeaders => {
    HttpHeaders.contentTypeHeader: 'application/json',
  };

  T _decode<T>(http.Response res, T Function(dynamic) mapper) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = res.body.isEmpty ? null : jsonDecode(res.body);
      return mapper(body);
    }
    throw HttpException('HTTP ${res.statusCode}: ${res.body}');
  }

  // CREATE RATING
  Future<void> createRating({
    required String bookingId,
    required String raterUserId,
    required String targetUserId,
    required int stars,
  }) async {
    final payload = {
      'booking_id': bookingId,
      'rater_id': raterUserId,
      'target_user_id': targetUserId,
      'stars': stars,
    };

    await _client.post(
      _uri('/api/ratings/'),
      headers: _jsonHeaders,
      body: jsonEncode(payload),
    );
  }

  // CHECK IF USER HAS ALREADY RATED
  Future<bool> hasAlreadyRated({
    required String bookingId,
    required String raterUserId,
  }) async {
    try {
      final res = await _client.get(
        _uri('/api/ratings/has-rated/', {
          'booking_id': bookingId,
          'rater_id': raterUserId,
        }),
      );

      return _decode<bool>(res, (body) {
        return body['has_rated'] as bool? ?? false;
      });
    } catch (e) {
      print('Error checking if rated: $e');
      return false;
    }
  }

  // GET RATINGS FOR USER
  Future<List<Map<String, dynamic>>> getRatingsForUser(String userId) async {
    try {
      final res = await _client.get(
        _uri('/api/ratings/', {'target_user_id': userId}),
      );

      return _decode<List<Map<String, dynamic>>>(res, (body) {
        final results = body is Map<String, dynamic> ? body['results'] : body;
        return (results as List).map((json) {
          return json as Map<String, dynamic>;
        }).toList();
      });
    } catch (e) {
      print('Error fetching ratings: $e');
      return [];
    }
  }
}
```

---

## 5. CUBIT/STATE MANAGEMENT UPDATES

### Booking Cubit: No Changes Required!

The `BookingCubit` already uses repository pattern:

```dart
class BookingCubit extends Cubit<BookingState> {
  final BookingRepository bookingRepository;
  final RatingRepository ratingRepository;

  BookingCubit()
    : bookingRepository = BookingRepository(Supabase.instance.client),  // ← UPDATE
      ratingRepository = RatingRepository(Supabase.instance.client),    // ← UPDATE
      super(BookingInitial());
  
  // ... rest of cubit remains unchanged
}
```

#### Update BookingCubit Constructor:

```dart
// Replace Supabase with HTTP
BookingCubit()
  : bookingRepository = BookingRepository(),  // Uses http.Client
    ratingRepository = RatingRepository(),    // Uses http.Client
    super(BookingInitial());
```

---

## 6. INTEGRATION STEPS (In Order)

1. **Update Environment Variables**:
   - Set `DJANGO_BASE_URL` to your Django server (e.g., `http://10.0.2.2:8000` for Android emulator)
   - Ensure Supabase environment variables are still set for any non-API operations

2. **Replace Repository Files**:
   - [ ] Update `ProfileRepository` to use HTTP
   - [ ] Update `BookingRepository` to use HTTP
   - [ ] Update `RatingRepository` to use HTTP
   - [ ] Verify `ItemRepository` is already HTTP-compatible

3. **Update Cubits**:
   - [ ] Update `BookingCubit` to use new repository constructors
   - [ ] Update `ProfileCubit` to use new `ProfileRepository`
   - [ ] Update `AuthCubit` if it uses profile data

4. **Test Each Feature**:
   - [ ] Items listing with filters
   - [ ] Item details
   - [ ] Profile view & edit
   - [ ] Create booking
   - [ ] Accept/decline booking
   - [ ] Mark deposit received
   - [ ] Mark deposit returned
   - [ ] Submit rating
   - [ ] Check if already rated

5. **Deploy**:
   - [ ] Build Android APK
   - [ ] Build iOS IPA
   - [ ] Publish to stores

---

## 7. BASE URL CONFIGURATION

### For Local Development (Android Emulator):
```dart
const String _baseUrl = 'http://10.0.2.2:8000';  // Django on host machine
```

### For Local Development (iOS Simulator):
```dart
const String _baseUrl = 'http://localhost:8000';  // Django on host machine
```

### For Production:
```dart
const String _baseUrl = 'https://api.yourdomain.com';  // Your Django server
```

### Using Environment Variables:
```bash
# Build with environment variable
flutter run --dart-define=DJANGO_BASE_URL=http://192.168.1.100:8000
```

---

## 8. ERROR HANDLING

### Common HTTP Errors (Add to Repositories):

```dart
Future<T> _handleError<T>(HttpException e, T defaultValue) {
  if (e.message.contains('400')) {
    throw ValidationException(e.message);
  } else if (e.message.contains('401')) {
    throw AuthenticationException('Unauthorized - check your token');
  } else if (e.message.contains('403')) {
    throw AuthorizationException('Access denied');
  } else if (e.message.contains('404')) {
    throw NotFoundException('Resource not found');
  } else if (e.message.contains('500')) {
    throw ServerException('Server error');
  }
  return defaultValue;
}
```

---

## 9. TESTING CHECKLIST

- [ ] All item filtering works (categories, search, excludeUserId)
- [ ] Pagination works with both `page_size` and `pageSize`
- [ ] Booking creation succeeds
- [ ] Booking status transitions work (pending → accepted → active → completed)
- [ ] Deposit transitions work (none → received → returned)
- [ ] Rating submission succeeds
- [ ] `hasAlreadyRated()` check prevents duplicate ratings
- [ ] Profile fetch and update work
- [ ] Error handling shows meaningful messages
- [ ] Offline scenarios are handled gracefully

---

## 10. MIGRATION COMPLETE!

Once all repositories are updated and tested, the mobile app will be fully migrated to the Django REST API backend while maintaining 100% feature parity with the original Supabase implementation.

**No user-facing feature changes. No logic changes. Pure backend swap.**
