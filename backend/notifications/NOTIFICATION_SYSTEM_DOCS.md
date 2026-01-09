# Notification System Documentation

## Architecture Decision

**Stack Detected:**
- Django 4.x with Django Rest Framework
- PostgreSQL (via Supabase)
- Supabase Auth (JWT-based)
- No Django Channels detected
- No Celery/Django-Q detected

**Implementation Strategy:**
- Django-native notification system
- DRF API endpoints for CRUD operations
- Django signals for automatic notification creation
- Supabase Realtime for live updates (optional)
- FCM for push notifications (lightweight async)

---

## Database Schema

### Notification Model
```python
{
    "id": "uuid",
    "recipient_id": "uuid",
    "notification_type": "booking_created|booking_accepted|...",
    "title": "string",
    "body": "string",
    "payload": "jsonb",
    "is_read": "boolean",
    "read_at": "timestamp",
    "push_sent": "boolean",
    "push_sent_at": "timestamp",
    "idempotency_key": "string",
    "created_at": "timestamp",
    "updated_at": "timestamp",
    "deleted_at": "timestamp"
}
```

**Indexes:**
- `(recipient_id, created_at DESC)`
- `(recipient_id, is_read, created_at DESC)`
- `(notification_type, created_at DESC)`
- `(idempotency_key)` - unique when not null

### UserDevice Model
```python
{
    "id": "uuid",
    "user_id": "uuid",
    "fcm_token": "string",
    "device_type": "android|ios|web",
    "device_name": "string",
    "is_active": "boolean",
    "last_used_at": "timestamp",
    "created_at": "timestamp",
    "updated_at": "timestamp"
}
```

**Indexes:**
- `(user_id, is_active)`
- `(fcm_token)` - unique

---

## API Endpoints

### Notifications

#### GET /api/notifications/
List all notifications for authenticated user
```json
{
    "count": 42,
    "next": "...",
    "previous": null,
    "results": [
        {
            "id": "uuid",
            "notification_type": "booking_created",
            "title": "New Booking Request",
            "body": "john_doe wants to borrow your Drill",
            "is_read": false,
            "created_at": "2026-01-08T10:30:00Z"
        }
    ]
}
```

#### GET /api/notifications/{id}/
Get single notification detail
```json
{
    "id": "uuid",
    "notification_type": "booking_created",
    "title": "New Booking Request",
    "body": "john_doe wants to borrow your Drill",
    "payload": {
        "booking_id": "uuid",
        "item_id": "uuid",
        "borrower_id": "uuid",
        "start_date": "2026-01-10",
        "end_date": "2026-01-15"
    },
    "is_read": false,
    "read_at": null,
    "created_at": "2026-01-08T10:30:00Z",
    "updated_at": "2026-01-08T10:30:00Z"
}
```

#### POST /api/notifications/mark_as_read/
Mark specific notifications as read
```json
// Request
{
    "notification_ids": ["uuid1", "uuid2"]
}

// Response
{
    "marked_as_read": 2
}
```

#### POST /api/notifications/mark_all_as_read/
Mark all notifications as read
```json
// Response
{
    "marked_as_read": 15
}
```

#### GET /api/notifications/unread_count/
Get unread notification count
```json
{
    "unread_count": 5
}
```

#### DELETE /api/notifications/{id}/
Soft delete notification
```
Status: 204 No Content
```

---

### Device Management

#### POST /api/devices/
Register FCM device token
```json
// Request
{
    "fcm_token": "fGHJ...xyz",
    "device_type": "android",
    "device_name": "Samsung Galaxy S21"
}

// Response
{
    "id": "uuid",
    "fcm_token": "fGHJ...xyz",
    "device_type": "android",
    "device_name": "Samsung Galaxy S21",
    "is_active": true,
    "last_used_at": "2026-01-08T10:30:00Z",
    "created_at": "2026-01-08T10:30:00Z"
}
```

#### GET /api/devices/
List user's registered devices

