import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/profile_repository.dart';
import '../../../data/models/user_model.dart' as models;

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repo;

  ProfileCubit({ProfileRepository? repository})
      : _repo = repository ?? ProfileRepository(supabase: Supabase.instance.client),
        super(ProfileInitial());

  Future<void> loadMyProfile() async {
    emit(ProfileLoading());
    try {
      final profile = await _repo.getMyProfile();
      if (profile == null) {
        emit(const ProfileError('Profile not found'));
        return;
      }
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> refreshById(String userId) async {
    emit(ProfileLoading());
    try {
      final profile = await _repo.getProfileById(userId);
      if (profile == null) {
        emit(const ProfileError('Profile not found'));
        return;
      }
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
