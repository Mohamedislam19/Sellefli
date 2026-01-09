import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import '../../core/api/api_config.dart';
import '../models/booking_model.dart';
import '../models/item_model.dart';
import '../models/user_model.dart' as models;

class BookingRepository {
  final SupabaseClient supabase;
  final String _baseUrl;
  final http.Client _client;

  BookingRepository(this.supabase, {String? baseUrl, http.Client? httpClient})
      : _baseUrl = (baseUrl ?? ApiConfig.apiBaseUrl).replaceAll(RegExp(r'/+$'), ''),
        _client = httpClient ?? http.Client();

  // CREATE BOOKING 
  Future<String> createBooking(Booking booking) async {
    // Keep creation via Supabase for now since i don't know how islam implemented it on the backend
    final response = await supabase
        .from('bookings')
        .insert(booking.toJson())
        .select()
        .single();

    return response['id'] as String;
  }

  // GET BOOKING BY ID (with Item and User details)
  Future<Map<String, dynamic>?> getBookingDetails(String bookingId) async {
    final uri = Uri.parse('$_baseUrl/api/bookings/$bookingId/');
    final resp = await _client.get(uri);
    if (resp.statusCode == 404) return null;
    if (resp.statusCode != 200) {
      throw Exception('Failed to load booking: ${resp.statusCode}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final booking = Booking.fromJson(data);
    final itemJson = data['item'] as Map<String, dynamic>?;
    final borrowerJson = data['borrower'] as Map<String, dynamic>?;
    final ownerJson = data['owner'] as Map<String, dynamic>?;
    return {
      'booking': booking,
      'item': itemJson != null ? Item.fromJson(itemJson) : null,
      'borrower': borrowerJson != null ? models.User.fromJson(borrowerJson) : null,
      'owner': ownerJson != null ? models.User.fromJson(ownerJson) : null,
      'imageUrl': data['image_url'] as String?,
    };
  }

  // GET INCOMING REQUESTS (For Owner)
  Future<List<Map<String, dynamic>>> getIncomingRequests(String ownerId) async {
    final uri = Uri.parse('$_baseUrl/api/bookings/incoming/?owner_id=$ownerId');
    final resp = await _client.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Failed to load incoming bookings: ${resp.statusCode}');
    }
    final list = jsonDecode(resp.body) as List<dynamic>;
    return list.map<Map<String, dynamic>>((e) {
      final m = e as Map<String, dynamic>;
      return {
        'booking': Booking.fromJson(m),
        'item': m['item'] != null ? Item.fromJson(m['item'] as Map<String, dynamic>) : null,
        'borrower': m['borrower'] != null ? models.User.fromJson(m['borrower'] as Map<String, dynamic>) : null,
        'owner': m['owner'] != null ? models.User.fromJson(m['owner'] as Map<String, dynamic>) : null,
        'imageUrl': m['image_url'] as String?,
      };
    }).toList();
  }

  // GET MY REQUESTS (For Borrower)
  Future<List<Map<String, dynamic>>> getMyRequests(String borrowerId) async {
    final uri = Uri.parse('$_baseUrl/api/bookings/my-requests/?borrower_id=$borrowerId');
    final resp = await _client.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Failed to load my requests: ${resp.statusCode}');
    }
    final list = jsonDecode(resp.body) as List<dynamic>;
    return list.map<Map<String, dynamic>>((e) {
      final m = e as Map<String, dynamic>;
      return {
        'booking': Booking.fromJson(m),
        'item': m['item'] != null ? Item.fromJson(m['item'] as Map<String, dynamic>) : null,
        'borrower': m['borrower'] != null ? models.User.fromJson(m['borrower'] as Map<String, dynamic>) : null,
        'owner': m['owner'] != null ? models.User.fromJson(m['owner'] as Map<String, dynamic>) : null,
        'imageUrl': m['image_url'] as String?,
      };
    }).toList();
  }

  // UPDATE BOOKING STATUS (Accept/Decline)
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    final uri = Uri.parse('$_baseUrl/api/bookings/$bookingId/status/');
    final resp = await _client.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status.name}),
    );
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to update status: ${resp.statusCode}');
    }
  }

  // UPDATE DEPOSIT STATUS
  Future<void> updateDepositStatus(
    String bookingId,
    DepositStatus depositStatus,
  ) async {
    final uri = Uri.parse('$_baseUrl/api/bookings/$bookingId/deposit/');
    final resp = await _client.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'deposit_status': depositStatus.name}),
    );
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to update deposit: ${resp.statusCode}');
    }
  }

  // GENERATE BOOKING CODE
  Future<void> generateBookingCode(String bookingId) async {
    final uri = Uri.parse('$_baseUrl/api/bookings/$bookingId/generate-code/');
    final resp = await _client.post(uri);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to generate code: ${resp.statusCode}');
    }
  }

  // DELETE BOOKING
  Future<void> deleteBooking(String bookingId) async {
    final uri = Uri.parse('$_baseUrl/api/bookings/$bookingId/');
    final resp = await _client.delete(uri);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to delete booking: ${resp.statusCode}');
    }
  }

  // GET USER TRANSACTIONS (History)
  Future<List<Map<String, dynamic>>> getUserTransactions(String userId) async {
    final uri = Uri.parse('$_baseUrl/api/bookings/user-transactions/?user_id=$userId&limit=10');
    final resp = await _client.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Failed to load transactions: ${resp.statusCode}');
    }
    final list = jsonDecode(resp.body) as List<dynamic>;
    return list.map<Map<String, dynamic>>((e) {
      final m = e as Map<String, dynamic>;
      final booking = Booking.fromJson(m);
      return {
        'booking': booking,
        'item': m['item'] != null ? Item.fromJson(m['item'] as Map<String, dynamic>) : null,
        'imageUrl': m['image_url'] as String?,
        'isBorrower': m['is_borrower'] as bool? ?? (booking.borrowerId == userId),
      };
    }).toList();
  }
}


