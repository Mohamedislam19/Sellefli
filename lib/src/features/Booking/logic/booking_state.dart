part of 'booking_cubit.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingActionLoading extends BookingState {}

class BookingDetailsLoaded extends BookingState {
  final Map<String, dynamic> bookingDetails;

  BookingDetailsLoaded(this.bookingDetails);
}

class BookingListLoaded extends BookingState {
  final List<Map<String, dynamic>> bookings;

  BookingListLoaded(this.bookings);
}

class BookingActionSuccess extends BookingState {
  final String message;

  BookingActionSuccess(this.message);
}

class BookingError extends BookingState {
  final String error;

  BookingError(this.error);
}


