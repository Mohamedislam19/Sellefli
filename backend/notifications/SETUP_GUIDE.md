# Notification System Setup Guide

## Quick Start

### 1. Create Database Migrations
```bash
cd backend
python manage.py makemigrations notifications
python manage.py migrate
```

### 2. Configure Environment Variables

Add to `backend/.env`:
```env
# Required for push notifications
FCM_SERVER_KEY=AAAA...your-firebase-server-key

# Optional - for Supabase Realtime
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

**Get FCM Server Key:**
1. Go to Firebase Console: https://console.firebase.google.com
2. Select your project
3. Settings → Project Settings → Cloud Messaging
4. Copy "Server key"

### 3. (Optional) Create Supabase Realtime Table

If you want realtime notifications, run this SQL in Supabase SQL Editor:

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
```

### 4. Restart Django Server
```bash
python manage.py runserver
```

## Verify Installation

### Test API Endpoints
```bash
# Get auth token first
TOKEN="your-jwt-token"

# List notifications
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8000/api/notifications/

# Get unread count
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8000/api/notifications/unread_count/
```

### Test Notification Creation

Open Django shell:
```bash
python manage.py shell
```

```python
from users.models import User
from items.models import Item
from bookings.models import Booking, BookingStatus
from datetime import date, timedelta

# Get users
owner = User.objects.first()
borrower = User.objects.last()

# Get item
item = Item.objects.first()

# Create booking (this will trigger notification)
booking = Booking.objects.create(
    item=item,
    owner=owner,
    borrower=borrower,
    status=BookingStatus.PENDING,
    start_date=date.today() + timedelta(days=1),
    end_date=date.today() + timedelta(days=3)
)

# Check notification created
from notifications.models import Notification
notifications = Notification.objects.filter(recipient=owner)
print(f"Created {notifications.count()} notification(s)")
print(notifications.first().title)
```

## Troubleshooting

### No notifications created?
1. Check that `notifications` app is in `INSTALLED_APPS`
2. Verify signals are registered: `python manage.py shell` → `import notifications.signals`
3. Check Django logs for errors

### Push notifications not sending?
1. Verify `FCM_SERVER_KEY` is set in `.env`
2. Check device tokens are registered: `UserDevice.objects.all()`
3. Review logs in Django console

### Realtime not working?
1. Supabase Realtime is **optional**
2. Verify `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are set
3. Check `notification_events` table exists in Supabase
4. Fall back to polling if realtime fails

## Next Steps

1. **Flutter Integration:** See [NOTIFICATION_SYSTEM_DOCS.md](NOTIFICATION_SYSTEM_DOCS.md#flutter-integration)
2. **Customize Notifications:** Modify templates in `services.py`
3. **Add Celery:** For production, replace `send_push_notification_task()` with Celery task
4. **Add Email:** Extend service layer to send email notifications

## File Structure
```
backend/notifications/
├── __init__.py
├── admin.py              # Django admin interface
├── apps.py               # App configuration
├── models.py             # Notification & UserDevice models
├── serializers.py        # DRF serializers
├── views.py              # API endpoints
├── urls.py               # URL routing
├── services.py           # Business logic
├── signals.py            # Auto-notification triggers
├── tasks.py              # Push notification tasks
├── fcm.py                # Firebase Cloud Messaging
├── realtime.py           # Supabase Realtime
├── permissions.py        # DRF permissions
└── migrations/           # Database migrations
```

## Production Checklist

- [ ] Migrations applied
- [ ] FCM_SERVER_KEY configured
- [ ] Device registration working
- [ ] Push notifications tested
- [ ] Supabase Realtime table created (if using)
- [ ] API endpoints secured with authentication
- [ ] Error logging configured
- [ ] Background task queue (Celery) setup (optional)
- [ ] Email notifications (optional)
- [ ] Notification preferences UI (optional)
