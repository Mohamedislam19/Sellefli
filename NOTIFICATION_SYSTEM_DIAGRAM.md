# Notification System - Complete Flow Diagram

## System Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              FLUTTER MOBILE APP                              │
│                                                                               │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                  │
│  │ Notification │    │ FCM Receiver │    │   Supabase   │                  │
│  │    Screen    │    │ (Background) │    │   Realtime   │                  │
│  │              │    │              │    │  Subscriber  │                  │
│  │ - List view  │    │ - Show toast │    │              │                  │
│  │ - Badge cnt  │    │ - Update UI  │    │ - Live sync  │                  │
│  │ - Mark read  │    │ - Navigate   │    │ - Badge upd  │                  │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘                  │
│         │                    │                    │                          │
│         │ HTTP GET/POST      │ FCM Message        │ WebSocket                │
│         │ Authorization:     │ (Push)             │ Subscribe                │
│         │ Bearer JWT         │                    │                          │
└─────────┼────────────────────┼────────────────────┼──────────────────────────┘
          │                    │                    │
          │                    │                    │
          ▼                    ▼                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            DJANGO BACKEND SERVER                             │
│                                                                               │
│  ╔═══════════════════════════════════════════════════════════════════════╗  │
│  ║                         API LAYER (DRF)                                ║  │
│  ╠═══════════════════════════════════════════════════════════════════════╣  │
│  ║                                                                         ║  │
│  ║  GET  /api/notifications/              → List notifications            ║  │
│  ║  GET  /api/notifications/{id}/         → Get detail                    ║  │
│  ║  POST /api/notifications/mark_as_read/ → Mark as read                  ║  │
│  ║  GET  /api/notifications/unread_count/ → Get badge count               ║  │
│  ║  POST /api/devices/                     → Register FCM token           ║  │
│  ║                                                                         ║  │
│  ║  Authentication: SupabaseAuthentication (JWT)                          ║  │
│  ║  Permissions: IsNotificationRecipient, IsDeviceOwner                   ║  │
│  ║                                                                         ║  │
│  ╚═══════════════════════════════════════════════════════════════════════╝  │
│                                    │                                          │
│                                    ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │              NotificationViewSet / UserDeviceViewSet                 │    │
│  │                                                                       │    │
│  │  - Query filtering: recipient=request.user                           │    │
│  │  - Pagination: PageNumberPagination (10/page)                        │    │
│  │  - Serialization: NotificationSerializer                             │    │
│  │  - Permission checks: Has object permission                          │    │
│  └─────────────────────────┬───────────────────────────────────────────┘    │
│                             │                                                 │
│                             ▼                                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    NotificationService                               │    │
│  │                    (Business Logic Layer)                            │    │
│  │                                                                       │    │
│  │  create_notification(recipient, type, title, body, payload)          │    │
│  │      │                                                                │    │
│  │      ├─► Check idempotency_key (prevent duplicates)                  │    │
│  │      ├─► Create Notification record in DB                            │    │
│  │      ├─► Trigger realtime broadcast (Supabase)                       │    │
│  │      └─► Queue push notification task                                │    │
│  │                                                                       │    │
│  │  Specialized creators:                                                │    │
│  │  - create_booking_created_notification(booking)                      │    │
│  │  - create_booking_accepted_notification(booking)                     │    │
│  │  - create_booking_declined_notification(booking)                     │    │
│  │  - create_item_returned_notification(booking)                        │    │
│  │  - create_deposit_released_notification(booking)                     │    │
│  │  - create_rating_received_notification(rating)                       │    │
│  │                                                                       │    │
│  └─────────────────────────┬───────────────────────────────────────────┘    │
│                             │                                                 │
│                             │                                                 │
│          ┌──────────────────┼──────────────────┐                             │
│          │                  │                  │                             │
│          ▼                  ▼                  ▼                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                       │
│  │   Django     │  │   Realtime   │  │     Push     │                       │
│  │   Signals    │  │   Service    │  │   Task       │                       │
│  │              │  │              │  │              │                       │
│  │ Booking.save │  │ POST to      │  │ send_push_   │                       │
│  │ Rating.save  │  │ Supabase     │  │ notification │                       │
│  │              │  │ /rest/v1/    │  │ _task()      │                       │
│  │ ↓ Triggers   │  │ notification │  │              │                       │
│  │ auto-create  │  │ _events      │  │ For each     │                       │
│  │              │  │              │  │ UserDevice:  │                       │
│  └──────────────┘  └──────────────┘  │              │                       │
│                                       │ FCMService   │                       │
│                                       │ .send_notif  │                       │
│                                       └──────┬───────┘                       │
│                                              │                                │
│  ┌───────────────────────────────────────────┴────────────────────────┐     │
│  │                     FCMService (Firebase Integration)               │     │
│  │                                                                      │     │
│  │  send_notification(token, title, body, data)                        │     │
│  │      │                                                               │     │
│  │      ├─► Build FCM payload (notification + data)                    │     │
│  │      ├─► POST to fcm.googleapis.com/fcm/send                        │     │
│  │      ├─► Handle response (success/failure)                          │     │
│  │      ├─► If InvalidToken → mark device inactive                     │     │
│  │      └─► Update notification.push_sent = True                       │     │
│  │                                                                      │     │
│  └──────────────────────────────────────────────────────────────────────┘    │
│                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                     DATABASE MODELS                                  │    │
│  │                                                                       │    │
│  │  ┌─────────────────┐      ┌─────────────────┐                       │    │
│  │  │  Notification   │      │   UserDevice    │                       │    │
│  │  ├─────────────────┤      ├─────────────────┤                       │    │
│  │  │ id (PK)         │      │ id (PK)         │                       │    │
│  │  │ recipient_id FK │      │ user_id FK      │                       │    │
│  │  │ notif_type      │      │ fcm_token UNIQ  │                       │    │
│  │  │ title           │      │ device_type     │                       │    │
│  │  │ body            │      │ device_name     │                       │    │
│  │  │ payload JSONB   │      │ is_active       │                       │    │
│  │  │ is_read         │      │ last_used_at    │                       │    │
│  │  │ read_at         │      │ created_at      │                       │    │
│  │  │ push_sent       │      └─────────────────┘                       │    │
│  │  │ push_sent_at    │                                                 │    │
│  │  │ idempotency_key │                                                 │    │
│  │  │ created_at      │      Indexes:                                  │    │
│  │  │ updated_at      │      - (user_id, is_active)                    │    │
│  │  │ deleted_at      │      - (fcm_token) UNIQUE                      │    │
│  │  └─────────────────┘                                                 │    │
│  │                                                                       │    │
│  │  Indexes:                                                            │    │
│  │  - (recipient_id, created_at DESC)                                  │    │
│  │  - (recipient_id, is_read, created_at DESC)                         │    │
│  │  - (notification_type, created_at DESC)                             │    │
│  │  - (idempotency_key) UNIQUE                                         │    │
│  │                                                                       │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                               │
└───────────────────────────────┬───────────────────────────────────────────────┘
                                │
                                ▼
                    ┌─────────────────────────┐
                    │    PostgreSQL           │
                    │    (Supabase Pooler)    │
                    │                         │
                    │  Tables:                │
                    │  - notifications        │
                    │  - user_devices         │
                    │                         │
                    │  Connection:            │
                    │  - pooler.supabase.com  │
                    │  - port 6543            │
                    │  - SSL required         │
                    └─────────────────────────┘


                    ┌─────────────────────────┐
                    │  Supabase Realtime      │
                    │  (Optional)             │
                    │                         │
                    │  Table:                 │
                    │  - notification_events  │
                    │                         │
                    │  Ephemeral broadcast    │
                    │  WebSocket pub/sub      │
                    └─────────────────────────┘


                    ┌─────────────────────────┐
                    │  Firebase Cloud         │
                    │  Messaging (FCM)        │
                    │                         │
                    │  fcm.googleapis.com     │
                    │                         │
                    │  Delivers push to       │
                    │  Android/iOS devices    │
                    └─────────────────────────┘