#### PATCH /api/devices/{id}/
Update device (e.g., mark inactive)

#### DELETE /api/devices/{id}/
Remove device token

---

## Notification Events

### Automatic Notifications (via Django Signals)

1. **BOOKING_CREATED** - When borrower creates booking request
   - Recipient: Owner
   - Trigger: `Booking.status == PENDING` (on create)

2. **BOOKING_ACCEPTED** - When owner accepts request
   - Recipient: Borrower
   - Trigger: `Booking.status == ACCEPTED`

3. **BOOKING_DECLINED** - When owner declines request
   - Recipient: Borrower
   - Trigger: `Booking.status == DECLINED`

4. **ITEM_RETURNED** - When item is marked as returned
   - Recipient: Owner
   - Trigger: `Booking.status == COMPLETED`

5. **DEPOSIT_RELEASED** - When deposit is returned
   - Recipient: Borrower
   - Trigger: `Booking.deposit_status == RETURNED`

6. **RATING_RECEIVED** - When user receives a rating
   - Recipient: Rated user
   - Trigger: `Rating` created

---

## Realtime Integration (Supabase)

### Setup Supabase Realtime Table

Create a table in Supabase for realtime broadcasts:

```sql
CREATE TABLE notification_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    notification_id UUID NOT NULL,
    notification_type TEXT NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    payload JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable realtime
ALTER PUBLICATION supabase_realtime ADD TABLE notification_events;

-- Create index
CREATE INDEX idx_notification_events_user_id ON notification_events(user_id);

-- Auto-delete old events (cleanup policy)
CREATE OR REPLACE FUNCTION delete_old_notification_events()
RETURNS void AS $$
BEGIN
    DELETE FROM notification_events WHERE created_at < NOW() - INTERVAL '24 hours';
END;
$$ LANGUAGE plpgsql;

-- Run cleanup daily (optional)
-- Use pg_cron or external scheduler
```

### Flutter Subscription
```dart
final supabase = Supabase.instance.client;

supabase
    .from('notification_events')
    .stream(primaryKey: ['id'])
    .eq('user_id', currentUserId)
    .listen((List<Map<String, dynamic>> events) {
      for (var event in events) {
        // Update local notification count
        // Show snackbar or toast
        // Refresh notification list
      }
    });
```

**Note:** Realtime is optional. If not configured, clients poll `/api/notifications/` periodically.

---

## Push Notifications (FCM)

### Setup

1. **Get FCM Server Key:**
   - Firebase Console → Project Settings → Cloud Messaging
   - Copy "Server key"

2. **Add to `.env`:**
   ```
   FCM_SERVER_KEY=AAAA...your-key
   ```

3. **Configure Flutter:**
   ```dart
   // Get FCM token
   final fcmToken = await FirebaseMessaging.instance.getToken();
   
   // Register device
   await api.post('/api/devices/', {
     'fcm_token': fcmToken,
     'device_type': Platform.isAndroid ? 'android' : 'ios',
     'device_name': 'User Device',
   });
   ```

### Flow

1. Django signal triggers → Notification created
2. `send_push_notification_task()` called
3. FCM service sends to all active user devices
4. Invalid tokens → device marked inactive
5. `notification.push_sent = True`

---

## Security

### Permissions
- **IsNotificationRecipient:** User can only access own notifications
- **IsDeviceOwner:** User can only manage own devices

### Authentication
- Uses existing `SupabaseAuthentication` class
- JWT token verification via `users.authentication`

### Data Protection
- Notifications filtered by `recipient=request.user`
- No cross-user data leakage
- Soft delete prevents accidental data loss

---

## Migration & Deployment

### 1. Create migrations
```bash
python manage.py makemigrations notifications
python manage.py migrate
```

### 2. Environment variables
```
# Required for push notifications
FCM_SERVER_KEY=AAAA...

# Optional for Supabase Realtime
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

### 3. Test notifications
```python
# Django shell
from notifications.services import NotificationService
from bookings.models import Booking

