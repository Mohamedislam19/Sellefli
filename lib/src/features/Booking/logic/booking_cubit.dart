import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/rating_repository.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository bookingRepository;
  final RatingRepository ratingRepository;

  BookingCubit()
    : bookingRepository = BookingRepository(Supabase.instance.client),
      ratingRepository = RatingRepository(), // Uses Django backend via HTTP
      super(BookingInitial());

  // FETCH BOOKING DETAILS
  Future<void> fetchBookingDetails(String bookingId) async {
    try {
      if (isClosed) return;
      emit(BookingLoading());

      final details = await bookingRepository.getBookingDetails(bookingId);

      if (details == null) {
        if (!isClosed) emit(BookingError('Booking not found'));
        return;
      }

      if (!isClosed) emit(BookingDetailsLoaded(details));
    } catch (e) {
      if (!isClosed) emit(BookingError(e.toString()));
    }
  }

  // FETCH INCOMING REQUESTS (for owner)
  Future<void> fetchIncomingRequests(String ownerId) async {
    try {
      if (isClosed) return;
      emit(BookingLoading());

      final requests = await bookingRepository.getIncomingRequests(ownerId);

      if (!isClosed) emit(BookingListLoaded(requests));
    } catch (e) {
      if (!isClosed) emit(BookingError(e.toString()));
    }
  }

  // FETCH MY REQUESTS (for borrower)
  Future<void> fetchMyRequests(String borrowerId) async {
    try {
      if (isClosed) return;
      emit(BookingLoading());

      final requests = await bookingRepository.getMyRequests(borrowerId);

      if (!isClosed) emit(BookingListLoaded(requests));
    } catch (e) {
      if (!isClosed) emit(BookingError(e.toString()));
    }
  }

  // ACCEPT BOOKING
  Future<void> acceptBooking(String bookingId) async {
    try {
      if (isClosed) return;
      emit(BookingActionLoading());

      await bookingRepository.updateBookingStatus(
        bookingId,
        BookingStatus.accepted,
      );
      await bookingRepository.generateBookingCode(bookingId);

      if (!isClosed) {
        emit(BookingActionSuccess('Booking accepted successfully'));
      }
    } catch (e) {
      if (!isClosed) emit(BookingError(e.toString()));
    }
  }

  // DECLINE BOOKING
  Future<void> declineBooking(String bookingId) async {
    try {
      if (isClosed) return;
      emit(BookingActionLoading());

      await bookingRepository.updateBookingStatus(
        bookingId,
        BookingStatus.declined,
      );

      if (!isClosed) emit(BookingActionSuccess('Booking declined'));
    } catch (e) {
      if (!isClosed) emit(BookingError(e.toString()));
    }
  }

  // MARK DEPOSIT AS RETURNED
  Future<void> markDepositReturned(String bookingId) async {
    try {
      if (isClosed) return;
      emit(BookingActionLoading());

      await bookingRepository.updateDepositStatus(
        bookingId,
        DepositStatus.returned,
      );
      await bookingRepository.updateBookingStatus(
        bookingId,
        BookingStatus.completed,
      );

      if (!isClosed) emit(BookingActionSuccess('Deposit marked as returned'));
    } catch (e) {
      if (!isClosed) emit(BookingError(e.toString()));
    }
  }

  // KEEP DEPOSIT
  Future<void> keepDeposit(String bookingId) async {
    try {
      if (isClosed) return;
      emit(BookingActionLoading());

      await bookingRepository.updateDepositStatus(
        bookingId,
        DepositStatus.kept,
      );
      await bookingRepository.updateBookingStatus(
        bookingId,
        BookingStatus.closed,
      );

      if (!isClosed) emit(BookingActionSuccess('Deposit kept'));
    } catch (e) {
      if (!isClosed) emit(BookingError(e.toString()));
    }
  }

  // MARK DEPOSIT AS RECEIVED
  // (Owner acknowledges they have received the deposit and booking becomes active)
  // Allowed only when booking status is accepted & depositStatus is none.
  Future<void> markDepositReceived(String bookingId) async {
    try {
      if (isClosed) return;
      emit(BookingActionLoading());

      // Fetch current details to validate state before updating
      final details = await bookingRepository.getBookingDetails(bookingId);
      if (details == null) {
        if (!isClosed) emit(BookingError('Booking not found'));
        return;
      }
      final booking = details['booking'] as Booking;

      if (booking.status != BookingStatus.accepted ||
          booking.depositStatus != DepositStatus.none) {
        if (!isClosed) {
          emit(BookingError('Cannot mark deposit received in current state'));
        }
        return;
      }

      await bookingRepository.updateDepositStatus(
        bookingId,
        DepositStatus.received,
      );
      // Move booking to active lifecycle phase now that deposit is secured
      await bookingRepository.updateBookingStatus(
        bookingId,
        BookingStatus.active,
      );

      if (!isClosed) emit(BookingActionSuccess('Deposit marked as received'));
    } catch (e) {
      if (!isClosed) emit(BookingError(e.toString()));
    }
  }

  // CREATE BOOKING REQUEST
  Future<void> createBookingRequest({
    required String itemId,
    required String ownerId,
    required String borrowerId,
    required DateTime startDate,
    required DateTime returnByDate,
    double? totalCost,
  }) async {
    try {
      if (isClosed) return;
      emit(BookingActionLoading());

      final booking = Booking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        itemId: itemId,
        ownerId: ownerId,
        borrowerId: borrowerId,
        startDate: startDate,
        returnByDate: returnByDate,
        totalCost: totalCost,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await bookingRepository.createBooking(booking);

      if (!isClosed) {
        emit(BookingActionSuccess('Booking request sent successfully'));
      }
    } catch (e) {
      if (!isClosed) {
        emit(BookingError(e.toString()));
      }
    }
  }

  // SUBMIT RATING
  Future<void> submitRating({
    required String bookingId,
    required String raterUserId,
    required String targetUserId,
    required int stars,
  }) async {
    try {
      if (isClosed) return;
      emit(BookingActionLoading());
      await ratingRepository.createRating(
        bookingId: bookingId,
        raterUserId: raterUserId,
        targetUserId: targetUserId,
        stars: stars,
      );
      if (!isClosed) {
        emit(BookingActionSuccess('Rating submitted successfully'));
      }
    } catch (e) {
      if (!isClosed) {
        emit(BookingError(e.toString()));
      }
    }
  }

  // CHECK IF USER HAS ALREADY RATED THIS BOOKING
  Future<bool> hasAlreadyRated({
    required String bookingId,
    required String raterUserId,
  }) async {
    return ratingRepository.hasAlreadyRated(
      bookingId: bookingId,
      raterUserId: raterUserId,
    );
  }
}