```

---

## Event-Driven Flow (Booking Created Example)

```
┌────────────────────────────────────────────────────────────────────┐
│ 1. USER ACTION: Borrower creates booking request via Flutter app   │
└────────────────────┬───────────────────────────────────────────────┘
                     │
                     ▼
┌────────────────────────────────────────────────────────────────────┐
│ 2. API CALL: POST /api/bookings/                                   │
│    {                                                                │
│      "item_id": "...",                                              │
│      "start_date": "2026-01-10",                                   │
│      "return_by_date": "2026-01-15"                                │
│    }                                                                │
└────────────────────┬───────────────────────────────────────────────┘
                     │
                     ▼
┌────────────────────────────────────────────────────────────────────┐
│ 3. DJANGO VIEW: BookingViewSet.create()                            │
│    - Validates data                                                 │
│    - Creates Booking instance                                       │
│    - booking.status = PENDING                                       │
│    - booking.save()  ← This triggers the signal                    │
└────────────────────┬───────────────────────────────────────────────┘
                     │
                     ▼
┌────────────────────────────────────────────────────────────────────┐
│ 4. DJANGO SIGNAL: post_save(sender=Booking, instance=booking)      │
│    @receiver in notifications/signals.py                            │
│    - Checks: created=True and status=PENDING                        │
│    - Calls: NotificationService.create_booking_created_notification │
└────────────────────┬───────────────────────────────────────────────┘
                     │
                     ▼
