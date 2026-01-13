import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/rating_model.dart';

/// RatingRepository - uses Django backend API for all rating operations.
/// The app never communicates directly with Supabase for ratings.
/// Django handles validation, calculation, and database updates.
class RatingRepository {
  /// Configure your backend base URL. Override via --dart-define=DJANGO_BASE_URL
  /// Production: https://sellefli.onrender.com
  static const String _baseUrl = String.fromEnvironment(
    'DJANGO_BASE_URL',
    defaultValue: 'https://sellefli.onrender.com',
  );

  final http.Client _client;

  RatingRepository([http.Client? client]) : _client = client ?? http.Client();

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

  /// Get auth headers with Supabase JWT token for Django authentication
  Future<Map<String, String>> get _authHeaders async {
    var session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      final expiresAt = session.expiresAt;
      if (expiresAt != null) {
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final timeUntilExpiry = expiresAt - now;

        // Refresh if token is expired or about to expire within 5 minutes
        if (timeUntilExpiry < 300) {
          try {
            final response = await Supabase.instance.client.auth
                .refreshSession();
            session = response.session;
          } catch (e) {
            if (timeUntilExpiry <= 0) {
              throw Exception('Session expired. Please log in again.');
            }
          }
        }
      }
    }

    final currentSession = Supabase.instance.client.auth.currentSession;
    final token = currentSession?.accessToken;

    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };
  }

  T _decode<T>(http.Response res, T Function(dynamic) mapper) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = res.body.isEmpty ? null : jsonDecode(res.body);
      return mapper(body);
    }
    throw HttpException('HTTP ${res.statusCode}: ${res.body}');
  }

  /// Check if a rating already exists for this booking by this user.
  /// Calls Django: GET /api/ratings/has-rated/?booking_id=...&rater_id=...
  Future<bool> hasAlreadyRated({
    required String bookingId,
    required String raterUserId,
  }) async {
    final res = await _client.get(
      _uri('/api/ratings/has-rated/', {
        'booking_id': bookingId,
        'rater_id': raterUserId,
      }),
      headers: await _authHeaders,
    );

    return _decode<bool>(res, (body) => body['has_rated'] as bool);
  }

  /// Create a rating via Django backend.
  /// Django validates the request, creates the rating, and updates user stats.
  /// Calls Django: POST /api/ratings/
  Future<void> createRating({
    required String bookingId,
    required String raterUserId,
    required String targetUserId,
    required int stars,
  }) async {
    final url = _uri('/api/ratings/');
    final headers = await _authHeaders;
    final body = jsonEncode({
      'booking_id': bookingId,
      'rater_id': raterUserId,
      'target_user_id': targetUserId,
      'stars': stars,
    });

    developer.log('Creating rating: POST $url', name: 'RatingRepository');
    developer.log('Request body: $body', name: 'RatingRepository');

    try {
      final res = await _client
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      developer.log(
        'Response status: ${res.statusCode}',
        name: 'RatingRepository',
      );
      developer.log('Response body: ${res.body}', name: 'RatingRepository');

      if (res.statusCode < 200 || res.statusCode >= 300) {
        final error = jsonDecode(res.body);
        final message = error is Map
            ? (error['detail'] ??
                  error.values.first?.toString() ??
                  'Rating failed')
            : 'Rating failed';
        throw Exception(message);
      }
    } catch (e) {
      developer.log('Error creating rating: $e', name: 'RatingRepository');
      rethrow;
    }
  }

  /// Get all ratings for a user via Django.
  /// Calls Django: GET /api/ratings/?target_user_id=...
  Future<List<Rating>> getUserRatings(String userId) async {
    final res = await _client.get(
      _uri('/api/ratings/', {'target_user_id': userId}),
      headers: await _authHeaders,
    );

    return _decode<List<Rating>>(res, (body) {
      final results = body is Map<String, dynamic> ? body['results'] : body;
      return (results as List)
          .map((json) => Rating.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  /// Get average rating for a user via Django.
  /// Calls Django: GET /api/users/<userId>/
  Future<double> getUserAverageRating(String userId) async {
    final res = await _client.get(
      _uri('/api/users/$userId/'),
      headers: await _authHeaders,
    );

    return _decode<double>(res, (body) {
      final sum = body['rating_sum'] as int? ?? 0;
      final count = body['rating_count'] as int? ?? 0;
      return count > 0 ? sum / count : 0.0;
    });
  }
}
