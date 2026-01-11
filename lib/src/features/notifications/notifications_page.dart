import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _notificationService = NotificationService();
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _loading = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final notifications = await _notificationService.getNotifications(userId);
      setState(() {
        _notifications = notifications;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        actions: [
          if (_notifications.any((n) => !(n['is_read'] ?? false)))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              "You'll be notified about bookings and updates",
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        itemCount: _notifications.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['is_read'] ?? false;
    final type = notification['notification_type'] ?? '';
    final title = notification['title'] ?? 'Notification';
    final body = notification['body'] ?? '';
    final createdAt = notification['created_at'] ?? '';

    return Dismissible(
      key: Key(notification['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) => _deleteNotification(notification['id']),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRead ? Colors.grey[200]! : Colors.blue[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getColorForType(type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIconForType(type),
              color: _getColorForType(type),
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
              fontSize: 15,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                body,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                _formatTime(createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          onTap: () => _handleNotificationTap(notification),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    if (type.contains('booking_created')) return Icons.event_available;
    if (type.contains('booking_accepted')) return Icons.check_circle;
    if (type.contains('booking_declined')) return Icons.cancel;
    if (type.contains('booking_canceled')) return Icons.event_busy;
    if (type.contains('booking_started')) return Icons.play_arrow;
    if (type.contains('booking_completed')) return Icons.task_alt;
    if (type.contains('rating')) return Icons.star;
    if (type.contains('deposit')) return Icons.attach_money;
    if (type.contains('item_deleted')) return Icons.delete;
    if (type.contains('item_unavailable')) return Icons.block;
    return Icons.notifications;
  }

  Color _getColorForType(String type) {
    if (type.contains('accepted') || type.contains('completed')) {
      return Colors.green;
    }
    if (type.contains('declined') || type.contains('canceled') || type.contains('deleted')) {
      return Colors.red;
    }
    if (type.contains('deposit')) return Colors.orange;
    if (type.contains('rating')) return Colors.amber;
    return Colors.blue;
  }

  String _formatTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 7) {
        return '${date.day}/${date.month}/${date.year}';
      }
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (e) {
      return '';
    }
  }

  Future<void> _handleNotificationTap(Map<String, dynamic> notification) async {
    final isRead = notification['is_read'] ?? false;
    if (!isRead) {
      await _notificationService.markAsRead(notification['id']);
      setState(() {
        notification['is_read'] = true;
      });
    }

    final payload = notification['payload'] as Map<String, dynamic>?;
    if (payload == null || !mounted) return;

    // Navigate based on notification type and payload
    if (payload.containsKey('booking_id')) {
      Navigator.pushNamed(
        context,
        '/booking-detail',
        arguments: payload['booking_id'],
      );
    } else if (payload.containsKey('item_id')) {
      Navigator.pushNamed(
        context,
        '/item-detail',
        arguments: payload['item_id'],
      );
    }
  }

  Future<void> _markAllAsRead() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      await _notificationService.markAllAsRead(userId);
      await _loadNotifications();
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    await _notificationService.deleteNotification(notificationId);
    setState(() {
      _notifications.removeWhere((n) => n['id'] == notificationId);
    });
  }
}