┌────────────────────────────────────────────────────────────────────┐
│ 5. NOTIFICATION SERVICE:                                            │
│    create_booking_created_notification(booking)                     │
│    ├─► Generate idempotency_key                                     │
│    │   = hash(owner.id + "booking_created" + booking.id)           │
│    │                                                                 │
│    ├─► Check for duplicate                                          │
│    │   Notification.objects.filter(idempotency_key=...).exists()   │
│    │   If exists → return existing, skip creation                  │
│    │                                                                 │
│    ├─► Create notification record                                   │
│    │   Notification.objects.create(                                 │
│    │       recipient=booking.owner,                                 │
│    │       notification_type="booking_created",                     │
│    │       title="New Booking Request",                             │
│    │       body="john_doe wants to borrow your Drill",             │
│    │       payload={booking_id, item_id, ...},                     │
│    │       idempotency_key=key                                      │
│    │   )                                                             │
│    │                                                                 │
│    ├─► Trigger realtime broadcast                                   │
│    │   SupabaseRealtimeService.broadcast_notification()            │
│    │   POST to /rest/v1/notification_events                        │
│    │   → Supabase broadcasts via WebSocket                         │
│    │   → Flutter subscribers receive instant update                │
│    │                                                                 │
│    └─► Queue push notification                                      │
│        send_push_notification_task(notification.id)                │
└────────────────────┬───────────────────────────────────────────────┘
                     │
                     ▼
┌────────────────────────────────────────────────────────────────────┐
│ 6. PUSH NOTIFICATION TASK:                                          │
│    send_push_notification_task(notification_id)                     │
│    ├─► Load notification from DB                                    │
│    ├─► Get active devices for recipient                             │
│    │   UserDevice.objects.filter(user=owner, is_active=True)       │
│    │                                                                 │
│    └─► For each device:                                             │
│        FCMService.send_notification(                                │
│            token=device.fcm_token,                                  │
│            title="New Booking Request",                             │
│            body="john_doe wants to borrow your Drill",             │
│            data={booking_id, item_id, ...}                         │
│        )                                                             │
└────────────────────┬───────────────────────────────────────────────┘
                     │
                     ▼
┌────────────────────────────────────────────────────────────────────┐
│ 7. FCM SERVICE:                                                     │
│    FCMService.send_notification()                                   │
│    ├─► Build FCM payload                                            │
│    │   {                                                             │
│    │     "to": "fGHJ8Kz...xyz",                                     │
│    │     "notification": {title, body},                             │
│    │     "data": {booking_id, item_id, ...}                        │
│    │   }                                                             │
│    │                                                                 │
│    ├─► POST to fcm.googleapis.com/fcm/send                          │
│    │   Authorization: key=FCM_SERVER_KEY                            │
│    │                                                                 │
│    ├─► Handle response                                              │
│    │   Success: notification.push_sent = True                       │
│    │   InvalidToken: device.is_active = False                       │
│    │                                                                 │
│    └─► Save to database                                             │
└────────────────────┬───────────────────────────────────────────────┘
                     │
                     ▼
