import '../../../data/models/user_model.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User profile;
  final List<Map<String, dynamic>> transactions;
  const ProfileLoaded(this.profile, {this.transactions = const []});
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
}
