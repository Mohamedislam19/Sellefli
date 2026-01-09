import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart' as models;
import 'auth_repository.dart';
import '../../core/services/api_client.dart';

class ProfileRepository {
  static const String _baseUrl = String.fromEnvironment(
    'DJANGO_BASE_URL',
    defaultValue: 'http://localhost:9000',
  );

  static const Duration _timeout = Duration(seconds: 5);

  final http.Client _client;
  final AuthRepository? _authRepository;
  final ApiClient _apiClient = ApiClient();

  ProfileRepository({http.Client? client, AuthRepository? authRepository})
    : _client = client ?? http.Client(),
      _authRepository = authRepository;

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

  Future<Map<String, String>> get _jsonHeaders async {
    return await _apiClient.getAuthHeaders();
  }

  /// Get auth headers with Supabase JWT token
  Future<Map<String, String>> get _authHeaders async {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken;

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

  /// Get current user's profile from Django API
  /// GET /api/users/me/
  Future<models.User?> getMyProfile() async {
    try {
      final userId = _apiClient.currentUserId ?? _authRepository?.currentUser?.id;
      if (userId == null) return null;

      final headers = await _jsonHeaders;
      final res = await _client.get(
        _uri('/api/users/me/', {'id': userId}),
        headers: headers,
      ).timeout(_timeout);

      if (res.statusCode == 404) return null;

      return _decode<models.User?>(res, (body) {
        if (body == null) return null;
        return models.User.fromJson(body as Map<String, dynamic>);
      });
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  /// Get user profile by ID from Django API
  /// GET /api/users/{userId}/
  Future<models.User?> getProfileById(String userId) async {
    try {
      final headers = await _jsonHeaders;
      final res = await _client.get(
        _uri('/api/users/$userId/'),
        headers: headers,
      ).timeout(_timeout);

      if (res.statusCode == 404) return null;

      return _decode<models.User?>(res, (body) {
        if (body == null) return null;
        return models.User.fromJson(body as Map<String, dynamic>);
      });
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// Upload avatar to Django backend
  /// POST /api/users/{userId}/upload-avatar/ (multipart)
  Future<String?> uploadAvatar(File file) async {
    try {
      final userId = _apiClient.currentUserId ?? _authRepository?.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final headers = await _jsonHeaders;
      final request = http.MultipartRequest(
        'POST',
        _uri('/api/users/$userId/upload-avatar/'),
      );

      // Add authorization header to multipart request
      request.headers.addAll(headers);

      request.files.add(
        await http.MultipartFile.fromPath('avatar', file.path),
      );

      final response = await request.send();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = await response.stream.bytesToString();
        final json = jsonDecode(responseBody) as Map<String, dynamic>;
        return json['avatar_url'] as String?;
      } else {
        throw Exception('Failed to upload avatar: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  /// Update user profile on Django backend
  /// PATCH /api/users/{userId}/update-profile/
  Future<models.User?> updateProfile({
    String? username,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final userId = _apiClient.currentUserId ?? _authRepository?.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

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

      if (updates.isEmpty) {
        return await getMyProfile();
      }

      final headers = await _jsonHeaders;
      final res = await _client.patch(
        _uri('/api/users/$userId/update-profile/'),
        headers: headers,
        body: jsonEncode(updates),
      );

      return _decode<models.User?>(res, (body) {
        if (body == null) return null;
        return models.User.fromJson(body as Map<String, dynamic>);
      });
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
