import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart' as models;

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  Future<models.User?> getMyProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;
    final data = await _supabase
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return models.User.fromJson(data);
  }

  Future<models.User?> getProfileById(String userId) async {
    final data = await _supabase
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return models.User.fromJson(data);
  }

  Future<String?> uploadAvatar(File file) async {
    // If project uses Supabase storage for images, follow bucket 'avatars'
    final ext = file.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    final path = '$userId/$fileName';
    try {
      await _supabase.storage
          .from('avatars')
          .upload(path, file, fileOptions: const FileOptions(upsert: true));
      final publicUrl = _supabase.storage.from('avatars').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  Future<models.User?> updateProfile({
    String? username,
    String? phone,
    String? avatarUrl,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

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
      final data = await _supabase
          .from('users')
          .update(updates)
          .eq('id', userId)
          .select()
          .maybeSingle();
      if (data == null) {
        throw Exception('Failed to update profile - no data returned');
      }
      return models.User.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}


