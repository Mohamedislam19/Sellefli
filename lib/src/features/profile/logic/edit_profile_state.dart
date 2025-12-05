part of 'edit_profile_cubit.dart';

abstract class EditProfileState {
  const EditProfileState();
}

class EditProfileInitial extends EditProfileState {}

class EditProfileSaving extends EditProfileState {}

class EditProfileSuccess extends EditProfileState {
  final models.User profile;
  const EditProfileSuccess(this.profile);
}

class EditProfileError extends EditProfileState {
  final String message;
  const EditProfileError(this.message);
}
