import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/booking_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repo;
  final BookingRepository _bookingRepo;

  ProfileCubit({
    required ProfileRepository profileRepository,
    required BookingRepository bookingRepository,
  }) : _repo = profileRepository,
       _bookingRepo = bookingRepository,
       super(ProfileInitial());

  Future<void> loadMyProfile() async {
    emit(ProfileLoading());
    try {
      final profile = await _repo.getMyProfile();
      if (profile == null) {
        emit(const ProfileError('Profile not found'));
        return;
      }
      final transactions = await _bookingRepo.getUserTransactions(profile.id);
      emit(ProfileLoaded(profile, transactions: transactions));
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
      final transactions = await _bookingRepo.getUserTransactions(userId);
      emit(ProfileLoaded(profile, transactions: transactions));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
