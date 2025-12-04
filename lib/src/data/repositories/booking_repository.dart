import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';
import '../models/item_model.dart';
import '../models/user_model.dart' as models;

class BookingRepository {
  final SupabaseClient supabase;

  BookingRepository(this.supabase);

  // CREATE BOOKING (Request)
  Future<String> createBooking(Booking booking) async {
    final response = await supabase
        .from('bookings')
        .insert(booking.toJson())
        .select()
        .single();

    return response['id'] as String;
  }

  // GET BOOKING BY ID (with Item and User details)
  Future<Map<String, dynamic>?> getBookingDetails(String bookingId) async {
    final bookingData = await supabase
        .from('bookings')
        .select()
        .eq('id', bookingId)
        .maybeSingle();

    if (bookingData == null) return null;

    final booking = Booking.fromJson(bookingData);

    // Fetch related item
    final itemData = await supabase
        .from('items')
        .select()
        .eq('id', booking.itemId)
        .maybeSingle();

    // Fetch first image for item (if any)
    final imageData = await supabase
      .from('item_images')
      .select()
      .eq('item_id', booking.itemId)
      .order('position')
      .limit(1)
      .maybeSingle();

    // Fetch borrower details
    final borrowerData = await supabase
        .from('users')
        .select()
        .eq('id', booking.borrowerId)
        .maybeSingle();

    // Fetch owner details
    final ownerData = await supabase
        .from('users')
        .select()
        .eq('id', booking.ownerId)
        .maybeSingle();

    return {
      'booking': booking,
      'item': itemData != null ? Item.fromJson(itemData) : null,
      'borrower': borrowerData != null ? models.User.fromJson(borrowerData) : null,
      'owner': ownerData != null ? models.User.fromJson(ownerData) : null,
      'imageUrl': imageData?['image_url'] as String?,
    };
  }

  // GET INCOMING REQUESTS (For Owner)
  Future<List<Map<String, dynamic>>> getIncomingRequests(String ownerId) async {
    final bookingsData = await supabase
        .from('bookings')
        .select()
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);

    List<Map<String, dynamic>> results = [];

    for (var bookingJson in bookingsData) {
      final booking = Booking.fromJson(bookingJson);

      // Fetch item details
      final itemData = await supabase
          .from('items')
          .select()
          .eq('id', booking.itemId)
          .maybeSingle();

      // Fetch borrower details
      final borrowerData = await supabase
          .from('users')
          .select()
          .eq('id', booking.borrowerId)
          .maybeSingle();

      // Get first image
      final imageData = await supabase
          .from('item_images')
          .select()
          .eq('item_id', booking.itemId)
          .order('position')
          .limit(1)
          .maybeSingle();

      results.add({
        'booking': booking,
        'item': itemData != null ? Item.fromJson(itemData) : null,
        'borrower': borrowerData != null ? models.User.fromJson(borrowerData) : null,
        'imageUrl': imageData?['image_url'] as String?,
      });
    }

    return results;
  }


  // GET MY REQUESTS (For Borrower)
  Future<List<Map<String, dynamic>>> getMyRequests(String borrowerId) async {
    final bookingsData = await supabase
        .from('bookings')
        .select()
        .eq('borrower_id', borrowerId)
        .order('created_at', ascending: false);

    List<Map<String, dynamic>> results = [];

    for (var bookingJson in bookingsData) {
      final booking = Booking.fromJson(bookingJson);

      // Fetch item details
      final itemData = await supabase
          .from('items')
          .select()
          .eq('id', booking.itemId)
          .maybeSingle();

      // Fetch owner details
      final ownerData = await supabase
          .from('users')
          .select()
          .eq('id', booking.ownerId)
          .maybeSingle();

      // Get first image
      final imageData = await supabase
          .from('item_images')
          .select()
          .eq('item_id', booking.itemId)
          .order('position')
          .limit(1)
          .maybeSingle();

      results.add({
        'booking': booking,
        'item': itemData != null ? Item.fromJson(itemData) : null,
        'owner': ownerData != null ? models.User.fromJson(ownerData) : null,
        'imageUrl': imageData?['image_url'] as String?,
      });
    }

    return results;
  }

  // UPDATE BOOKING STATUS (Accept/Decline)
  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    await supabase.from('bookings').update({
      'status': status.name,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', bookingId);
  }

  // UPDATE DEPOSIT STATUS
  Future<void> updateDepositStatus(String bookingId, DepositStatus depositStatus) async {
    await supabase.from('bookings').update({
      'deposit_status': depositStatus.name,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', bookingId);
  }

  // GENERATE BOOKING CODE
  Future<void> generateBookingCode(String bookingId) async {
    // Generate a unique code (SF-XXX-XXX format)
    final code = 'SF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    
    await supabase.from('bookings').update({
      'booking_code': code,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', bookingId);
  }

  // DELETE BOOKING
  Future<void> deleteBooking(String bookingId) async {
    await supabase.from('bookings').delete().eq('id', bookingId);
  }
}
