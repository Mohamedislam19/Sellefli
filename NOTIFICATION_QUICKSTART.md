# 🔔 Notification System - QUICK START

**Status:** ✅ Installed & Operational  
**Branch:** `notifications`  
**Commit:** `fc13cae`

---

## ⚡ 30-Second Overview

A complete, production-ready notification system is now installed in Selefli:

- ✅ **Database:** Tables created & migrated
- ✅ **API:** 8 REST endpoints live
- ✅ **Auto-triggers:** Signals active for bookings & ratings
- ✅ **Verified:** Tests passed with real data

---

## 🎯 What You Can Do Right Now

### 1. Test the API (No setup needed)

```bash
# Get your JWT token first, then:
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8000/api/notifications/unread_count/

# Response: {"unread_count": 0}
```

### 2. Create a Booking → Notification Auto-Created

Every booking you create will now automatically generate a notification for the owner:

```python
# In your app or Django shell
booking = Booking.objects.create(...)
# → Notification created automatically! ✨
```

### 3. View in Django Admin

```bash
python backend/manage.py runserver
# Navigate to: http://localhost:8000/admin/notifications/notification/
```

---

## 📱 Enable Push Notifications (Optional - 2 minutes)

### Step 1: Get Firebase Server Key
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Settings → Cloud Messaging
4. Copy "Server key"

### Step 2: Add to Environment
Edit `backend/.env`:
```env
FCM_SERVER_KEY=AAAA...your-key-here
```

### Step 3: Restart Server
```bash
python backend/manage.py runserver
```

**Done!** Push notifications now work.

---

## 🔌 API Endpoints (All Working)

| Endpoint | Method | What It Does |
|----------|--------|--------------|
| `/api/notifications/` | GET | List all notifications |
| `/api/notifications/{id}/` | GET | Get one notification |
| `/api/notifications/mark_as_read/` | POST | Mark as read |
| `/api/notifications/mark_all_as_read/` | POST | Mark all as read |
| `/api/notifications/unread_count/` | GET | Get badge count |
| `/api/notifications/{id}/` | DELETE | Delete notification |
| `/api/devices/` | POST | Register device token |
| `/api/devices/` | GET | List devices |

---

## 🎓 Documentation

Everything is documented:

| Document | Purpose |
|----------|---------|
| [NOTIFICATION_INSTALLATION_COMPLETE.md](NOTIFICATION_INSTALLATION_COMPLETE.md) | What was installed |
| [NOTIFICATION_API_REFERENCE.md](NOTIFICATION_API_REFERENCE.md) | API usage guide |
| [NOTIFICATION_IMPLEMENTATION_SUMMARY.md](NOTIFICATION_IMPLEMENTATION_SUMMARY.md) | Technical overview |
| [backend/notifications/SETUP_GUIDE.md](backend/notifications/SETUP_GUIDE.md) | Setup help |
| [backend/notifications/NOTIFICATION_SYSTEM_DOCS.md](backend/notifications/NOTIFICATION_SYSTEM_DOCS.md) | Complete docs |

---

## 🚀 Flutter Integration (When Ready)

```dart
// 1. Fetch notifications
final response = await http.get(
  Uri.parse('$baseUrl/api/notifications/'),
  headers: {'Authorization': 'Bearer $token'},
);

// 2. Get unread count
final count = await http.get(
  Uri.parse('$baseUrl/api/notifications/unread_count/'),
  headers: {'Authorization': 'Bearer $token'},
);

// 3. Register device
final fcmToken = await FirebaseMessaging.instance.getToken();
await http.post(
  Uri.parse('$baseUrl/api/devices/'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'fcm_token': fcmToken,
    'device_type': Platform.isAndroid ? 'android' : 'ios',
  }),
);
```

Full Flutter guide: [backend/notifications/NOTIFICATION_SYSTEM_DOCS.md#flutter-integration](backend/notifications/NOTIFICATION_SYSTEM_DOCS.md#flutter-integration)

---

## ✨ Automatic Notifications

These events now trigger automatic notifications:

| Event | Who Gets Notified |
|-------|-------------------|
| Booking created | Item owner |
| Booking accepted | Borrower |
| Booking declined | Borrower |
| Item returned | Item owner |
| Deposit released | Borrower |
| Rating received | Rated user |

**No code needed** - Django signals handle everything automatically.

---

## 🎉 That's It!

The notification system is fully operational. Start using it right away:

1. **Test the API** with curl or Postman
2. **Create bookings** - notifications auto-generate
3. **Add FCM key** when ready for push
4. **Integrate with Flutter** when ready

**Everything just works.** ✅

---

**Questions?** Check [SETUP_GUIDE.md](backend/notifications/SETUP_GUIDE.md#troubleshooting)