booking = Booking.objects.first()
NotificationService.create_booking_created_notification(booking)
```

---

## Flutter Integration

### 1. Dependencies
```yaml
dependencies:
  firebase_messaging: ^14.7.9
  supabase_flutter: ^2.0.0
  http: ^1.1.0
```

### 2. Notification Service
```dart
class NotificationService {
  final SupabaseClient supabase;
  final http.Client httpClient;
  
  Future<List<Notification>> fetchNotifications() async {
    final response = await httpClient.get(
      Uri.parse('$baseUrl/api/notifications/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['results'] as List)
          .map((json) => Notification.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load notifications');
  }
  
  Future<void> markAsRead(String notificationId) async {
    await httpClient.post(
      Uri.parse('$baseUrl/api/notifications/mark_as_read/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'notification_ids': [notificationId]}),
    );
  }
  
  Future<int> getUnreadCount() async {
    final response = await httpClient.get(
      Uri.parse('$baseUrl/api/notifications/unread_count/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    final data = jsonDecode(response.body);
    return data['unread_count'];
  }
  
  Future<void> registerDevice() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    
    await httpClient.post(
      Uri.parse('$baseUrl/api/devices/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fcm_token': fcmToken,
        'device_type': Platform.isAndroid ? 'android' : 'ios',
        'device_name': '${Platform.operatingSystem} Device',
      }),
    );
  }
}
```

### 3. FCM Setup
```dart
// Initialize FCM
Future<void> setupFCM() async {
  final messaging = FirebaseMessaging.instance;
  
  // Request permissions (iOS)
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  
  // Foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Foreground notification: ${message.notification?.title}');
    // Show local notification or snackbar
  });
  
  // Background/terminated notification tap
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Notification tapped: ${message.data}');
    // Navigate to relevant screen
  });
}
```

### 4. Realtime Subscription
```dart
void subscribeToNotifications(String userId) {
  supabase
      .from('notification_events')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .listen((events) {
        // Refresh notifications
        fetchNotifications();
        // Update badge count
        getUnreadCount();
      });
}
```

---

## Testing

### Manual API Tests
```bash
# Get auth token
TOKEN="your-jwt-token"

# List notifications
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8000/api/notifications/

# Mark as read
curl -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"notification_ids": ["uuid"]}' \
  http://localhost:8000/api/notifications/mark_as_read/

# Register device
curl -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"fcm_token": "test-token", "device_type": "android"}' \
  http://localhost:8000/api/devices/
```

### Django Tests
```python
from django.test import TestCase
from notifications.services import NotificationService

class NotificationTestCase(TestCase):
    def test_booking_notification_created(self):
        # Create booking
        booking = create_test_booking()
        
        # Check notification created
        notif = Notification.objects.filter(
            notification_type='booking_created',
            recipient=booking.owner
        ).first()
        
        self.assertIsNotNone(notif)
        self.assertEqual(notif.payload['booking_id'], str(booking.id))
