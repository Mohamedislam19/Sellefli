enum BookingStatus { pending, accepted, active, completed, declined, closed }

enum DepositStatus { none, received, returned, kept }

class Booking {
  final String id;
  final String itemId;
  final String ownerId;
  final String borrowerId;
  final BookingStatus status;
  final DepositStatus depositStatus;
  final String? bookingCode;
  final DateTime startDate;
  final DateTime returnByDate;
  final double? totalCost;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.itemId,
    required this.ownerId,
    required this.borrowerId,
    this.status = BookingStatus.pending,
    this.depositStatus = DepositStatus.none,
    this.bookingCode,
    required this.startDate,
    required this.returnByDate,
    this.totalCost,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return Booking(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      ownerId: json['owner_id'] as String,
      borrowerId: json['borrower_id'] as String,
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      depositStatus: DepositStatus.values.firstWhere(
        (e) => e.name == json['deposit_status'],
        orElse: () => DepositStatus.none,
      ),
      bookingCode: json['booking_code'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      returnByDate: DateTime.parse(json['return_by_date'] as String),
      totalCost: _toDouble(json['total_cost']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'owner_id': ownerId,
      'borrower_id': borrowerId,
      'status': status.name,
      'deposit_status': depositStatus.name,
      'booking_code': bookingCode,
      'start_date': startDate.toIso8601String(),
      'return_by_date': returnByDate.toIso8601String(),
      'total_cost': totalCost,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
