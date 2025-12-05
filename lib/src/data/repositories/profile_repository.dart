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
    final data = await _supabase.from('users').select().eq('id', userId).maybeSingle();
    if (data == null) return null;
    return models.User.fromJson(data);
  }

  Future<models.User?> getProfileById(String userId) async {
    final data = await _supabase.from('users').select().eq('id', userId).maybeSingle();
    if (data == null) return null;
    return models.User.fromJson(data);
  }

  Future<String?> uploadAvatar(File file) async {
    // If project uses Supabase storage for images, follow bucket 'avatars'
    final ext = file.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;
    final path = 'avatars/$userId/$fileName';
    try {
      await _supabase.storage
          .from('avatars')
          .upload(path, file, fileOptions: const FileOptions(upsert: true));
      final publicUrl = _supabase.storage.from('avatars').getPublicUrl(path);
      return publicUrl;
    } catch (_) {
      return null;
    }
  }

  Future<models.User?> updateProfile({
    String? username,
    String? email,
    String? phone,
    String? avatarUrl,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;
    final updates = <String, dynamic>{
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final data = await _supabase
        .from('users')
        .update(updates)
        .eq('id', userId)
        .select()
        .maybeSingle();
    if (data == null) return null;
    return models.User.fromJson(data);
  }
}
