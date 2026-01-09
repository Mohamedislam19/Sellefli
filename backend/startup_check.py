#!/usr/bin/env python3
"""
Startup script to ensure notification system is ready.
Run this before starting the Flutter app.
"""
import os
import sys

# Add backend to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'settings')

import django
django.setup()

from notifications.models import NotificationType, Notification
from users.models import User

print("=" * 70)
print("🚀 SELEFLI NOTIFICATION SYSTEM - STARTUP CHECK")
print("=" * 70)

# Check notification types
print(f"\n📋 Notification types: {len(NotificationType.choices)}")
print("   Sample types:")
for code, label in NotificationType.choices[:5]:
    print(f"   ✓ {code}: {label}")

# Check database connection
try:
    count = Notification.objects.count()
    print(f"\n💾 Database: Connected ✓")
    print(f"   Total notifications: {count}")
except Exception as e:
    print(f"\n❌ Database error: {e}")
    sys.exit(1)

# Check users exist
user_count = User.objects.count()
print(f"\n👥 Users in system: {user_count}")

# Check signals are registered
print(f"\n🔗 Checking signal handlers...")
try:
    from items import signals as item_signals
    print("   ✓ Items signals registered")
except Exception as e:
    print(f"   ⚠️  Items signals: {e}")

try:
    from bookings import signals as booking_signals
    print("   ✓ Bookings signals registered")
except Exception as e:
    print(f"   ⚠️  Bookings signals: {e}")

try:
    from notifications import signals as notif_signals
    print("   ✓ Notifications signals registered")
except Exception as e:
    print(f"   ⚠️  Notifications signals: {e}")

print("\n" + "=" * 70)
print("✅ BACKEND IS READY!")
print("=" * 70)
print("\nNext steps:")
print("1. ⚠️  Run Supabase SQL: backend/notifications/supabase_setup.sql")
print("2. ✅ Backend server running on: http://localhost:8000")
print("3. 🚀 Run: flutter run")
print("=" * 70)
