"""
Create a PostgreSQL trigger to automatically populate notification_events
when a new notification is created. This ensures realtime works even if
the API broadcast fails.
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
    print("  CREATING NOTIFICATION TRIGGER FOR REALTIME")
    print("="*70 + "\n")
    
    with connection.cursor() as cursor:
        # Drop existing trigger and function if they exist
        print("Removing old trigger if exists...")
        cursor.execute("""
            DROP TRIGGER IF EXISTS notification_created_trigger ON notifications;
            DROP FUNCTION IF EXISTS broadcast_notification_event();
        """)
        
        # Create function to insert into notification_events
        print("Creating trigger function...")
        cursor.execute("""
            CREATE OR REPLACE FUNCTION broadcast_notification_event()
            RETURNS TRIGGER AS $$
            BEGIN
                -- Insert into notification_events for realtime broadcast
                INSERT INTO notification_events (
                    user_id,
                    notification_id,
                    notification_type,
                    title,
                    body,
                    payload,
                    created_at
                ) VALUES (
                    NEW.recipient_id,
                    NEW.id,
                    NEW.notification_type,
                    NEW.title,
                    NEW.body,
                    NEW.payload,
                    NEW.created_at
                );
                
                RETURN NEW;
            END;
            $$ LANGUAGE plpgsql;
        """)
        print("✅ Trigger function created")
        
        # Create trigger
        print("Creating trigger...")
        cursor.execute("""
            CREATE TRIGGER notification_created_trigger
            AFTER INSERT ON notifications
            FOR EACH ROW
            EXECUTE FUNCTION broadcast_notification_event();
        """)
        print("✅ Trigger created")
        
        # Test the trigger
        print("\nVerifying trigger...")
        cursor.execute("""
            SELECT tgname, tgenabled 
            FROM pg_trigger 
            WHERE tgname = 'notification_created_trigger';
        """)
        result = cursor.fetchone()
        if result:
            trigger_name, enabled = result
            status = "ENABLED" if enabled == 'O' else "DISABLED"
            print(f"✅ Trigger '{trigger_name}' is {status}")
        else:
            print("❌ Trigger not found")
    
    print("\n" + "="*70)
    print("  TRIGGER SETUP COMPLETE")
    print("="*70 + "\n")
    
    print("How it works:")
    print("1. When a notification is created in 'notifications' table")
    print("2. The trigger automatically inserts into 'notification_events'")
    print("3. Supabase Realtime broadcasts to subscribed Flutter clients")
    print("4. Users receive notifications instantly!")
    print()
    print("Test it now:")
    print("  python test_create_notification.py")
    print()
    
except Exception as e:
    print(f"\n❌ ERROR: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
