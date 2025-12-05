import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/profile_repository.dart';
import '../../../data/models/user_model.dart' as models;

part 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final ProfileRepository _repo;

  EditProfileCubit({ProfileRepository? repository})
      : _repo = repository ?? ProfileRepository(supabase: Supabase.instance.client),
        super(EditProfileInitial());

  Future<void> submit({
    String? username,
    String? email,
    String? phone,
    String? bio,
    File? avatarFile,
  }) async {
    emit(EditProfileSaving());
    try {
      String? avatarUrl;
      if (avatarFile != null) {
        avatarUrl = await _repo.uploadAvatar(avatarFile);
      }
      final updated = await _repo.updateProfile(
        username: username,
        email: email,
        phone: phone,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      if (updated == null) {
        emit(const EditProfileError('Failed to update profile'));
        return;
      }
      emit(EditProfileSuccess(updated));
    } catch (e) {
      emit(EditProfileError(e.toString()));
    }
  }
}