┌────────────────────────────────────────────────────────────────────┐
│ 8. FLUTTER APP RECEIVES:                                            │
│    ┌──────────────────────────────────────────────────┐            │
│    │ A. Push Notification (FCM)                        │            │
│    │    - Shows system notification                    │            │
│    │    - Updates badge count                          │            │
│    │    - User taps → Navigate to booking detail       │            │
│    └──────────────────────────────────────────────────┘            │
│    ┌──────────────────────────────────────────────────┐            │
│    │ B. Realtime Event (Supabase WebSocket)           │            │
│    │    - Instant in-app update                        │            │
│    │    - Refresh notification list                    │            │
│    │    - Update badge without delay                   │            │
│    └──────────────────────────────────────────────────┘            │
│    ┌──────────────────────────────────────────────────┐            │
│    │ C. API Polling (Fallback)                        │            │
│    │    - GET /api/notifications/unread_count/         │            │
│    │    - Periodic refresh (every 30s when active)     │            │
│    └──────────────────────────────────────────────────┘            │
└────────────────────────────────────────────────────────────────────┘
```

---

## Security Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ Flutter App                                                      │
│   GET /api/notifications/                                        │
│   Headers: {                                                     │
│     "Authorization": "Bearer eyJhbGci...JWT_TOKEN"              │
│   }                                                               │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│ DRF Authentication                                               │
│   SupabaseAuthentication.authenticate(request)                  │
│   ├─► Extract JWT from Authorization header                     │
│   ├─► Verify JWT signature with SUPABASE_JWT_SECRET            │
│   ├─► Extract user_id from JWT payload                          │
│   ├─► Load User instance from database                          │
│   └─► Return (user, token) or raise AuthenticationFailed        │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│ DRF Permission                                                   │
│   IsAuthenticated.has_permission(request, view)                 │
│   ├─► Check request.user is authenticated                       │
│   └─► Deny if anonymous                                         │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│ ViewSet QuerySet Filtering                                       │
│   NotificationViewSet.get_queryset()                             │
│   ├─► Notification.objects.filter(                              │
│   │       recipient=self.request.user,  ← CRITICAL SECURITY     │
│   │       deleted_at__isnull=True                               │
│   │   )                                                          │
│   └─► User can ONLY see their own notifications                 │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│ Object-Level Permission                                          │
│   IsNotificationRecipient.has_object_permission(obj)            │
│   ├─► Check obj.recipient == request.user                       │
│   └─► Prevents access to individual notification if not owner   │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│ Return Data                                                      │
│   Serialized notifications for authenticated user only          │
└─────────────────────────────────────────────────────────────────┘
```

---

## Performance Optimizations

```
┌─────────────────────────────────────────────────────────────────┐
│ Database Level                                                   │
│   ├─► Composite Indexes                                         │
│   │   - (recipient_id, created_at DESC)                         │
│   │   - (recipient_id, is_read, created_at DESC)               │
│   │   Query: WHERE recipient_id = X ORDER BY created_at DESC   │
│   │   Result: Index scan instead of sequential scan            │
│   │                                                              │
│   ├─► Connection Pooling                                        │
│   │   - Supabase pooler (port 6543)                            │
│   │   - CONN_MAX_AGE = 600 (10 min)                            │
│   │   - CONN_HEALTH_CHECKS = True                              │
│   │                                                              │
│   └─► JSONB Payload                                             │
│       - Efficient storage for variable metadata                │
│       - No schema changes needed for new fields                │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ Application Level                                                │
│   ├─► Pagination                                                │
│   │   - PageNumberPagination (10 items/page)                   │
│   │   - Reduces payload size                                    │
│   │   - Faster serialization                                    │
│   │                                                              │
│   ├─► Select Related                                            │
│   │   - .select_related('recipient')                            │
│   │   - Single JOIN query instead of N+1                       │
│   │                                                              │
│   ├─► Lightweight List Serializer                               │
│   │   - NotificationListSerializer (fewer fields)               │
│   │   - Used for list view                                      │
│   │   - Full serializer only for detail view                    │
│   │                                                              │
│   └─► Idempotency Check                                         │
│       - Prevents duplicate DB inserts                           │
│       - Hash-based key generation                               │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ Network Level                                                    │
│   ├─► HTTP/2 (modern clients)                                   │
│   ├─► gzip compression (Django middleware)                      │
│   └─► CDN for static assets (if deployed)                       │
└─────────────────────────────────────────────────────────────────┘
```

---

**Version:** 1.0.0  
**Status:** Production Ready  
**Performance:** Optimized  
**Security:** Enterprise-grade
