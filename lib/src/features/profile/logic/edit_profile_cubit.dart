import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/profile_repository.dart';
import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final ProfileRepository _repo;

  EditProfileCubit({required ProfileRepository profileRepository})
      : _repo = profileRepository,
        super(EditProfileInitial());

  Future<void> submit({
    String? username,
    String? email,
    String? phone,
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
