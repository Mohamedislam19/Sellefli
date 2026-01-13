import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// ApiClient - Centralized HTTP client for all Django backend communication.
///
/// This service handles:
/// - All HTTP requests to the Django backend
/// - JWT token storage and retrieval using SharedPreferences
/// - Automatic token refresh when expired
/// - Authorization header injection
///
/// BFF Pattern: The Flutter app ONLY communicates with Django.
/// Django handles all Supabase communication server-side.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  /// Configure your backend base URL. Override via --dart-define=DJANGO_BASE_URL
  /// Production: https://sellefli.onrender.com
  static const String baseUrl = String.fromEnvironment(
    'DJANGO_BASE_URL',
    defaultValue: 'https://sellefli.onrender.com',
  );

  /// Request timeout duration
  static const Duration timeout = Duration(seconds: 15);

  final http.Client _client = http.Client();

  // Token storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _tokenExpiresAtKey = 'token_expires_at';

  // Cached values (loaded from SharedPreferences on init)
  String? _accessToken;
  String? _refreshToken;
  String? _userId;
  String? _userEmail;
  int? _tokenExpiresAt; // Unix timestamp in seconds

  /// Initialize the API client - call this in main() before runApp()
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
    _userId = prefs.getString(_userIdKey);
    _userEmail = prefs.getString(_userEmailKey);
    _tokenExpiresAt = prefs.getInt(_tokenExpiresAtKey);

    debugPrint(
      '[ApiClient] Initialized. User: $_userEmail, Token exists: ${_accessToken != null}',
    );
  }

  /// Check if user is currently authenticated
  bool get isAuthenticated => _accessToken != null && _userId != null;

  /// Get the current user ID
  String? get currentUserId => _userId;

  /// Get the current user email
  String? get currentUserEmail => _userEmail;

  /// Get the current access token (for external use if needed)
  String? get accessToken => _accessToken;

  /// Store authentication tokens after login/signup
  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String userEmail,
    int? expiresAt,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _userId = userId;
    _userEmail = userEmail;
    _tokenExpiresAt = expiresAt;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userEmailKey, userEmail);
    if (expiresAt != null) {
      await prefs.setInt(_tokenExpiresAtKey, expiresAt);
    }

    debugPrint('[ApiClient] Tokens stored for user: $userEmail');
  }

  /// Clear all stored tokens (on logout)
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _userEmail = null;
    _tokenExpiresAt = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_tokenExpiresAtKey);

    debugPrint('[ApiClient] Tokens cleared');
  }

  /// Build a URI for an API endpoint
  Uri uri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('$baseUrl$path');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...query.map((k, v) => MapEntry(k, v?.toString() ?? '')),
      },
    );
  }

  /// Get headers with Authorization token (auto-refreshes if needed)
  Future<Map<String, String>> getAuthHeaders() async {
    await _refreshTokenIfNeeded();

    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (_accessToken != null)
        HttpHeaders.authorizationHeader: 'Bearer $_accessToken',
    };
  }

  /// Get headers without Authorization (for public endpoints)
  Map<String, String> get publicHeaders => {
    HttpHeaders.contentTypeHeader: 'application/json',
  };

  /// Refresh the access token if it's expired or about to expire
  Future<void> _refreshTokenIfNeeded() async {
    if (_accessToken == null || _refreshToken == null) return;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expiresAt = _tokenExpiresAt ?? 0;
    final timeUntilExpiry = expiresAt - now;

    // Refresh if token is expired or will expire within 5 minutes
    if (timeUntilExpiry < 300) {
      try {
        debugPrint(
          '[ApiClient] Token ${timeUntilExpiry <= 0 ? "EXPIRED" : "expiring soon"}, refreshing...',
        );
        await refreshToken();
        debugPrint('[ApiClient] Token refreshed successfully');
      } catch (e) {
        debugPrint('[ApiClient] Token refresh failed: $e');
        if (timeUntilExpiry <= 0) {
          // Token is expired and refresh failed - clear tokens
          await clearTokens();
          throw Exception('Session expired. Please log in again.');
        }
        // Otherwise continue with current token (it's still valid for a bit)
      }
    }
  }

  /// Manually refresh the access token
  Future<void> refreshToken() async {
    if (_refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await _client.post(
      uri('/api/users/token/refresh/'),
      headers: publicHeaders,
      body: jsonEncode({'refresh_token': _refreshToken}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      _accessToken = body['access_token'];
      _tokenExpiresAt = body['expires_at'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, _accessToken!);
      if (_tokenExpiresAt != null) {
        await prefs.setInt(_tokenExpiresAtKey, _tokenExpiresAt!);
      }
    } else {
      throw Exception('Token refresh failed: ${response.statusCode}');
    }
  }

  // ===========================================================================
  // HTTP Methods with automatic auth header injection
  // ===========================================================================

  /// GET request with authentication
  Future<http.Response> get(
    String path, {
    Map<String, dynamic>? query,
    bool requiresAuth = true,
  }) async {
    final headers = requiresAuth ? await getAuthHeaders() : publicHeaders;
    return _client.get(uri(path, query), headers: headers).timeout(timeout);
  }

  /// POST request with authentication
  Future<http.Response> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool requiresAuth = true,
  }) async {
    final headers = requiresAuth ? await getAuthHeaders() : publicHeaders;
    return _client
        .post(
          uri(path, query),
          headers: headers,
          body: body is String ? body : jsonEncode(body),
        )
        .timeout(timeout);
  }

  /// PUT request with authentication
  Future<http.Response> put(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool requiresAuth = true,
  }) async {
    final headers = requiresAuth ? await getAuthHeaders() : publicHeaders;
    return _client
        .put(
          uri(path, query),
          headers: headers,
          body: body is String ? body : jsonEncode(body),
        )
        .timeout(timeout);
  }

  /// PATCH request with authentication
  Future<http.Response> patch(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool requiresAuth = true,
  }) async {
    final headers = requiresAuth ? await getAuthHeaders() : publicHeaders;
    return _client
        .patch(
          uri(path, query),
          headers: headers,
          body: body is String ? body : jsonEncode(body),
        )
        .timeout(timeout);
  }

  /// DELETE request with authentication
  Future<http.Response> delete(
    String path, {
    Map<String, dynamic>? query,
    bool requiresAuth = true,
  }) async {
    final headers = requiresAuth ? await getAuthHeaders() : publicHeaders;
    return _client.delete(uri(path, query), headers: headers).timeout(timeout);
  }

  /// Multipart POST request (for file uploads)
  Future<http.StreamedResponse> postMultipart(
    String path, {
    required List<http.MultipartFile> files,
    Map<String, String>? fields,
    bool requiresAuth = true,
  }) async {
    final request = http.MultipartRequest('POST', uri(path));

    if (requiresAuth && _accessToken != null) {
      await _refreshTokenIfNeeded();
      request.headers[HttpHeaders.authorizationHeader] = 'Bearer $_accessToken';
    }

    if (fields != null) {
      request.fields.addAll(fields);
    }

    request.files.addAll(files);

    return _client.send(request).timeout(timeout);
  }

  // ===========================================================================
  // Response Handling Utilities
  // ===========================================================================

  /// Decode a successful JSON response
  T decode<T>(http.Response response, T Function(dynamic) mapper) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = response.body.isEmpty ? null : jsonDecode(response.body);
      return mapper(body);
    }
    throw HttpException('HTTP ${response.statusCode}: ${response.body}');
  }

  /// Check if response is successful
  bool isSuccess(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// Parse error message from response
  String parseErrorMessage(
    http.Response response, {
    String defaultMessage = 'Request failed',
  }) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        if (body.containsKey('error')) return body['error'];
        if (body.containsKey('detail')) return body['detail'];
        if (body.containsKey('message')) return body['message'];
        // Flatten validation errors
        return body.values.map((v) => v is List ? v.join(' ') : v).join('\n');
      }
    } catch (_) {}
    return response.body.isEmpty ? defaultMessage : response.body;
  }
}
