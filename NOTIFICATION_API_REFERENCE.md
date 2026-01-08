# 🚀 Notification API Quick Reference

## Authentication
All endpoints require:
```
Authorization: Bearer <jwt_token>
```

---

## 📬 Notification Endpoints

### List Notifications
```http
GET /api/notifications/
```
**Response:**
```json
{
  "count": 42,
  "next": "http://.../api/notifications/?page=2",
  "previous": null,
  "results": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "notification_type": "booking_created",
      "title": "New Booking Request",
      "body": "john_doe wants to borrow your Drill",
      "is_read": false,
      "created_at": "2026-01-08T10:30:00Z"
    }
  ]
}
```

### Get Notification Detail
```http
GET /api/notifications/{id}/
```
**Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "notification_type": "booking_created",
  "title": "New Booking Request",
  "body": "john_doe wants to borrow your Drill",
  "payload": {
    "booking_id": "123e4567-e89b-12d3-a456-426614174000",
    "item_id": "789e4567-e89b-12d3-a456-426614174000",
    "borrower_id": "456e4567-e89b-12d3-a456-426614174000",
    "start_date": "2026-01-10",
    "end_date": "2026-01-15"
  },
  "is_read": false,
  "read_at": null,
  "created_at": "2026-01-08T10:30:00Z",
  "updated_at": "2026-01-08T10:30:00Z"
}
```

### Mark As Read
```http
POST /api/notifications/mark_as_read/
Content-Type: application/json

{
  "notification_ids": [
    "550e8400-e29b-41d4-a716-446655440000",
    "660e8400-e29b-41d4-a716-446655440001"
  ]
}
```
**Response:**
```json
{
  "marked_as_read": 2
}
```

### Mark All As Read
```http
POST /api/notifications/mark_all_as_read/
```
**Response:**
```json
{
  "marked_as_read": 15
}
```

### Get Unread Count
```http
GET /api/notifications/unread_count/
```
**Response:**
```json
{
  "unread_count": 5
}
```

### Delete Notification
```http
DELETE /api/notifications/{id}/
```
**Response:**
```
Status: 204 No Content
```

---

## 📱 Device Endpoints

### Register Device
```http
POST /api/devices/
Content-Type: application/json

{
  "fcm_token": "fGHJ8Kz...xyz123",
  "device_type": "android",
  "device_name": "Samsung Galaxy S21"
}
```
**Response:**
```json
{
  "id": "770e8400-e29b-41d4-a716-446655440000",
  "fcm_token": "fGHJ8Kz...xyz123",
  "device_type": "android",
  "device_name": "Samsung Galaxy S21",
  "is_active": true,
  "last_used_at": "2026-01-08T10:30:00Z",
  "created_at": "2026-01-08T10:30:00Z"
}
```

### List Devices
```http
GET /api/devices/
```
**Response:**
```json
[
  {
    "id": "770e8400-e29b-41d4-a716-446655440000",
    "fcm_token": "fGHJ8Kz...xyz123",
    "device_type": "android",
    "device_name": "Samsung Galaxy S21",
    "is_active": true,
    "last_used_at": "2026-01-08T10:30:00Z",
    "created_at": "2026-01-08T10:30:00Z"
  }
]
```

### Update Device
```http
PATCH /api/devices/{id}/
Content-Type: application/json

{
  "is_active": false
}
```

### Delete Device
```http
DELETE /api/devices/{id}/
```
**Response:**
```
Status: 204 No Content
```

---

## 🔔 Notification Types

| Type | Event | Recipient |
|------|-------|-----------|
| `booking_created` | Borrower creates request | Owner |
| `booking_accepted` | Owner accepts | Borrower |
| `booking_declined` | Owner declines | Borrower |
| `item_returned` | Item marked returned | Owner |
| `deposit_released` | Deposit returned | Borrower |
| `rating_received` | Rating created | Rated user |

---

## 🧪 cURL Examples

### List Notifications
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8000/api/notifications/
```

### Get Unread Count
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8000/api/notifications/unread_count/
```

### Mark As Read
```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"notification_ids": ["550e8400-e29b-41d4-a716-446655440000"]}' \
  http://localhost:8000/api/notifications/mark_as_read/
```

### Register Device
```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"fcm_token": "test-token", "device_type": "android"}' \
  http://localhost:8000/api/devices/
```

---

## 🎯 Common Workflows

### 1. Initial App Load
```
1. GET /api/notifications/unread_count/
2. Display badge with count
3. User taps notifications icon
4. GET /api/notifications/?page=1
5. Display list
```

### 2. Mark Notification Read
```
1. User taps notification
2. POST /api/notifications/mark_as_read/
3. Navigate to relevant screen
4. Update badge count
```

### 3. Device Registration (First Launch)
```
1. Get FCM token from Firebase
2. POST /api/devices/
3. Store device_id locally
4. Subscribe to Supabase Realtime (optional)
```

### 4. Refresh Notifications
```
1. Pull-to-refresh triggered
2. GET /api/notifications/?page=1
3. Update list
4. GET /api/notifications/unread_count/
5. Update badge
```

---

## ⚡ Rate Limits

- **Anonymous:** 100 requests/hour
- **Authenticated:** 1000 requests/hour

---

## ❌ Error Responses

### 401 Unauthorized
```json
{
  "detail": "Authentication credentials were not provided."
}
```

### 403 Forbidden
```json
{
  "detail": "You do not have permission to perform this action."
}
```

### 404 Not Found
```json
{
  "detail": "Not found."
}
```

### 400 Bad Request
```json
{
  "error": "No notification IDs provided"
}
```

---

## 🔗 Related Documentation
- [Complete Technical Docs](backend/notifications/NOTIFICATION_SYSTEM_DOCS.md)
- [Setup Guide](backend/notifications/SETUP_GUIDE.md)
- [Implementation Summary](NOTIFICATION_IMPLEMENTATION_SUMMARY.md)
