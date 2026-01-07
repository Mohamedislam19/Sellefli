import 'package:flutter_test/flutter_test.dart';
import 'package:sellefli/src/data/models/booking_model.dart';

import '../../../helpers/test_bootstrap.dart';

void main() {
  bootstrapUnitTests();

  group('Booking model', () {
    test('fromJson/toJson preserves enum names', () {
      final json = {
        'id': 'b1',
        'item_id': 'i1',
        'owner_id': 'u1',
        'borrower_id': 'u2',
        'status': 'accepted',
        'deposit_status': 'received',
        'booking_code': 'SF-123-456',
        'start_date': '2024-01-01T00:00:00.000Z',
        'return_by_date': '2024-01-02T00:00:00.000Z',
        'total_cost': 12.5,
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-02T00:00:00.000Z',
      };

      final booking = Booking.fromJson(json);
      expect(booking.status, BookingStatus.accepted);
      expect(booking.depositStatus, DepositStatus.received);

      final serialized = booking.toJson();
      expect(serialized['status'], 'accepted');
      expect(serialized['deposit_status'], 'received');
      expect(serialized['total_cost'], 12.5);
    });

    test('fromJson falls back to defaults for unknown enum values', () {
      final json = {
        'id': 'b1',
        'item_id': 'i1',
        'owner_id': 'u1',
        'borrower_id': 'u2',
        'status': 'nope',
        'deposit_status': 'nope',
        'start_date': '2024-01-01T00:00:00.000Z',
        'return_by_date': '2024-01-02T00:00:00.000Z',
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-02T00:00:00.000Z',
      };

      final booking = Booking.fromJson(json);
      expect(booking.status, BookingStatus.pending);
      expect(booking.depositStatus, DepositStatus.none);
    });
  });
}
