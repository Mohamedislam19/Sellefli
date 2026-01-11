"""
Test script to verify notification system is working correctly.
"""
import os
import sys
import django

# Setup Django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'settings')
django.setup()

from users.models import User
from notifications.models import Notification, NotificationType
from notifications.services import NotificationService


def test_notification_system():
    """Test the notification system."""
    print("\n" + "="*60)
    print("  Notification System Verification Test")
    print("="*60 + "\n")
    
    # Check if users exist
    user_count = User.objects.count()
    print(f"✅ Database connected: {user_count} users in database")
    
    # Check notification models
    notification_count = Notification.objects.count()
    print(f"✅ Notification table created: {notification_count} existing notifications")
    
    # Test creating a notification (if user exists)
    if user_count > 0:
        test_user = User.objects.first()
        print(f"\n📝 Creating test notification for: {test_user.username}")
        
        notification = NotificationService.create_notification(
            recipient=test_user,
            notification_type=NotificationType.BOOKING_CREATED,
            title="Test Notification",
            body="This is a test notification to verify the system works",
            payload={"test": True, "created_by": "verification_script"},
            send_push=False  # Don't send push for test
        )
        
        if notification:
            print(f"✅ Notification created successfully!")
            print(f"   ID: {notification.id}")
            print(f"   Type: {notification.notification_type}")
            print(f"   Title: {notification.title}")
            print(f"   Recipient: {notification.recipient.username}")
            
            # Test idempotency
            print(f"\n🔄 Testing idempotency...")
            duplicate = NotificationService.create_notification(
                recipient=test_user,
                notification_type=NotificationType.BOOKING_CREATED,
                title="Test Notification",
                body="This is a test notification to verify the system works",
                payload={"test": True, "created_by": "verification_script"},
                idempotency_key=notification.idempotency_key,
                send_push=False
            )
            
            if duplicate and duplicate.id == notification.id:
                print(f"✅ Idempotency working! Duplicate prevented.")
            
            # Clean up test notification
            notification.delete()
            print(f"✅ Test notification cleaned up")
        else:
            print(f"❌ Failed to create notification")
    else:
        print(f"\n⚠️  No users in database. Skipping notification creation test.")
    
    # Test notification types
    print(f"\n📋 Available notification types:")
    for choice in NotificationType.choices:
        print(f"   - {choice[0]}: {choice[1]}")
    
    # Test unread count
    if user_count > 0:
        test_user = User.objects.first()
        unread = NotificationService.get_unread_count(test_user)
        print(f"\n📊 Unread notifications for {test_user.username}: {unread}")
    
    print("\n" + "="*60)
    print("  ✅ Notification System Verification Complete!")
    print("="*60 + "\n")
    
    print("Next steps:")
    print("1. Add FCM_SERVER_KEY to backend/.env for push notifications")
    print("2. Test API endpoints: http://localhost:8000/api/notifications/")
    print("3. Read documentation: backend/notifications/SETUP_GUIDE.md")
    print()


if __name__ == "__main__":
    try:
        test_notification_system()
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
