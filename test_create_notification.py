"""
Create a test notification to verify the system is working.
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'backend'))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'settings')

try:
    import django
    django.setup()
    
    from users.models import User
    from notifications.services import NotificationService
    from notifications.models import NotificationType
    
    print("\n" + "="*70)
    print("  CREATING TEST NOTIFICATION")
    print("="*70 + "\n")
    
    # Get the first user
    user = User.objects.first()
    if not user:
        print("❌ No users found in database")
        print("   Create a user account first")
        sys.exit(1)
    
    print(f"Creating test notification for user: {user.username}")
    print(f"User ID: {user.id}\n")
    
    # Create a test notification
    notification = NotificationService.create_notification(
        recipient=user,
        notification_type=NotificationType.BOOKING_CREATED,
        title="🎉 Test Notification",
        body="Your notification system is working! This is a test message to verify real-time notifications.",
        payload={
            "test": True,
            "timestamp": "2026-01-10",
            "message": "If you see this in your Flutter app, everything is working correctly!"
        },
        send_push=False  # Don't send push notification for test
    )
    
    if notification:
        print("✅ Test notification created successfully!")
        print(f"   ID: {notification.id}")
        print(f"   Type: {notification.notification_type}")
        print(f"   Title: {notification.title}")
        print(f"   Body: {notification.body}")
        print(f"   Recipient: {notification.recipient.username}")
        print()
        
        # Check if notification_event was created
        from django.db import connection
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT COUNT(*) FROM notification_events 
                WHERE user_id = %s
            """, [str(user.id)])
            event_count = cursor.fetchone()[0]
            
            if event_count > 0:
                print(f"✅ Notification event broadcasted ({event_count} total events for this user)")
                print("   The Flutter app should receive this in real-time!")
            else:
                print("⚠️  No notification event found")
                print("   Check if the signal/trigger is working")
        
        print("\n" + "="*70)
        print("  TEST COMPLETE")
        print("="*70 + "\n")
        
        print("Next Steps:")
        print("1. Open your Flutter app (or run: flutter run)")
        print("2. Login as user:", user.username)
        print("3. Check the notifications page")
        print("4. You should see the test notification!")
        print()
        print("To create more test notifications, run:")
        print("  python test_create_notification.py")
        print()
        
    else:
        print("❌ Failed to create notification")
        sys.exit(1)
        
except Exception as e:
    print(f"\n❌ ERROR: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