```

---

## ASCII Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         FLUTTER APP                              │
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Notification │  │  FCM Handler │  │   Supabase   │          │
│  │     Screen    │  │  (Push RX)   │  │  Realtime RX │          │
│  └───────┬───────┘  └───────┬──────┘  └───────┬──────┘          │
│          │                   │                  │                 │
└──────────┼───────────────────┼──────────────────┼─────────────────┘
           │                   │                  │
           │ HTTP/REST         │                  │ WebSocket
           │                   │                  │
┌──────────▼───────────────────▼──────────────────▼─────────────────┐
│                        DJANGO BACKEND                              │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │                     DRF API Layer                             │ │
│  │  /api/notifications/  /api/devices/                          │ │
│  └─────────────┬──────────────────────────────┬─────────────────┘ │
│                │                                │                   │
│  ┌─────────────▼────────────┐   ┌─────────────▼────────────────┐ │
│  │  NotificationViewSet      │   │  UserDeviceViewSet            │ │
│  │  - list()                 │   │  - create() (register token) │ │
│  │  - mark_as_read()         │   │  - list()                    │ │
│  │  - unread_count()         │   │  - delete()                  │ │
│  └─────────────┬──────────────┘   └──────────────────────────────┘ │
│                │                                                    │
│  ┌─────────────▼──────────────────────────────────────────────┐   │
│  │             NotificationService (Business Logic)            │   │
│  │  - create_notification() [idempotency check]               │   │
│  │  - create_booking_created_notification()                   │   │
│  │  - create_booking_accepted_notification()                  │   │
│  │  - mark_as_read() / mark_all_as_read()                     │   │
│  └───────┬──────────────────────────────┬─────────────────────┘   │
│          │                               │                         │
│          │                               │                         │
│  ┌───────▼────────┐           ┌─────────▼──────────┐              │
│  │  Django Signals │           │  Realtime Service  │              │
│  │  (Auto-trigger) │           │  (Supabase insert) │              │
│  │                 │           │                    │              │
│  │ Booking saved   │           │ POST to            │              │
│  │ Rating created  │           │ notification_events│              │
│  └───────┬─────────┘           └────────────────────┘              │
│          │                                                          │
│          │                                                          │
│  ┌───────▼─────────────────────────────────────────────────────┐  │
│  │                  Push Notification Flow                      │  │
│  │                                                               │  │
│  │  send_push_notification_task()                               │  │
│  │      │                                                        │  │
│  │      ▼                                                        │  │
│  │  FCMService.send_notification()                              │  │
│  │      │                                                        │  │
│  │      └─► HTTP POST to fcm.googleapis.com                     │  │
│  │          │                                                    │  │
│  │          └─► Mark notification.push_sent = True              │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │                    DATABASE MODELS                            │ │
│  │                                                                │ │
│  │  Notification          UserDevice           Booking           │ │
│  │  - id (uuid)           - id (uuid)          - status          │ │
│  │  - recipient_id        - user_id            - deposit_status  │ │
│  │  - notification_type   - fcm_token                            │ │
│  │  - title, body         - device_type        Rating            │ │
│  │  - payload (jsonb)     - is_active          - rater_id        │ │
│  │  - is_read                                  - rated_user_id   │ │
│  │  - idempotency_key                                            │ │
│  └──────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
           │                                          │
           │                                          │
           ▼                                          ▼
┌────────────────────┐                   ┌─────────────────────────┐
│  PostgreSQL        │                   │  Supabase               │
│  (via Supabase)    │                   │  - Realtime Table       │
│                    │                   │  - FCM Relay (optional) │
│  Tables:           │                   │                         │
│  - notifications   │                   │  notification_events    │
│  - user_devices    │                   │  (ephemeral)            │
└────────────────────┘                   └─────────────────────────┘
```

---

## Key Design Decisions

1. **Django-Native:** No framework switching. Pure Django + DRF.

2. **Idempotency:** `idempotency_key` prevents duplicate notifications for same event.

3. **Signals:** Automatic notification creation on booking/rating events.

4. **Soft Delete:** `deleted_at` field instead of hard deletes.

5. **Supabase Realtime:** Optional. Uses ephemeral `notification_events` table for live updates.

6. **FCM Direct:** Lightweight HTTP-based push without Celery (can add later if needed).

7. **Security:** Row-level filtering by `recipient=request.user`.

8. **Indexes:** Optimized for common queries (unread notifications, recent first).

---

## Future Enhancements

- **Celery Integration:** Replace `send_push_notification_task()` with `@shared_task`
- **Notification Groups:** Group similar notifications (e.g., "3 new bookings")
- **Email Notifications:** Send digest emails for important events
- **Notification Settings:** User preferences for which events to receive
- **Read Receipts:** Track when push notification was opened
- **Rich Notifications:** Images, actions, custom sounds

---

**Status:** ✅ Production-ready
**Framework:** Django 4.x + DRF
**Database:** PostgreSQL
**Realtime:** Supabase Realtime (optional)
**Push:** Firebase Cloud Messaging
