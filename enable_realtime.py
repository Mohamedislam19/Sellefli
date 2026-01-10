"""
Enable Realtime publication for notification_events table.
This allows Flutter to receive real-time notifications.
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'backend'))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'settings')

try:
    import django
    django.setup()
    
    from django.db import connection
    
    print("\n" + "="*70)
    print("  ENABLING REALTIME FOR NOTIFICATIONS")
    print("="*70 + "\n")
    
    with connection.cursor() as cursor:
        # Check if the publication exists
        print("Checking Realtime publication...")
        cursor.execute("""
            SELECT EXISTS (
                SELECT 1 FROM pg_publication 
                WHERE pubname = 'supabase_realtime'
            );
        """)
        pub_exists = cursor.fetchone()[0]
        
        if pub_exists:
            print("✅ supabase_realtime publication exists")
            
            # Add notification_events table to publication
            print("\nAdding notification_events to Realtime publication...")
            try:
                cursor.execute("""
                    ALTER PUBLICATION supabase_realtime 
                    ADD TABLE notification_events;
                """)
                print("✅ notification_events added to Realtime!")
            except Exception as e:
                if "already a member" in str(e).lower() or "already exists" in str(e).lower():
                    print("✅ notification_events already in Realtime publication")
                else:
                    print(f"⚠️  Could not add to publication: {e}")
                    print("   You may need to do this manually in Supabase Dashboard")
            
            # Verify the table is in publication
            cursor.execute("""
                SELECT tablename 
                FROM pg_publication_tables 
                WHERE pubname = 'supabase_realtime' 
                AND tablename = 'notification_events';
            """)
            result = cursor.fetchone()
            
            if result:
                print("\n✅ REALTIME IS ENABLED for notification_events!")
            else:
                print("\n⚠️  notification_events not found in publication")
                print("   Please enable manually:")
                print("   1. Go to: https://usddlozrhceftmnhnknw.supabase.co")
                print("   2. Database → Replication")
                print("   3. Toggle Realtime ON for notification_events")
        else:
            print("❌ supabase_realtime publication not found")
            print("   This might be a permission issue.")
            print("   Please enable Realtime manually in Supabase Dashboard:")
            print("   1. Go to: https://usddlozrhceftmnhnknw.supabase.co")
            print("   2. Database → Replication")
            print("   3. Toggle Realtime ON for notification_events")
    
    print("\n" + "="*70)
    print("  SETUP VERIFICATION")
    print("="*70 + "\n")
    
    print("To test the notification system:")
    print("1. Run your Flutter app: flutter run")
    print("2. Create a test notification:")
    print("   python -c \"from backend.notifications.services import NotificationService; from backend.users.models import User; NotificationService.create_notification(User.objects.first(), 'booking_created', 'Test', 'This is a test')\"")
    print("3. Watch it appear in real-time in your app!")
    print()
    
except Exception as e:
    print(f"\n❌ ERROR: {e}")
    import traceback
    traceback.print_exc()
