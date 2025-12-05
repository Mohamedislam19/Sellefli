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
    String? phone,
    File? avatarFile,
  }) async {
    emit(EditProfileSaving());
    try {
      String? avatarUrl;

      // Upload avatar if a new image was selected
      if (avatarFile != null) {
        avatarUrl = await _repo.uploadAvatar(avatarFile);
        if (avatarUrl == null || avatarUrl.isEmpty) {
          emit(const EditProfileError('Failed to upload avatar image'));
          return;
        }
      }

      // Update profile with new data
      final updated = await _repo.updateProfile(
        username: username,
        phone: phone,
        avatarUrl: avatarUrl,
      );

      if (updated == null) {
        emit(const EditProfileError('Failed to update profile'));
        return;
      }

      emit(EditProfileSuccess(updated));
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('unique constraint') ||
          errorMessage.contains('duplicate key')) {
        if (errorMessage.contains('phone')) {
          errorMessage = 'This phone number is already in use';
        } else if (errorMessage.contains('email')) {
          errorMessage = 'This email is already in use';
        } else {
          errorMessage = 'This information is already in use';
        }
      }
      emit(EditProfileError(errorMessage));
    }
  }
}
