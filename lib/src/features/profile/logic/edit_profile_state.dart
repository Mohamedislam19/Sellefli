import '../../../data/models/user_model.dart';

abstract class EditProfileState {
  const EditProfileState();
}

class EditProfileInitial extends EditProfileState {}

class EditProfileSaving extends EditProfileState {}

class EditProfileSuccess extends EditProfileState {
  final User profile;
  const EditProfileSuccess(this.profile);
}

class EditProfileError extends EditProfileState {
  final String message;
  const EditProfileError(this.message);
}


