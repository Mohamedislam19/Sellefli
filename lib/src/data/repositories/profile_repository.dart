import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/user_model.dart' as models;
import 'auth_repository.dart';

class ProfileRepository {
  static const String _baseUrl = String.fromEnvironment(
    'DJANGO_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  final http.Client _client;
  final AuthRepository? _authRepository;

  ProfileRepository({
    http.Client? client,
    AuthRepository? authRepository,
  })  : _client = client ?? http.Client(),
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

  /// Get current user's profile from Django API
  /// GET /api/users/me/
  Future<models.User?> getMyProfile() async {
    try {
      final currentUser = _authRepository?.currentUser;
      final userId = currentUser?.id;
      if (userId == null) return null;

      final res = await _client.get(
        _uri('/api/users/me/', {'id': userId}),
        headers: _jsonHeaders,
      );

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
      final res = await _client.get(
        _uri('/api/users/$userId/'),
        headers: _jsonHeaders,
      );

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
      final currentUser = _authRepository?.currentUser;
      final userId = currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final request = http.MultipartRequest(
        'POST',
        _uri('/api/users/$userId/upload-avatar/'),
      );

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
      final currentUser = _authRepository?.currentUser;
      final userId = currentUser?.id;
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

      final res = await _client.patch(
        _uri('/api/users/$userId/update-profile/'),
        headers: _jsonHeaders,
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


