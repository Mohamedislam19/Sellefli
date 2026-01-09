import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing real-time notifications
class NotificationService {
  final _supabase = Supabase.instance.client;
  RealtimeChannel? _channel;

  /// Subscribe to realtime notifications for current user
  void subscribeToNotifications(
    String userId,
    Function(Map<String, dynamic>) onNotification,
  ) {
    _channel = _supabase
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notification_events',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final notification = payload.newRecord;
            onNotification(notification);
          },
        )
        .subscribe();
  }

  /// Unsubscribe from notifications
  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }

  /// Fetch all notifications for user
  Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('recipient_id', userId)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase.from('notifications').update({
        'is_read': true,
        'read_at': DateTime.now().toIso8601String(),
      }).eq('id', notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase.from('notifications').update({
        'is_read': true,
        'read_at': DateTime.now().toIso8601String(),
      }).eq('recipient_id', userId).eq('is_read', false);
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  /// Get unread count
  Future<int> getUnreadCount(String userId) async {
    try {
      final count = await _supabase
          .from('notifications')
          .count(CountOption.exact)
          .eq('recipient_id', userId)
          .eq('is_read', false)
          .isFilter('deleted_at', null);

      return count;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  /// Delete notification (soft delete)
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase.from('notifications').update({
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', notificationId);
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
}
